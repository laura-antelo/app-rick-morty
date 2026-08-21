//
//  CharacterRepository.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation
import UIKit
import Combine

protocol CharacterRepository {
    func getCharacters(page: Int?, name: String?) -> AnyPublisher<PaginatedResult<Character>, Error>
    func getCharacterDetail(id: Int) -> AnyPublisher<Character, Error>
}

final class DefaultCharacterRepository: CharacterRepository {
    
    
    private let api: APIClient
    
    init(api: APIClient) {
        self.api = api
    }
    
    func getCharacters(page: Int? = nil, name: String? = nil) -> AnyPublisher<PaginatedResult<Character>, Error> {
        api.request(.characters(page: page, name: name), responseType: ResponseDTO<CharacterDTO>.self)
            .flatMap { [api] response -> AnyPublisher<PaginatedResult<Character>, Error> in
                let characterPublishers = response.results.map { dto in
                    api.fetchImage(from: dto.image)
                        .map { image in
                            dto.toDomain(image: image)
                        }
                        .eraseToAnyPublisher( )
                }
                
                guard !characterPublishers.isEmpty else {
                    return Just(PaginatedResult(items: [], hasNextPage: response.info.next != nil))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return Publishers.MergeMany(characterPublishers)
                    .collect()
                    .map { characters in
                        PaginatedResult(items: characters.sorted { $0.id < $1.id }, hasNextPage: response.info.next != nil)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getCharacterDetail(id: Int) -> AnyPublisher<Character, any Error> {
        api.request(.characterDetail(id: id), responseType: CharacterDTO.self)
            .flatMap { [api] dto in
                api.fetchImage(from: dto.image)
                    .map { image in
                        dto.toDomain(image: image)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher( )
    }
}

private extension CharacterDTO {
    func toDomain(image: UIImage?) -> Character {
        Character(id: id, name: name,status: CharacterStatus(rawValue: status) ?? .unknown, species: species, type: type ?? "", gender: gender, origin: origin.toDomain(), location: location.toDomain(), imageURL: URL(string: self.image), episodeIds: episode.compactMap{ $0.apiResourceId }, image: image)
    }
}

private extension CharacterLocationReferenceDTO {
    func toDomain() -> LocationReference {
        LocationReference(id: url.apiResourceId, name: name)
    }
}

private extension String {
    var apiResourceId: Int? {
        guard let lastPathComponent = URL(string: self)?.lastPathComponent else { return nil }
        
        return Int(lastPathComponent)
    }
}

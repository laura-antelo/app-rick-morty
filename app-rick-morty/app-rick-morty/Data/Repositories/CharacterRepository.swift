//
//  CharacterRepository.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation
import Combine

protocol CharacterRepository {
    func getCharacters(page: Int?, name: String?) -> AnyPublisher<[Character], Error>
    func getCharacterDetail(id: Int) -> AnyPublisher<Character, Error>
}

final class DefaultCharacterRepository: CharacterRepository {
    
    
    private let api: APIClient
    
    init(api: APIClient) {
        self.api = api
    }
    
    func getCharacters(page: Int? = nil, name: String? = nil) -> AnyPublisher<[Character], Error> {
        api.request(.characters(page: page, name: name), responseType: ResponseDTO<CharacterDTO>.self)
            .map { response in
                response.results.map { $0.toDomain() }
            }.eraseToAnyPublisher()
    }
    
    func getCharacterDetail(id: Int) -> AnyPublisher<Character, any Error> {
        api.request(.characterDetail(id: id), responseType: CharacterDTO.self).map { dto in
            dto.toDomain()
        }.eraseToAnyPublisher( )
    }
}

private extension CharacterDTO {
    func toDomain() -> Character {
        Character(id: id, name: name,status: CharacterStatus(rawValue: status) ?? .unknown, species: species, type: type ?? "", gender: gender, origin: origin.toDomain(), location: location.toDomain(), imageURL: URL(string: image), episodeIds: episode.compactMap{ $0.apiResourceId })
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

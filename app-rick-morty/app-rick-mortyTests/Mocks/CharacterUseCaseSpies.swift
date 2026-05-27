//
//  CharacterUseCaseSpies.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 18/5/26.
//

import Combine
@testable import app_rick_morty

final class GetCharactersUseCaseSpy: GetCharactersUseCase {
    var receivedPage: Int?
    var receivedName: String?
    
    var result: Result<PaginatedResult<Character>, Error> = .success(PaginatedResult(items: [], hasNextPage: false))
    
    func execute(page: Int?, name: String?) -> AnyPublisher<PaginatedResult<Character>, any Error> {
        receivedName = name
        receivedPage = page
        
        return result.publisher.eraseToAnyPublisher()
    }
}

final class GetCharacterDetailUseCaseSpy: GetCharacterDetailUseCase {
    var receivedId: Int?
    
    var result: Result<Character, Error> = .success(TestRickAndMortyData.character)
    
    func execute(id: Int) -> AnyPublisher<Character, any Error> {
        receivedId = id
        
        return result.publisher.eraseToAnyPublisher()
    }
}

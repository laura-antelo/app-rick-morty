//
//  RepositorySpies.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 18/5/26.
//

import Combine
@testable import app_rick_morty

final class CharacterRepositorySpy: CharacterRepository {
    var getCharactersPage: Int?
    var getCharactersName: String?
    var getCharacterDetailId: Int?
    
    var charactersResult: Result<PaginatedResult<Character>, Error> = .success(PaginatedResult(items: [], hasNextPage: false))
    var characterDetailResult: Result<Character, Error> = .success(TestRickAndMortyData.character)
    
    func getCharacters(page: Int?, name: String?) -> AnyPublisher<PaginatedResult<Character>, any Error> {
        getCharactersPage = page
        getCharactersName = name
        
        return charactersResult.publisher.eraseToAnyPublisher()
    }
    
    func getCharacterDetail(id: Int) -> AnyPublisher<Character, any Error> {
        getCharacterDetailId = id
        
        return characterDetailResult.publisher.eraseToAnyPublisher()
    }
}

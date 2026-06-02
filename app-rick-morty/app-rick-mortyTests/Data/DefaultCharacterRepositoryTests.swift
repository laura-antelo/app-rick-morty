//
//  DefaultCharacterRepositoryTests.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 21/5/26.
//

import Testing
@testable import app_rick_morty
import Combine

struct DefaultCharacterRepositoryTests {
    
    @MainActor
    @Test func WhenGetCharacters_ThenReturnsCharacters() async throws {
        let apiClientSpy = APIClientSpy()
        
        apiClientSpy.response = ResponseDTO(info: TestRickAndMortyData.pageInfo, results: [TestRickAndMortyData.characterDTO])
        
        let sut = DefaultCharacterRepository(api: apiClientSpy)

        let publisher = sut.getCharacters(page: 1, name: "Rick")
        
        var iterator = publisher.values.makeAsyncIterator()
        let result = try await iterator.next()
        
        #expect(result?.items.first?.id == 1)
    }
    
    @MainActor
    @Test func WhenGetCharacterDetail_ThenReturnsCharacter() async throws {
        let apiClientSpy = APIClientSpy()
        
        apiClientSpy.response = TestRickAndMortyData.characterDTO
        
        let sut = DefaultCharacterRepository(api: apiClientSpy)
        
        var character: Character?
        
        let publisher = sut.getCharacterDetail(id: 1)
        
        var iterator = publisher.values.makeAsyncIterator()
        character = try await iterator.next()
        
        #expect(character?.id == 1)
    }
}

//
//  UseCaseTests.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 21/5/26.
//

import Combine
import Testing
@testable import app_rick_morty

struct UseCaseTests {
    
    @MainActor
    @Test func WhenGetCharactersUseCaseExecutes_ThenCallsRepository() async throws {
        let repository = CharacterRepositorySpy()
        let sut = DefaultGetCharactersUseCase(repository: repository)
        
        let publisher = sut.execute(page: 2, name: "Rick")
        
        var iterator = publisher.values.makeAsyncIterator()
        _ = try await iterator.next()
        
        #expect(repository.getCharactersPage == 2)
    }
    
    @MainActor
    @Test func WhenGetCharacterDetailDetailUseCaseExecutes_ThenCallsRepository() async throws {
        let repository = CharacterRepositorySpy()
        let sut = DefaultGetCharacterDetailUseCase(repository: repository)
        
        let publisher = sut.execute(id: 1)
        var iterator = publisher.values.makeAsyncIterator()
        _ = try await iterator.next()
        
        #expect(repository.getCharacterDetailId == 1)
    }
    
    @MainActor
    @Test func WhenGetEpisodesUseCaseExecutes_ThenCallsRepository() async throws {
        let repository = EpisodeRepositorySpy()
        let sut = DefaultGetEpisodesUseCase(repository: repository)
        
        let publisher = sut.execute(page: 1, name: "Pilot")
        
        var iterator = publisher.values.makeAsyncIterator()
        _ = try await iterator.next()
        
        #expect(repository.getEpisodesPage == 1)
    }
    
    @MainActor
    @Test func WhenGetEpisodeDetailDetailUseCaseExecutes_ThenCallsRepository() async throws {
        let repository = EpisodeRepositorySpy()
        let sut = DefaultGetEpisodeDetailUseCase(repository: repository)
        
        let publisher = sut.execute(id: 1)
        var iterator = publisher.values.makeAsyncIterator()
        _ = try await iterator.next()
        
        #expect(repository.getEpisodeDetailId == 1)
    }
}

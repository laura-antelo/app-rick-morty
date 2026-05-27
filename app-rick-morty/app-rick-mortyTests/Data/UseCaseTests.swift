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
    
    @MainActor
    @Test func WhenGetLocationsUseCaseExecutes_ThenCallsRepository() async throws {
        let repository = LocationRepositorySpy()
        let sut = DefaultGetLocationsUseCase(repository: repository)
        
        let publisher = sut.execute(page: 1, name: "Earth")
        
        var iterator = publisher.values.makeAsyncIterator()
        _ = try await iterator.next()
        
        #expect(repository.getLocationsPage == 1)
    }
    
    @MainActor
    @Test func WhenGetLocationDetailUseCaseExecutes_ThenCallsRepository() async throws {
        let repository = LocationRepositorySpy()
        let sut = DefaultGetLocationDetailUseCase(repository: repository)
        
        let publisher = sut.execute(id: 1)
        var iterator = publisher.values.makeAsyncIterator()
        _ = try await iterator.next()
        
        #expect(repository.getLocationDetailId == 1)
    }
    
    @MainActor
    @Test func WhenGetFavoriteUseCaseExecutes_ThenReturnsFavorites() {
        let repository = FavoriteRepositorySpy()
        repository.favorites = [TestRickAndMortyData.characterFavorite]
        
        let sut = DefaultGetFavoriteUseCase(repository: repository)
        
        let favorites = sut.execute(.character)
        
        #expect(favorites.first?.id == 1)
    }
    
    @MainActor
    @Test func WhenIsFavoriteUseCaseExecutes_ThenReturnsFavoriteState() {
        let repository = FavoriteRepositorySpy()
        repository.favorites = [TestRickAndMortyData.characterFavorite]
        
        let sut = DefaultIsFavoriteUseCase(repository: repository)
        
        #expect(sut.execute(TestRickAndMortyData.characterFavorite))
    }
    
    @MainActor
    @Test func WhenToggleFavoriteUseCaseExecutes_ThenTogglesFavorite() {
        let repository = FavoriteRepositorySpy()
        repository.favorites = [TestRickAndMortyData.characterFavorite]
        
        let sut = DefaultToggleFavoriteUseCase(repository: repository)
        
        let isFavorite = sut.execute(TestRickAndMortyData.characterFavorite)
        
        #expect(isFavorite == false)
    }
}

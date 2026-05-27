//
//  EpisodeDetailViewModelTests.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 21/5/26.
//

import Combine
import Testing
@testable import app_rick_morty

struct EpisodeDetailViewModelTests {
    
    @MainActor
    @Test func WhenEpisodeDetailViewDidLoad_ThenPublishesEpisode() async throws {
        let dependencies = RickAndMortyDependenciesMock()
        let navigationCoordinator = CoordinatorSpy()
        
        dependencies.episodeDependenciesMock.getEpisodeDetailUseCaseSpy.result = .success(TestRickAndMortyData.episode)
        
        let sut = DefaultEpisodeDetailViewModel(episodeId: 1, dependencies: dependencies, navigationCoordinator: navigationCoordinator)
        
        let publisher = sut.episodePublisher
        var iterator = publisher.values.makeAsyncIterator()
        
        _ = await iterator.next()
        
        sut.viewDidLoad()
        
        let episode = await iterator.next()
        
        #expect(episode??.id == 1)
    }
    
    @MainActor
    @Test func WhenEpisodeFavoriteButtonIsTapped_ThenFavoriteStateChanges() async throws {
        let dependencies = RickAndMortyDependenciesMock()
        let navigationCoordinator = CoordinatorSpy()
        
        dependencies.episodeDependenciesMock.getEpisodeDetailUseCaseSpy.result = .success(TestRickAndMortyData.episode)
        
        let sut = DefaultEpisodeDetailViewModel(episodeId: 1, dependencies: dependencies, navigationCoordinator: navigationCoordinator)
        
        let publisher = sut.isFavoritePublisher
        var iterator = publisher.values.makeAsyncIterator()
        
        _ = await iterator.next()
        
        sut.viewDidLoad()
        _ = await iterator.next()
        
        sut.didTapFavorite()
        
        let isFavorite = await iterator.next()
        
        #expect(isFavorite == true)
    }
    
    @MainActor
    @Test func WhenEpisodeDetailSelectsCharacter_ThenRequestsCharacterNavigation() async throws {
        let dependencies = RickAndMortyDependenciesMock()
        let navigationCoordinator = CoordinatorSpy()
        
        dependencies.episodeDependenciesMock.getEpisodeDetailUseCaseSpy.result = .success(TestRickAndMortyData.episode)
        
        let sut = DefaultEpisodeDetailViewModel(episodeId: 1, dependencies: dependencies, navigationCoordinator: navigationCoordinator)
        
        sut.didSelectCharacter(id: 1)
        
        #expect(navigationCoordinator.receivedCharacterDetailId == 1)
    }
}

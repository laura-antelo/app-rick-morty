//
//  CharacterDetailViewModelTests.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 21/5/26.
//

import Combine
import Testing
@testable import app_rick_morty

struct CharacterDetailViewModelTests {
    
    @MainActor
    @Test func WhenCharacterDetailViewDidLoad_ThenPublishesCharacter() async throws {
        let dependencies = CharacterDependenciesMock()
        let navigationCoordinator = CoordinatorSpy()
        
        dependencies.getCharacterDetailUseCaseSpy.result = .success(TestRickAndMortyData.character)
        
        let sut = DefaultCharacterDetailViewModel(characterId: 1, dependencies: dependencies, navigationCoordinator: navigationCoordinator)
        
        let publisher = sut.characterPublisher
        var iterator = publisher.values.makeAsyncIterator()
        
        _ = await iterator.next()
        
        sut.viewDidLoad()
        
        let character = await iterator.next()
        
        #expect(character??.id == 1)
    }
    
    @MainActor
    @Test func WhenCharacterDetailSelectsLocation_ThenRequestsLocationNavigation() async throws {
        let dependencies = CharacterDependenciesMock()
        let navigationCoordinator = CoordinatorSpy()
        
        dependencies.getCharacterDetailUseCaseSpy.result = .success(TestRickAndMortyData.character)
        
        let sut = DefaultCharacterDetailViewModel(characterId: 1, dependencies: dependencies, navigationCoordinator: navigationCoordinator)
        
        sut.didSelectLocation(id: 3)
        
        #expect(navigationCoordinator.receivedLocationDetailId == 3)
    }
    
    @MainActor
    @Test func WhenCharacterDetailSelectsEpisode_ThenRequestsEpisodeNavigation() async throws {
        let dependencies = CharacterDependenciesMock()
        let navigationCoordinator = CoordinatorSpy()
        
        dependencies.getCharacterDetailUseCaseSpy.result = .success(TestRickAndMortyData.character)
        
        let sut = DefaultCharacterDetailViewModel(characterId: 1, dependencies: dependencies, navigationCoordinator: navigationCoordinator)
        
        sut.didSelectEpisode(id: 1)
        
        #expect(navigationCoordinator.receivedEpisodeDetailId == 1)
    }
}

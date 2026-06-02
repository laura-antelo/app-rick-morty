//
//  LocationDetailViewModelTests.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 21/5/26.
//

import Combine
import Testing
@testable import app_rick_morty

struct LocationDetailViewModelTests {
    
    @MainActor
    @Test func WhenLocationDetailViewDidLoad_ThenPublishesLocation() async throws {
        let dependencies = RickAndMortyDependenciesMock()
        let navigationCoordinator = CoordinatorSpy()
        
        dependencies.locationDependenciesMock.getLocationDetailUseCaseSpy.result = .success(TestRickAndMortyData.location)
        
        let sut = DefaultLocationDetailViewModel(locationId: 1, dependencies: dependencies, navigationCoordinator: navigationCoordinator)
        
        let publisher = sut.locationPublisher
        var iterator = publisher.values.makeAsyncIterator()
        
        _ = await iterator.next()
        
        sut.viewDidLoad()
        
        let location = await iterator.next()
        
        #expect(location??.id == 1)
    }
    
    @MainActor
    @Test func WhenLocationFavoriteButtonIsTapped_ThenFavoriteStateChanges() async throws {
        let dependencies = RickAndMortyDependenciesMock()
        let navigationCoordinator = CoordinatorSpy()
        
        dependencies.locationDependenciesMock.getLocationDetailUseCaseSpy.result = .success(TestRickAndMortyData.location)
        
        let sut = DefaultLocationDetailViewModel(locationId: 1, dependencies: dependencies, navigationCoordinator: navigationCoordinator)
        
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
    @Test func WhenLocationDetailSelectsCharacter_ThenRequestsCharacterNavigation() async throws {
        let dependencies = RickAndMortyDependenciesMock()
        let navigationCoordinator = CoordinatorSpy()
        
        dependencies.locationDependenciesMock.getLocationDetailUseCaseSpy.result = .success(TestRickAndMortyData.location)
        
        let sut = DefaultLocationDetailViewModel(locationId: 1, dependencies: dependencies, navigationCoordinator: navigationCoordinator)
        
        sut.didSelectCharacter(id: 1)
        
        #expect(navigationCoordinator.receivedCharacterDetailId == 1)
    }
}

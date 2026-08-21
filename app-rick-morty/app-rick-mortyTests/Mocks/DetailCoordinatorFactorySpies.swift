//
//  DetailCoordinatorFactorySpies.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 22/5/26.
//

import UIKit
@testable import app_rick_morty

final class CharacterDetailCoordinatorFactorySpy: CharacterDetailCoordinatorFactory {
    var receivedCharacterId: Int?
    var receivedNavigationCoordinator: NavegationCoordinator?
    var coordinatorToReturn = DetailCoordinatorSpy()
    
    func createNew(characterId: Int, navigationCoordinator: any NavegationCoordinator) -> CharacterDetailCoordinator {
        receivedCharacterId = characterId
        receivedNavigationCoordinator = navigationCoordinator
        return coordinatorToReturn
    }
}

final class EpisodeDetailCoordinatorFactorySpy: EpisodeDetailCoordinatorFactory {
    var receivedEpisodeId: Int?
    var receivedNavigationCoordinator: NavegationCoordinator?
    var coordinatorToReturn = DetailCoordinatorSpy()
    
    func createNew(episodeId: Int, navigationCoordinator: any NavegationCoordinator) -> EpisodeDetailCoordinator {
        receivedEpisodeId = episodeId
        receivedNavigationCoordinator = navigationCoordinator
        return coordinatorToReturn
    }
}

final class LocationDetailCoordinatorFactorySpy: LocationDetailCoordinatorFactory {
    var receivedLocationId: Int?
    var receivedNavigationCoordinator: NavegationCoordinator?
    var coordinatorToReturn = DetailCoordinatorSpy()
    
    func createNew(locationId: Int, navigationCoordinator: any NavegationCoordinator) -> LocationDetailCoordinator {
        receivedLocationId = locationId
        receivedNavigationCoordinator = navigationCoordinator
        return coordinatorToReturn
    }
}

final class DetailCoordinatorSpy: CharacterDetailCoordinator, LocationDetailCoordinator, EpisodeDetailCoordinator {
    var startCallCount = 0
    var viewControllerToReturn = UIViewController()
    
    func start() -> UIViewController {
        startCallCount += 1
        return viewControllerToReturn
    }
}

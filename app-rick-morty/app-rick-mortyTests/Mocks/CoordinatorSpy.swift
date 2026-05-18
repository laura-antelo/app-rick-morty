//
//  CoordinatorSpy.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 18/5/26.
//

import UIKit
@testable import app_rick_morty

final class CoordinatorSpy: CharacterCoordinator, LocationCoordinator, EpisodeCoordinator {
    var receivedCharacterDetailId: Int?
    var receivedLocationDetailId: Int?
    var receivedEpisodeDetailId: Int?
    
    func start() -> UIViewController {
        UIViewController()
    }
    
    func goToEpisodeDetail(id: Int) {
        receivedEpisodeDetailId = id
    }
    
    func goToLocationDetail(id: Int) {
        receivedLocationDetailId = id
    }
    
    func goToCharacterDetail(id: Int) {
        receivedCharacterDetailId = id
    }
}

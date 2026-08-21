//
//  NavegationCoordinator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 15/5/26.
//

import Foundation

protocol NavegationCoordinator: AnyObject {
    func goToCharacterDetail(id: Int)
    func goToLocationDetail(id: Int)
    func goToEpisodeDetail(id: Int)
}

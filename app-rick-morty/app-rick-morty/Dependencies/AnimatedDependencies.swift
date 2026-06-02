//
//  AnimatedDependencies.swift
//  app-rick-morty
//
//  Created by Jose Servet Font on 2/6/26.
//

protocol AnimatedDependencies {
    func resolve() -> AnimatedViewModel
    func resolve() -> AnimatedCoordinatorDecorator
    func resolve() -> Coordinator
    func resolve() -> AnimatedViewController
}

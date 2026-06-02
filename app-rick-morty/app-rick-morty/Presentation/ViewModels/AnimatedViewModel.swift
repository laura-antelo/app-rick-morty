//
//  AnimatedViewModel.swift
//  app-rick-morty
//
//  Created by Jose Servet Font on 2/6/26.
//

protocol AnimatedViewModel {
    func didPressNextScreenButton()
}

final class DefaultAnimatedViewModel: AnimatedViewModel {
    let dependencies: AnimatedDependencies

    init(dependencies: AnimatedDependencies) {
        self.dependencies = dependencies
    }

    func didPressNextScreenButton() {
        let coordinator: AnimatedCoordinatorDecorator = dependencies.resolve()
        coordinator.goToDecoratedScreen()
    }
}

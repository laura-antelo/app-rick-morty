//
//  AnimatedCoordinatorDecorator.swift
//  app-rick-morty
//
//  Created by Jose Servet Font on 2/6/26.
//

import UIKit

protocol Coordinator {
    func start() -> UIViewController
}

extension DefaultMainCoordinator: Coordinator {}

protocol AnimatedCoordinatorDecorator: Coordinator {
    func goToDecoratedScreen()
}

final class DefaultAnimatedCoordinatorDecorator: AnimatedCoordinatorDecorator {
    let decorated: Coordinator
    let window: UIWindow

    init(decorated: Coordinator, window: UIWindow) {
        self.decorated = decorated
        self.window = window
    }

    func start() -> UIViewController {
        let animatedViewController: AnimatedViewController = resolve()
        return animatedViewController
    }

    func goToDecoratedScreen() {
        let viewController = decorated.start()
        window.rootViewController = viewController
    }
}

extension DefaultAnimatedCoordinatorDecorator: AnimatedDependencies {
    func resolve() -> any AnimatedViewModel {
        return DefaultAnimatedViewModel(dependencies: self)
    }

    func resolve() -> any AnimatedCoordinatorDecorator {
        return self
    }

    func resolve() -> any Coordinator {
        return decorated
    }

    func resolve() -> AnimatedViewController {
        return AnimatedViewController(viewModel: resolve())
    }
}


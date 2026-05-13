//
//  MainTabBarController.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit

class MainTabBarController: UITabBarController {

    private let initialViewControllers: [UIViewController]
    
    init(initialViewControllers: [UIViewController]) {
        self.initialViewControllers = initialViewControllers
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        viewControllers = initialViewControllers
    }

}

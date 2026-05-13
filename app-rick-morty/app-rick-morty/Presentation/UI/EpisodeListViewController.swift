//
//  EpisodeListViewController.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit

class EpisodeListViewController: UIViewController {

    private let dependencies: RickAndMortyDependencies
    
    init(dependencies: RickAndMortyDependencies) {
        self.dependencies = dependencies
        super.init(nibName: "EpisodeListViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    private func setupView() {
        navigationItem.title = "Episodios"
    }

}

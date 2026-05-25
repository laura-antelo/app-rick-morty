//
//  EpisodeDetailViewController.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 15/5/26.
//

import UIKit
import Combine

class EpisodeDetailViewController: UIViewController {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var codeLabel: UILabel!
    @IBOutlet private weak var airDateLabel: UILabel!
    @IBOutlet private weak var relatedTableView: UITableView!
    
    private let viewModel: EpisodeDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var relatedCharacters: [Character] = []
    
    init(viewModel: EpisodeDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "EpisodeDetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTableView()
        bindViewModel()
        
        viewModel.viewDidLoad()
    }
    
    private func setupView() {
        navigationItem.title = "Detalle del episodio"
    }
    
    private func setupTableView() {
        relatedTableView.register(UINib(nibName: "CharacterTableViewCell", bundle: nil), forCellReuseIdentifier: "CharacterTableViewCell")
        
        relatedTableView.tableFooterView = UIView()
    }
    
    private func bindViewModel() {
        viewModel.episodePublisher
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] episode in
                guard let episode else { return }
                self?.configure(with: episode)
            }.store(in: &cancellables)
        
        viewModel.relatedCharactersPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] characters in
                self?.updateRelatedCharacters(characters)
            }.store(in: &cancellables)
    }
    
    private func configure(with episode: Episode) {
        nameLabel.text = episode.name
        codeLabel.text = "\(episode.code)"
        airDateLabel.text = "Fecha de emisión: \(episode.airDate)"
    }
    
    private func updateRelatedCharacters(_ characters: [Character]) {
        self.relatedCharacters = characters
        self.relatedTableView.reloadData()
    }
}

extension EpisodeDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relatedCharacters.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Personajes"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterTableViewCell", for: indexPath) as? CharacterTableViewCell else { return UITableViewCell() }
        
        cell.configure(with: relatedCharacters[indexPath.row])
        
        return cell
    }
}

extension EpisodeDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let character = relatedCharacters[indexPath.row]
        
        viewModel.didSelectCharacter(id: character.id)
    }
}

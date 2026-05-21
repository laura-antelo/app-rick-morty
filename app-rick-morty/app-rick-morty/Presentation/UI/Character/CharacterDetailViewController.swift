//
//  CharacterDetailViewController.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 15/5/26.
//

import UIKit
import Combine

class CharacterDetailViewController: UIViewController {

    
    @IBOutlet private weak var characterImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var speciesLabel: UILabel!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var genderLabel: UILabel!
    @IBOutlet private weak var relatedTableView: UITableView!
    
    private let viewModel: CharacterDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var character: Character?
    
    private enum Section: Int, CaseIterable {
        case locations
        case episodes
    }
    
    private enum LocationRow: Int {
        case origin = 0
        case latestLocation = 1
    }
    
    init(viewModel: CharacterDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "CharacterDetailViewController", bundle: nil)
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
        navigationItem.title = "Detalle del personaje"
    }
    
    private func setupTableView() {
        relatedTableView.register(UINib(nibName: "EpisodeTableViewCell", bundle: nil), forCellReuseIdentifier: "EpisodeTableViewCell")
        relatedTableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationTableViewCell")
        
        relatedTableView.tableFooterView = UIView()
    }
    
    private func bindViewModel() {
        viewModel.characterPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] character in
                guard let character else { return }
                
                self?.updateUI(with: character)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with character: Character) {
        self.character = character
        updateTexts(with: character)
        updateImages(with: character)
        relatedTableView.reloadData()
    }
    
    private func updateTexts(with character: Character) {
        nameLabel.text = character.name
        statusLabel.text = "Estado: \(character.status.displayText)"
        speciesLabel.text = "Especie: \(character.species)"
        typeLabel.text = character.type.isEmpty ? "" : "Tipo: \(character.type)"
        genderLabel.text = "Género: \(character.gender)"
    }
    
    private func updateImages(with character: Character) {
        characterImageView.image = UIImage(systemName: "person.crop.square")
    }
    
    private func configureOriginCell(_ cell: LocationTableViewCell, origin: LocationReference) {
        cell.configure(with: origin, title: "Origen")
    }
    
    private func configureLocationCell(_ cell: LocationTableViewCell, location: LocationReference) {
        cell.configure(with: location, title: "Última ubicación")
    }
}

extension CharacterDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let character, let section = Section(rawValue: section) else { return 0 }
        
        switch section {
        case .locations:
            return 2
        case .episodes:
            return character.episodeIds.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { return nil }
        
        switch section {
        case .locations:
            return "Ubicaciones"
        case .episodes:
            return "Episodios"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let character, let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .locations:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell") as? LocationTableViewCell else { return UITableViewCell() }
            
            if indexPath.row == 0 {
                configureOriginCell(cell, origin: character.origin)
            } else {
                configureLocationCell(cell, location: character.location)
            }
            
            return cell
        case .episodes:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeTableViewCell") as? EpisodeTableViewCell else { return UITableViewCell() }
            
            let episodeId = character.episodeIds[indexPath.row]
            cell.configure(episodeId: episodeId)
            
            return cell
        }
    }
}

extension CharacterDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let character, let section = Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .locations:
            let locationId: Int?
            
            if indexPath.row == 0 {
                locationId = character.origin.id
            } else {
                locationId = character.location.id
            }
            
            guard let locationId else { return }
            
            viewModel.didSelectLocation(id: locationId)
        case .episodes:
            let episodeId = character.episodeIds[indexPath.row]
            
            viewModel.didSelectEpisode(id: episodeId)
        }
    }
}

private extension CharacterStatus {
    var displayText: String {
        switch self {
        case .alive:
            return "Vivo"
        case .dead:
            return "Muerto"
        case .unknown:
            return "Desconocido"
        }
    }
}

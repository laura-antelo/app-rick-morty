//
//  LocationDetailViewController.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 15/5/26.
//

import UIKit
import Combine

class LocationDetailViewController: UIViewController {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var dimensionLabel: UILabel!
    @IBOutlet private weak var relatedTableView: UITableView!
    
    private let viewModel: LocationDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var relatedResidents: [Character] = []
    
    init(viewModel: LocationDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "LocationDetailViewController", bundle: nil)
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
        navigationItem.title = "Detalle de la ubicación"
    }
    
    private func setupTableView() {
        relatedTableView.register(UINib(nibName: "CharacterTableViewCell", bundle: nil), forCellReuseIdentifier: "CharacterTableViewCell")
        
        relatedTableView.tableFooterView = UIView()
    }
    
    private func bindViewModel() {
        viewModel.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] location in
                guard let location else {return}
                
                self?.updateTexts(with: location)
            }.store(in: &cancellables)
        
        viewModel.relatedResidentsPublisher
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] residents in
                self?.updateRelatedResidents(residents)
            }.store(in: &cancellables)
    }
    
    private func updateTexts(with location: Location) {
        nameLabel.text = location.name
        typeLabel.text = "Tipo: \(location.type)"
        dimensionLabel.text = "Dimensión: \(location.dimension)"
    }
    
    private func updateRelatedResidents(_ residents: [Character]){
        relatedResidents = residents
        relatedTableView.reloadData( )
    }
}

extension LocationDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relatedResidents.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Residentes"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterTableViewCell", for: indexPath) as? CharacterTableViewCell else { return UITableViewCell() }
        
        cell.configure(with: relatedResidents[indexPath.row])
        
        return cell
    }
}

extension LocationDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let character = relatedResidents[indexPath.row]
        
        viewModel.didSelectCharacter(id: character.id)
    }
}

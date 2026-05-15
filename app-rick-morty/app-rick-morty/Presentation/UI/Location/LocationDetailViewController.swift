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
    
    private var location: Location?
    
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
                
                self?.location = location
                self?.configure(with: location)
                self?.relatedTableView.reloadData()
            }.store(in: &cancellables)
    }
    
    private func configure(with location: Location) {
        nameLabel.text = location.name
        typeLabel.text = "Tipo: \(location.type)"
        dimensionLabel.text = "Dimensión: \(location.dimension)"
    }
}

extension LocationDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        location?.residentsIds.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Residentes"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let location, let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterTableViewCell", for: indexPath) as? CharacterTableViewCell else { return UITableViewCell() }
        
        let characterId = location.residentsIds[indexPath.row]
        cell.configure(characterId: characterId)
        
        return cell
    }
}

extension LocationDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let location else { return }
        
        let characterId = location.residentsIds[indexPath.row]
        viewModel.didSelectCharacter(id: characterId)
    }
}

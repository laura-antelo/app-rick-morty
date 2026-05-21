//
//  LocationListViewController.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit
import Combine

class LocationListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel: LocationListViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    private var locations: [Location] = []
    private var currentSearchText: String = ""
    
    private enum SectionType: Int, CaseIterable {
        case search = 0
        case locations = 1
    }
    
    init(viewModel: LocationListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "LocationListViewController", bundle: nil)
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
        navigationItem.title = "Ubicaciones"
    }
    
    private func setupTableView(){
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell")
        tableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationTableViewCell")
    }
    
    private func bindViewModel(){
        viewModel.locationsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] locations in
                self?.updateLocations(locations)
            }
            .store(in: &cancellables)
    }
    
    private func updateLocations(_ locations: [Location]) {
        self.locations = locations
        tableView.reloadData()
    }
    
    private func updateSearchText(_ text: String){
        currentSearchText = text
        viewModel.updateSearchText(text)
    }
}

extension LocationListViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return SectionType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SectionType(rawValue: section) else { return 0 }
        
        switch section {
        case .search:
            return 1
        case .locations:
            return locations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = SectionType(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .search:
            return makeSearchCell(tableView: tableView, indexPath: indexPath)
        case .locations:
            return makeLocationCell(tableView: tableView, indexPath: indexPath)
        }
    }
    
    private func makeSearchCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
        cell.configure(text: currentSearchText) { [weak self] text in
            self?.updateSearchText(text)
        }
        
        return cell
    }
    
    private func makeLocationCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as! LocationTableViewCell
        let location = locations[indexPath.row]
        cell.configure(with: location)
        
        return cell
    }
}

extension LocationListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let sectionType = SectionType(rawValue: indexPath.section), sectionType == .locations else {
            return
        }
        
        let location = locations[indexPath.row]
        viewModel.didSelectLocation(id: location.id)
    }
}


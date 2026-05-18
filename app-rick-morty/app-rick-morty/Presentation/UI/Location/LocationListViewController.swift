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
                self?.locations = locations
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension LocationListViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return locations.count
        default :
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return makeSearchCell(tableView: tableView, indexPath: indexPath)
        case 1:
            return makeLocationCell(tableView: tableView, indexPath: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    private func makeSearchCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
        cell.configure(text: currentSearchText) { [weak self] text in
            self?.currentSearchText = text
            self?.viewModel.updateSearchText(text)
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
    }
}


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
    private var canLoadMore = false
    private var isFavoriteFilterActive = false
    
    private enum SectionType: Int, CaseIterable {
        case search = 0
        case locations = 1
        case loadMore = 2
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
        navigationItem.title = String(localized: "locations.title")
    }
    
    private func setupTableView(){
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell")
        tableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationTableViewCell")
        tableView.register(UINib(nibName: "LoadMoreTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTableViewCell")
    }
    
    private func bindViewModel(){
        viewModel.locationsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] locations in
                self?.updateLocations(locations)
            }
            .store(in: &cancellables)
        
        viewModel.canLoadMorePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canLoadMore in
                self?.updateCanLoadMore(canLoadMore)
            }
            .store(in: &cancellables)
        
        viewModel.isFavoriteFilterActivePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isActive in
                self?.updateFavoriteFilter(isActive)
            }
            .store(in: &cancellables)
    }
    
    private func updateLocations(_ locations: [Location]) {
        self.locations = locations
        tableView.reloadSections(IndexSet(integer: SectionType.locations.rawValue), with: .none)
    }
    
    private func updateSearchText(_ text: String){
        currentSearchText = text
        viewModel.updateSearchText(text)
    }
    
    private func updateCanLoadMore(_ canLoadMore: Bool) {
        guard self.canLoadMore != canLoadMore else { return }
        
        self.canLoadMore = canLoadMore
        tableView.reloadSections(IndexSet(integer: SectionType.loadMore.rawValue), with: .none)
    }
    
    private func updateFavoriteFilter(_ isActive: Bool) {
        isFavoriteFilterActive = isActive
        tableView.reloadSections(IndexSet(integer: SectionType.search.rawValue), with: .none)
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
        case .loadMore:
            return canLoadMore ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = SectionType(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .search:
            return makeSearchCell(tableView: tableView, indexPath: indexPath)
        case .locations:
            return makeLocationCell(tableView: tableView, indexPath: indexPath)
        case .loadMore:
            return makeLoadMoreCell(tableView: tableView, indexPath: indexPath)
        }
    }
    
    private func makeSearchCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
        
        cell.configure(
            text: currentSearchText, isFavoriteFilterActive: isFavoriteFilterActive,
            onTextChanged: { [weak self] text in
                self?.updateSearchText(text) },
            onFavoriteFilterChanged: { [weak self] in
                self?.viewModel.didTapFavoriteFilter()
            }
        )
        
        return cell
    }
    
    private func makeLocationCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as! LocationTableViewCell
        let location = locations[indexPath.row]
        cell.configure(with: location)
        
        return cell
    }
    
    private func makeLoadMoreCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreTableViewCell", for: indexPath) as! LoadMoreTableViewCell
                  
        cell.configure { [weak self] in
            self?.viewModel.loadMore()
        }
        
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


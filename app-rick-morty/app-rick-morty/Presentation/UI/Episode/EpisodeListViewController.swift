//
//  EpisodeListViewController.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit
import Combine

class EpisodeListViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel: EpisodeListViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    private var episodes: [Episode] = []
    private var currentSearchText: String = ""
    private var canLoadMore = false
    private var isFavoriteFilterActive = false
    
    private enum SectionType: Int, CaseIterable {
        case search = 0
        case episodes = 1
        case loadMore = 2
    }
    
    init(viewModel: EpisodeListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "EpisodeListViewController", bundle: nil)
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
        navigationItem.title = "Episodios"
    }

    private func setupTableView(){
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell")
        tableView.register(UINib(nibName: "EpisodeTableViewCell", bundle: nil), forCellReuseIdentifier: "EpisodeTableViewCell")
        tableView.register(UINib(nibName: "LoadMoreTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTableViewCell")
    }
    
    private func bindViewModel(){
        viewModel.episodesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] episodes in
                self?.updateEpisodes(episodes)
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
    
    private func updateEpisodes(_ episodes: [Episode]) {
        self.episodes = episodes
        tableView.reloadSections(IndexSet(integer: SectionType.episodes.rawValue), with: .none)
    }
    
    private func updateSearchText(_ text: String) {
        currentSearchText = text
        viewModel.updateSearchText(text)
    }
    
    private func updateFavoriteFilter(_ isActive: Bool) {
        isFavoriteFilterActive = isActive
        tableView.reloadSections(IndexSet(integer: SectionType.search.rawValue), with: .none)
    }
    
    private func updateCanLoadMore(_ canLoadMore: Bool) {
        guard self.canLoadMore != canLoadMore else { return }
        
        self.canLoadMore = canLoadMore
        tableView.reloadSections(IndexSet(integer: SectionType.loadMore.rawValue), with: .none)
    }
}

extension EpisodeListViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return SectionType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SectionType(rawValue: section) else { return 0 }
        
        switch section {
        case .search:
            return 1
        case .episodes:
            return episodes.count
        case .loadMore:
            return canLoadMore ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = SectionType(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .search:
            return makeSearchCell(tableView: tableView, indexPath: indexPath)
        case .episodes:
            return makeEpisodeCell(tableView: tableView, indexPath: indexPath)
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
    
    private func makeEpisodeCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeTableViewCell", for: indexPath) as! EpisodeTableViewCell
        let episode = episodes[indexPath.row]
        cell.configure(with: episode)
        
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

extension EpisodeListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let sectionType = SectionType(rawValue: indexPath.section), sectionType == .episodes else {
            return
        }
        
        let episode = episodes[indexPath.row]
        viewModel.didSelectEpisode(id: episode.id)
    }
}

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
    private var sectionTypes: [SectionType] = [.search, .loadMore]
    private var collapsedSeasons: Set<Int> = []
    private var sortOption: EpisodeSortOption = .chapterOrder
    
    private var currentSearchText: String = ""
    private var canLoadMore = false
    private var isFavoriteFilterActive = false
    
    private enum SectionType {
        case search
        case season(SeasonSection)
        case loadMore
    }
    
    private struct SeasonSection {
        let season: Int
        let episodes: [Episode]
    }
    
    private enum EpisodeSortOption {
        case chapterOrder
        case ratingDescending
        case ratingAscending
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
        navigationItem.title = String(localized: "episodes.title")
        updateSortButton()
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
    
    private func updateSortButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), menu: makeSortMenu())
    }
    
    private func makeSortMenu() -> UIMenu {
        return UIMenu(
            title: String(localized: "episode.sort.menu.title"),
            children: [
                UIAction(title: String(localized: "episode.sort.chapter_order"), state: sortOption == .chapterOrder ? .on : .off) { [weak self] _ in
                    self?.updateSortOption(.chapterOrder)
                },
                UIAction(title: String(localized: "episode.sort.rating_asc"), state: sortOption == .ratingAscending ? .on : .off) { [weak self] _ in
                    self?.updateSortOption(.ratingAscending)
                },
                UIAction(title: String(localized: "episode.sort.rating_desc"), state: sortOption == .ratingDescending ? .on : .off) { [weak self] _ in
                    self?.updateSortOption(.ratingDescending)}
            ]
        )
    }
    
    private func updateSortOption (_ sortOption: EpisodeSortOption) {
        self.sortOption = sortOption
        self.sectionTypes = makeSectionTypes(from: episodes)
        updateSortButton()
        tableView.reloadData()
    }
    
    private func updateEpisodes(_ episodes: [Episode]) {
        self.episodes = episodes
        self.sectionTypes = makeSectionTypes(from: episodes)
        tableView.reloadData()
    }
    
    private func updateSearchText(_ text: String) {
        currentSearchText = text
        viewModel.updateSearchText(text)
    }
    
    private func updateFavoriteFilter(_ isActive: Bool) {
        isFavoriteFilterActive = isActive
        tableView.reloadData()
    }
    
    private func updateCanLoadMore(_ canLoadMore: Bool) {
        self.canLoadMore = canLoadMore
        tableView.reloadData()
    }
    
    private func makeSectionTypes(from episodes: [Episode]) -> [SectionType] {
        let groupedEpisodes = Dictionary(grouping: episodes) { episode in
            episode.season
        }
        
        let seasonSections = groupedEpisodes
            .map { season, episodes in
                SeasonSection(season: season, episodes: sortedEpisodes(episodes))
            }
            .sorted { first, second in
                first.season < second.season
            }
        
        var sections: [SectionType] = [.search]
        sections.append(contentsOf: seasonSections.map { .season($0) })
        sections.append(.loadMore)
        
        return sections
    }
    
    private func sortedEpisodes(_ episodes: [Episode]) -> [Episode] {
        switch sortOption {
        case .chapterOrder:
            return episodes.sorted { first, second in
                if first.episodeNumber == second.episodeNumber {
                    return first.id < second.id
                }
                
                return first.episodeNumber < second.episodeNumber
            }
        case .ratingAscending:
            return episodes.sorted { first, second in
                compareByRating(first, second, ascending: true)
            }
        case .ratingDescending:
            return episodes.sorted { first, second in
                compareByRating(first, second, ascending: false)
            }
        }
    }
    
    private func compareByRating(_ first: Episode, _ second: Episode, ascending: Bool) -> Bool {
        let firstHasRating = first.rating > 0
        let secondHasRating = second.rating > 0
        
        if firstHasRating != secondHasRating {
            return firstHasRating == ascending
        }
        
        if first.rating == second.rating {
            if first.episodeNumber == second.episodeNumber {
                return first.id < second.id
            }
            
            return first.episodeNumber < second.episodeNumber
        }
        
        if ascending {
            return first.rating < second.rating
        } else {
            return first.rating > second.rating
        }
    }
    
    @objc private func didTapSeasonHeader(_ sender: UIButton) {
        let season = sender.tag
        
        if collapsedSeasons.contains(season) {
            collapsedSeasons.remove(season)
        } else {
            collapsedSeasons.insert(season)
        }
        
        guard let sectionIndex = sectionTypes.firstIndex(where: { sectionType in
            if case .season(let seasonSection) = sectionType {
                return seasonSection.season == season
            }
            
            return false
        }) else { return }
        
        tableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
    }
}

extension EpisodeListViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTypes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sectionTypes[section] {
        case .search:
            return 1
        case .season(let seasonSection):
            return collapsedSeasons.contains(seasonSection.season) ? 0 : seasonSection.episodes.count
        case .loadMore:
            return canLoadMore ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sectionTypes[indexPath.section] {
        case .search:
            return makeSearchCell(tableView: tableView, indexPath: indexPath)
        case .season(let seasonSection):
            let episode = seasonSection.episodes[indexPath.row]
            return makeEpisodeCell(tableView: tableView, indexPath: indexPath, episode: episode)
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
    
    private func makeEpisodeCell(tableView: UITableView, indexPath: IndexPath, episode: Episode) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeTableViewCell", for: indexPath) as! EpisodeTableViewCell
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
        
        guard case .season(let seasonSection) = sectionTypes[indexPath.section] else {
            return
        }
        
        let episode = seasonSection.episodes[indexPath.row]
        viewModel.didSelectEpisode(id: episode.id)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard case .season(let seasonSection) = sectionTypes[section] else {
            return nil
        }
        
        let isCollapse = collapsedSeasons.contains(seasonSection.season)
        
        let button = UIButton(type: .system)
        button.tag = seasonSection.season
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.font = .boldSystemFont(ofSize: 25)
        button.addTarget(self, action: #selector(didTapSeasonHeader(_:)), for: .touchUpInside)
        let title = String(format: String(localized: "episode.season.header.format"), seasonSection.season)
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.image = UIImage(systemName: isCollapse ? "chevron.right" : "chevron.down")
        configuration.imagePlacement = .leading
        configuration.imagePadding = 8
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 6, trailing: 16)
        
        button.configuration = configuration
        
        return button
    }
}

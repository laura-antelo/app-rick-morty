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
    
    private enum SectionType: Int, CaseIterable {
        case search = 0
        case episodes = 1
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
    }
    
    private func bindViewModel(){
        viewModel.episodesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] episodes in
                self?.episodes = episodes
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
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
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = SectionType(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .search:
            return makeSearchCell(tableView: tableView, indexPath: indexPath)
        case .episodes:
            return makeEpisodeCell(tableView: tableView, indexPath: indexPath)
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
    
    private func makeEpisodeCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeTableViewCell", for: indexPath) as! EpisodeTableViewCell
        let episode = episodes[indexPath.row]
        cell.configure(with: episode)
        
        return cell
    }
}

extension EpisodeListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.section == 1 else { return }
        
        let episode = episodes[indexPath.row]
        viewModel.didSelectEpisode(id: episode.id)
    }
}

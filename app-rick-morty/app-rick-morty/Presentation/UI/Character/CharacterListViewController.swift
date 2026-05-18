//
//  CharacterListViewController.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 11/5/26.
//

import UIKit
import Combine

class CharacterListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel: CharacterListViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var characters: [Character] = []
    private var currentSearchText: String = ""
    
    private enum SectionType: Int, CaseIterable {
        case search = 0
        case characters = 1
    }
    
    init(viewModel: CharacterListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "CharacterListViewController", bundle: nil)
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
        navigationItem.title = "Personajes"
    }
    
    private func setupTableView(){
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell")
        tableView.register(UINib(nibName: "CharacterTableViewCell", bundle: nil), forCellReuseIdentifier: "CharacterTableViewCell")
    }
    
    private func bindViewModel(){
        viewModel.charactersPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] characters in
                self?.characters = characters
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension CharacterListViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return SectionType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SectionType(rawValue: section) else { return 0 }
        
        switch section {
        case .search:
            return 1
        case .characters:
            return characters.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = SectionType(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .search:
            return makeSearchCell(tableView: tableView, indexPath: indexPath)
        case .characters:
            return makeCharacterCell(tableView: tableView, indexPath: indexPath)
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
    
    private func makeCharacterCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterTableViewCell", for: indexPath) as! CharacterTableViewCell
        let character = characters[indexPath.row]
        cell.configure(with: character)
        
        return cell
    }
}

extension CharacterListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.section == 1 else { return }
        
        let character = characters[indexPath.row]
        viewModel.didSelectCharacter(id: character.id)
    }
}

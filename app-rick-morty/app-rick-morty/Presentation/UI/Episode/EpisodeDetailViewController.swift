//
//  EpisodeDetailViewController.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 15/5/26.
//

import UIKit
import Combine

class EpisodeDetailViewController: UIViewController {
    
    @IBOutlet private weak var episodeImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var codeLabel: UILabel!
    @IBOutlet private weak var airDateLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var synopsisLabel: UILabel!
    @IBOutlet private weak var relatedTableView: UITableView!
    @IBOutlet private weak var favoriteButton: UIButton!
    
    private let viewModel: EpisodeDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let exportTextBuilder = DetailExportTextBuilder()
    private let pdfGenerator = PDFGenerator()
    
    private var episode: Episode?
    private var relatedCharacters: [Character] = []
    
    init(viewModel: EpisodeDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "EpisodeDetailViewController", bundle: nil)
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
        navigationItem.title = String(localized: "episode.detail.title")
        setupExportButtons()
        updateFavoriteButton(isFavorite: false)
    }
    
    private func setupExportButtons() {
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(didTapShareButton))
        
        navigationItem.setRightBarButtonItems([shareButton], animated: false)
    }
    
    private func setupTableView() {
        relatedTableView.register(UINib(nibName: "CharacterTableViewCell", bundle: nil), forCellReuseIdentifier: "CharacterTableViewCell")
        
        relatedTableView.tableFooterView = UIView()
    }
    
    private func bindViewModel() {
        viewModel.episodePublisher
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] episode in
                guard let episode else { return }
                self?.configure(with: episode)
            }.store(in: &cancellables)
        
        viewModel.relatedCharactersPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] characters in
                self?.updateRelatedCharacters(characters)
            }.store(in: &cancellables)
        
        viewModel.isFavoritePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavorite in
                self?.updateFavoriteButton(isFavorite: isFavorite)
            }.store(in: &cancellables)
    }
    
    private func configure(with episode: Episode) {
        self.episode = episode
        nameLabel.text = episode.name
        codeLabel.text = String(format: String(localized: "episode.season_episode.format"), episode.season, episode.episodeNumber)
        airDateLabel.text = String(format: String(localized: "episode.air_date.format"), episode.airDate)
        ratingLabel.text = String(format: String(localized: "episode.rating.format"), episode.rating, episode.voteCount)
        synopsisLabel.text = episode.synopsis.isEmpty ? String(localized: "episode.synopsis.empty") : episode.synopsis
        episodeImageView.image = episode.image ?? UIImage(systemName: "tv")
    }
    
    private func updateRelatedCharacters(_ characters: [Character]) {
        self.relatedCharacters = characters
        self.relatedTableView.reloadData()
    }
    
    private func updateFavoriteButton(isFavorite: Bool) {
        let imageName = isFavorite ? "heart.fill" : "heart"
        
        favoriteButton.setTitle("", for: .normal)
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    private func share(items: [Any]) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = view
        
        present(activityViewController, animated: true)
    }
    
    private func showExportError() {
        let alertController = UIAlertController(title: String(localized: "export.error.title"), message: String(localized: "export.error.message"), preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: String(localized: "accept"), style: .default))
        
        present(alertController, animated: true)
    }
    
    @IBAction private func didTapFavoriteButton(_ sender: UIButton) {
        viewModel.didTapFavorite()
    }
    
    @objc private func didTapShareButton() {
        guard let episode else { showExportError(); return }
        
        let text = exportTextBuilder.makeText(for: episode)
        let fileName = "episodio_\(episode.code).pdf"
        
        guard let pdfURL = pdfGenerator.generatePDF(title: episode.name, content: text, filename: fileName) else {
            showExportError()
            return
        }
        
        share(items: [pdfURL])
    }
}

extension EpisodeDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relatedCharacters.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(localized: "characters.title")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterTableViewCell", for: indexPath) as? CharacterTableViewCell else { return UITableViewCell() }
        
        cell.configure(with: relatedCharacters[indexPath.row])
        
        return cell
    }
}

extension EpisodeDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let character = relatedCharacters[indexPath.row]
        
        viewModel.didSelectCharacter(id: character.id)
    }
}

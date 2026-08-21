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
    @IBOutlet private weak var favoriteButton: UIButton!
    
    private let viewModel: LocationDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let exportTextBuilder = DetailExportTextBuilder()
    private let pdfGenerator = PDFGenerator()
    
    private var location: Location?
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
        navigationItem.title = String(localized: "location.detail.title")
        updateFavoriteButton(isFavorite: false)
    }
    
    private func setupTableView() {
        relatedTableView.register(UINib(nibName: "CharacterTableViewCell", bundle: nil), forCellReuseIdentifier: "CharacterTableViewCell")
        
        relatedTableView.tableFooterView = UIView()
    }
    
    private func setupExportButtons() {
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(didTapShareButton))
        
        navigationItem.setRightBarButtonItems([shareButton], animated: false)
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
        
        viewModel.isFavoritePublisher
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] isFavorite in
                self?.updateFavoriteButton(isFavorite: isFavorite)
            }.store(in: &cancellables)
    }
    
    private func updateTexts(with location: Location) {
        self.location = location
        nameLabel.text = location.name
        typeLabel.text = String(format: String(localized: "type.format"), location.type)
        dimensionLabel.text = String(format: String(localized: "location.dimension.format"),location.dimension)
    }
    
    private func updateRelatedResidents(_ residents: [Character]){
        relatedResidents = residents
        relatedTableView.reloadData( )
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
        guard let location else { showExportError(); return }
        
        let text = exportTextBuilder.makeText(for: location)
        let fileName = "location_\(location.id).pdf"
        
        guard let pdfURL = pdfGenerator.generatePDF(title: location.name, content: text, filename: fileName) else {
            showExportError()
            return
        }
        
        share(items: [pdfURL])
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
        return String(localized: "location.residents.format")
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

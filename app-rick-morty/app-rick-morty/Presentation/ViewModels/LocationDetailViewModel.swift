//
//  LocationDetailViewModel.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 15/5/26.
//

import Foundation
import Combine

protocol LocationDetailViewModel {
    var locationPublisher: AnyPublisher<Location?, Never> { get }
    var relatedResidentsPublisher: AnyPublisher<[Character], Never> { get }
    var isFavoritePublisher: AnyPublisher<Bool, Never> { get }
    
    func viewDidLoad()
    func didSelectCharacter(id: Int)
    func didTapFavorite()
}

final class DefaultLocationDetailViewModel: LocationDetailViewModel {
    private let locationId: Int
    private let dependencies: RickAndMortyDependencies
    private weak var navigationCoordinator: NavegationCoordinator?
    
    private var cancellables = Set<AnyCancellable>()
    private let locationSubject = CurrentValueSubject<Location?, Never>(nil)
    private let relatedResidentsSubject = CurrentValueSubject<[Character], Never>([])
    private let isFavoriteSubject = CurrentValueSubject<Bool, Never>(false)
    
    private var currentLocation: Location?
    
    var relatedResidentsPublisher: AnyPublisher<[Character], Never> {
        relatedResidentsSubject.eraseToAnyPublisher()
    }
    
    var locationPublisher: AnyPublisher<Location?, Never> {
        locationSubject.eraseToAnyPublisher()
    }
    
    var isFavoritePublisher: AnyPublisher<Bool, Never> {
        isFavoriteSubject.eraseToAnyPublisher()
    }
    
    init(locationId: Int, dependencies: RickAndMortyDependencies, navigationCoordinator: NavegationCoordinator) {
        self.locationId = locationId
        self.dependencies = dependencies
        self.navigationCoordinator = navigationCoordinator
    }
    
    func viewDidLoad() {
        loadLocation()
    }
    
    func didSelectCharacter(id: Int) {
        navigationCoordinator?.goToCharacterDetail(id: id)
    }
    
    func didTapFavorite() {
        guard let currentLocation else { return }
        
        let favorite = Favorite(id: currentLocation.id, type: .location, name: currentLocation.name)
        
        let useCase: ToggleFavoriteUseCase = dependencies.resolve()
        let isFavorite = useCase.execute(favorite)
        
        isFavoriteSubject.send(isFavorite)
    }
    
    private func loadLocation() {
        let useCase: GetLocationDetailUseCase = dependencies.resolve()
        
        useCase.execute(id: locationId)
            .receive(on: DispatchQueue.main)
            .sink{ completion in
                if case .failure(let error) = completion {
                    print("ERROR loading location detail:", error)
                }
            } receiveValue: { [weak self] location in
                guard let self = self else { return }
                self.currentLocation = location
                self.locationSubject.send(location)
                self.updateFavoriteState(location: location)
                self.loadRelatedCharacters(ids: location.residentsIds)
            }
            .store(in: &cancellables)
    }
    
    private func updateFavoriteState(location: Location) {
        let favorite = Favorite(id: location.id, type: .location, name: location.name)
        
        let useCase: IsFavoriteUseCase = dependencies.resolve()
        let isFavorite = useCase.execute(favorite)
        
        isFavoriteSubject.send(isFavorite)
    }
    
    private func loadRelatedCharacters(ids: [Int]) {
        guard !ids.isEmpty else {
            relatedResidentsSubject.send([])
            return
        }
        
        let useCase: GetCharacterDetailUseCase = dependencies.resolve()
        ids.publisher
            .flatMap(maxPublishers: .max(4)) { id in
                useCase.execute(id: id)
                    .map { Optional($0) }
                    .replaceError(with: nil)
            }
            .compactMap{ $0 }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] characters in
                self?.relatedResidentsSubject.send(characters)
            }
            .store(in: &cancellables)
    }
}

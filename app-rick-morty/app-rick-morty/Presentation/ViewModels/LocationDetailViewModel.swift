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
    
    func viewDidLoad()
    func didSelectCharacter(id: Int)
}

final class DefaultLocationDetailViewModel: LocationDetailViewModel {
    private let locationId: Int
    private let dependencies: RickAndMortyDependencies
    private weak var navigationCoordinator: NavegationCoordinator?
    
    private var cancellables = Set<AnyCancellable>()
    private let locationSubject = CurrentValueSubject<Location?, Never>(nil)
    private let relatedResidentsSubject = CurrentValueSubject<[Character], Never>([])
    
    var relatedResidentsPublisher: AnyPublisher<[Character], Never> {
        relatedResidentsSubject.eraseToAnyPublisher()
    }
    
    var locationPublisher: AnyPublisher<Location?, Never> {
        locationSubject.eraseToAnyPublisher()
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
    
    private func loadLocation() {
        let useCase: GetLocationDetailUseCase = dependencies.resolve()
        
        useCase.execute(id: locationId)
            .receive(on: DispatchQueue.main)
            .sink{ completion in
                if case .failure(let error) = completion {
                    print("ERROR loading location detail:", error)
                }
            } receiveValue: { [weak self] location in
                self?.locationSubject.send(location)
                self?.loadRelatedCharacters(ids: location.residentsIds)
            }
            .store(in: &cancellables)
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

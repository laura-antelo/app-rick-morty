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
    
    func viewDidLoad()
    func didSelectCharacter(id: Int)
}

final class DefaultLocationDetailViewModel: LocationDetailViewModel {
    private let locationId: Int
    private let dependencies: LocationDependencies
    private weak var navigationCoordinator: NavegationCoordinator?
    
    private var cancellables = Set<AnyCancellable>()
    private let locationSubject = CurrentValueSubject<Location?, Never>(nil)
    
    var locationPublisher: AnyPublisher<Location?, Never> {
        locationSubject.eraseToAnyPublisher()
    }
    
    init(locationId: Int, dependencies: LocationDependencies, navigationCoordinator: NavegationCoordinator) {
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
                    print("ERROR loading character detail:", error)
                }
            } receiveValue: { [weak self] location in
                self?.locationSubject.send(location)
            }
            .store(in: &cancellables)
    }
}

//
//  GetLocationDetailUseCase.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation
import Combine

protocol GetLocationDetailUseCase {
    func execute(id: Int) -> AnyPublisher<Location, Error>
}

final class DefaultGetLocationDetailUseCase: GetLocationDetailUseCase {
    private let repository: LocationRepository
    
    init(repository: LocationRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) -> AnyPublisher<Location, any Error> {
        return repository.getLocationDetail(id: id)
    }
}

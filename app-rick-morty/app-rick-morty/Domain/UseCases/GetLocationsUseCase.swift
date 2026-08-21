//
//  GetLocationRepository.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation
import Combine

protocol GetLocationsUseCase {
    func execute(page: Int?, name: String?) -> AnyPublisher<PaginatedResult<Location>, Error>
}

final class DefaultGetLocationsUseCase: GetLocationsUseCase {
    private let repository: LocationRepository
    
    init(repository: LocationRepository) {
        self.repository = repository
    }
    
    func execute(page: Int?, name: String?) -> AnyPublisher<PaginatedResult<Location>, any Error> {
        return repository.getLocations(page: page, name: name)
    }
}

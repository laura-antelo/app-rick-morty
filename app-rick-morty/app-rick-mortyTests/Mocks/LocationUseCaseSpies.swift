//
//  LocationUseCaseSpies.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 18/5/26.
//

import Combine
@testable import app_rick_morty

final class GetLocationsUseCaseSpy: GetLocationsUseCase {
    var receivedPage: Int?
    var receivedName: String?
    
    var result: Result<[Location], Error> = .success([])
    
    func execute(page: Int?, name: String?) -> AnyPublisher<[Location], any Error> {
        receivedName = name
        receivedPage = page
        
        return result.publisher.eraseToAnyPublisher()
    }
}

final class GetLocationDetailUseCaseSpy: GetLocationDetailUseCase {
    var receivedId: Int?
    
    var result: Result<Location, Error> = .success(TestRickAndMortyData.location)
    
    func execute(id: Int) -> AnyPublisher<Location, any Error> {
        receivedId = id
        
        return result.publisher.eraseToAnyPublisher()
    }
}

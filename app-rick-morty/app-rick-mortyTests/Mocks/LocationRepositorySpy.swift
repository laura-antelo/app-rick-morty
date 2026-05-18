//
//  LocationRepositorySpy.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 18/5/26.
//

import Combine
@testable import app_rick_morty

final class LocationRepositorySpy: LocationRepository {
    var getLocationsPage: Int?
    var getLocationsName: String?
    var getLocationDetailId: Int?
    
    var locationsResult: Result<[Location], Error> = .success([])
    var locationDetailResult: Result<Location, Error> = .success(TestRickAndMortyData.location)
    
    func getLocations(page: Int?, name: String?) -> AnyPublisher<[Location], any Error> {
        getLocationsPage = page
        getLocationsName = name
        
        return locationsResult.publisher.eraseToAnyPublisher()
    }
    
    func getLocationDetail(id: Int) -> AnyPublisher<Location, any Error> {
        getLocationDetailId = id
        
        return locationDetailResult.publisher.eraseToAnyPublisher()
    }
}

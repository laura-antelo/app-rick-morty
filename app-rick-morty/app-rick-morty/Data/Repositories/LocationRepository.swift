//
//  LocationRepository.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation
import Combine

protocol LocationRepository {
    func getLocations(page: Int?, name: String?) -> AnyPublisher<[Location], Error>
    func getLocationDetail(id: Int) -> AnyPublisher<Location, Error>
}

final class DefaultLocationRepository: LocationRepository {
    
    private let api: APIClient
    
    init(api: APIClient) {
        self.api = api
    }
    
    func getLocations(page: Int?, name: String?) -> AnyPublisher<[Location], any Error> {
        api.request(.locations(page: page, name: name), responseType: ResponseDTO<LocationDTO>.self)
            .map { response in
                response.results.map { $0.toDomain() }
            }.eraseToAnyPublisher()
    }
    
    func getLocationDetail(id: Int) -> AnyPublisher<Location, any Error> {
        api.request(.locationDetail(id: id), responseType: LocationDTO.self).map { dto in
            dto.toDomain()
        }.eraseToAnyPublisher( )
    }
}

private extension LocationDTO {
    func toDomain() -> Location {
        Location(id: id, name: name, type: type, dimension: dimension, residentsIds: residents.compactMap{ $0.apiResourceId } )
    }
}

private extension String {
    var apiResourceId: Int? {
        guard let lastPathComponent = URL(string: self)?.lastPathComponent else { return nil }
        
        return Int(lastPathComponent)
    }
}

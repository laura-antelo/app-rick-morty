//
//  DefaultLocationRepositoryTests.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 21/5/26.
//

import Combine
import Testing
@testable import app_rick_morty

struct DefaultLocationRepositoryTests {
    
    @MainActor
    @Test func whenGetLocations_ThenReturnsLocations() async throws {
        let apiClientSpy = APIClientSpy()
        apiClientSpy.response = ResponseDTO(info: TestRickAndMortyData.pageInfo, results: [TestRickAndMortyData.locationDTO])
        
        let sut = DefaultLocationRepository(api: apiClientSpy)
        
        let publisher = sut.getLocations(page: 1, name: "Earth")
        
        var iterator = publisher.values.makeAsyncIterator()
        var result = try await iterator.next()
        
        #expect(result?.items.first?.id == 1)
    }
    
    @MainActor
    @Test func WhenGetLocationDetail_ThenReturnsLocation() async throws {
        let apiClientSpy = APIClientSpy()
        apiClientSpy.response = TestRickAndMortyData.locationDTO
        
        let sut = DefaultLocationRepository(api: apiClientSpy)
        
        var location: Location?
        
        let publisher = sut.getLocationDetail(id: 1)
        
        var iterator = publisher.values.makeAsyncIterator()
        location = try await iterator.next()
        
        #expect(location?.id == 1)
    }
}

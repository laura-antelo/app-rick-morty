//
//  APIEndpointTests.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 27/5/26.
//

import Combine
import Testing
@testable import app_rick_morty
import Foundation

struct APIEndpointTests {
    
    @Test func WhenCharactersEndpointIsCreated_ThenURLIsCorrect() throws {
        let sut = APIEndpoint.characters(page: 1, name: "Rick")
        
        let request = try sut.urlRequest()
        
        #expect(request.url?.absoluteString == "https://rickandmortyapi.com/api/character?page=1&name=Rick")
    }
    
    @Test func WhenCharacterDetailEndpointIsCreated_ThenURLIsCorrect() throws {
        let sut = APIEndpoint.characterDetail(id: 1)
        
        let request = try sut.urlRequest()
        
        #expect(request.url?.absoluteString == "https://rickandmortyapi.com/api/character/1")
    }
    
    @Test func WhenEpisodesEndpointIsCreated_ThenURLIsCorrect() throws {
        let sut = APIEndpoint.episodes(page: 1, name: "Pilot")
        
        let request = try sut.urlRequest()
        
        #expect(request.url?.absoluteString == "https://rickandmortyapi.com/api/episode?page=1&name=Pilot")
    }
    
    @Test func WhenEpisodeDetailEndpointIsCreated_ThenURLIsCorrect() throws {
        let sut = APIEndpoint.episodeDetail(id: 1)
        
        let request = try sut.urlRequest()
        
        #expect(request.url?.absoluteString == "https://rickandmortyapi.com/api/episode/1")
    }
    
    @Test func WhenLocationsEndpointIsCreated_ThenURLIsCorrect() throws {
        let sut = APIEndpoint.locations(page: 1, name: "Earth")
        
        let request = try sut.urlRequest()
        
        #expect(request.url?.absoluteString == "https://rickandmortyapi.com/api/location?page=1&name=Earth")
    }
    
    @Test func WhenLocationDetailEndpointIsCreated_ThenURLIsCorrect() throws {
        let sut = APIEndpoint.locationDetail(id: 1)
        
        let request = try sut.urlRequest()
        
        #expect(request.url?.absoluteString == "https://rickandmortyapi.com/api/location/1")
    }
}

//
//  DefaultEpisodeRepositoryTests.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 21/5/26.
//

import Combine
import Testing
@testable import app_rick_morty

struct DefaultEpisodeRepositoryTests {
    
    @MainActor
    @Test func WhenGetEpisodes_ThenReturnsEpisodes() async throws {
        let apiClientSpy = APIClientSpy()
        apiClientSpy.response = ResponseDTO(info: TestRickAndMortyData.pageInfo, results: [TestRickAndMortyData.episodeDTO])
        
        let sut = DefaultEpisodeRepository(api: apiClientSpy)
        
        var episodes: [Episode]?
        
        let publisher = sut.getEpisodes(page: 1, name: "Pilot")
        
        var iterator = publisher.values.makeAsyncIterator()
        episodes = try await iterator.next()
        
        #expect(episodes?.first?.id == 1)
    }
    
    @MainActor
    @Test func WhenGetEpisodeDetail_ThenReturnsEpisode() async throws {
        let apiClientSpy = APIClientSpy()
        apiClientSpy.response = TestRickAndMortyData.episodeDTO
        
        let sut = DefaultEpisodeRepository(api: apiClientSpy)
        
        var episode: Episode?
        
        let publisher = sut.getEpisodeDetail(id: 1)
        
        var iterator = publisher.values.makeAsyncIterator()
        episode = try await iterator.next()
        
        #expect(episode?.id == 1)
    }
}

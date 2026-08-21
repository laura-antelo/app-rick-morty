//
//  ListViewModelTests.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 21/5/26.
//

import Foundation
import Combine
import Testing
@testable import app_rick_morty

struct ListViewModelTests {
    
    @MainActor
    @Test func WhenCharacterListViewModelDidLoad_ThenPublishersCharacters() async throws {
        let dependencies = CharacterDependenciesMock()
        
        dependencies.getCharacterUseCaseSpy.result = .success([TestRickAndMortyData.character])
        
        let sut = DefaultCharacterListViewModel(dependencies: dependencies)
        
        let publisher = sut.charactersPublisher
        var iterator = publisher.values.makeAsyncIterator()
        
        _ = await iterator.next()
        
        sut.viewDidLoad()
        
        let characters = await iterator.next()
        
        #expect(characters?.first?.id == 1)
    }
    
    @MainActor
    @Test func WhenCharacterIsSelected_ThenRequestsCharacterNavigation() async throws {
        let dependencies = CharacterDependenciesMock()
        
        let sut = DefaultCharacterListViewModel(dependencies: dependencies)
        
        sut.didSelectCharacter(id: 1)
        
        #expect(dependencies.characterCoordinatorSpy.receivedCharacterDetailId == 1)
    }
    
    @MainActor
    @Test func WhenCharacterSearchTextIsUpdated_ThenPublishesFilteredCharacters() async throws {
        let dependencies = CharacterDependenciesMock()
        let filteredCharacter = TestRickAndMortyData.character
        
        dependencies.getCharacterUseCaseSpy.result = .success([TestRickAndMortyData.character])
        
        let sut = DefaultCharacterListViewModel(dependencies: dependencies)
        
        let publisher = sut.charactersPublisher
        var iterator = publisher.values.makeAsyncIterator()
        
        _ = await iterator.next()
        
        sut.viewDidLoad()
        
        _ = await iterator.next()
        
        dependencies.getCharacterUseCaseSpy.result = .success([filteredCharacter])
        
        sut.updateSearchText("Rick")
        
        let characters = await iterator.next()
        
        #expect(characters?.first?.name == "Rick Sanchez")
    }
    
    @MainActor
    @Test func WhenLocationListViewModelDidLoad_ThenPublishersLocations() async throws {
        let dependencies = LocationDependenciesMock()
        
        dependencies.getLocationUseCaseSpy.result = .success([TestRickAndMortyData.location])
        
        let sut = DefaultLocationListViewModel(dependencies: dependencies)
        
        let publisher = sut.locationsPublisher
        var iterator = publisher.values.makeAsyncIterator()
        
        _ = await iterator.next()
        
        sut.viewDidLoad()
        
        let locations = await iterator.next()
        
        #expect(locations?.first?.id == 1)
    }
    
    @MainActor
    @Test func WhenLocationIsSelected_ThenRequestsLocationNavigation() async throws {
        let dependencies = LocationDependenciesMock()
        
        let sut = DefaultLocationListViewModel(dependencies: dependencies)
        
        sut.didSelectLocation(id: 1)
        
        #expect(dependencies.locationCoordinatorSpy.receivedLocationDetailId == 1)
    }
    
    @MainActor
    @Test func WhenLocationSearchTextIsUpdated_ThenPublishesFilteredLocations() async throws {
        let dependencies = LocationDependenciesMock()
        let filteredLocation = TestRickAndMortyData.location
        
        dependencies.getLocationUseCaseSpy.result = .success([TestRickAndMortyData.location])
        
        let sut = DefaultLocationListViewModel(dependencies: dependencies)
        
        let publisher = sut.locationsPublisher
        var iterator = publisher.values.makeAsyncIterator()
        
        _ = await iterator.next()
        
        sut.viewDidLoad()
        
        _ = await iterator.next()
        
        dependencies.getLocationUseCaseSpy.result = .success([filteredLocation])
        
        sut.updateSearchText("Earth")
        
        let locations = await iterator.next()
        
        #expect(locations?.first?.name == "Earth")
    }
    
    @MainActor
    @Test func WhenEpisodeListViewModelDidLoad_ThenPublishersEpisodes() async throws {
        let dependencies = EpisodeDependenciesMock()
        
        dependencies.getEpisodesUseCaseSpy.result = .success([TestRickAndMortyData.episode])
        
        let sut = DefaultEpisodeListViewModel(dependencies: dependencies)
        
        let publisher = sut.episodesPublisher
        var iterator = publisher.values.makeAsyncIterator()
        
        _ = await iterator.next()
        
        sut.viewDidLoad()
        
        let episodes = await iterator.next()
        
        #expect(episodes?.first?.id == 1)
    }
    
    @MainActor
    @Test func WhenEpisodeIsSelected_ThenRequestsEpisodeNavigation() async throws {
        let dependencies = EpisodeDependenciesMock()
        
        let sut = DefaultEpisodeListViewModel(dependencies: dependencies)
        
        sut.didSelectEpisode(id: 1)
        
        #expect(dependencies.episodeCoordinatorSpy.receivedEpisodeDetailId == 1)
    }
    
    @MainActor
    @Test func WhenEpisodeSearchTextIsUpdated_ThenPublishesFilteredEpisodes() async throws {
        let dependencies = EpisodeDependenciesMock()
        let filteredEpisode = TestRickAndMortyData.episode
        
        dependencies.getEpisodesUseCaseSpy.result = .success([TestRickAndMortyData.episode])
        
        let sut = DefaultEpisodeListViewModel(dependencies: dependencies)
        
        let publisher = sut.episodesPublisher
        var iterator = publisher.values.makeAsyncIterator()
        
        _ = await iterator.next()
        
        sut.viewDidLoad()
        
        _ = await iterator.next()
        
        dependencies.getEpisodesUseCaseSpy.result = .success([filteredEpisode])
        
        sut.updateSearchText("Pilot")
        
        let episodes = await iterator.next()
        
        #expect(episodes?.first?.name == "Pilot")
    }
}

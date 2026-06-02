//
//  CacheDecoratorTests.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 27/5/26.
//

import Combine
import Testing
@testable import app_rick_morty

struct CacheDecoratorTests {
    
    @MainActor
    @Test func WhenCharacterListIsCached_ThenReturnsCachedList() async throws {
        let repository = CharacterRepositorySpy()
        let cache = DiskCache(folderName: "CacheDecoratorTests")
        let sut = CacheCharacterDecorator(decoratedRepository: repository, cache: cache)
        
        repository.charactersResult = .success(PaginatedResult(items: [TestRickAndMortyData.character], hasNextPage: false))
        
        var publisher = sut.getCharacters(page: 1, name: nil)
        var iterator = publisher.values.makeAsyncIterator()
        _ = try await iterator.next()
        
        repository.charactersResult = .failure(TestError.expectedFailure)
        
        publisher = sut.getCharacters(page: 1, name: nil)
        iterator = publisher.values.makeAsyncIterator()
        let result = try await iterator.next()
        
        #expect(result?.items.first?.id == 1)
    }
    
    @MainActor
    @Test func WhenCharacterDetailIsCached_ThenReturnsCachedCharacter() async throws {
        let repository = CharacterRepositorySpy()
        let cache = DiskCache(folderName: "CacheDecoratorTests")
        let sut = CacheCharacterDecorator(decoratedRepository: repository, cache: cache)
        
        repository.characterDetailResult = .success(TestRickAndMortyData.character)
        
        var publisher = sut.getCharacterDetail(id: 1)
        var iterator = publisher.values.makeAsyncIterator()
        _ = try await iterator.next()
        
        repository.characterDetailResult = .failure(TestError.expectedFailure)
        
        publisher = sut.getCharacterDetail(id: 1)
        iterator = publisher.values.makeAsyncIterator()
        let character = try await iterator.next()
        
        #expect(character?.id == 1)
    }
    
    @MainActor
    @Test func WhenLocationListIsCached_ThenReturnsCachedList() async throws {
        let repository = LocationRepositorySpy()
        let cache = DiskCache(folderName: "CacheDecoratorTests")
        let sut = CacheLocationDecorator(decoratedRepository: repository, cache: cache)
        
        repository.locationsResult = .success(PaginatedResult(items: [TestRickAndMortyData.location], hasNextPage: false))
        
        var publisher = sut.getLocations(page: 1, name: nil)
        var iterator = publisher.values.makeAsyncIterator()
        _ = try await iterator.next()
        
        repository.locationsResult = .failure(TestError.expectedFailure)
        
        publisher = sut.getLocations(page: 1, name: nil)
        iterator = publisher.values.makeAsyncIterator()
        let result = try await iterator.next()
        
        #expect(result?.items.first?.id == 1)
    }
    
    @MainActor
    @Test func WhenLocationDetailIsCached_ThenReturnsCachedLocation() async throws {
        let repository = LocationRepositorySpy()
        let cache = DiskCache(folderName: "CacheDecoratorTests")
        let sut = CacheLocationDecorator(decoratedRepository: repository, cache: cache)
        
        repository.locationDetailResult = .success(TestRickAndMortyData.location)
        
        var publisher = sut.getLocationDetail(id: 1)
        var iterator = publisher.values.makeAsyncIterator()
        _ = try await iterator.next()
        
        repository.locationDetailResult = .failure(TestError.expectedFailure)
        
        publisher = sut.getLocationDetail(id: 1)
        iterator = publisher.values.makeAsyncIterator()
        let location = try await iterator.next()
        
        #expect(location?.id == 1)
    }
    
    @MainActor
    @Test func WhenEpisodeListIsCached_ThenReturnsCachedList() async throws {
        let repository = EpisodeRepositorySpy()
        let cache = DiskCache(folderName: "CacheDecoratorTests")
        let sut = CacheEpisodeDecorator(decoratedRepository: repository, cache: cache)
        
        repository.episodesResult = .success(PaginatedResult(items: [TestRickAndMortyData.episode], hasNextPage: false))
        
        var publisher = sut.getEpisodes(page: 1, name: nil)
        var iterator = publisher.values.makeAsyncIterator()
        _ = try await iterator.next()
        
        repository.episodesResult = .failure(TestError.expectedFailure)
        
        publisher = sut.getEpisodes(page: 1, name: nil)
        iterator = publisher.values.makeAsyncIterator()
        let result = try await iterator.next()
        
        #expect(result?.items.first?.id == 1)
    }
    
    @MainActor
    @Test func WhenEpisodeDetailIsCached_ThenReturnsCachedEpisode() async throws {
        let repository = EpisodeRepositorySpy()
        let cache = DiskCache(folderName: "CacheDecoratorTests")
        let sut = CacheEpisodeDecorator(decoratedRepository: repository, cache: cache)
        
        repository.episodeDetailResult = .success(TestRickAndMortyData.episode)
        
        var publisher = sut.getEpisodeDetail(id: 1)
        var iterator = publisher.values.makeAsyncIterator()
        _ = try await iterator.next()
        
        repository.episodeDetailResult = .failure(TestError.expectedFailure)
        
        publisher = sut.getEpisodeDetail(id: 1)
        iterator = publisher.values.makeAsyncIterator()
        let episode = try await iterator.next()
        
        #expect(episode?.id == 1)
    }
    
}

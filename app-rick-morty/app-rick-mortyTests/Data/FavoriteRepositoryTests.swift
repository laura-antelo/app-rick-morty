//
//  FavoriteRepositoryTests.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 27/5/26.
//

import Foundation
import Testing
@testable import app_rick_morty

struct FavoriteRepositoryTests {
    
    @Test func WhenToggleFavorite_ThenFavoriteIsStored() {
        let sut = makeSUT()
        
        _ = sut.toggleFavorite(TestRickAndMortyData.characterFavorite)
        
        #expect(sut.isFavorite(TestRickAndMortyData.characterFavorite))
    }
    
    @Test func WhenToggleFavoriteTwice_ThenFavoriteIsNotStored() {
        let sut = makeSUT()
        
        _ = sut.toggleFavorite(TestRickAndMortyData.characterFavorite)
        _ = sut.toggleFavorite(TestRickAndMortyData.characterFavorite)
        
        let isFavorite = sut.isFavorite(TestRickAndMortyData.characterFavorite)
        
        #expect(isFavorite == false)
    }
    
    @Test func WhenGetFavoritesByType_ThenReturnsOnlyRequestedType() {
        let sut = makeSUT()
        
        _ = sut.toggleFavorite(TestRickAndMortyData.characterFavorite)
        _ = sut.toggleFavorite(TestRickAndMortyData.episodeFavorite)
        
        #expect(sut.getFavorites(type: .character).count == 1)
    }
    
    private func makeSUT() -> DefaultFavoriteRepository {
        let suiteName = "FavoriteRepositoryTests"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        
        return DefaultFavoriteRepository(userDefaults: userDefaults)
    }
}

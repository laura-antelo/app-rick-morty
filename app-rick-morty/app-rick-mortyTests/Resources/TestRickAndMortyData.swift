//
//  TestRickAndMortyData.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 18/5/26.
//

import Foundation
@testable import app_rick_morty

enum TestRickAndMortyData {
    static let pageInfo = PageInfoDTO(count: 1, pages: 1, next: nil, prev: nil)
    
    static let characterDTO = CharacterDTO(
        id: 1, name: "Rick Sanchez", status: "Alive", species: "Human", type: "", gender: "Male",
        origin: CharacterLocationReferenceDTO(
            name: "Citadel of Ricks",
            url: "https://rickandmortyapi.com/api/location/3"
        ),
        location: CharacterLocationReferenceDTO(
            name: "Earth",
            url: "https://rickandmortyapi.com/api/location/1"
        ),
        image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
        episode: ["https://rickandmortyapi.com/api/episode/1", "https://rickandmortyapi.com/api/episode/2"],
        url: "https://rickandmortyapi.com/api/character/1",
        created: "2017-11-04T18:48:46.250Z"
    )
    
    static let locationDTO = LocationDTO(
        id: 1, name: "Earth", type: "Planet", dimension: "Dimension C-137",
        residents: ["https://rickandmortyapi.com/api/character/1", "https://rickandmortyapi.com/api/character/2"],
        url: "https://rickandmortyapi.com/api/location/1",
        created: "2017-11-04T19:43:39.000Z"
    )
    
    static let episodeDTO = EpisodeDTO(
        id: 1, name: "Pilot", airDate: "December 2, 2013", episode: "S01E01",
        characters: ["https://rickandmortyapi.com/api/character/1", "https://rickandmortyapi.com/api/character/2"],
        url: "https://rickandmortyapi.com/api/episode/1",
        created: "2017-11-04T18:49:36.000Z"
    )
    
    static let character = Character(
        id: 1, name: "Rick Sanchez", status: .alive, species: "Human", type: "", gender: "Male",
        origin: LocationReference(id: 1, name: "Earth"), location: LocationReference(id: 3, name: "Citadel of Ricks"),
        imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"),
        episodeIds: [1, 2], image: nil
    )
    
    static let location = Location(
        id: 1, name: "Earth", type: "Planet", dimension: "Dimension C-137", residentsIds: [1, 2]
    )
    
    static let episode = Episode(
        id: 1, name: "Pilot", airDate: "December 2, 2013", code: "S01E01", charactersIds: [1, 2]
    )
    
    static let characterFavorite = Favorite(id: 1, type: .character, name: "Rick Sanchez")
    
    static let locationFavorite = Favorite(id: 1, type: .location, name: "Earth")
    
    static let episodeFavorite = Favorite(id: 1, type: .episode, name: "Pilot")
}

//
//  CharacterDTO.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation

struct CharacterDTO: Decodable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String?
    let gender: String
    let origin: CharacterLocationReferenceDTO
    let location: CharacterLocationReferenceDTO
    let image: String
    let episode: [String]
    let url: String
    let created: String
}

struct CharacterLocationReferenceDTO: Decodable {
    let name: String
    let url: String
}

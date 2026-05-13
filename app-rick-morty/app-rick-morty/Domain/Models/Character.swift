//
//  Character.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation

struct Character {
    let id: Int
    let name: String
    let status: CharacterStatus
    let species: String
    let type: String
    let gender: String
    let origin: LocationReference
    let location: LocationReference
    let imageURL: URL?
    let episodeIds: [Int]
}

enum CharacterStatus: String {
    case alive, dead, unknown
    
    init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "alive": self = .alive
        case "dead": self = .dead
        default: self = .unknown
        }
    }
}

struct LocationReference {
    let id: Int?
    let name: String
}

//
//  LocationDTO.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation

struct LocationDTO: Decodable {
    let id: Int
    let name: String
    let type: String
    let dimension: String
    let residents: [String]
    let url: String
    let created: String
}

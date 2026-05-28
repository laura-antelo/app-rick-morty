//
//  Episode.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation
import UIKit

struct Episode {
    let id: Int
    let name: String
    let airDate: String
    let code: String
    let charactersIds: [Int]
    
    let image: UIImage?
    let synopsis: String
    let rating: Double
    let voteCount: Int
    let season: Int
    let episodeNumber: Int
    
    init(id: Int, name: String, airDate: String, code: String, charactersIds: [Int], image: UIImage?, synopsis: String, rating: Double, voteCount: Int, season: Int, episodeNumber: Int) {
        self.id = id
        self.name = name
        self.airDate = airDate
        self.code = code
        self.charactersIds = charactersIds
        self.image = image
        self.synopsis = synopsis
        self.rating = rating
        self.voteCount = voteCount
        self.season = season
        self.episodeNumber = episodeNumber
    }
}

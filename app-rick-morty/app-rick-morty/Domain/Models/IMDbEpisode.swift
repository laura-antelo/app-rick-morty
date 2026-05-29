//
//  IMDbEpisode.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 29/5/26.
//

import Foundation
import UIKit

struct IMDbEpisode {
    let id: String
    let title: String
    let image: UIImage?
    let synopsis: String
    let rating: Double
    let voteCount: Int
    let season: Int
    let episodeNumber: Int
}

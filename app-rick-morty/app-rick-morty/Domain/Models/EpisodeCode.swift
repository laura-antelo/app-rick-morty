//
//  EpisodeCode.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 29/5/26.
//

import Foundation

struct EpisodeCode {
    let season: Int
    let episodeNumber: Int
}

enum EpisodeCodeParser {
    static func parse(_ code: String) -> EpisodeCode {
        let pattern = #"S(\d+)E(\d+)"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: code, range: NSRange(code.startIndex..., in: code)),
              let seasonRange = Range(match.range(at: 1), in: code),
              let episodeRange = Range(match.range(at: 2), in: code) else {
            return EpisodeCode(season: 0, episodeNumber: 0)
        }
        
        return EpisodeCode(season: Int(code[seasonRange]) ?? 0, episodeNumber: Int(code[episodeRange]) ?? 0)
    }
}

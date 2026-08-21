//
//  TranslationDTO.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 3/6/26.
//

import Foundation

struct TranslationResponseDTO: Decodable {
    let responseData: TranslationResponseDataDTO
}

struct TranslationResponseDataDTO: Decodable {
    let translatedText: String
}

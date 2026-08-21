//
//  TranslationRepository.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 3/6/26.
//

import Foundation
import Combine

protocol TranslationRepository {
    func translate(_ text: String, from sourceLanguage: AppLanguage, to targetLanguage: AppLanguage) -> AnyPublisher<String, Error>
}

final class MyMemoryTranslationRepository: TranslationRepository {
    private let api: TranslationAPIClient
    
    init(api: TranslationAPIClient) {
        self.api = api
    }
    
    func translate(_ text: String, from sourceLanguage: AppLanguage, to targetLanguage: AppLanguage) -> AnyPublisher<String, any Error> {
        let cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanedText.isEmpty, sourceLanguage != targetLanguage, cleanedText.utf8.count <= 500 else {
            return Just(text)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return api.request(.translate(text: cleanedText, from: sourceLanguage, to: targetLanguage), responseType: TranslationResponseDTO.self)
            .map { response in
                response.responseData.translatedText.isEmpty ? text : response.responseData.translatedText
            }
            .eraseToAnyPublisher()
    }
}

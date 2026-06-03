//
//  CacheTranslationDecorator.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 3/6/26.
//

import Foundation
import Combine

final class CacheTranslationDecorator: TranslationRepository {
    private let decoratedRepository: TranslationRepository
    private let cache: DiskCache
    
    init(decoratedRepository: TranslationRepository, cache: DiskCache = .shared) {
        self.decoratedRepository = decoratedRepository
        self.cache = cache
    }
    
    
    func translate(_ text: String, from sourceLanguage: AppLanguage, to targetLanguage: AppLanguage) -> AnyPublisher<String, Error> {
        let cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanedText.isEmpty else {
            return Just(text)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let cachedKey = "translation_\(sourceLanguage.rawValue)_\(targetLanguage.rawValue)_\(stableHash(text))"
        
        if let cachedTranslation = cache.load(CachedTranslation.self, forKey: cachedKey) {
            return Just(cachedTranslation.text)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return decoratedRepository.translate(cleanedText, from: sourceLanguage, to: targetLanguage)
            .handleEvents(receiveOutput: { [cache] translatedText in
                cache.save(CachedTranslation(text: translatedText), forKey: cachedKey)
            })
            .eraseToAnyPublisher()
    }
    
    private func stableHash(_ text: String) -> String {
        var hash: UInt64 = 5381
        
        for byte in text.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(byte)
        }
        
        return String(hash)
    }
}

private struct CachedTranslation: Codable {
    let text: String
}

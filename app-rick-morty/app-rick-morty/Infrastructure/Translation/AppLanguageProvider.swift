//
//  AppLanguageProvider.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 3/6/26.
//

import Foundation

protocol AppLanguageProvider {
    var currentLanguage: AppLanguage { get }
}

final class DefaultAppLanguageProvider: AppLanguageProvider {
    
    var currentLanguage: AppLanguage {
        let languageCode = Locale.preferredLanguages.first?
            .prefix(2)
            .lowercased() ?? AppLanguage.english.rawValue
        
        return AppLanguage(rawValue: languageCode) ?? .english
    }
}

enum AppLanguage: String {
    case english = "en"
    case spanish = "es"
    case portuguese = "pt"
}


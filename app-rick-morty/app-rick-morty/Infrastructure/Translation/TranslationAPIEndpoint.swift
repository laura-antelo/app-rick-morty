//
//  TranslationAPIEndpoint.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 3/6/26.
//

import Foundation

enum TranslationAPIEndpoint {
    case translate(text: String, from: AppLanguage, to: AppLanguage)
    
    private var baseURL: URL {
        URL(string: "https://api.mymemory.translated.net")!
    }
    
    private var path: String {
        switch self {
        case .translate:
            return "get"
        }
    }
    
    private var queryItems: [URLQueryItem] {
        switch self {
        case .translate(let text, let sourceLanguage, let targetLanguage):
            return [
                URLQueryItem(name: "q", value: text),
                URLQueryItem(name: "langpair", value: "\(sourceLanguage.rawValue)|\(targetLanguage.rawValue)")
            ]
        }
    }
    
    func urlRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw TranslationAPIClientError.invalidURL
        }
        
        components.queryItems = queryItems
        
        guard let fullURL = components.url else {
            throw TranslationAPIClientError.invalidURL
        }
        
        var urlRequest = URLRequest(url: fullURL)
        urlRequest.httpMethod = "GET"
        
        return urlRequest
    }
}

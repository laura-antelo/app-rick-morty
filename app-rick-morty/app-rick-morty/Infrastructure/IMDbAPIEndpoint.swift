//
//  IMDbAPIEndpoint.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 28/5/26.
//

import Foundation

enum IMDbAPIEndpoint {
    case episodes(nextPageToken: String?)
    
    private var baseURL: URL {
        URL(string: "https://api.imdbapi.dev")!
    }
    
    private var path: String {
        switch self {
        case .episodes:
            return "titles/tt2861424/episodes"
        }
    }
    
    private var queryItems: [URLQueryItem] {
        switch self {
        case .episodes(let nextPageToken):
            guard let nextPageToken, !nextPageToken.isEmpty else {
                return []
            }
            
            return [URLQueryItem(name: "nextPageToken", value: nextPageToken)]
        }
    }
    
    func urlRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw IMDbAPIClientError.invalidURL
        }
        
        let queryItems = self.queryItems
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard let fullURL = components.url else {
            throw IMDbAPIClientError.invalidURL
        }
        
        var urlRequest = URLRequest(url: fullURL)
        urlRequest.httpMethod = "GET"
        
        return urlRequest
    }
}

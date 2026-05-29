//
//  IMDbAPIEndpoint.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 28/5/26.
//

import Foundation

enum IMDbAPIEndpoint {
    case episodes
    
    private var baseURL: URL {
        URL(string: "https://api.imdbapi.dev")!
    }
    
    private var path: String {
        switch self {
        case .episodes:
            return "titles/tt2861424/episodes"
        }
    }
    
    func urlRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let fullURL = components.url else {
            throw IMDbAPIClientError.invalidURL
        }
        
        var urlRequest = URLRequest(url: fullURL)
        urlRequest.httpMethod = "GET"
        
        return urlRequest
    }
}

//
//  APIEndpoing.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation

enum APIEndpoint {
    case episodes(page: Int?, name: String?)
    case episodeDetail(id: Int)
    
    case characters(page: Int?, name: String?)
    case characterDetail(id: Int)
    
    case locations(page: Int?, name: String?)
    case locationDetail(id: Int)
    
    private var baseURL: URL {
        URL(string: "https://rickandmortyapi.com/api")!
    }
    
    private var path: String {
        switch self {
        case .episodes:
            return "episode"
        case .episodeDetail(let id):
            return "episode/\(id)"
        case .characters:
            return "character"
        case .characterDetail(let id):
            return "character/\(id)"
        case .locations:
            return "location"
        case .locationDetail(let id):
            return "location/\(id)"
        }
    }
    
    private var queryItems: [URLQueryItem] {
        switch self {
        case .episodes(let page, let name),
            .characters(let page, let name),
            .locations(let page, let name):
            
            var queryItems: [URLQueryItem] = []
            
            if let page {
                queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
            }
            
            if let name = name?.trimmingCharacters(in: .whitespacesAndNewlines) {
                queryItems.append(URLQueryItem(name: "name", value: name))
            }
            
            return queryItems
        case .episodeDetail, .locationDetail, .characterDetail:
            return []
        }
    }
    
    func urlRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw APIClientError.invalidURL
        }
        
        let queryItems = self.queryItems
        
        guard let fullURL = components.url else {
            throw APIClientError.invalidURL
        }
        
        var urlRequest = URLRequest(url: fullURL)
        urlRequest.httpMethod = "GET"
        
        return urlRequest
    }
}

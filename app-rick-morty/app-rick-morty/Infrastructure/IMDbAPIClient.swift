//
//  IMDbAPIClient.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 28/5/26.
//

import Foundation
import Combine

protocol IMDbAPIClient {
    func request<T: Decodable>(_ endpoint: IMDbAPIEndpoint, responseType: T.Type) -> AnyPublisher<T, Error>
}

final class URLSessionIMDbAPIClient: IMDbAPIClient {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    func request<T: Decodable>(_ endpoint: IMDbAPIEndpoint, responseType: T.Type) -> AnyPublisher<T, any Error> {
        do {
            let request = try endpoint.urlRequest()
            
            return session.dataTaskPublisher(for: request)
                .tryMap { (data, response) in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw IMDbAPIClientError.invalidResponse
                    }
                    
                    guard (200..<300).contains(httpResponse.statusCode) else {
                        throw IMDbAPIClientError.statusCode(httpResponse.statusCode)
                    }
                    
                    return data
                }
                .decode(type: responseType, decoder: decoder)
                .mapError { error in
                    if error is DecodingError {
                        return IMDbAPIClientError.decodingError(error)
                    }
                    
                    return error
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher( )
        }
    }
}

enum IMDbAPIClientError: Error {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingError(Error)
}

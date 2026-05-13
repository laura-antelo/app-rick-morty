//
//  APIClient.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation
import Combine

protocol APIClient {
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) -> AnyPublisher<T, Error>
}

final class URLSessionAPIClient: APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) -> AnyPublisher<T, any Error> {
        do {
            let request = try endpoint.urlRequest()
            
            return session.dataTaskPublisher(for: request)
                .tryMap { (data, response) in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIClientError.invalidResponse
                    }
                    
                    guard (200..<300).contains(httpResponse.statusCode) else {
                        throw APIClientError.statusCode(httpResponse.statusCode)
                    }
                    
                    return data
                }.decode(type: responseType, decoder: decoder)
                .mapError { error in
                    if let apiClientError = error as? APIClientError { return apiClientError }
                    if error is DecodingError { return APIClientError.decodingError(error) }
                    return error
                }.eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}

enum APIClientError: Error {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingError(Error)
}

//
//  TranslationAPIClient.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 3/6/26.
//

import Foundation
import Combine

protocol TranslationAPIClient {
    func request<T: Decodable>(_ endpoint: TranslationAPIEndpoint, responseType: T.Type) -> AnyPublisher<T, Error>
}

final class URLSessionTranslationAPIClient: TranslationAPIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    func request<T: Decodable>(_ endpoint: TranslationAPIEndpoint, responseType: T.Type) -> AnyPublisher<T, Error>  {
        do {
            let request = try endpoint.urlRequest()
            
            return session.dataTaskPublisher(for: request)
                .tryMap { data, response in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw TranslationAPIClientError.invalidResponse
                    }
                    
                    guard (200..<300).contains(httpResponse.statusCode) else {
                        throw TranslationAPIClientError.statusCode(httpResponse.statusCode)
                    }
                    
                    return data
                }
                .decode(type: responseType, decoder: decoder)
                .mapError { error in
                    if error is DecodingError {
                        return TranslationAPIClientError.decodingError(error)
                    }
                    
                    return error
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
}

enum TranslationAPIClientError: Error {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingError(Error)
}

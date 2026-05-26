//
//  APIClient.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation
import Combine
import UIKit

protocol APIClient {
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) -> AnyPublisher<T, Error>
    func fetchImage(from urlString: String?) -> AnyPublisher<UIImage?, Error>
}

final class URLSessionAPIClient: APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let imageCache: ImageDiskCache
    
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder(), imageCache: ImageDiskCache = .shared) {
        self.session = session
        self.decoder = decoder
        self.imageCache = imageCache
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
                    if error is DecodingError { return APIClientError.decodingError(error) }
                    return error
                }.eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func fetchImage(from urlString: String?) -> AnyPublisher<UIImage?, any Error> {
        guard let urlString, let url = URL(string: urlString) else {
            return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        if let cachedData = imageCache.data(forKey: urlString), let cachedImage = UIImage(data: cachedData) {
            return Just(cachedImage)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .map { [imageCache] data in
                imageCache.save(data, forKey: urlString)
                return UIImage(data: data)
            }
            .mapError { $0 as Error }
            .catch { _ in Just(nil).setFailureType(to: Error.self) }
            .eraseToAnyPublisher()
    }
}

enum APIClientError: Error {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingError(Error)
}

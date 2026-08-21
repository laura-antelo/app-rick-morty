//
//  APIClientSpy.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 18/5/26.
//

import Combine
import Foundation
@testable import app_rick_morty

final class APIClientSpy: APIClient {
    
    var receivedEndpoint: APIEndpoint?
    var receivedResponseType: Any.Type?
    
    var response: Any?
    var error: Error?
    
    func request<T>(_ endpoint: APIEndpoint, responseType: T.Type) -> AnyPublisher<T, any Error> where T : Decodable {
        self.receivedEndpoint = endpoint
        self.receivedResponseType = responseType
        
        if let error = error {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        guard let response = response as? T else {
            return Fail(error: TestError.unexpectedResponseType).eraseToAnyPublisher()
        }
        
        return Just(response)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    var receivedURLString: String? {
        try? receivedEndpoint?.urlRequest().url?.absoluteString
    }
}

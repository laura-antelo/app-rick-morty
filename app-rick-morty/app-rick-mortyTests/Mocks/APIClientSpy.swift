//
//  APIClientSpy.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 18/5/26.
//

import Combine
import Foundation
import UIKit
@testable import app_rick_morty

final class APIClientSpy: APIClient {
    
    var receivedEndpoint: APIEndpoint?
    var receivedResponseType: Any.Type?
    var receivedImageURLString: String?
    
    var response: Any?
    var error: Error?
    var imageToReturn: UIImage?
    
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) -> AnyPublisher<T, any Error> {
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
    
    func fetchImage(from urlString: String?) -> AnyPublisher<UIImage?, any Error> {
        receivedImageURLString = urlString
        
        return Just(imageToReturn)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    var receivedURLString: String? {
        try? receivedEndpoint?.urlRequest().url?.absoluteString
    }
}

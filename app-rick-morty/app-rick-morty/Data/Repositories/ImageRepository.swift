//
//  ImageRepository.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 29/5/26.
//

import Foundation
import UIKit
import Combine

protocol ImageRepository {
    func getImage(from urlString: String) -> AnyPublisher<UIImage?, Error>
}

final class DefaultImageRepository: ImageRepository {
    private let api: APIClient
    
    init(api: APIClient) {
        self.api = api
    }
    
    func getImage(from urlString: String) -> AnyPublisher<UIImage?, Error> {
        api.fetchImage(from: urlString)
    }
}

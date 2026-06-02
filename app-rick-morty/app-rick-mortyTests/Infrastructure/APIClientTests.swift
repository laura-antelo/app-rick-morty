//
//  APIClientTests.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 27/5/26.
//

import Foundation
import UIKit
import Combine
import Testing
@testable import app_rick_morty

private struct DecodableTestResponse: Decodable {
    let id: Int
    let name: String
}

final class URLProtocolMock: URLProtocol {
    static var data: Data?
    static var response: HTTPURLResponse?
    static var error: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        if let error = Self.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        if let response = Self.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let data = Self.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
    
    static func reset() {
        data = nil
        response = nil
        error = nil
    }
}

@Suite(.serialized)
struct APIClientTests {
    
    @MainActor
    @Test func WhenRequestSucceeds_ThenDecodableIsReturned() async throws {
        URLProtocolMock.reset()
        
        let sut = makeSUT()
        let url = try APIEndpoint.characterDetail(id: 1).urlRequest().url!
        
        URLProtocolMock.data = #"{"id":1,"name":"Rick"}"#.data(using: .utf8)
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        let publisher = sut.request(.characterDetail(id:1), responseType: DecodableTestResponse.self)
        
        var iterator = publisher.values.makeAsyncIterator()
        let response = try await iterator.next()
        
        URLProtocolMock.reset()
        
        #expect(response?.id == 1)
    }
    
    @MainActor
    @Test func WhenStatusCodeIsNotSuccessful_ThenReturnsStatusCodeError() async throws {
        URLProtocolMock.reset()
        
        let sut = makeSUT()
        let url = try APIEndpoint.characterDetail(id: 1).urlRequest().url!
        
        URLProtocolMock.data = Data()
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)
    
        var isExpectedError = false
        
        do {
            let publisher = sut.request(.characterDetail(id: 1), responseType: DecodableTestResponse.self)
            
            var iterator = publisher.values.makeAsyncIterator()
            _ = try await iterator.next()
        } catch {
            if case APIClientError.statusCode(404) = error {
                isExpectedError = true
            }
        }
        
        URLProtocolMock.reset()
        
        #expect(isExpectedError)
    }
    
    @MainActor
    @Test func WhenImageIsCached_ThenFetchImageReturnsCachedImage() async throws {
        let cache = ImageDiskCache(folderName: "ImageDiskCacheTests")
        
        let imageURL = "https://rickandmortyapi.com/api/character/avatar/1.jpeg"
        let imageData = makeImageData()
        
        cache.save(imageData, forKey: imageURL)
        
        let sut = makeSUT(imageCache: cache)
        
        let publisher = sut.fetchImage(from: imageURL)
        var iterator = publisher.values.makeAsyncIterator()
        let image = try await iterator.next()
        
        #expect(image != nil)
    }
    
    private func makeSUT(imageCache: ImageDiskCache = ImageDiskCache(folderName: "ImageDiskCacheTests")) -> URLSessionAPIClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        
        let session = URLSession(configuration: configuration)
        
        return URLSessionAPIClient(session: session, imageCache: imageCache)
    }
    
    private func makeImageData() -> Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        
        let image = renderer.image { context in
            UIColor.black.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        
        return image.pngData() ?? Data()
    }
}

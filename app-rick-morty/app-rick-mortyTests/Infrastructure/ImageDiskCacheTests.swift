//
//  ImageDiskCacheTests.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 27/5/26.
//

import Foundation
import Testing
@testable import app_rick_morty

struct ImageDiskCacheTests {
    
    @Test func WhenImageDataIsSaved_ThenCanBeLoaded() {
        let sut = ImageDiskCache(folderName: "ImageDiskCacheTests")
        
        let data = Data([1, 2, 3])
        
        sut.save(data, forKey: "image")
        
        #expect(sut.data(forKey: "image") == data)
    }
    
    @Test func WhenImageIsNotSaved_ThenNilIsReturned() {
        let sut = ImageDiskCache(folderName: "ImageDiskCacheTests")
        
        #expect(sut.data(forKey: "missing-image") == nil)
    }
}

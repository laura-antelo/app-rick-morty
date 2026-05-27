//
//  DiskCacheTests.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 27/5/26.
//

import Foundation
import Testing
@testable import app_rick_morty

private struct CacheTestValue: Codable {
    let id: Int
    let name: String
}

struct DiskCacheTests {
    
    @Test func WhenValueIsSaved_ThenCanBeLoad() {
        let sut = DiskCache(folderName: "DiskCacheTests")
        
        sut.save(CacheTestValue(id: 1, name: "Rick"), forKey: "character")
        
        let value = sut.load(CacheTestValue.self, forKey: "character")
        
        #expect(value?.id == 1)
    }
    
    @Test func WhenValueIsNotSaved_ThenNilIsReturned() {
        let sut = DiskCache(folderName: "DiskCacheTests")
        
        let value = sut.load(CacheTestValue.self, forKey: "missing")
        
        #expect(value == nil)
    }
}

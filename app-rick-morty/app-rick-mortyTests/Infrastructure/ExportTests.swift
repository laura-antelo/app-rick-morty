//
//  ExportTests.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 27/5/26.
//

import Foundation
import Testing
@testable import app_rick_morty

struct ExportTests {
    
    @Test func WhenCharacterExportTextIsBuilt_ThenContainsCharacterName() throws {
        let sut = DetailExportTextBuilder()
        
        let text = sut.makeText(for: TestRickAndMortyData.character)
        
        #expect(text.contains("Rick Sanchez"))
    }
    
    @Test func WhenLocationExportTextIsBuilt_ThenContainsLocationName() throws {
        let sut = DetailExportTextBuilder()
        
        let text = sut.makeText(for: TestRickAndMortyData.location)
        
        #expect(text.contains("Earth"))
    }
    
    @Test func WhenEpisodeExportTextIsBuilt_ThenContainsEpisodeName() throws {
        let sut = DetailExportTextBuilder()
        
        let text = sut.makeText(for: TestRickAndMortyData.episode)
        
        #expect(text.contains("Pilot"))
    }
}

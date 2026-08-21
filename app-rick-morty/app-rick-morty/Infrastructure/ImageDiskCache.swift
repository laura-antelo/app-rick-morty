//
//  ImageDiskCache.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 26/5/26.
//

import Foundation

final class ImageDiskCache {
    
    static let shared = ImageDiskCache()
    
    private let fileManager: FileManager
    private let directoryURL: URL
    
    init(fileManager: FileManager = .default, folderName: String = "RickAndMortyImageCache") {
        self.fileManager = fileManager
        
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        
        self.directoryURL = cacheDirectory.appendingPathComponent(folderName, isDirectory: true)
        
        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }
    
    func data(forKey key: String) -> Data? {
        let fileURL = directoryURL.appendingPathComponent(safeFileName(key), isDirectory: false)
        
        return try? Data(contentsOf: fileURL)
    }
    
    func save(_ data: Data, forKey key: String) {
        let fileURL = directoryURL.appendingPathComponent(safeFileName(key), isDirectory: false)
        
        try? data.write(to: fileURL, options: .atomic)
    }
    
    private func safeFileName(_ key: String) -> String {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        
        let cleanedKey = key
            .components(separatedBy: allowedCharacters.inverted)
            .joined(separator: "_")
        
        return "\(cleanedKey).json"
    }
}

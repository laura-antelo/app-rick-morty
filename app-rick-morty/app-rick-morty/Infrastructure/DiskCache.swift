//
//  DiskCache.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 26/5/26.
//

import Foundation

final class DiskCache {
    
    static let shared = DiskCache()
    
    private let fileManager: FileManager
    private let directoryURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(fileManager: FileManager = .default, folderName: String = "RickAndMortyCache") {
        self.fileManager = fileManager
        
        let baseURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        
        self.directoryURL = baseURL.appendingPathComponent(folderName, isDirectory: true)
        
        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }
    
    func save<T: Encodable>(_ value: T, forKey key: String) {
        let fileURL = directoryURL.appendingPathComponent(safeFileName(key))
        
        guard let data = try? encoder.encode(value) else { return }
        
        try? data.write(to: fileURL, options: .atomic)
    }
    
    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        let fileURL = directoryURL.appendingPathComponent(safeFileName(key))
        
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        
        return try? decoder.decode(type, from: data)
    }
    
    private func safeFileName(_ key: String) -> String {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        
        let cleanedKey = key
            .components(separatedBy: allowedCharacters.inverted)
            .joined(separator: "_")
        
        return "\(cleanedKey).json"
    }
    
}

struct CachedPaginatedResult<Item: Codable>: Codable {
    let items: [Item]
    let hasNextPage: Bool
}

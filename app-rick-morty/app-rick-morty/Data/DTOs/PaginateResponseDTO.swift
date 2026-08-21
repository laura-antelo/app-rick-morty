//
//  PaginateResponseDTO.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation

struct ResponseDTO<T: Decodable>: Decodable {
    let info: PageInfoDTO
    let results: [T]
}

struct PageInfoDTO: Decodable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}

struct PaginatedResult<Item> {
    let items: [Item]
    let hasNextPage: Bool
}

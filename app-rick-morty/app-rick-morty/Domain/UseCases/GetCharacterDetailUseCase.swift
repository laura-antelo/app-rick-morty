//
//  GetCharacterDetailUseCase.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation
import Combine

protocol GetCharacterDetailUseCase {
    func execute(id: Int) -> AnyPublisher<Character, Error>
}

final class DefaultGetCharacterDetailUseCase: GetCharacterDetailUseCase {
    private let repository: CharacterRepository
    
    init(repository: CharacterRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) -> AnyPublisher<Character, any Error> {
        return repository.getCharacterDetail(id: id)
    }
}

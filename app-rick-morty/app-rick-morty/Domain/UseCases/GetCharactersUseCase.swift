//
//  GetCharactersUseCase.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 13/5/26.
//

import Foundation
import Combine

protocol GetCharactersUseCase {
    func execute(page: Int?, name: String?) -> AnyPublisher<[Character], Error>
}

final class DefaultGetCharactersUseCase: GetCharactersUseCase {
    private let repository: CharacterRepository
    
    init(repository: CharacterRepository) {
        self.repository = repository
    }
    
    func execute(page: Int?, name: String?) -> AnyPublisher<[Character], any Error> {
        return repository.getCharacters(page: page, name: name)
    }
}

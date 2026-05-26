//
//  DetailExportTextBuilder.swift
//  app-rick-morty
//
//  Created by Laura Antelo Gonzalez on 25/5/26.
//

import Foundation

final class DetailExportTextBuilder {
    
    func makeText(for character: Character) -> String {
        return """
        Detalle del personaje
        
        Nombre: \(character.name)
        Género: \(character.gender)
        Estado: \(statusText(character.status))
        Especie: \(character.species)
        Tipo: \(character.type.isEmpty ? "Sin tipo" : character.type)
        Origen: \(character.origin.name)
        Última ubicación: \(character.location.name)
        Episodios: \(character.episodeIds.count)
        """
    }
    
    func makeText(for location: Location) -> String {
        return """
            Detalle de la ubicación
            
            Nombre: \(location.name)
            Tipo: \(location.type)
            Dimensión: \(location.dimension)
            Residentes: \(location.residentsIds.count)
            """
    }
    
    func makeText(for episode: Episode) -> String {
        return """
            Detalle del episodio
            
            Nombre: \(episode.name)
            Código: \(episode.code)
            Fecha de emisión: \(episode.airDate)
            Personajes: \(episode.charactersIds.count)
            """
    }
    
    private func statusText(_ status: CharacterStatus) -> String {
        switch status {
        case .alive:
            return "Vivo"
        case .dead:
            return "Muerto"
        case .unknown:
            return "Desconocido"
        }
    }
}

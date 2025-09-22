//
//  CharacterDetailPresenter.swift
//  RickyAndMortyUIKit
//
//  Created by Pablo on 22/9/25.
//

import Foundation

protocol CharacterDetailDisplayLogic: AnyObject {
    func setLoading(_ loading: Bool)
    func display(viewModel: CharacterDetailViewModel)
    func displayError(_ message: String)
    func setupView()
}

class CharacterDetailPresenter: CharacterDetailPresenterLogic {
    
    weak var view: CharacterDetailDisplayLogic?
    
    private let repository: RickyAndMortyCharactersRepositoryProtocol
    private let character: Character
    
    init(character: Character,
         repository: RickyAndMortyCharactersRepositoryProtocol = RickyAndMortyCharactersRepository()) {
        self.character = character
        self.repository = repository
    }
    
    func setupView() {
        view?.setLoading(true)
        view?.setupView()
        
        // Montamos el VM base (sin episodio aún)
        var rows: [(String, String)] = [
            ("Status", character.status),
            ("Species", character.species),
        ]
        if !character.type.isEmpty {
            rows.append(("Type", character.type))
        }
        rows.append(contentsOf: [
            ("Gender", character.gender),
            ("Origin", character.origin.name),
            ("Last known location", character.location.name)
        ])
        
        let baseVM = CharacterDetailViewModel(
            title: character.name,
            imageURL: URL(string: character.image),
            rows: rows
        )
        
        view?.display(viewModel: baseVM)
        
        // Cargar datos extra en paralelo (p. ej. primer episodio)
        Task {
            guard let firstEpURLString = character.episode.first,
                  let firstEpURL = URL(string: firstEpURLString) else {
                return
            }
            do {
                // llamada a repo
                let episode = try await repository.fetchEpisode(url: firstEpURL)
                var enrichedRows = baseVM.rows
                enrichedRows.insert(("First episode", "\(episode.episode) — \(episode.name)"), at: 1)
                
                let enrichedVM = CharacterDetailViewModel(
                    title: baseVM.title,
                    imageURL: baseVM.imageURL,
                    rows: enrichedRows
                )
                
                await MainActor.run {
                    self.view?.display(viewModel: enrichedVM)
                }
            } catch {
                await MainActor.run {
                    self.view?.displayError(error.localizedDescription)
                }
            }
            await MainActor.run { self.view?.setLoading(false) }
        }
    }
}

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
        
        let subtitleComponents = [
            character.species,
            character.type.isEmpty ? nil : character.type,
            character.gender
        ].compactMap { $0 }.filter { !$0.isEmpty }
        
        let baseVM = CharacterDetailViewModel(
            title: character.name,
            subtitle: subtitleComponents.joined(separator: " • "),
            status: character.status,
            locationTitle: "Last known location",
            locationValue: character.location.name,
            imageURL: URL(string: character.image),
            rows: rows
        )
        
        view?.display(viewModel: baseVM)
        
        Task {
            guard let firstEpURLString = character.episode.first,
                  let firstEpURL = URL(string: firstEpURLString) else {
                return
            }
            do {
                let episode = try await repository.fetchEpisode(url: firstEpURL)
                var enrichedRows = baseVM.rows
                enrichedRows.insert(("First episode", "\(episode.episode) — \(episode.name)"), at: 1)
                
                let enrichedVM = CharacterDetailViewModel(
                    title: baseVM.title,
                    subtitle: baseVM.subtitle,
                    status: baseVM.status,
                    locationTitle: baseVM.locationTitle,
                    locationValue: baseVM.locationValue,
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

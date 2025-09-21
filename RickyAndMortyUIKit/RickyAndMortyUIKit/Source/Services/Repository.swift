//
//  Repository.swift
//  RickyAndMortyUIKit
//
//  Created by Pablo on 20/9/25.
//

import Foundation

protocol RickyAndMortyCharactersRepositoryProtocol {
    func listCharacters(page: Int?, name: String?) async throws -> PaginatedResponse<Character>
    func fetchCharacter(url: URL) async throws -> Character
    func fetchLocation(url: URL) async throws -> Location
    func fetchEpisode(url: URL) async throws -> Episode
    func fetchCharacters(ids: [Int]) async throws -> [Character]
}

struct RickyAndMortyCharactersRepository: RickyAndMortyCharactersRepositoryProtocol {
    
    private let base = URL(string: "https://rickandmortyapi.com/api/")!
    private let repository: Networking
    
    init(client: Networking = RickyAndMortyApiManager()) {
        self.repository = client
    }
    
    func listCharacters(page: Int? = nil, name: String? = nil) async throws -> PaginatedResponse<Character> {
        var components = URLComponents(url: base.appending(path: "character"), resolvingAgainstBaseURL: false)!
        var queryItems: [URLQueryItem] = []
        if let page { queryItems.append(URLQueryItem(name: "page", value: String(page))) }
        if let name, !name.isEmpty { queryItems.append(URLQueryItem(name: "name", value: name)) }
        if !queryItems.isEmpty { components.queryItems = queryItems }
        guard let url = components.url else { throw APIError.invalidURL }
        return try await repository.fetch(url)
    }
    
    func fetchCharacters(ids: [Int]) async throws -> [Character] {
        guard !ids.isEmpty else { return [] }
        let path = "character/\(ids.map(String.init).joined(separator: ","))"
        let url = base.appending(path: path)
        
        struct OneOrMany: Decodable {
            let many: [Character]
            init(from decoder: Decoder) throws {
                let c = try decoder.singleValueContainer()
                if let arr = try? c.decode([Character].self) { many = arr }
                else if let one = try? c.decode(Character.self) { many = [one] }
                else { many = [] }
            }
        }
        
        let wrapped: OneOrMany = try await repository.fetch(url)
        return wrapped.many
    }
    
    func fetchCharacter(url: URL) async throws -> Character { try await repository.fetch(url) }
    
    func fetchLocation(url: URL) async throws -> Location { try await repository.fetch(url) }
    
    func fetchEpisode(url: URL) async throws -> Episode { try await repository.fetch(url) }
}

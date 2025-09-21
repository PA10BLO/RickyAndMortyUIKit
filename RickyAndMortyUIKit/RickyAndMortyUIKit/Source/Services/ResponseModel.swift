//
//  ResponseModel.swift
//  RickyAndMortyUIKit
//
//  Created by Pablo on 20/9/25.
//

struct PageInfo: Decodable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}

struct PaginatedResponse<T: Decodable>: Decodable {
    let info: PageInfo
    let results: [T]
}

struct Character: Identifiable, Decodable, Equatable, Hashable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: LocationRef
    let location: LocationRef
    let image: String
    let episode: [String]
    let url: String
    let created: String

    struct LocationRef: Decodable, Equatable, Hashable {
        let name: String
        let url: String
    }
}

struct Location: Identifiable, Decodable, Equatable, Hashable {
    let id: Int
    let name: String
    let type: String
    let dimension: String
    let residents: [String]
    let url: String
    let created: String
}

struct Episode: Identifiable, Decodable, Equatable, Hashable {
    let id: Int
    let name: String
    let air_date: String
    let episode: String
    let characters: [String]
    let url: String
    let created: String
}

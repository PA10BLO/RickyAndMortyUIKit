//
//  RickyAndMortyUIKitTests.swift
//  RickyAndMortyUIKitTests
//
//  Created by Pablo on 20/9/25.
//

import XCTest
@testable import RickyAndMortyUIKit

class CharacterDetailPresenterTests: XCTestCase {
    
    enum TestError: Error {
        case stub
    }
    
    func testSetupViewWithEpisodeEnrichesViewModel() {
        let character = makeCharacter(episodes: ["https://example.com/api/episode/1"])
        let episode = Episode(
            id: 1,
            name: "Pilot",
            air_date: "December 2, 2013",
            episode: "S01E01",
            characters: [],
            url: "https://example.com/api/episode/1",
            created: "2017-11-10T12:56:33.798Z"
        )
        let repository = StubCharactersRepository(result: .success(episode))
        let presenter = CharacterDetailPresenter(character: character, repository: repository)
        let view = MockCharacterDetailView()
        
        let viewModelsExpectation = expectation(description: "Receives enriched view model")
        view.expectedViewModelCount = 2
        view.viewModelExpectation = viewModelsExpectation
        
        let loadingExpectation = expectation(description: "Stops loading after fetching episode")
        view.loadingExpectation = loadingExpectation
        
        presenter.view = view
        presenter.setupView()
        
        wait(for: [viewModelsExpectation, loadingExpectation], timeout: 1.0)
        
        XCTAssertTrue(view.setupViewCalled)
        XCTAssertEqual(view.loadingStates, [true, false])
        XCTAssertEqual(view.viewModels.count, 2)
        
        let baseModel = view.viewModels[0]
        XCTAssertEqual(baseModel.rows.count, 6)
        
        let enrichedModel = view.viewModels[1]
        XCTAssertEqual(enrichedModel.rows[1].title, "First episode")
        XCTAssertTrue(enrichedModel.rows[1].value.contains(episode.name))
        XCTAssertTrue(view.errorMessages.isEmpty)
    }
    
    func testSetupViewWithoutEpisodesStopsLoadingAndKeepsBaseRows() {
        let character = makeCharacter(episodes: [], type: "")
        let repository = StubCharactersRepository(result: .failure(TestError.stub))
        let presenter = CharacterDetailPresenter(character: character, repository: repository)
        let view = MockCharacterDetailView()
        
        view.expectedViewModelCount = 1
        presenter.view = view
        presenter.setupView()
        
        XCTAssertEqual(view.viewModels.count, 1)
        XCTAssertEqual(view.loadingStates, [true])
        XCTAssertTrue(view.errorMessages.isEmpty)
    }
    
    func testSetupViewWithEpisodeFailureNotifiesError() {
        let character = makeCharacter(episodes: ["https://example.com/api/episode/2"])
        let repository = StubCharactersRepository(result: .failure(TestError.stub))
        let presenter = CharacterDetailPresenter(character: character, repository: repository)
        let view = MockCharacterDetailView()
        
        let viewModelExpectation = expectation(description: "Receives base view model even on failure")
        view.expectedViewModelCount = 1
        view.viewModelExpectation = viewModelExpectation
        
        let loadingExpectation = expectation(description: "Stops loading after failure")
        view.loadingExpectation = loadingExpectation
        
        let errorExpectation = expectation(description: "Displays error message")
        view.errorExpectation = errorExpectation
        
        presenter.view = view
        presenter.setupView()
        
        wait(for: [viewModelExpectation, loadingExpectation, errorExpectation], timeout: 1.0)
        
        XCTAssertEqual(view.viewModels.count, 1)
        XCTAssertEqual(view.loadingStates, [true, false])
        XCTAssertEqual(view.errorMessages.count, 1)
    }
}

private extension CharacterDetailPresenterTests {
    func makeCharacter(episodes: [String], type: String = "Scientist") -> Character {
        Character(
            id: 1,
            name: "Rick Sanchez",
            status: "Alive",
            species: "Human",
            type: type,
            gender: "Male",
            origin: .init(name: "Earth (C-137)", url: "https://example.com/api/location/1"),
            location: .init(name: "Citadel of Ricks", url: "https://example.com/api/location/3"),
            image: "https://example.com/api/character/avatar/1.jpeg",
            episode: episodes,
            url: "https://example.com/api/character/1",
            created: "2017-11-04T18:48:46.250Z"
        )
    }
    
    private final class MockCharacterDetailView: CharacterDetailDisplayLogic {
        private(set) var loadingStates: [Bool] = []
        private(set) var viewModels: [CharacterDetailViewModel] = []
        private(set) var errorMessages: [String] = []
        private(set) var setupViewCalled = false
        
        var loadingExpectation: XCTestExpectation?
        var viewModelExpectation: XCTestExpectation?
        var errorExpectation: XCTestExpectation?
        var expectedViewModelCount = 0
        
        func setLoading(_ loading: Bool) {
            loadingStates.append(loading)
            if !loading {
                loadingExpectation?.fulfill()
            }
        }
        
        func display(viewModel: CharacterDetailViewModel) {
            viewModels.append(viewModel)
            if expectedViewModelCount > 0, viewModels.count == expectedViewModelCount {
                viewModelExpectation?.fulfill()
            }
        }
        
        func displayError(_ message: String) {
            errorMessages.append(message)
            errorExpectation?.fulfill()
        }
        
        func setupView() {
            setupViewCalled = true
        }
    }
    
    private final class StubCharactersRepository: RickyAndMortyCharactersRepositoryProtocol {
        private let result: Result<Episode, Error>
        
        init(result: Result<Episode, Error>) {
            self.result = result
        }
        
        func listCharacters(page: Int?, name: String?) async throws -> PaginatedResponse<Character> {
            throw CharacterDetailPresenterTests.TestError.stub
        }
        
        func fetchCharacter(url: URL) async throws -> Character {
            throw CharacterDetailPresenterTests.TestError.stub
        }
        
        func fetchLocation(url: URL) async throws -> Location {
            throw CharacterDetailPresenterTests.TestError.stub
        }
        
        func fetchEpisode(url: URL) async throws -> Episode {
            switch result {
            case .success(let episode):
                return episode
            case .failure(let error):
                throw error
            }
        }
        
        func fetchCharacters(ids: [Int]) async throws -> [Character] {
            throw CharacterDetailPresenterTests.TestError.stub
        }
    }
}

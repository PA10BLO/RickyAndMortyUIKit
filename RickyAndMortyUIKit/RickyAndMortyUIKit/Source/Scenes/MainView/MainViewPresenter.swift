//
//  MainViewPresenter.swift
//  RickyAndMortyUIKit
//
//  Created by Pablo on 20/9/25.
//

protocol MainViewDisplayLogic: AnyObject {
    func setupView()
    func display(characters: [Character])
    func displayError(_ message: String)
}

class MainViewPresenter: MainViewPresenterLogic {

    weak var view: MainViewDisplayLogic?

    private let repository: RickyAndMortyCharactersRepositoryProtocol
    private var currentPage = 1
    private var totalPages = 1
    private var isFetching = false
    private var lastQuery: String?

    private var accumulated: [Character] = []   // <- NUEVO

    init(repository: RickyAndMortyCharactersRepositoryProtocol = RickyAndMortyCharactersRepository()) {
        self.repository = repository
    }

    func setupView() {
        view?.setupView()
        fetch(page: 1, query: nil, reset: true)
    }

    func loadInitial() {
        currentPage = 1
        fetch(page: currentPage, query: lastQuery, reset: true)
    }

    func loadNextPage() {
        guard !isFetching, currentPage < totalPages else { return }
        fetch(page: currentPage + 1, query: lastQuery, reset: false)
    }

    func search(name: String?) {
        lastQuery = (name?.isEmpty == false) ? name : nil
        currentPage = 1
        fetch(page: 1, query: lastQuery, reset: true)
    }

    private func fetch(page: Int, query: String?, reset: Bool) {
        guard !isFetching else { return }
        isFetching = true

        Task {
            do {
                let pageResp = try await repository.listCharacters(page: page, name: query)
                totalPages = pageResp.info.pages
                let items = pageResp.results

                if reset {
                    accumulated = items
                } else {
                    accumulated.append(contentsOf: items)
                }
                currentPage = page

                await MainActor.run {
                    self.view?.display(characters: self.accumulated)
                    self.isFetching = false
                }
            } catch {
                await MainActor.run {
                    self.view?.displayError(error.localizedDescription)
                    self.isFetching = false
                }
            }
        }
    }
}

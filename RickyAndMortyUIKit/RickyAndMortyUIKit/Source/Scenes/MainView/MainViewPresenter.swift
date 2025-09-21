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
    
    init(repository: RickyAndMortyCharactersRepositoryProtocol = RickyAndMortyCharactersRepository()) {
        self.repository = repository
    }
    
    func setupView() {
        view?.setupView()
        fetch(page: 1, query: nil)
    }
    
    func loadInitial() {
        currentPage = 1
        fetch(page: currentPage, query: lastQuery)
    }
    
    func loadNextPage() {
        guard !isFetching, currentPage < totalPages else { return }
        fetch(page: currentPage + 1, query: lastQuery)
    }
    
    
    func search(name: String?) {
        lastQuery = (name?.isEmpty == false) ? name : nil
        currentPage = 1
        fetch(page: 1,
              query: lastQuery)
    }
    
    private func fetch(page: Int, query: String?) {
        guard !isFetching else { return }
        isFetching = true
        
        Task {
            do {
                let pageResp = try await repository.listCharacters(page: page, name: query)
                totalPages = pageResp.info.pages
                let items = pageResp.results
                await MainActor.run {
                    self.view?.display(characters: items)
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

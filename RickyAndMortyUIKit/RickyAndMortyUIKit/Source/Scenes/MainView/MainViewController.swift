//
//  ViewController.swift
//  RickyAndMortyUIKit
//
//  Created by Pablo on 20/9/25.
//

import UIKit

protocol MainViewPresenterLogic {
    func setupView()
    func loadInitial()
    func search(name: String?)
    func loadNextPage()
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contentContainer: UIView!
    let tableView = UITableView()
    var presenter: MainViewPresenterLogic?
    private var characters: [Character] = []
    
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "Sin resultados"
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.isHidden = true
        return l
    }()
    
    func setupScene() {
        let viewController = self
        let setupPresenter = MainViewPresenter()
        setupPresenter.view = viewController
        presenter = setupPresenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.setupView()
    }
}

extension MainViewController: MainViewDisplayLogic {
    
    func setupView() {
        title = "Rick & Morty"
        view.backgroundColor = .systemBackground
        
        searchBar.searchBarStyle = .minimal
        searchBar.isTranslucent = true
        searchBar.delegate = self
        
        setupTableView()
    }
    
    func display(characters: [Character]) {
        self.characters = characters
        emptyLabel.isHidden = !characters.isEmpty
        tableView.reloadData()
    }
    
    func displayError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: "CharacterCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = 65
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        contentContainer.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell", for: indexPath) as? UserTableViewCell
        else { return UITableViewCell() }
        
        let character = characters[indexPath.row]
        cell.configure(with: character)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let character = characters[indexPath.row]
        let vc = CharacterDetailViewController(character: character)
        if let navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            present(vc, animated: true)
        }
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        debounceSearch(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter?.search(name: searchBar.text)
        searchBar.resignFirstResponder()
    }
    
    private static var pendingWorkItem: DispatchWorkItem?
    
    private func debounceSearch(_ text: String) {
        MainViewController.pendingWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.presenter?.search(name: text)
        }
        MainViewController.pendingWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: work)
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        if offsetY > contentHeight - height * 1.5 {
            presenter?.loadNextPage()
        }
    }
}

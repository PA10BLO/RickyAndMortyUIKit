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
    @IBOutlet weak var contentTableView: UIStackView!
    let tableView = UITableView()
    var presenter: MainViewPresenterLogic?
    private var characters: [Character] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewController = self
        let setupPresenter = MainViewPresenter()
        
        setupPresenter.view = viewController
        presenter = setupPresenter
        presenter?.setupView()
    }
    
    
}


extension MainViewController: MainViewDisplayLogic {
    
    func setupView() {
        setupComponents()
    }
    
    func display(characters: [Character]) {
        self.characters = characters
        tableView.reloadData()
    }
    
    func displayError(_ message: String) {
        // Presenta una alerta sencilla
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupComponents() {
        searchBar.searchBarStyle = .minimal
        searchBar.isTranslucent = true
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UserTableViewCell.self,
                           forCellReuseIdentifier: "CharacterCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = 65
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.translatesAutoresizingMaskIntoConstraints = false
        contentTableView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: contentTableView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentTableView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentTableView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentTableView.bottomAnchor)
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
        // Navegar a detalle si quieres
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Búsqueda live. Puedes añadir debounce si lo prefieres.
        presenter?.search(name: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter?.search(name: searchBar.text)
        searchBar.resignFirstResponder()
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        // Cuando nos acercamos al final (último 1.5 pantallas de altura)
        if offsetY > contentHeight - height * 1.5 {
            presenter?.loadNextPage()
        }
    }
}

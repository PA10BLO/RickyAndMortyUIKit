//
//  CharacterDetailViewController.swift
//  RickyAndMortyUIKit
//
//  Created by Pablo on 22/9/25.
//

// CharacterDetailViewController.swift

import UIKit

protocol CharacterDetailPresenterLogic {
    func setupView()
}

struct CharacterDetailViewModel {
    let title: String
    let imageURL: URL?
    let rows: [(title: String, value: String)]
}

class CharacterDetailViewController: UIViewController {
    private let character: Character
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let infoStack = UIStackView()
    var presenter: CharacterDetailPresenterLogic?
    private let spinner = UIActivityIndicatorView(style: .large)
    
    init(character: Character) {
        self.character = character
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let setupPresenter = CharacterDetailPresenter(character: character)
        setupPresenter.view = self
        presenter = setupPresenter
        presenter?.setupView()
    }
}

extension CharacterDetailViewController: CharacterDetailDisplayLogic {
    
    func setupView() {
        
        
        view.backgroundColor = .systemBackground
        title = character.name
        bind()
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.font = .systemFont(ofSize: 28, weight: .bold)
        nameLabel.numberOfLines = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        infoStack.axis = .vertical
        infoStack.spacing = 8
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(infoStack)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.75),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            infoStack.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            infoStack.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            infoStack.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
    
    private func bind() {
        if let url = URL(string: character.image) {
            ImageLoader.shared.load(url: url) { [weak self] img in self?.imageView.image = img }
        }
        nameLabel.text = character.name
        addRow(title: "Status", value: character.status)
        addRow(title: "Species", value: character.species)
        if !character.type.isEmpty { addRow(title: "Type", value: character.type) }
        addRow(title: "Gender", value: character.gender)
        addRow(title: "Origin", value: character.origin.name)
        addRow(title: "Last known location", value: character.location.name)
    }
    
    private func addRow(title: String, value: String) {
        let t = UILabel(); t.font = .systemFont(ofSize: 14, weight: .semibold); t.text = title
        let v = UILabel(); v.font = .systemFont(ofSize: 16); v.numberOfLines = 0; v.text = value
        let stack = UIStackView(arrangedSubviews: [t, v])
        stack.axis = .vertical
        stack.spacing = 2
        infoStack.addArrangedSubview(stack)
    }
    
    func setLoading(_ loading: Bool) {
        loading ? spinner.startAnimating() : spinner.stopAnimating()
    }
    
    func display(viewModel: CharacterDetailViewModel) {
        title = viewModel.title
        nameLabel.text = viewModel.title
        
        if let url = viewModel.imageURL {
            ImageLoader.shared.load(url: url) { [weak self] img in self?.imageView.image = img }
        } else {
            imageView.image = UIImage(systemName: "person.crop.square")
        }
        
        // refrescar filas
        infoStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for row in viewModel.rows {
            addRow(title: row.title, value: row.value)
        }
    }
    
    func displayError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

//
//  CharacterTableViewCell.swift
//  RickyAndMortyUIKit
//
//  Created by Pablo on 20/9/25.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    private let containerView = UIView()
    let characterImageView = UIImageView()
    let nameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle,reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        containerView.backgroundColor = .clear
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.2
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        
        characterImageView.layer.cornerRadius = 25
        characterImageView.layer.borderWidth = 1
        characterImageView.layer.borderColor = UIColor.systemGray.cgColor
        characterImageView.clipsToBounds = true
        characterImageView.contentMode = .scaleAspectFill
        characterImageView.image = UIImage(systemName: "person.circle")
        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.font = .boldSystemFont(ofSize: 17)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(characterImageView)
        containerView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            characterImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            characterImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            characterImageView.widthAnchor.constraint(equalToConstant: 50),
            characterImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.leadingAnchor.constraint(equalTo: characterImageView.trailingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    func configure(with character: Character) {
        nameLabel.text = character.name
        if let url = URL(string: character.image) {
            ImageLoader.shared.load(url: url) { [weak self] image in
                guard let self else { return }
                self.characterImageView.image = image ?? UIImage(systemName: "person.circle")
            }
        } else {
            characterImageView.image = UIImage(systemName: "person.circle")
        }
    }
}

final class ImageLoader {
    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, UIImage>()
    private let session: URLSession

    private init(session: URLSession = .shared) {
        self.session = session
    }

    func load(url: URL, completion: @escaping (UIImage?) -> Void) {
        let key = url as NSURL
        if let cached = cache.object(forKey: key) {
            completion(cached)
            return
        }
        Task {
            do {
                let (data, _) = try await session.data(from: url)
                let img = UIImage(data: data)
                if let img { cache.setObject(img, forKey: key) }
                await MainActor.run { completion(img) }
            } catch {
                await MainActor.run { completion(nil) }
            }
        }
    }
}

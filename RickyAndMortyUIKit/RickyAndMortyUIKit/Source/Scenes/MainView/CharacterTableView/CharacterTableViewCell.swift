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
    private let statusDot = UIView()
    
    override init(style: UITableViewCell.CellStyle,reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        characterImageView.image = UIImage(systemName: "person.circle")
        nameLabel.text = nil
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowRadius = 6
        containerView.layer.shadowOffset = .init(width: 0, height: 2)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        characterImageView.layer.cornerRadius = 25
        characterImageView.layer.borderWidth = 1
        characterImageView.layer.borderColor = UIColor.systemGray5.cgColor
        characterImageView.clipsToBounds = true
        characterImageView.contentMode = .scaleAspectFill
        characterImageView.image = UIImage(systemName: "person.circle")
        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.font = .boldSystemFont(ofSize: 17)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        statusDot.layer.cornerRadius = 6
        statusDot.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(characterImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(statusDot)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            characterImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            characterImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            characterImageView.widthAnchor.constraint(equalToConstant: 50),
            characterImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.leadingAnchor.constraint(equalTo: characterImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            statusDot.widthAnchor.constraint(equalToConstant: 12),
            statusDot.heightAnchor.constraint(equalToConstant: 12),
            statusDot.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            statusDot.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    func configure(with character: Character) {
        nameLabel.text = character.name
        let status = character.status.lowercased()
        if status == "alive" { statusDot.backgroundColor = .systemGreen }
        else if status == "dead" { statusDot.backgroundColor = .systemRed }
        else { statusDot.backgroundColor = .systemGray2 }
        
        if let url = URL(string: character.image) {
            ImageLoader.shared.load(url: url) { [weak self] image in
                self?.characterImageView.image = image ?? UIImage(systemName: "person.circle")
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

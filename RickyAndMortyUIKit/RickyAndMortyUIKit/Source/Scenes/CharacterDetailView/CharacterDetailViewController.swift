
//
//  CharacterDetailViewController.swift
//  RickyAndMortyUIKit
//
//  Created by Pablo on 22/9/25.
//

import UIKit

protocol CharacterDetailPresenterLogic {
    func setupView()
}

struct CharacterDetailViewModel {
    let title: String
    let subtitle: String
    let status: String
    let locationTitle: String
    let locationValue: String
    let imageURL: URL?
    let rows: [(title: String, value: String)]
}

class CharacterDetailViewController: UIViewController {
    private let character: Character
    private let imageView = UIImageView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStack = UIStackView()
    private let headerContainer = UIView()
    private let headerImageView = UIImageView()
    private let headerOverlay = UIView()
    private let headerGradientLayer = CAGradientLayer()
    private let headerInfoStack = UIStackView()
    private let statusBadge = InsetLabel(insets: UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12))
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let locationTitleLabel = UILabel()
    private let locationValueLabel = UILabel()
    private let infoTitleLabel = UILabel()
    private let infoCardView = UIView()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer.frame = headerOverlay.bounds
        infoCardView.layer.shadowPath = UIBezierPath(roundedRect: infoCardView.bounds,
                                                     cornerRadius: infoCardView.layer.cornerRadius).cgPath
    }
}

extension CharacterDetailViewController: CharacterDetailDisplayLogic {
    
    func setupView() {
        view.backgroundColor = .systemBackground
        title = character.name
        
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
        
        configureScrollView()
        configureHeader()
        configureInfoSection()
        configureSpinner()
    }
    
    func setLoading(_ loading: Bool) {
        if loading {
            spinner.startAnimating()
            if spinner.superview != nil {
                view.bringSubviewToFront(spinner)
            }
        } else {
            spinner.stopAnimating()
        }
    }
    
    func display(viewModel: CharacterDetailViewModel) {
        apply(viewModel: viewModel)
    }
    
    func displayError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .clear
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 24
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    private func configureHeader() {
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.layer.cornerRadius = 28
        headerContainer.layer.cornerCurve = .continuous
        headerContainer.clipsToBounds = true
        
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.backgroundColor = .tertiarySystemFill
        headerImageView.tintColor = .secondaryLabel
        
        headerOverlay.translatesAutoresizingMaskIntoConstraints = false
        headerOverlay.isUserInteractionEnabled = false
        headerGradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.75).cgColor]
        headerGradientLayer.locations = [0, 1]
        headerOverlay.layer.addSublayer(headerGradientLayer)
        
        headerInfoStack.translatesAutoresizingMaskIntoConstraints = false
        headerInfoStack.axis = .vertical
        headerInfoStack.spacing = 8
        headerInfoStack.alignment = .leading
        
        statusBadge.font = .systemFont(ofSize: 13, weight: .semibold)
        statusBadge.textColor = .white
        statusBadge.layer.cornerRadius = 14
        statusBadge.layer.cornerCurve = .continuous
        statusBadge.clipsToBounds = true
        statusBadge.text = character.status.uppercased()
        statusBadge.backgroundColor = color(forStatus: character.status)
        
        nameLabel.font = .systemFont(ofSize: 30, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 0
        
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        subtitleLabel.numberOfLines = 0
        let initialSubtitleComponents = [
            character.species,
            character.type.isEmpty ? nil : character.type,
            character.gender
        ].compactMap { $0 }.filter { !$0.isEmpty }
        subtitleLabel.text = initialSubtitleComponents.joined(separator: " • ")
        
        locationTitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        locationTitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        locationTitleLabel.text = "Last known location"
        
        locationValueLabel.font = .systemFont(ofSize: 16, weight: .regular)
        locationValueLabel.textColor = UIColor.white
        locationValueLabel.numberOfLines = 0
        locationValueLabel.text = character.location.name
        
        headerInfoStack.addArrangedSubview(statusBadge)
        headerInfoStack.addArrangedSubview(nameLabel)
        headerInfoStack.addArrangedSubview(subtitleLabel)
        headerInfoStack.addArrangedSubview(locationTitleLabel)
        headerInfoStack.addArrangedSubview(locationValueLabel)
        headerInfoStack.setCustomSpacing(12, after: nameLabel)
        headerInfoStack.setCustomSpacing(10, after: subtitleLabel)
        headerInfoStack.setCustomSpacing(4, after: locationTitleLabel)
        
        headerContainer.addSubview(headerImageView)
        headerContainer.addSubview(headerOverlay)
        headerOverlay.addSubview(headerInfoStack)
        
        NSLayoutConstraint.activate([
            headerImageView.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            headerImageView.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            
            headerOverlay.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            headerOverlay.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            headerOverlay.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            headerOverlay.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            
            headerInfoStack.leadingAnchor.constraint(equalTo: headerOverlay.leadingAnchor, constant: 20),
            headerInfoStack.trailingAnchor.constraint(equalTo: headerOverlay.trailingAnchor, constant: -20),
            headerInfoStack.bottomAnchor.constraint(equalTo: headerOverlay.bottomAnchor, constant: -20)
        ])
        
        headerContainer.heightAnchor.constraint(equalTo: headerContainer.widthAnchor, multiplier: 0.75).isActive = true
        
        contentStack.addArrangedSubview(headerContainer)
    }
    
    private func configureInfoSection() {
        infoTitleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        infoTitleLabel.textColor = .label
        infoTitleLabel.text = "Character Info"
        
        infoCardView.translatesAutoresizingMaskIntoConstraints = false
        infoCardView.backgroundColor = .secondarySystemBackground
        infoCardView.layer.cornerRadius = 24
        infoCardView.layer.cornerCurve = .continuous
        infoCardView.layer.shadowColor = UIColor.label.withAlphaComponent(0.08).cgColor
        infoCardView.layer.shadowOpacity = 0.12
        infoCardView.layer.shadowRadius = 18
        infoCardView.layer.shadowOffset = CGSize(width: 0, height: 12)
        
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.axis = .vertical
        infoStack.spacing = 0
        
        infoCardView.layoutMargins = UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20)
        infoCardView.addSubview(infoStack)
        
        NSLayoutConstraint.activate([
            infoStack.topAnchor.constraint(equalTo: infoCardView.layoutMarginsGuide.topAnchor),
            infoStack.leadingAnchor.constraint(equalTo: infoCardView.layoutMarginsGuide.leadingAnchor),
            infoStack.trailingAnchor.constraint(equalTo: infoCardView.layoutMarginsGuide.trailingAnchor),
            infoStack.bottomAnchor.constraint(equalTo: infoCardView.layoutMarginsGuide.bottomAnchor)
        ])
        
        contentStack.addArrangedSubview(infoTitleLabel)
        contentStack.addArrangedSubview(infoCardView)
        contentStack.setCustomSpacing(12, after: infoTitleLabel)
    }
    
    private func configureSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    private func apply(viewModel: CharacterDetailViewModel) {
        title = viewModel.title
        nameLabel.text = viewModel.title
        
        subtitleLabel.text = viewModel.subtitle
        subtitleLabel.isHidden = viewModel.subtitle.isEmpty
        locationTitleLabel.text = viewModel.locationTitle.uppercased()
        locationValueLabel.text = viewModel.locationValue
        configureStatusBadge(with: viewModel.status)
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.image = nil
        
        if let url = viewModel.imageURL {
            ImageLoader.shared.load(url: url) { [weak self] image in
                self?.headerImageView.contentMode = .scaleAspectFill
                self?.headerImageView.image = image
            }
        } else {
            headerImageView.image = UIImage(systemName: "person.crop.square")
            headerImageView.contentMode = .scaleAspectFit
        }
        infoStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for row in viewModel.rows {
            addRow(title: row.title, value: row.value)
        }
    }
    private func configureStatusBadge(with status: String) {
        let trimmed = status.trimmingCharacters(in: .whitespacesAndNewlines)
        statusBadge.isHidden = trimmed.isEmpty
        guard !trimmed.isEmpty else { return }
        statusBadge.text = trimmed.uppercased()
        statusBadge.backgroundColor = color(forStatus: trimmed)
    }
    
    private func addRow(title: String, value: String) {
        if !infoStack.arrangedSubviews.isEmpty {
            infoStack.addArrangedSubview(makeSeparator())
        }
        
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title.uppercased()
        
        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: 17, weight: .medium)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0
        valueLabel.text = value
        
        let container = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        container.axis = .vertical
        container.spacing = 6
        container.isLayoutMarginsRelativeArrangement = true
        container.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        infoStack.addArrangedSubview(container)
    }
    
    private func makeSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = UIColor.separator.withAlphaComponent(0.4)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
        return separator
    }
    
    private func color(forStatus status: String) -> UIColor {
        switch status.lowercased() {
            case "alive":
                return UIColor.systemGreen
            case "dead":
                return UIColor.systemRed
            default:
                return UIColor.systemGray
        }
    }
}

private final class InsetLabel: UILabel {
    private let insets: UIEdgeInsets
    
    init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let baseSize = super.intrinsicContentSize
        return CGSize(width: baseSize.width + insets.left + insets.right,
                      height: baseSize.height + insets.top + insets.bottom)
    }
}

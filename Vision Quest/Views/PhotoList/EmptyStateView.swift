//
//  EmptyStateView.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 08/04/26.
//

import UIKit

enum EmptyStateType {
    case settings
    case noPhotos
}

final class EmptyStateView: UIView {
    
    private let type: EmptyStateType

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var button: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .systemBlue
        
        let button = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
            guard self?.type == .settings else { return }
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(type: EmptyStateType) {
        self.type = type
        super.init(frame: .zero)
        setup()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setup() {
        addSubview(imageView)
        addSubview(label)
        addSubview(button)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -60),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configure() {
        switch type {
        case .settings:
            imageView.tintColor = .secondaryLabel
            let configSymbol = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
            imageView.preferredSymbolConfiguration = configSymbol
            imageView.image = UIImage(systemName: "photo.on.rectangle.angled")
            
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.text = AppStrings.settingsRedirectionTitle
            label.textColor = .label
            
            button.configuration?.title = AppStrings.openSettings
            button.isHidden = false
            
        case .noPhotos:
            imageView.tintColor = .systemGray3
            let configSymbol = UIImage.SymbolConfiguration(pointSize: 80, weight: .light)
            imageView.preferredSymbolConfiguration = configSymbol
            imageView.image = UIImage(systemName: "camera.on.rectangle")
            
            label.font = .systemFont(ofSize: 22, weight: .bold)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.paragraphSpacingBefore = 8
            
            let attributedText = NSMutableAttributedString(
                string: AppStrings.emptyPhotoListTitle,
                attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .bold), .foregroundColor: UIColor.label, .paragraphStyle: paragraphStyle]
            )
            
            let message = "\n\(AppStrings.emptyPhotoListMessage)"
            attributedText.append(NSAttributedString(
                string: message,
                attributes: [.font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: UIColor.secondaryLabel, .paragraphStyle: paragraphStyle]
            ))
            
            label.attributedText = attributedText
            button.isHidden = true
        }
    }
}

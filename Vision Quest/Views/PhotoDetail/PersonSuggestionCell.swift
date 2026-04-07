//
//  PersonSuggestionCell.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import UIKit
import Photos

final class PersonSuggestionCell: UITableViewCell {
    static let identifier = "PersonSuggestionCell"
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        iv.layer.cornerRadius = 20
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .medium)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    // Store current request ID to avoid loading wrong images if recycled quickly
    private var currentImageRequestID: PHImageRequestID?
    private var currentFaceId: UUID?
    private var currentFace: DetectedFace?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            {
                let c = contentView.heightAnchor.constraint(equalToConstant: 60)
                c.priority = .defaultHigh
                return c
            }()
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with person: PersonModel, defaultFace: DetectedFace?) {
        profileImageView.image = nil
        nameLabel.text = person.name
        profileImageView.isHidden = false
        
        currentFace = defaultFace
        currentFaceId = defaultFace?.id
        if let face = defaultFace {
            loadProfileImageAsync(face: face)
        }
    }
    
    private func loadProfileImageAsync(face: DetectedFace) {
        let faceId = face.id
        let assetId = face.assetId
        let rect = CGRect(x: face.boundingBoxX, y: face.boundingBoxY, width: face.boundingBoxWidth, height: face.boundingBoxHeight)
        
        let fetchOptions = PHFetchOptions()
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: fetchOptions)
        guard let asset = assets.firstObject else { return }
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        
        currentImageRequestID = manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { [weak self] image, _ in
            guard let self = self, self.currentFaceId == faceId, let image = image else { return }
            
            // Crop async to avoid blocking main thread with heavy CoreGraphics operations
            DispatchQueue.global(qos: .userInitiated).async {
                let cropped = image.cropped(to: rect)
                DispatchQueue.main.async {
                    if self.currentFaceId == faceId {
                        self.profileImageView.image = cropped
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let requestID = currentImageRequestID {
            PHImageManager.default().cancelImageRequest(requestID)
        }
        currentImageRequestID = nil
        currentFaceId = nil
        currentFace = nil
        profileImageView.image = nil
        nameLabel.text = nil
    }
}

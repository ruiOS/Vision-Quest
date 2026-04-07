//
//  PhotoCell.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 08/04/26.
//

import UIKit
import Photos

final class PhotoCell: BaseCollectionViewCell {
    static let identifier = "PhotoCell"
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        contentView.addSubview(badgeLabel)
        
        pinImageViewToEdges()
        
        NSLayoutConstraint.activate([
            badgeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            badgeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            badgeLabel.widthAnchor.constraint(equalToConstant: 24),
            badgeLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(with item: PhotoWithFaces) {
        badgeLabel.text = "\(item.faces.count)"
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        currentImageRequestID = manager.requestImage(for: item.asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: options) { [weak self] image, _ in
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
    }
}

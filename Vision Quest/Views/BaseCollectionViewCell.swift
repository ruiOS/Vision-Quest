//
//  BaseCollectionViewCell.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 08/04/26.
//

import UIKit
import Photos

class BaseCollectionViewCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .systemGray5
        return iv
    }()
    
    var currentImageRequestID: PHImageRequestID?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubview(imageView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let requestID = currentImageRequestID {
            PHImageManager.default().cancelImageRequest(requestID)
        }
        currentImageRequestID = nil
        imageView.image = nil
    }
    
    func fetchAndCropImage(for face: DetectedFace) {
        let fetchOptions = PHFetchOptions()
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [face.assetId], options: fetchOptions)
        guard let asset = assets.firstObject else { return }
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        currentImageRequestID = manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { [weak self] image, _ in
            guard let self = self, let image = image else { return }
            DispatchQueue.global(qos: .userInitiated).async {
                let rect = CGRect(x: face.boundingBoxX, y: face.boundingBoxY, width: face.boundingBoxWidth, height: face.boundingBoxHeight)
                let croppedAndScaled = image.cropped(to: rect)
                DispatchQueue.main.async {
                    self.imageView.image = croppedAndScaled
                }
            }
        }
    }
    
    func pinImageViewToEdges() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

//
//  FaceCell.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 08/04/26.
//

import UIKit
import Photos

final class FaceCell: BaseCollectionViewCell {
    static let identifier = "FaceCell"
    
    override func setupViews() {
        super.setupViews()
        pinImageViewToEdges()
    }
    
    func configure(with face: DetectedFace) {
        fetchAndCropImage(for: face)
    }
}

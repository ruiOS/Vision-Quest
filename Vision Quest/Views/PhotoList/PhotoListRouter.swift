//
//  PhotoListRouter.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import UIKit
import Photos

protocol PhotoListRoutable {
    func routeToPhotoDetail(asset: PHAsset, faces: [DetectedFace])
}

final class PhotoListRouter: PhotoListRoutable {
    weak var viewController: UIViewController?
    
    func routeToPhotoDetail(asset: PHAsset, faces: [DetectedFace]) {
        let detailVC = PhotoDetailBuilder.build(with: asset, faces: faces)
        detailVC.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
}

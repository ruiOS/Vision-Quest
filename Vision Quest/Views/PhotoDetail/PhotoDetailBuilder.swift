//
//  PhotoDetailBuilder.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import UIKit
import Photos

final class PhotoDetailBuilder {
    static func build(with asset: PHAsset, faces: [DetectedFace]) -> UIViewController {
        let worker = PhotoDetailWorker(faceRepository: FaceRepository())
        let dependencies = PhotoDetailDependencies(photoDetailWorker: worker)
        let router = PhotoDetailRouter()
        let viewModel = PhotoDetailViewModel(asset: asset, initialFaces: faces, dependencies: dependencies, router: router)
        let viewController = PhotoDetailViewController(viewModel: viewModel)
        viewModel.view = viewController
        router.viewController = viewController
        return viewController
    }
}

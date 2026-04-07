//
//  PhotoDetailViewModel.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Foundation
import Photos

protocol PhotoDetailViewModelable {
    var asset: PHAsset { get }
    var faces: [DetectedFace] { get }
    func viewDidLoad()
    func didTapFace(_ face: DetectedFace)
}

final class PhotoDetailViewModel: PhotoDetailViewModelable {
    weak var view: PhotoDetailViewable?
    let asset: PHAsset
    var faces: [DetectedFace]
    let dependencies: PhotoDetailDependenciesProtocol
    let router: PhotoDetailRoutable

    init(asset: PHAsset, initialFaces: [DetectedFace], dependencies: PhotoDetailDependenciesProtocol, router: PhotoDetailRoutable) {
        self.asset = asset
        self.faces = initialFaces
        self.dependencies = dependencies
        self.router = router
    }

    func viewDidLoad() {
        self.faces = dependencies.photoDetailWorker.getFaces(for: asset.localIdentifier)
    }

    func didTapFace(_ face: DetectedFace) {
        router.routeToTaggingSheet(
            faceId: face.id,
            worker: dependencies.photoDetailWorker,
            delegate: self
        )
    }
}

// MARK: - TaggingSheetDelegate

extension PhotoDetailViewModel: TaggingSheetDelegate {
    func taggingSheetDidFinish() {
        self.faces = dependencies.photoDetailWorker.getFaces(for: asset.localIdentifier)
        view?.refreshFaces()
    }

    func taggingSheet(didUpdateTag newPersonId: UUID, newPersonName: String, didPersonChange: Bool) {
        if didPersonChange {
            router.notifyPersonChanged(newPersonId: newPersonId, newPersonName: newPersonName)
        }
    }
}

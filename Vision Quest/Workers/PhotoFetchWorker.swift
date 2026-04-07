//
//  PhotoFetchWorker.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Foundation
import Photos

protocol PhotoFetchWorkerProtocol {
    func fetchExistingPhotos() -> [PhotoWithFaces]
}

final class PhotoFetchWorker: PhotoFetchWorkerProtocol {
    private let faceRepository: FaceRepositoryProtocol
    
    init(faceRepository: FaceRepositoryProtocol) {
        self.faceRepository = faceRepository
    }
    
    func fetchExistingPhotos() -> [PhotoWithFaces] {
        let allFaces = faceRepository.getAllFaces()
        let grouped = Dictionary(grouping: allFaces, by: { $0.assetId })
        let assetIds = Array(grouped.keys)
        
        let fetchOptions = PHFetchOptions()
        let phAssets = PHAsset.fetchAssets(withLocalIdentifiers: assetIds, options: fetchOptions)
        
        var loadedPhotos: [PhotoWithFaces] = []
        phAssets.enumerateObjects { asset, _, _ in
            if let faces = grouped[asset.localIdentifier] {
                loadedPhotos.append(PhotoWithFaces(asset: asset, faces: faces))
            }
        }
        
        return loadedPhotos.sorted {
            ($0.asset.creationDate ?? Date.distantPast) > ($1.asset.creationDate ?? Date.distantPast)
        }
    }
}

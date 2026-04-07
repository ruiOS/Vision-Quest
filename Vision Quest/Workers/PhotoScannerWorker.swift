//
//  PhotoScannerWorker.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import UIKit
import Photos

protocol PhotoScannerWorkerProtocol {
    func processAssetsStream(
        _ assets: [PHAsset],
        onProgress: @escaping (Int, Int) -> Void,
        onPhotoProcessed: @escaping (PhotoWithFaces) -> Void
    )
}

final class PhotoScannerWorker: PhotoScannerWorkerProtocol {
    private let photoLibraryService: PhotoLibraryServiceProtocol
    private let faceDetectionService: FaceDetectionServiceProtocol
    private let faceRepository: FaceRepositoryProtocol
    private let scanStatusRepository: ScanStatusRepositoryProtocol
    
    init(
        photoLibraryService: PhotoLibraryServiceProtocol,
        faceDetectionService: FaceDetectionServiceProtocol,
        faceRepository: FaceRepositoryProtocol,
        scanStatusRepository: ScanStatusRepositoryProtocol
    ) {
        self.photoLibraryService = photoLibraryService
        self.faceDetectionService = faceDetectionService
        self.faceRepository = faceRepository
        self.scanStatusRepository = scanStatusRepository
    }
    
    func processAssetsStream(
        _ assets: [PHAsset],
        onProgress: @escaping (Int, Int) -> Void,
        onPhotoProcessed: @escaping (PhotoWithFaces) -> Void
    ) {
        let backgroundQueue = DispatchQueue(label: "com.visionquest.scanQueue", qos: .background)
        
        backgroundQueue.async { [weak self] in
            self?.executeScanLoop(assets: assets, onProgress: onProgress, onPhotoProcessed: onPhotoProcessed)
        }
    }
    
    // MARK: - Private Helpers
    
    private func executeScanLoop(
        assets: [PHAsset],
        onProgress: @escaping (Int, Int) -> Void,
        onPhotoProcessed: @escaping (PhotoWithFaces) -> Void
    ) {
        _ = scanStatusRepository.prefetchAllProcessedIDs() // prime cache
        
        let unprocessedAssets = assets.filter { !scanStatusRepository.isProcessed($0.localIdentifier) }
        let totalUnprocessed = unprocessedAssets.count
        
        guard totalUnprocessed > 0 else {
            DispatchQueue.main.async { onProgress(totalUnprocessed, totalUnprocessed) }
            return
        }
        
        for (index, asset) in unprocessedAssets.enumerated() {
            processSingleAsset(asset, onPhotoProcessed: onPhotoProcessed)
            DispatchQueue.main.async { onProgress(index + 1, totalUnprocessed) }
        }
    }
    
    private func processSingleAsset(
        _ asset: PHAsset,
        onPhotoProcessed: @escaping (PhotoWithFaces) -> Void
    ) {
        let semaphore = DispatchSemaphore(value: 0)
        var hasHandled = false
        
        photoLibraryService.requestImage(for: asset, size: CGSize(width: 600, height: 600)) { [weak self] image in
            guard let self = self, !hasHandled else { return }
            hasHandled = true
            
            guard let image = image else {
                self.scanStatusRepository.markProcessed(asset.localIdentifier)
                semaphore.signal()
                return
            }
            
            self.detectAndSaveFaces(in: image, for: asset, onPhotoProcessed: onPhotoProcessed) {
                semaphore.signal()
            }
        }
        
        semaphore.wait()
    }
    
    private func detectAndSaveFaces(
        in image: UIImage,
        for asset: PHAsset,
        onPhotoProcessed: @escaping (PhotoWithFaces) -> Void,
        completion: @escaping () -> Void
    ) {
        faceDetectionService.detectFaces(in: image) { [weak self] boundingBoxes in
            guard let self = self else {
                completion()
                return
            }
            
            let assetFaces = self.saveDetectedFaces(boundingBoxes: boundingBoxes, for: asset)
            self.scanStatusRepository.markProcessed(asset.localIdentifier)
            
            if !assetFaces.isEmpty {
                let photoWithFaces = PhotoWithFaces(asset: asset, faces: assetFaces)
                DispatchQueue.main.async {
                    onPhotoProcessed(photoWithFaces)
                }
            }
            
            completion()
        }
    }
    
    private func saveDetectedFaces(boundingBoxes: [CGRect], for asset: PHAsset) -> [DetectedFace] {
        var assetFaces: [DetectedFace] = []
        for bbox in boundingBoxes {
            let detectedFace = DetectedFace(
                id: UUID(),
                assetId: asset.localIdentifier,
                boundingBoxX: Double(bbox.origin.x),
                boundingBoxY: Double(bbox.origin.y),
                boundingBoxWidth: Double(bbox.size.width),
                boundingBoxHeight: Double(bbox.size.height),
                personName: nil
            )
            faceRepository.saveFace(detectedFace)
            assetFaces.append(detectedFace)
        }
        return assetFaces
    }
}

//
//  PhotoListDependencies.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Foundation

protocol PhotoListDependenciesProtocol {
    var photoLibraryService: PhotoLibraryServiceProtocol { get }
    var faceDetectionService: FaceDetectionServiceProtocol { get }
    var faceRepository: FaceRepositoryProtocol { get }
    var scanStatusRepository: ScanStatusRepositoryProtocol { get }
    var photoScannerWorker: PhotoScannerWorkerProtocol { get }
    var photoFetchWorker: PhotoFetchWorkerProtocol { get }
}

struct PhotoListDependencies: PhotoListDependenciesProtocol {
    let photoLibraryService: PhotoLibraryServiceProtocol
    let faceDetectionService: FaceDetectionServiceProtocol
    let faceRepository: FaceRepositoryProtocol
    let scanStatusRepository: ScanStatusRepositoryProtocol
    let photoScannerWorker: PhotoScannerWorkerProtocol
    let photoFetchWorker: PhotoFetchWorkerProtocol
}

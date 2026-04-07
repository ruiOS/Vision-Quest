//
//  PhotoListBuilder.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import UIKit

final class PhotoListBuilder {

    func build() -> UIViewController {
        let photoLibraryService = PhotoLibraryService()
        let faceDetectionService = FaceDetectionService()
        let faceRepository = FaceRepository()
        let scanStatusRepository = ScanStatusRepository()
        
        let photoScannerWorker = PhotoScannerWorker(
            photoLibraryService: photoLibraryService,
            faceDetectionService: faceDetectionService,
            faceRepository: faceRepository,
            scanStatusRepository: scanStatusRepository
        )
        
        let photoFetchWorker = PhotoFetchWorker(faceRepository: faceRepository)
        
        let dependencies = PhotoListDependencies(
            photoLibraryService: photoLibraryService,
            faceDetectionService: faceDetectionService,
            faceRepository: faceRepository,
            scanStatusRepository: scanStatusRepository,
            photoScannerWorker: photoScannerWorker,
            photoFetchWorker: photoFetchWorker
        )
        let router = PhotoListRouter()
        let viewModel = PhotoListViewModel(dependencies: dependencies, router: router)
        let viewController = PhotoListViewController(viewModel: viewModel)
        viewModel.view = viewController
        router.viewController = viewController
        return viewController
    }
}

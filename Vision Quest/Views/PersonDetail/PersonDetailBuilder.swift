//
//  PersonDetailBuilder.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import UIKit
import Photos

final class PersonDetailBuilder {
    static func build(with personName: String, personId: UUID) -> UIViewController {
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
        let viewModel = PersonDetailViewModel(personName: personName, personId: personId, dependencies: dependencies)
        let viewController = PersonDetailViewController(viewModel: viewModel)
        viewModel.view = viewController
        return viewController
    }
}

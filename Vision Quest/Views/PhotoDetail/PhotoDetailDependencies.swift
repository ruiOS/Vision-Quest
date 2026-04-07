//
//  PhotoDetailDependencies.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Photos

protocol PhotoDetailDependenciesProtocol {
    var photoDetailWorker: PhotoDetailWorkerProtocol { get }
}

struct PhotoDetailDependencies: PhotoDetailDependenciesProtocol {
    let photoDetailWorker: PhotoDetailWorkerProtocol
}

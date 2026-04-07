//
//  PhotoListViewModel.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Foundation
import Photos

struct PhotoWithFaces {
    let asset: PHAsset
    let faces: [DetectedFace]
}

protocol PhotoListViewModelable {
    var photos: [PhotoWithFaces] { get }
    func viewDidLoad()
    func startScanning()
    func didSelectPhoto(at index: Int)
}

final class PhotoListViewModel {
    weak var view: PhotoListViewable?
    let dependencies: PhotoListDependenciesProtocol
    let router: PhotoListRoutable
    
    var photos: [PhotoWithFaces] = []
    
    init(dependencies: PhotoListDependenciesProtocol, router: PhotoListRoutable) {
        self.dependencies = dependencies
        self.router = router
    }
}

extension PhotoListViewModel: PhotoListViewModelable {
    func didSelectPhoto(at index: Int) {
        let selectedItem = photos[index]
        router.routeToPhotoDetail(asset: selectedItem.asset, faces: selectedItem.faces)
    }

    func viewDidLoad() {
        view?.set(state: .loading)
        fetchExistingPhotos()
        startScanning()
    }
    
    private func fetchExistingPhotos() {
        self.photos = dependencies.photoFetchWorker.fetchExistingPhotos()
        if !self.photos.isEmpty {
            view?.set(state: .success(self.photos))
        }
    }
    
    func startScanning() {
        dependencies.photoLibraryService.requestAuthorization { [weak self] authorized in
            guard let self = self else { return }
            guard authorized else {
                self.view?.set(state: .error)
                return
            }
            
            let assets = self.dependencies.photoLibraryService.fetchLatestPhotos()
            
            if assets.count == 0 {
                if self.photos.isEmpty {
                    self.view?.set(state: .success([]))
                }
                return
            }
            
            self.dependencies.photoScannerWorker.processAssetsStream(
                assets,
                onProgress: { [weak self] scanned, total in
                    if scanned == total && self?.photos.isEmpty == true {
                        self?.view?.set(state: .success([]))
                    }
                },
                onPhotoProcessed: { [weak self] photoWithFaces in
                    guard let self = self else { return }
                    self.photos.append(photoWithFaces)
                    self.view?.appendNewPhoto(photoWithFaces, at: self.photos.count - 1)
                }
            )
        }
    }
}

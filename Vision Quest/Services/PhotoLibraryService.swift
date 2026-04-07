//
//  PhotoLibraryService.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Photos
import UIKit

protocol PhotoLibraryServiceProtocol {
    func requestAuthorization(completion: @escaping (Bool) -> Void)
    func fetchLatestPhotos() -> [PHAsset]
    func requestImage(for asset: PHAsset, size: CGSize, completion: @escaping (UIImage?) -> Void)
}

final class PhotoLibraryService: PhotoLibraryServiceProtocol {
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                completion(status == .authorized || status == .limited)
            }
        }
    }
    
    func fetchLatestPhotos() -> [PHAsset] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var assets: [PHAsset] = []
        fetchResult.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        return assets
    }
    
    func requestImage(for asset: PHAsset, size: CGSize, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: options) { image, info in
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
            if !isDegraded {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
}

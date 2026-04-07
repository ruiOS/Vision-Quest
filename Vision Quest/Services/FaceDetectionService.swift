//
//  FaceDetectionService.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Vision
import UIKit

protocol FaceDetectionServiceProtocol {
    func detectFaces(in image: UIImage, completion: @escaping ([CGRect]) -> Void)
}

final class FaceDetectionService: FaceDetectionServiceProtocol {
    func detectFaces(in image: UIImage, completion: @escaping ([CGRect]) -> Void) {
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async { completion([]) }
            return
        }
        
        let orientation = self.cgImageOrientation(from: image.imageOrientation)
        
        DispatchQueue.global(qos: .userInitiated).async {
            autoreleasepool {
                let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
                let request = VNDetectFaceRectanglesRequest()
                
                if #available(iOS 15.0, *) {
                    request.revision = VNDetectFaceRectanglesRequestRevision2
                }
                
                do {
                    try handler.perform([request])
                    
                    guard let results = request.results else {
                        DispatchQueue.main.async { completion([]) }
                        return
                    }
                    
                    let boundingBoxes = results.map { $0.boundingBox }
                    DispatchQueue.main.async { completion(boundingBoxes) }
                } catch {
                    DispatchQueue.main.async { completion([]) }
                }
            }
        }
    }
    
    private func cgImageOrientation(from uiOrientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch uiOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}

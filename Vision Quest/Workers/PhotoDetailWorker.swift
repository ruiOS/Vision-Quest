//
//  PhotoDetailWorker.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Foundation

protocol PhotoDetailWorkerProtocol {
    func getFaces(for assetId: String) -> [DetectedFace]
    func getFace(by faceId: UUID) -> DetectedFace?
    @discardableResult
    func updateFacePerson(faceId: UUID, personId: UUID?, newPersonName: String?, isDefaultPic: Bool) -> (UUID, String, Bool)?
    func getAllPersons() -> [PersonModel]
}

final class PhotoDetailWorker: PhotoDetailWorkerProtocol {
    private let faceRepository: FaceRepositoryProtocol
    
    init(faceRepository: FaceRepositoryProtocol) {
        self.faceRepository = faceRepository
    }
    
    func getFaces(for assetId: String) -> [DetectedFace] {
        return faceRepository.getFaces(for: assetId)
    }

    func getFace(by faceId: UUID) -> DetectedFace? {
        return faceRepository.getFace(by: faceId)
    }
    
    @discardableResult
    func updateFacePerson(faceId: UUID, personId: UUID?, newPersonName: String?, isDefaultPic: Bool) -> (UUID, String, Bool)? {
        return faceRepository.updateFacePerson(faceId: faceId, personId: personId, newPersonName: newPersonName, isDefaultPic: isDefaultPic)
    }
    
    func getAllPersons() -> [PersonModel] {
        return faceRepository.getAllPersons()
    }
}

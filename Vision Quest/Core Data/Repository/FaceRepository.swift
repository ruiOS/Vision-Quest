//
//  FaceRepository.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Foundation
import CoreData
import Photos

protocol FaceRepositoryProtocol {
    func getAllFaces() -> [DetectedFace]
    func getFaces(for assetId: String) -> [DetectedFace]
    func getFace(by faceId: UUID) -> DetectedFace?
    func saveFace(_ face: DetectedFace)
    @discardableResult
    func updateFacePerson(faceId: UUID, personId: UUID?, newPersonName: String?, isDefaultPic: Bool) -> (UUID, String, Bool)?
    func getAllPersons() -> [PersonModel]
    func getFaces(forPersonId personId: UUID) -> [DetectedFace]
    func getDefaultFace(forPersonId personId: UUID, defaultFaceId: UUID?) -> DetectedFace?
}

struct FaceRepository: FaceRepositoryProtocol {
    func getAllFaces() -> [DetectedFace] {
        let result = PersistentStorage.shared.fetchManagedObject(managedObject: CDFace.self)
        return result.compactMap { $0.convertToDetectedFace() }
    }
    
    func getFaces(for assetId: String) -> [DetectedFace] {
        let predicate = NSPredicate(format: "assetId == %@", assetId)
        let result: [CDFace]? = PersistentStorage.shared.fetchObjects(usingPredicate: predicate)
        return result?.compactMap { $0.convertToDetectedFace() } ?? []
    }
    
    func getFace(by faceId: UUID) -> DetectedFace? {
        let predicate = NSPredicate(format: "id == %@", faceId as CVarArg)
        let result: [CDFace]? = PersistentStorage.shared.fetchObjects(usingPredicate: predicate)
        return result?.first?.convertToDetectedFace()
    }

    func getFaces(forPersonId personId: UUID) -> [DetectedFace] {
        let predicate = NSPredicate(format: "person.id == %@", personId as CVarArg)
        let result: [CDFace]? = PersistentStorage.shared.fetchObjects(usingPredicate: predicate)
        let faces = result?.compactMap { $0.convertToDetectedFace() } ?? []
        
        let assetIds = faces.map { $0.assetId }
        let validAssets = PHAsset.fetchAssets(withLocalIdentifiers: assetIds, options: nil)
        var validAssetIds = Set<String>()
        validAssets.enumerateObjects { asset, _, _ in
            validAssetIds.insert(asset.localIdentifier)
        }
        return faces.filter { validAssetIds.contains($0.assetId) }
    }
    
    func getAllPersons() -> [PersonModel] {
        let result = PersistentStorage.shared.fetchManagedObject(managedObject: CDPerson.self)
        let persons: [PersonModel] = result.compactMap { cdPerson -> PersonModel? in
            guard let name = cdPerson.name else { return nil }
            return PersonModel(id: cdPerson.id, name: name, defaultFaceId: cdPerson.defaultFaceId)
        }
        
        let allFaces = getAllFaces()
        let assetIds = Array(Set(allFaces.map { $0.assetId }))
        let fetchedAssets = PHAsset.fetchAssets(withLocalIdentifiers: assetIds, options: nil)
        var validAssets = Set<String>()
        fetchedAssets.enumerateObjects { asset, _, _ in
            validAssets.insert(asset.localIdentifier)
        }
        
        var personValidFaces: [UUID: Bool] = [:]
        for face in allFaces {
            guard let pid = face.personId else { continue }
            if validAssets.contains(face.assetId) {
                personValidFaces[pid] = true
            }
        }
        
        return persons.filter { personValidFaces[$0.id] == true }
    }
    
    func saveFace(_ face: DetectedFace) {
        let cdFace = CDFace(context: PersistentStorage.shared.context)
        cdFace.id = face.id
        cdFace.assetId = face.assetId
        cdFace.boundingBoxX = face.boundingBoxX
        cdFace.boundingBoxY = face.boundingBoxY
        cdFace.boundingBoxWidth = face.boundingBoxWidth
        cdFace.boundingBoxHeight = face.boundingBoxHeight
        cdFace.personName = face.personName
        PersistentStorage.shared.saveContext()
    }
    
    @discardableResult
    func updateFacePerson(faceId: UUID, personId: UUID?, newPersonName: String?, isDefaultPic: Bool) -> (UUID, String, Bool)? {
        let context = PersistentStorage.shared.context

        let facePredicate = NSPredicate(format: "id == %@", faceId as CVarArg)
        guard let cdFace = (PersistentStorage.shared.fetchObjects(usingPredicate: facePredicate) as [CDFace]?)?.first else { return nil }
        let oldPerson = cdFace.person

        // Target resolving
        let targetPerson: CDPerson

        if let pid = personId {
            // Finding existing person explicitly
            let personPredicate = NSPredicate(format: "id == %@", pid as CVarArg)
            guard let existing = (PersistentStorage.shared.fetchObjects(usingPredicate: personPredicate) as [CDPerson]?)?.first else {
                return nil // Fallback fail
            }
            targetPerson = existing
        } else if let newName = newPersonName {
            // Generating completely new person entity structurally
            targetPerson = CDPerson(context: context)
            targetPerson.id = UUID()
            targetPerson.name = newName
        } else {
            return nil // Invalid parameters
        }
        
        var didPersonChange = false
        
        // Unlink Face from Old Person
        if let old = oldPerson, old.id != targetPerson.id {
            didPersonChange = true
            old.removeFromFaces(cdFace)
            
            if old.defaultFaceId == faceId {
                if let nextFace = old.faces?.anyObject() as? CDFace {
                    old.defaultFaceId = nextFace.id
                } else {
                    old.defaultFaceId = nil
                }
            }
            
            if old.faces?.count == 0 {
                context.delete(old)
            }
        } else if oldPerson == nil {
            didPersonChange = true
        }
        
        cdFace.personName = targetPerson.name // Caching legacy field for quick access
        cdFace.person = targetPerson
        
        if isDefaultPic || targetPerson.defaultFaceId == nil {
            targetPerson.defaultFaceId = faceId
        }
        
        PersistentStorage.shared.saveContext()
        return (targetPerson.id, targetPerson.name ?? "", didPersonChange)
    }

    func getDefaultFace(forPersonId personId: UUID, defaultFaceId: UUID?) -> DetectedFace? {
        let faces = getFaces(forPersonId: personId)
        if let defaultFaceId = defaultFaceId, let face = faces.first(where: { $0.id == defaultFaceId }) {
            return face
        }
        return faces.first
    }
}


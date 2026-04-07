//
//  PersonDetailViewModel.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Foundation
import Photos

protocol PersonDetailViewModelable {
    var personName: String { get }
    var faces: [DetectedFace] { get }
    func viewDidLoad()
    func getRoutingPayload(for face: DetectedFace) -> (PHAsset, [DetectedFace])?
    func setAsDefaultFace(for face: DetectedFace)
    func updatePersonId(_ newPersonId: UUID, name: String)
}

protocol PersonDetailViewable: AnyObject {
    func refreshData()
}

final class PersonDetailViewModel: PersonDetailViewModelable {
    var personName: String
    var personId: UUID
    private let dependencies: PhotoListDependenciesProtocol
    var faces: [DetectedFace] = []
    weak var view: PersonDetailViewable?
    
    init(personName: String, personId: UUID, dependencies: PhotoListDependenciesProtocol) {
        self.personName = personName
        self.personId = personId
        self.dependencies = dependencies
    }
    
    func viewDidLoad() {
        self.faces = dependencies.faceRepository.getFaces(forPersonId: personId)
        view?.refreshData()
    }
    
    func getRoutingPayload(for face: DetectedFace) -> (PHAsset, [DetectedFace])? {
        let fetchOptions = PHFetchOptions()
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [face.assetId], options: fetchOptions)
        guard let asset = assets.firstObject else { return nil }
        
        let allFaces = dependencies.faceRepository.getFaces(for: face.assetId)
        return (asset, allFaces)
    }
    
    func setAsDefaultFace(for face: DetectedFace) {
        dependencies.faceRepository.updateFacePerson(faceId: face.id, personId: personId, newPersonName: personName, isDefaultPic: true)
    }

    func updatePersonId(_ newPersonId: UUID, name: String) {
        personId = newPersonId
        personName = name
        viewDidLoad()
    }
}

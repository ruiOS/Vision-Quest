//
//  PeopleListViewModel.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Foundation
import Photos

protocol PeopleListViewModelable {
    var persons: [PersonModel] { get }
    func viewDidLoad()
    func viewWillAppear()
    func getDefaultFace(for person: PersonModel) -> DetectedFace?
    func routeToPersonDetail(person: PersonModel)
}

final class PeopleListViewModel: PeopleListViewModelable {
    weak var view: PeopleListViewable?
    var router: PeopleListRoutable?
    private let dependencies: PhotoListDependenciesProtocol
    var persons: [PersonModel] = []

    init(dependencies: PhotoListDependenciesProtocol) {
        self.dependencies = dependencies
    }
    
    func viewDidLoad() {
        loadPersons()
    }
    
    func viewWillAppear() {
        loadPersons()
    }
    
    private func loadPersons() {
        persons = dependencies.faceRepository.getAllPersons().sorted { $0.name < $1.name }
        view?.refreshData()
    }
    
    func getDefaultFace(for person: PersonModel) -> DetectedFace? {
        return dependencies.faceRepository.getDefaultFace(
            forPersonId: person.id,
            defaultFaceId: person.defaultFaceId
        )
    }
    
    func routeToPersonDetail(person: PersonModel) {
        router?.routeToPersonDetail(name: person.name, personId: person.id)
    }
}

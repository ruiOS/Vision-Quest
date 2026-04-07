//
//  TaggingSheetViewModel.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Foundation

// MARK: - Display model

/// Pairs a person with their resolved default face thumbnail — ready for the cell to consume.
struct PersonRow {
    let person: PersonModel
    let defaultFace: DetectedFace?
}

// MARK: - Protocols

protocol TaggingSheetViewModelable {
    var displayRows: [PersonRow] { get }
    func viewDidLoad()
    func didChangeSearchText(_ text: String)
    func didSelectPerson(_ person: PersonModel)
    func didConfirmNewTag(name: String)
}

// MARK: - ViewModel

final class TaggingSheetViewModel: TaggingSheetViewModelable {

    // MARK: Dependencies

    private let faceId: UUID
    private let worker: PhotoDetailWorkerProtocol

    weak var view: TaggingSheetViewable?
    weak var delegate: TaggingSheetDelegate?

    // MARK: State

    /// The currently filtered list shown in the table view.
    private(set) var displayRows: [PersonRow] = []
    private var allSuggestions: [PersonModel] = []

    /// The person explicitly selected from the suggestion list.
    /// Only cleared when a different person is selected or a new free-text tag is confirmed —
    /// NOT when the user merely types in the search bar.
    private var selectedPersonId: UUID?

    // MARK: Init

    init(faceId: UUID, worker: PhotoDetailWorkerProtocol) {
        self.faceId = faceId
        self.worker = worker
    }

    // MARK: TaggingSheetViewModelable

    func viewDidLoad() {
        allSuggestions = worker.getAllPersons()
        rebuildRows(for: "")
        view?.setSaveEnabled(false)
    }

    /// Typing in the search bar only filters — it never resets `selectedPersonId`.
    func didChangeSearchText(_ text: String) {
        rebuildRows(for: text)
        view?.setSaveEnabled(!text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    /// Tapping a row locks in the selected person and immediately saves.
    func didSelectPerson(_ person: PersonModel) {
        selectedPersonId = person.id
        commitTag(personId: person.id, name: person.name)
    }

    /// "Add new tag" button / keyboard search — creates or reuses under the typed name,
    /// clearing any previously selected person ID so it's treated as a new entry.
    func didConfirmNewTag(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        // If the text still matches the selected person's name, treat it as selecting that person.
        if let selectedId = selectedPersonId,
           let match = allSuggestions.first(where: { $0.id == selectedId }),
           match.name == trimmed {
            commitTag(personId: selectedId, name: trimmed)
        } else {
            // Free-text new tag — clear any stale selection.
            selectedPersonId = nil
            commitTag(personId: nil, name: trimmed)
        }
    }
}

// MARK: - Private helpers

private extension TaggingSheetViewModel {

    func rebuildRows(for text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered: [PersonModel]
        if trimmed.isEmpty {
            filtered = allSuggestions
        } else {
            filtered = allSuggestions.filter { $0.name.lowercased().contains(trimmed.lowercased()) }
        }
        displayRows = filtered.map { person in
            let face = person.defaultFaceId.flatMap { worker.getFace(by: $0) }
            return PersonRow(person: person, defaultFace: face)
        }
        view?.reloadSuggestions()
    }

    func commitTag(personId: UUID?, name: String) {
        guard let result = worker.updateFacePerson(
            faceId: faceId,
            personId: personId,
            newPersonName: name,
            isDefaultPic: personId == nil
        ) else { return }

        let (updatedPersonId, updatedName, didPersonChange) = result
        view?.dismissSheet()
        delegate?.taggingSheetDidFinish()
        if didPersonChange {
            delegate?.taggingSheet(didUpdateTag: updatedPersonId, newPersonName: updatedName, didPersonChange: true)
        }
    }
}

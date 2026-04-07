//
//  Localization.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Foundation

@propertyWrapper
struct Localized {
    private let key: String
    private let defaultValue: String

    init(_ key: String, default defaultValue: String) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: String {
        return NSLocalizedString(key, value: defaultValue, comment: "")
    }
}

struct AppStrings {
    // MARK: - Tab Bar
    @Localized("com.visionQuest.tabBar.photos", default: "Photos") static var tabPhotos: String
    @Localized("com.visionQuest.tabBar.people", default: "People") static var tabPeople: String

    // MARK: - Photo List
    @Localized("com.visionQuest.settingsRedirection.title", default: "Please provide library access to scan photos") static var settingsRedirectionTitle: String
    @Localized("com.visionQuest.settingsRedirection.buttonText", default: "Open Settings") static var openSettings: String
    @Localized("com.visionQuest.photos.list.title", default: "Face Detection") static var photoListTitle: String
    @Localized("com.visionQuest.photos.list.scanButton", default: "Scan Photo Library") static var scanButton: String
    @Localized("com.visionQuest.photos.list.fetchTitle", default: "Fetching") static var fetchTitle: String
    @Localized("com.visionQuest.photos.list.fetchMessage", default: "Please wait...") static var fetchMessage: String
    @Localized("com.visionQuest.photos.list.scanningLabel", default: "Scanning photos...") static var scanningLabel: String
    @Localized("com.visionQuest.photos.list.scanFormat", default: "Scanning photos...") static var scanFormat: String
    @Localized("com.visionQuest.photos.list.emptyTitle", default: "No Photos Found") static var emptyPhotoListTitle: String
    @Localized("com.visionQuest.photos.list.emptyMessage", default: "Your photo library appears to be empty. Snap a few photos and come back to experience the full magic of Vision Quest!") static var emptyPhotoListMessage: String

    // MARK: - People List
    @Localized("com.visionQuest.people.list.title", default: "People") static var peopleListTitle: String
    @Localized("com.visionQuest.people.list.emptyState", default: "List of People will come once you start tagging photos") static var peopleListEmptyState: String

    // MARK: - Tagging / Detail
    @Localized("com.visionQuest.tagging.fullNamePlaceholder", default: "Full Name") static var fullNamePlaceholder: String
    @Localized("com.visionQuest.tagging.makeDefaultProfile", default: "Set as person's reference picture") static var makeDefaultProfile: String
    @Localized("com.visionQuest.tagging.saveTag", default: "Save Tag") static var saveTag: String

    // MARK: - Tagging Sheet
    @Localized("com.visionQuest.tagging.sheet.title", default: "Tag Person") static var taggingSheetTitle: String
    @Localized("com.visionQuest.tagging.sheet.searchPlaceholder", default: "Search or enter new name") static var taggingSheetSearchPlaceholder: String
    @Localized("com.visionQuest.tagging.sheet.addNewTag", default: "Add new tag") static var taggingSheetAddNewTag: String
}

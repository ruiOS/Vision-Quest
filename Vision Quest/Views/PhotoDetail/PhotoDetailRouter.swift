//
//  PhotoDetailRouter.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import UIKit

// MARK: - Routing Protocol

protocol PhotoDetailRoutable {
    func routeToTaggingSheet(faceId: UUID, worker: PhotoDetailWorkerProtocol, delegate: TaggingSheetDelegate)
    func notifyPersonChanged(newPersonId: UUID, newPersonName: String)
}

// MARK: - Router

final class PhotoDetailRouter: PhotoDetailRoutable {
    weak var viewController: UIViewController?

    // MARK: Tagging Sheet

    func routeToTaggingSheet(
        faceId: UUID,
        worker: PhotoDetailWorkerProtocol,
        delegate: TaggingSheetDelegate
    ) {
        let taggingVM = TaggingSheetViewModel(
            faceId: faceId,
            worker: worker
        )
        taggingVM.delegate = delegate

        let tagVC = TaggingSheetViewController(viewModel: taggingVM)
        taggingVM.view = tagVC

        if #available(iOS 15.0, *) {
            if let sheet = tagVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
        }

        viewController?.present(tagVC, animated: true)
    }

    // MARK: Person-Change Delegate

    /// Walks the back-stack and asks the nearest PersonDetailViewController
    /// (via its delegate protocol) to reload itself with the updated person.
    func notifyPersonChanged(newPersonId: UUID, newPersonName: String) {
        guard let nav = viewController?.navigationController else { return }

        let vcs = nav.viewControllers
        // Find the PersonDetailViewController sitting behind PhotoDetailViewController
        guard
            let currentIndex = vcs.firstIndex(where: { $0 === viewController }),
            currentIndex > 0,
            let personDetailDelegate = vcs[currentIndex - 1] as? PhotoDetailToPersonDelegate
        else { return }

        personDetailDelegate.personDidChange(newPersonId: newPersonId, newPersonName: newPersonName)
    }
}

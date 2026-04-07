//
//  PeopleListRouter.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import UIKit

protocol PeopleListRoutable {
    func routeToPersonDetail(name: String, personId: UUID)
}

final class PeopleListRouter: PeopleListRoutable {
    weak var viewController: UIViewController?

    func routeToPersonDetail(name: String, personId: UUID) {
        let detailVC = PersonDetailBuilder.build(with: name, personId: personId)
        detailVC.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
}

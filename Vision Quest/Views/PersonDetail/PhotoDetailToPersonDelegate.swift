//
//  PhotoDetailToPersonDelegate.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 08/04/26.
//

import Foundation

protocol PhotoDetailToPersonDelegate: AnyObject {
    func personDidChange(newPersonId: UUID, newPersonName: String)
}

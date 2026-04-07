//
//  TaggingSheetDelegate.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 08/04/26.
//

import Foundation

protocol TaggingSheetDelegate: AnyObject {
    func taggingSheet(didUpdateTag newPersonId: UUID, newPersonName: String, didPersonChange: Bool)
    func taggingSheetDidFinish()
}

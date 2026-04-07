//
//  CDScannedAsset.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Foundation
import CoreData

@objc(CDScannedAsset)
public class CDScannedAsset: NSManagedObject {
    static let entityName: String = "CDScannedAsset"
    @NSManaged public var assetId: String
}

extension CDScannedAsset: NSManagedObjectEntityProtocol {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDScannedAsset> {
        return NSFetchRequest<CDScannedAsset>(entityName: entityName)
    }
}

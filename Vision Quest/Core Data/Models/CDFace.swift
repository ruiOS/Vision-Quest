//
//  CDFace.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Foundation
import CoreData

@objc(CDFace)
public final class CDFace: NSManagedObject {
    static let entityName: String = "CDFace"

    @NSManaged public var id: UUID?
    @NSManaged public var assetId: String?
    @NSManaged public var boundingBoxX: Double
    @NSManaged public var boundingBoxY: Double
    @NSManaged public var boundingBoxWidth: Double
    @NSManaged public var boundingBoxHeight: Double
    @NSManaged public var personName: String?
    @NSManaged public var person: CDPerson?
}

extension CDFace: NSManagedObjectEntityProtocol {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDFace> {
        return NSFetchRequest<CDFace>(entityName: entityName)
    }

    func convertToDetectedFace() -> DetectedFace? {
        guard let id = id, let assetId = assetId else { return nil }
        return DetectedFace(
            id: id,
            assetId: assetId,
            boundingBoxX: boundingBoxX,
            boundingBoxY: boundingBoxY,
            boundingBoxWidth: boundingBoxWidth,
            boundingBoxHeight: boundingBoxHeight,
            personName: personName,
            personId: person?.id
        )
    }
}

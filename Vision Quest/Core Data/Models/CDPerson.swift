//
//  CDPerson.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Foundation
import CoreData

@objc(CDPerson)
public final class CDPerson: NSManagedObject {
    static let entityName: String = "CDPerson"
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String?
    @NSManaged public var defaultFaceId: UUID?
    @NSManaged public var faces: NSSet?
}

extension CDPerson: NSManagedObjectEntityProtocol {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPerson> {
        return NSFetchRequest<CDPerson>(entityName: entityName)
    }
}

// MARK: Generated accessors for faces
extension CDPerson {
    @objc(addFacesObject:)
    @NSManaged public func addToFaces(_ value: CDFace)

    @objc(removeFacesObject:)
    @NSManaged public func removeFromFaces(_ value: CDFace)

    @objc(addFaces:)
    @NSManaged public func addToFaces(_ values: NSSet)

    @objc(removeFaces:)
    @NSManaged public func removeFromFaces(_ values: NSSet)
}

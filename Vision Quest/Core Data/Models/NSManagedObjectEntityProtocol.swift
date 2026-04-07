//
//  NSManagedObjectEntityProtocol.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Foundation

///NSManagedObject methods to access managedObject in app
protocol NSManagedObjectEntityProtocol{
    ///entityname of the object
    static var entityName: String {get}
}

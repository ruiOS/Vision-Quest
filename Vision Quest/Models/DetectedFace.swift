//
//  DetectedFace.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 08/04/26.
//

import Foundation

struct DetectedFace {
    let id: UUID
    let assetId: String
    let boundingBoxX: Double
    let boundingBoxY: Double
    let boundingBoxWidth: Double
    let boundingBoxHeight: Double
    var personName: String?
    var personId: UUID?
}

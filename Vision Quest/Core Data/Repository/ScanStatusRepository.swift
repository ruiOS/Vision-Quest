//
//  ScanStatusRepository.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Foundation
import CoreData

protocol ScanStatusRepositoryProtocol {
    func isProcessed(_ assetId: String) -> Bool
    func markProcessed(_ assetId: String)
    func prefetchAllProcessedIDs() -> Set<String>
}

final class ScanStatusRepository: ScanStatusRepositoryProtocol {
    private let context = PersistentStorage.shared.context
    private var cache: Set<String> = []
    private var isCacheLoaded = false
    
    func prefetchAllProcessedIDs() -> Set<String> {
        if isCacheLoaded { return cache }
        let result: [CDScannedAsset]? = PersistentStorage.shared.fetchObjects()
        cache = Set(result?.map { $0.assetId } ?? [])
        isCacheLoaded = true
        return cache
    }
    
    func isProcessed(_ assetId: String) -> Bool {
        if !isCacheLoaded {
            _ = prefetchAllProcessedIDs()
        }
        return cache.contains(assetId)
    }
    
    func markProcessed(_ assetId: String) {
        if !isCacheLoaded {
            _ = prefetchAllProcessedIDs()
        }
        
        guard !cache.contains(assetId) else { return }
        
        context.perform {
            let newRecord = CDScannedAsset(context: self.context)
            newRecord.assetId = assetId
            PersistentStorage.shared.saveContext()
            
            DispatchQueue.main.async {
                self.cache.insert(assetId)
            }
        }
    }
}

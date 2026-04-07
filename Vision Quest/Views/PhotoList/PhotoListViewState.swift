//
//  PhotoListViewState.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import Foundation

enum PhotoListViewState<T> {
    case loading
    case error
    case success(T)
}

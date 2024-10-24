//
//  File.swift
//  SwiftDataHelper
//
//  Created by macbook on 23.10.2024.
//

import SwiftData
import Foundation

/// A protocol that represents an identifiable model in SwiftData.
/// It combines `PersistentModel` and `Sendable` to ensure that models can be safely
/// passed across concurrency contexts and have a unique identifier.
///
/// Any model conforming to this protocol must define a unique `id` property.
public protocol IdentifiableModel: PersistentModel, Sendable {
    
    /// A unique identifier for the model.
    /// This identifier is a `String` and must be implemented by any conforming model.
    var id: String { get set }
}


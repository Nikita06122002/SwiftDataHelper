//
//  Database.swift
//  SwiftDataHelper
//
//  Created by macbook on 23.10.2024.
//

import Foundation
import Dependencies
import SwiftData

/// A global extension for accessing the database service dependency through `DependencyValues`.
/// This allows any part of the application to access the `Database` service by using
/// `DependencyValues.databaseService`.
extension DependencyValues {
    
    /// Provides access to the `Database` service, which allows retrieval of a `ModelContext`
    /// for performing database operations within the SwiftData context.
    var databaseService: Database {
        get { self[Database.self] }
        set { self[Database.self] = newValue }
    }
}

/// A `Database` struct that encapsulates a function to provide a `ModelContext`.
/// This context is used to interact with the underlying SwiftData container.
///
/// The `Database` is isolated on the `MainActor` to ensure that all operations on
/// the `ModelContext` are performed safely on the main thread.
@MainActor
struct Database {
    
    /// A closure that returns a `ModelContext` when called. This context is the main entry point
    /// for interacting with the SwiftData storage, such as performing fetches, inserts, updates, and deletions.
    ///
    /// - Throws: An error if the `ModelContext` cannot be provided.
    var context: () throws -> ModelContext
}

/// Conforms the `Database` struct to the `DependencyKey` protocol, allowing it to be used as a key
/// in the `DependencyValues` container. This conformance is marked with `@preconcurrency` to ensure
/// compatibility with concurrent contexts and to avoid issues with concurrency checks.
extension Database: @preconcurrency DependencyKey {
    
    /// The live implementation of the `Database` service. This provides a real `ModelContext` by
    /// retrieving the `appContext` from the shared `SwiftDataModelConfigurationProvider`.
    ///
    /// This value is isolated on the `MainActor` to ensure that all database operations occur on
    /// the main thread, which is required for thread safety when interacting with the `ModelContext`.
    public static let liveValue: Database = {
        Database(
            context: {
                return appContext
            }
        )
    }()
}

/// A globally accessible `ModelContext` for the application, used to interact with the SwiftData
/// container. This context is isolated on the `MainActor` to ensure that all operations are performed
/// on the main thread, which is necessary for SwiftData operations.
///
/// The `appContext` is initialized using the `SwiftDataModelConfigurationProvider.shared.container`.
@MainActor
let appContext: ModelContext = {
    let container = SwiftDataModelConfigurationProvider.shared.container
    return ModelContext(container)
}()

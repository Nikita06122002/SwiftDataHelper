//
//  GenericDataBase.swift
//  SwiftDataHelper
//
//  Created by macbook on 23.10.2024.
//

import Foundation
import Dependencies
import SwiftData

/// A generic database service for managing models that conform to `IdentifiableModel`.
/// This struct provides various asynchronous operations for fetching, adding, deleting,
/// and saving models within a SwiftData context.
public struct GenericDatabase<Model: IdentifiableModel> {
    
    /// Fetches all instances of `Model` from the database.
    var fetchAll: @MainActor () async throws -> [Model]
    
    /// Fetches models that match the specified fetch descriptor.
    var fetch: @MainActor (FetchDescriptor<Model>) async throws -> [Model]
    
    /// Fetches the count of models that match the specified fetch descriptor.
    var fetchCount: @MainActor (FetchDescriptor<Model>) async throws -> Int
    
    /// Adds a new `Model` instance to the database.
    var add: @MainActor (Model) async throws -> Void
    
    /// Deletes the specified `Model` instance from the database.
    var delete: @MainActor (Model) async throws -> Void
    
    /// Deletes a `Model` instance from the database by its identifier.
    var deleteById: @MainActor (String) async throws -> Void
    
    /// Saves any pending changes in the database.
    var save: @MainActor () async throws -> Void
    
    /// Enum representing possible database-related errors.
    enum DatabaseError: Error {
        case add
        case delete
        case save
        case notFound
    }
}

extension GenericDatabase: DependencyKey {
    
    /// The live implementation of the `GenericDatabase` for dependency injection.
    public static var liveValue: Self {
        Self(
            fetchAll: { @MainActor in
                let context = try DependencyValues._current.databaseService.context()
                let descriptor = FetchDescriptor<Model>()
                return try context.fetch(descriptor)
            },
            fetch: { @MainActor descriptor in
                let context = try DependencyValues._current.databaseService.context()
                return try context.fetch(descriptor)
            },
            fetchCount: { @MainActor descriptor in
                let context = try DependencyValues._current.databaseService.context()
                return try context.fetchCount(descriptor)
            },
            add: { @MainActor model in
                let context = try DependencyValues._current.databaseService.context()
                context.insert(model)
                try context.save()
            },
            delete: { @MainActor model in
                let context = try DependencyValues._current.databaseService.context()
                context.delete(model)
                try context.save()
            },
            deleteById: { @MainActor id in
                let context = try DependencyValues._current.databaseService.context()
                let descriptor = FetchDescriptor<Model>(
                    predicate: #Predicate { $0.id == id }
                )
                guard let modelToDelete = try context.fetch(descriptor).first else {
                    throw GenericDatabase.DatabaseError.notFound
                }
                context.delete(modelToDelete)
                try context.save()
            },
            save: { @MainActor in
                let context = try DependencyValues._current.databaseService.context()
                try context.save()
            }
        )
    }
}

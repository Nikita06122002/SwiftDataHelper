//
//  ConfigProvider.swift
//  SwiftDataHelper
//
//  Created by macbook on 22.10.2024.
//

import Foundation
import SwiftData

/// A class that provides configuration and management for SwiftData `ModelContainer`.
/// This class follows the singleton pattern and manages the creation and configuration of
/// the `ModelContainer` used in the application for storing persistent data.
///
/// Available starting from iOS 17.
@available(iOS 17, *)
public class SwiftDataModelConfigurationProvider {
    
    /// A shared singleton instance of `SwiftDataModelConfigurationProvider`. This instance
    /// is used to manage and configure the `ModelContainer` throughout the application.
    ///
    /// - Note: The singleton is isolated on the `MainActor` to ensure thread safety when managing
    ///         SwiftData operations.
    @MainActor public static var shared: SwiftDataModelConfigurationProvider!

    // MARK: - Configuration Properties
    
    /// A boolean indicating whether the data is stored only in memory or persists on disk.
    private var isStoredInMemoryOnly: Bool
    
    /// A boolean indicating whether the `ModelContext` automatically saves changes.
    private var autosaveEnabled: Bool
    
    /// An array of model types conforming to `PersistentModel.Type`. This schema defines the models
    /// that will be used in the `ModelContainer`.
    private var schema: [any PersistentModel.Type]

    // MARK: - ModelContainer
    
    @MainActor
       public static func initializeSchema(_ schema: [any PersistentModel.Type], isStoredInMemoryOnly: Bool = false, autosaveEnabled: Bool = true) {
           shared = SwiftDataModelConfigurationProvider(isStoredInMemoryOnly: isStoredInMemoryOnly, autosaveEnabled: autosaveEnabled, schema: schema)
       }
       
    
    /// The `ModelContainer` used to interact with the persistent store.
    /// This property is isolated on the `MainActor` to ensure that all SwiftData operations
    /// occur on the main thread, ensuring thread safety.
    @MainActor
    public private(set) var container: ModelContainer

    // MARK: - Initialization
    
    /// Initializes a new `SwiftDataModelConfigurationProvider` with the specified options.
    /// This initializer is private to enforce the singleton pattern.
    ///
    /// - Parameters:
    ///   - isStoredInMemoryOnly: A boolean that determines if the data is stored only in memory.
    ///   - autosaveEnabled: A boolean that enables automatic saving of changes in the `ModelContext`.
    ///   - schema: An array of model types that conform to `PersistentModel.Type` to define the schema.
    @MainActor
      private init(isStoredInMemoryOnly: Bool, autosaveEnabled: Bool, schema: [any PersistentModel.Type]) {
          self.isStoredInMemoryOnly = isStoredInMemoryOnly
          self.autosaveEnabled = autosaveEnabled
          self.schema = schema

          self.container = try! SwiftDataModelConfigurationProvider.createContainer(schema: schema, isStoredInMemoryOnly: isStoredInMemoryOnly, autosaveEnabled: autosaveEnabled)
      }

    // MARK: - Private Helper Methods
    
    /// Creates a new `ModelContainer` with the given schema and configuration options.
    ///
    /// - Parameters:
    ///   - schema: An array of model types conforming to `PersistentModel.Type` to define the schema.
    ///   - isStoredInMemoryOnly: A boolean that determines if the data is stored only in memory.
    ///   - autosaveEnabled: A boolean that enables automatic saving of changes in the `ModelContext`.
    /// - Returns: A new `ModelContainer` configured with the given schema and options.
    /// - Throws: An error if the container cannot be created with the provided schema.
    @MainActor
       private static func createContainer(schema: [any PersistentModel.Type], isStoredInMemoryOnly: Bool, autosaveEnabled: Bool) throws -> ModelContainer {
           let schema = Schema(schema)
           let configuration = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)
           let container = try ModelContainer(for: schema, configurations: [configuration])
           container.mainContext.autosaveEnabled = autosaveEnabled
           return container
       }
}

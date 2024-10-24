# SwiftDataHelper

A library to help manage and work with SwiftData databases in a SwiftUI project using TCA (The Composable Architecture)(not necessary) and Dependencies.

## Installation

To install SwiftDataHelper using Swift Package Manager, add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Nikita06122002/SwiftDataHelper", from: "1.0.0")
]
```

Or File -> Add Package Dependencies... -> paste url https://github.com/Nikita06122002/SwiftDataHelper to search field and download this package

# Configuration

In your `App` file (or wherever your SwiftUI entry point is), configure the SwiftData model by initializing it in the `init` method. For example:

```swift
@main
struct YourApp: App {
    init() {
        SwiftDataModelConfigurationProvider.initializeSchema([ YourModel.self ])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
           .modelContainer(SwiftDataModelConfigurationProvider.shared.container)
    }
}
```
This setup ensures that your SwiftData models are properly configured and managed throughout the app lifecycle.


# Usage with Dependencies

In the file where you are managing your dependencies, import `SwiftDataHelper` and `Dependencies`:

```swift
import SwiftDataHelper
import Dependencies
extension DependencyValues {

    var database: GenericDatabase<YourModel> {
        get { self[GenericDatabase<YourModel>.self] }
        set { self[GenericDatabase<YourModel>.self] = newValue }
    }
}
```
Here, GenericDatabase is a generic type that manages your models conforming to the IdentifiableModel protocol. Your model should be marked with the @Model attribute from SwiftData.

# Working with the Database

In the file that handles your database operations, inject the database using TCA's `Dependency` property wrapper:

```swift
@Dependency(\.database) var database
```

# Database Methods Overview

Now you can use the provided methods to interact with the database:

- `fetchAll`: Fetches all instances of `Model` from the database.
- `fetch`: Fetches models that match the specified fetch descriptor.
- `fetchCount`: Fetches the count of models that match the specified fetch descriptor.
- `add`: Adds a new `Model` instance to the database.
- `delete`: Deletes the specified `Model` instance from the database.
- `deleteById`: Deletes a `Model` instance from the database by its identifier.
- `save`: Saves any pending changes in the database.

These methods are asynchronous and designed to work with Swift's concurrency model using `async`/`await`.

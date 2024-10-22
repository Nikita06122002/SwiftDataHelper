import XCTest
import SwiftData
import Dependencies

@testable import SwiftDataHelper

@MainActor
final class TestContextActor: @unchecked Sendable {
    var context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [TestModel] {
        let descriptor = FetchDescriptor<TestModel>()
        return try context.fetch(descriptor)
    }

    func fetch(_ descriptor: FetchDescriptor<TestModel>) throws -> [TestModel] {
        return try context.fetch(descriptor)
    }

    func fetchCount(_ descriptor: FetchDescriptor<TestModel>) throws -> Int {
        return try context.fetchCount(descriptor)
    }

    func add(_ model: TestModel) throws {
        context.insert(model)
        try context.save()
    }

    func delete(_ model: TestModel) throws {
        context.delete(model)
        try context.save()
    }

    func deleteById(_ id: String) throws {
        let descriptor = FetchDescriptor<TestModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let modelToDelete = try context.fetch(descriptor).first else {
            throw GenericDatabase<TestModel>.DatabaseError.notFound
        }
        context.delete(modelToDelete)
        try context.save()
    }

    func save() throws {
        try context.save()
    }
}

@Model
class TestModel: IdentifiableModel, @unchecked Sendable {
    var id: String
    var name: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

final class GenericDatabaseTests: XCTestCase, @unchecked Sendable {

    var container: ModelContainer!
    var testDatabase: GenericDatabase<TestModel>!
    var contextActor: TestContextActor!

    override func setUp() async throws {
        try await super.setUp()

        contextActor = await MainActor.run {
                  let schema = Schema([TestModel.self])
                  let container = try! ModelContainer(for: schema, configurations: [ModelConfiguration(isStoredInMemoryOnly: true)])
                  let context = ModelContext(container)
                  return TestContextActor(context: context)
              }

        let localOperations = contextActor

        testDatabase = GenericDatabase<TestModel>(
            fetchAll: {
                try localOperations?.fetchAll() ?? []
            },
            fetch: { descriptor in
                try localOperations?.fetch(descriptor) ?? []
            },
            fetchCount: { descriptor in
                try localOperations?.fetchCount(descriptor) ?? 0
            },
            add: { model in
                try localOperations?.add(model)
            },
            delete: { model in
                try localOperations?.delete(model)
            },
            deleteById: { id in
                try localOperations?.deleteById(id)
            },
            save: {
                try localOperations?.save()
            }
        )
    }
    @MainActor
     override func tearDown() async throws {
         self.container = nil
         self.contextActor = nil
         self.testDatabase = nil
         try await super.tearDown()
     }

      @MainActor
      private func setUpResources() {
          let schema = Schema([TestModel.self])
          self.container = try! ModelContainer(for: schema, configurations: [ModelConfiguration(isStoredInMemoryOnly: true)])
          let context = ModelContext(self.container)
          self.contextActor = TestContextActor(context: context)
      }
    
    @MainActor
        private func clearResources() {
            self.container = nil
            self.contextActor = nil
            self.testDatabase = nil
        }

    func testFetchAll() async throws {
        let model1 = TestModel(id: "1", name: "Test1")
        let model2 = TestModel(id: "2", name: "Test2")

        try await testDatabase.add(model1)
        try await testDatabase.add(model2)

        let allModels = try await testDatabase.fetchAll()
        XCTAssertEqual(allModels.count, 2)
        XCTAssertEqual(allModels.first?.name, "Test1")
    }

    func testFetchWithDescriptor() async throws {
        let model1 = TestModel(id: "1", name: "Test1")
        let model2 = TestModel(id: "2", name: "Test2")

        try await testDatabase.add(model1)
        try await testDatabase.add(model2)

        let descriptor = FetchDescriptor<TestModel>(
            predicate: #Predicate { $0.id == "1" }
        )

        let fetchedModels = try await testDatabase.fetch(descriptor)
        XCTAssertEqual(fetchedModels.count, 1)
        XCTAssertEqual(fetchedModels.first?.name, "Test1")
    }

    func testFetchCount() async throws {
        let model1 = TestModel(id: "1", name: "Test1")
        let model2 = TestModel(id: "2", name: "Test2")

        try await testDatabase.add(model1)
        try await testDatabase.add(model2)

        let descriptor = FetchDescriptor<TestModel>(
            predicate: #Predicate { _ in true }
        )

        let count = try await testDatabase.fetchCount(descriptor)
        XCTAssertEqual(count, 2)
    }

    func testAddModel() async throws {
        let model = TestModel(id: "1", name: "Test1")
        try await testDatabase.add(model)

        let allModels = try await testDatabase.fetchAll()
        XCTAssertEqual(allModels.count, 1)
        XCTAssertEqual(allModels.first?.name, "Test1")
    }

    func testDeleteModel() async throws {
        let model1 = TestModel(id: "1", name: "Test1")
        let model2 = TestModel(id: "2", name: "Test2")

        try await testDatabase.add(model1)
        try await testDatabase.add(model2)

        try await testDatabase.delete(model1)

        let allModels = try await testDatabase.fetchAll()
        XCTAssertEqual(allModels.count, 1)
        XCTAssertEqual(allModels.first?.name, "Test2")
    }

    func testDeleteById() async throws {
        let model1 = TestModel(id: "1", name: "Test1")
        let model2 = TestModel(id: "2", name: "Test2")

        try await testDatabase.add(model1)
        try await testDatabase.add(model2)

        try await testDatabase.deleteById("1")

        let allModels = try await testDatabase.fetchAll()
        XCTAssertEqual(allModels.count, 1)
        XCTAssertEqual(allModels.first?.id, "2")
    }
}

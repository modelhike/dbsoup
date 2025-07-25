import Foundation
@testable import DBSoupParser

// MARK: - Test Framework

class DBSoupTest {
    private var testCount = 0
    private var passedTests = 0
    private var failedTests = 0
    
    func runAllTests() {
        print("🧪 Running DBSoup Parser Tests")
        print("==============================")
        print("")
        
        // Run individual test methods
            testBasicParsing()
            testRelationshipParsing()
            testFieldParsing()
            testDataTypeParsing()
            testValidation()
            testFormatting()
            testStatistics()
        
        printSummary()
    }
    
    private func testBasicParsing() {
        printTestHeader("Basic Parsing")
        
        let simpleDBSoup = """
        @test.dbsoup
        
        === DATABASE SCHEMA ===
        + Core
        
        === Core ===
        
        User
        ==========
        * id      : String     [PK]
        * name    : String
        - email   : String     [INDEX]
        """
        
        test("Parse simple DBSoup document") {
            let parser = DBSoupParser(content: simpleDBSoup)
            let document = try parser.parse()
            
            assert(document.header?.filename == "test", "Header filename should be 'test'")
            assert(document.schemaDefinition.modules.count == 1, "Should have 1 module")
            assert(document.schemaDefinition.moduleSections.count == 1, "Should have 1 module section")
            
            let coreSection = document.schemaDefinition.moduleSections.first!
            assert(coreSection.name == "Core", "Module name should be 'Core'")
            assert(coreSection.entities.count == 1, "Should have 1 entity")
            
            let userEntity = coreSection.entities.first!
            assert(userEntity.name == "User", "Entity name should be 'User'")
            assert(userEntity.type == .standard, "Entity should be standard type")
            assert(userEntity.fields.count == 3, "Should have 3 fields")
        }
    }
    
    private func testRelationshipParsing() {
        printTestHeader("Relationship Parsing")
        
        let relationshipDBSoup = """
        @test.dbsoup
        
        === RELATIONSHIP DEFINITIONS ===
        # One-to-Many Relationships
        User -> Post [1:M] (composition)
        Account -> User [1:M] (aggregation)
        
        # Many-to-Many Relationships
        User -> Role [M:N] (association) via UserRole
        
        === DATABASE SCHEMA ===
        + Core
        
        === Core ===
        
        User
        ==========
        * id : String [PK]
        """
        
        test("Parse relationship definitions") {
            let parser = DBSoupParser(content: relationshipDBSoup)
            let document = try parser.parse()
            
            guard let relationships = document.relationshipDefinitions else {
                throw TestError("No relationship definitions found")
            }
            
            assert(relationships.relationships.count == 3, "Should have 3 relationships")
            
            let userPostRel = relationships.relationships.first!
            assert(userPostRel.fromEntity == "User", "From entity should be 'User'")
            assert(userPostRel.toEntity == "Post", "To entity should be 'Post'")
            assert(userPostRel.cardinality == .oneToMany, "Cardinality should be 1:M")
            assert(userPostRel.nature == .composition, "Nature should be composition")
            
            let userRoleRel = relationships.relationships.last!
            assert(userRoleRel.viaEntity == "UserRole", "Via entity should be 'UserRole'")
        }
    }
    
    private func testFieldParsing() {
        printTestHeader("Field Parsing")
        
        let fieldDBSoup = """
        @test.dbsoup
        
        === DATABASE SCHEMA ===
        + Core
        
        === Core ===
        
        User
        ==========
        * id              : String                 [PK]
        - name, firstName : String(50)             [INDEX]
        @ password        : String                 [ENCRYPTED]
        ! email           : String                 [UK,INDEX]
        * created_at      : DateTime               [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
        - preferences     : JSON                   
        """
        
        test("Parse field definitions with various prefixes") {
            let parser = DBSoupParser(content: fieldDBSoup)
            let document = try parser.parse()
            
            let userEntity = document.schemaDefinition.moduleSections.first!.entities.first!
            assert(userEntity.fields.count == 6, "Should have 6 fields")
            
            let idField = userEntity.fields[0]
            assert(idField.prefixes.contains(.required), "ID field should be required")
            assert(idField.names == ["id"], "ID field should have one name")
            assert(idField.constraints.contains { $0.name == "PK" }, "ID field should have PK constraint")
            
            let nameField = userEntity.fields[1]
            assert(nameField.prefixes.contains(.optional), "Name field should be optional")
            assert(nameField.names == ["name", "firstName"], "Name field should have multiple names")
            
            let passwordField = userEntity.fields[2]
            assert(passwordField.prefixes.contains(.sensitive), "Password field should be sensitive")
            assert(passwordField.constraints.contains { $0.name == "ENCRYPTED" }, "Password should have ENCRYPTED constraint")
            
            let emailField = userEntity.fields[3]
            assert(emailField.prefixes.contains(.indexed), "Email field should be indexed")
        }
    }
    
    private func testDataTypeParsing() {
        printTestHeader("Data Type Parsing")
        
        let dataTypeDBSoup = """
        @test.dbsoup
        
        === DATABASE SCHEMA ===
        + Core
        
        === Core ===
        
        TestEntity
        ==========
        * simpleField     : String
        * parametricField : Decimal(10,2)
        * arrayField      : Array<String>
        * relationField   : Category[1..*]
        * jsonField       : JSON
        """
        
        test("Parse various data types") {
            let parser = DBSoupParser(content: dataTypeDBSoup)
            let document = try parser.parse()
            
            let entity = document.schemaDefinition.moduleSections.first!.entities.first!
            let fields = entity.fields
            
            // Simple type
            if case .simple(let type) = fields[0].dataType {
                assert(type == "String", "Simple field should be String type")
            } else {
                throw TestError("Expected simple data type")
            }
            
            // Parametric type
            if case .parametric(let type, let params) = fields[1].dataType {
                assert(type == "Decimal", "Parametric field should be Decimal type")
                assert(params == ["10", "2"], "Decimal should have precision and scale")
            } else {
                throw TestError("Expected parametric data type")
            }
            
            // Array type
            if case .array(let innerType) = fields[2].dataType {
                if case .simple(let type) = innerType {
                    assert(type == "String", "Array inner type should be String")
                } else {
                    throw TestError("Expected simple inner type")
                }
            } else {
                throw TestError("Expected array data type")
            }
            
            // Relationship array type
            if case .relationshipArray(let entityName, let cardinality) = fields[3].dataType {
                assert(entityName == "Category", "Relationship entity should be Category")
                assert(cardinality.min == 1, "Minimum cardinality should be 1")
                if case .unlimited = cardinality.max {
                    // Correct
                } else {
                    throw TestError("Expected unlimited cardinality")
                }
            } else {
                throw TestError("Expected relationship array data type")
            }
        }
    }
    
    private func testValidation() {
        printTestHeader("Validation")
        
        let invalidDBSoup = """
        @test.dbsoup
        
        === DATABASE SCHEMA ===
        + Core
        
        === Core ===
        
        User
        ==========
        * name : String
        """
        
        test("Validate DBSoup document with missing primary key") {
            let parser = DBSoupParser(content: invalidDBSoup)
            let document = try parser.parse()
            
            let validator = DBSoupValidator(document: document)
            let result = validator.validate()
            
            assert(!result.isValid, "Document should be invalid")
            assert(result.errors.count > 0, "Should have validation errors")
            
            let hasPrimaryKeyError = result.errors.contains { error in
                if case .missingPrimaryKey = error {
                    return true
                }
                return false
            }
            assert(hasPrimaryKeyError, "Should have missing primary key error")
        }
    }
    
    private func testFormatting() {
        printTestHeader("Formatting")
        
        let inputDBSoup = """
        @test.dbsoup
        
        === DATABASE SCHEMA ===
        + Core
        
        === Core ===
        
        User
        ==========
        * id   : String [PK]
        * name : String
        """
        
        test("Format DBSoup from parsed document") {
            let parser = DBSoupParser(content: inputDBSoup)
            let document = try parser.parse()
            
            let formatter = DBSoupFormatter()
            let output = formatter.format(document: document)
            
            assert(output.contains("@test.dbsoup"), "Output should contain header")
            assert(output.contains("=== DATABASE SCHEMA ==="), "Output should contain schema section")
            assert(output.contains("User"), "Output should contain User entity")
            assert(output.contains("* id"), "Output should contain id field")
            assert(output.contains("[PK]"), "Output should contain PK constraint")
        }
    }
    
    private func testStatistics() {
        printTestHeader("Statistics")
        
        let statsDBSoup = """
        @test.dbsoup
        
        === RELATIONSHIP DEFINITIONS ===
        # One-to-Many Relationships
        User -> Post [1:M] (composition)
        
        === DATABASE SCHEMA ===
        + Core
        + Auth
        
        === Core ===
        
        User
        ==========
        * id   : String [PK]
        * name : String
        
        Post
        ==========
        * id     : String [PK]
        * title  : String
        * userId : String [FK:User.id]
        
        === Auth ===
        
        Session
        ==========
        * id     : String [PK]
        * userId : String [FK:User.id]
        """
        
        test("Generate statistics for DBSoup document") {
            let parser = DBSoupParser(content: statsDBSoup)
            let document = try parser.parse()
            
            let statsGenerator = DBSoupStatisticsGenerator()
            let statistics = statsGenerator.generateStatistics(for: document)
            
            assert(statistics.totalEntities == 3, "Should have 3 entities")
            assert(statistics.standardEntities == 3, "Should have 3 standard entities")
            assert(statistics.embeddedEntities == 0, "Should have 0 embedded entities")
            assert(statistics.totalRelationships == 1, "Should have 1 relationship")
            assert(statistics.moduleCount == 2, "Should have 2 modules")
            assert(statistics.modules["Core"] == 2, "Core module should have 2 entities")
            assert(statistics.modules["Auth"] == 1, "Auth module should have 1 entity")
        }
    }
    
    // MARK: - Test Utilities
    
    private func test(_ description: String, block: () throws -> Void) {
        testCount += 1
        do {
            try block()
            print("  ✅ \(description)")
            passedTests += 1
        } catch {
            print("  ❌ \(description)")
            print("     Error: \(error)")
            failedTests += 1
        }
    }
    
    private func assert(_ condition: Bool, _ message: String) {
        testCount += 1
        if condition {
            passedTests += 1
        } else {
            failedTests += 1
            print("  ❌ FAILED: \(message)")
        }
    }
    
    private func printTestHeader(_ title: String) {
        print("\n📋 \(title)")
        print(String(repeating: "-", count: title.count + 3))
    }
    
    private func printSummary() {
        print("\n📊 Test Summary")
        print("===============")
        print("Total Tests: \(testCount)")
        print("Passed: \(passedTests)")
        print("Failed: \(failedTests)")
        
        if failedTests == 0 {
            print("\n🎉 All tests passed!")
        } else {
            print("\n⚠️  \(failedTests) test(s) failed")
        }
    }
}

// MARK: - Test Error

struct TestError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
}

extension TestError: LocalizedError {
    var errorDescription: String? {
        return message
    }
}

// MARK: - Main Entry Point

// Uncomment to run tests
// DBSoupTest().runAllTests() 
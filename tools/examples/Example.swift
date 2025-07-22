import Foundation

// MARK: - Example Usage

class DBSoupExample {
    
    func runExample() {
        print("🚀 DBSoup Parser Example")
        print("========================")
        print("")
        
        // Path to the roadwarrior.dbsoup file
        let dbsoupPath = "converted/dbsoup/schema/roadwarrior/20250711/roadwarrior.dbsoup"
        
        do {
            // 1. Parse the DBSoup file
            print("📖 Parsing DBSoup file...")
            let document = try parseDBSoupFile(path: dbsoupPath)
            
            // 2. Display basic information
            displayBasicInfo(document)
            
            // 3. Validate the document
            print("\n🔍 Validating schema...")
            validateSchema(document)
            
            // 4. Generate statistics
            print("\n📊 Generating statistics...")
            generateStatistics(document)
            
            // 5. Demonstrate formatting
            print("\n✨ Formatting example...")
            demonstrateFormatting(document)
            
            // 6. Show entity details
            print("\n🏗️ Entity details...")
            showEntityDetails(document)
            
        } catch {
            print("❌ Error: \(error)")
        }
    }
    
    // MARK: - Parse DBSoup File
    
    private func parseDBSoupFile(path: String) throws -> DBSoupDocument {
        // Check if file exists
        guard FileManager.default.fileExists(atPath: path) else {
            throw ExampleError.fileNotFound(path)
        }
        
        // Read file content
        let content = try String(contentsOfFile: path, encoding: .utf8)
        
        // Parse with DBSoup parser
        let parser = DBSoupParser(content: content)
        return try parser.parse()
    }
    
    // MARK: - Display Basic Information
    
    private func displayBasicInfo(_ document: DBSoupDocument) {
        print("✅ Successfully parsed DBSoup file!")
        print("")
        
        if let header = document.header {
            print("📋 Header: @\(header.filename).dbsoup")
        }
        
        if let relationships = document.relationshipDefinitions {
            print("🔗 Relationships: \(relationships.relationships.count)")
            
            // Group relationships by type
            let relationshipGroups = Dictionary(grouping: relationships.relationships) { $0.cardinality }
            for (cardinality, rels) in relationshipGroups {
                print("   • \(cardinality.rawValue): \(rels.count)")
            }
        }
        
        print("📦 Modules: \(document.schemaDefinition.modules.joined(separator: ", "))")
        
        let totalEntities = document.schemaDefinition.moduleSections.reduce(0) { $0 + $1.entities.count }
        let totalFields = document.schemaDefinition.moduleSections.reduce(0) { total, section in
            total + section.entities.reduce(0) { $0 + $1.fields.count }
        }
        
        print("🏗️ Total Entities: \(totalEntities)")
        print("📝 Total Fields: \(totalFields)")
    }
    
    // MARK: - Validate Schema
    
    private func validateSchema(_ document: DBSoupDocument) {
        let validator = DBSoupValidator(document: document)
        let result = validator.validate()
        
        if result.isValid {
            print("✅ Schema is valid!")
        } else {
            print("❌ Schema validation failed:")
            for error in result.errors {
                print("   • \(error.localizedDescription)")
            }
        }
        
        if !result.warnings.isEmpty {
            print("⚠️  Warnings:")
            for warning in result.warnings {
                print("   • \(warning)")
            }
        }
        
        print("📊 Summary: \(result.errors.count) errors, \(result.warnings.count) warnings")
    }
    
    // MARK: - Generate Statistics
    
    private func generateStatistics(_ document: DBSoupDocument) {
        let statsGenerator = DBSoupStatisticsGenerator()
        let statistics = statsGenerator.generateStatistics(for: document)
        
        print("📈 Schema Statistics:")
        print("   • Total Entities: \(statistics.totalEntities)")
        print("   • Standard Entities: \(statistics.standardEntities)")
        print("   • Embedded Entities: \(statistics.embeddedEntities)")
        print("   • Total Fields: \(statistics.totalFields)")
        print("   • Total Relationships: \(statistics.totalRelationships)")
        print("   • Modules: \(statistics.moduleCount)")
        
        print("\n📊 Top Data Types:")
        let sortedDataTypes = statistics.dataTypes.sorted { $0.value > $1.value }
        for (index, (dataType, count)) in sortedDataTypes.prefix(5).enumerated() {
            print("   \(index + 1). \(dataType): \(count)")
        }
        
        print("\n🏷️ Top Constraints:")
        let sortedConstraints = statistics.constraints.sorted { $0.value > $1.value }
        for (index, (constraint, count)) in sortedConstraints.prefix(5).enumerated() {
            print("   \(index + 1). \(constraint): \(count)")
        }
        
        print("\n📦 Entities per Module:")
        for (module, count) in statistics.modules.sorted(by: { $0.key < $1.key }) {
            print("   • \(module): \(count) entities")
        }
    }
    
    // MARK: - Demonstrate Formatting
    
    private func demonstrateFormatting(_ document: DBSoupDocument) {
        // Create a custom configuration
        let config = DBSoupFormatterConfig(
            fieldNameWidth: 18,
            dataTypeWidth: 22,
            constraintColumnStart: 42,
            includeComments: true,
            sortEntitiesAlphabetically: false,
            sortFieldsAlphabetically: false
        )
        
        let formatter = DBSoupFormatter(config: config)
        
        // Generate formatted output for just the User entity
        if let coreModule = document.schemaDefinition.moduleSections.first(where: { $0.name == "Core" }),
           let userEntity = coreModule.entities.first(where: { $0.name == "User" }) {
            
            // Create a minimal document with just the User entity
            let sampleModule = ModuleSection(name: "Core", entities: [userEntity])
            let sampleSchema = SchemaDefinition(modules: ["Core"], moduleSections: [sampleModule])
            let sampleDocument = DBSoupDocument(
                header: document.header,
                relationshipDefinitions: nil,
                schemaDefinition: sampleSchema
            )
            
            print("✨ Formatted User Entity:")
            print("```")
            let formattedOutput = formatter.format(document: sampleDocument)
            print(formattedOutput)
            print("```")
        }
    }
    
    // MARK: - Show Entity Details
    
    private func showEntityDetails(_ document: DBSoupDocument) {
        // Show details for each module
        for section in document.schemaDefinition.moduleSections {
            print("\n📦 Module: \(section.name)")
            print("   Entities: \(section.entities.count)")
            
            for entity in section.entities {
                let typeIcon = entity.type == .standard ? "🏗️" : "🔗"
                print("   \(typeIcon) \(entity.name)")
                
                // Count field types
                let fieldsByPrefix = Dictionary(grouping: entity.fields) { field in
                    field.prefixes.first?.rawValue ?? "?"
                }
                
                var fieldSummary: [String] = []
                if let required = fieldsByPrefix["*"] {
                    fieldSummary.append("\(required.count) required")
                }
                if let optional = fieldsByPrefix["-"] {
                    fieldSummary.append("\(optional.count) optional")
                }
                if let indexed = fieldsByPrefix["!"] {
                    fieldSummary.append("\(indexed.count) indexed")
                }
                if let sensitive = fieldsByPrefix["@"] {
                    fieldSummary.append("\(sensitive.count) sensitive")
                }
                
                print("      Fields: \(entity.fields.count) (\(fieldSummary.joined(separator: ", ")))")
                
                // Show primary key
                let primaryKeyFields = entity.fields.filter { field in
                    field.constraints.contains { $0.name == "PK" }
                }
                if !primaryKeyFields.isEmpty {
                    let pkNames = primaryKeyFields.flatMap { $0.names }
                    print("      Primary Key: \(pkNames.joined(separator: ", "))")
                }
                
                // Show foreign keys
                let foreignKeyFields = entity.fields.filter { field in
                    field.constraints.contains { $0.name == "FK" }
                }
                if !foreignKeyFields.isEmpty {
                    print("      Foreign Keys: \(foreignKeyFields.count)")
                    for fkField in foreignKeyFields {
                        if let fkConstraint = fkField.constraints.first(where: { $0.name == "FK" }),
                           let fkValue = fkConstraint.value {
                            print("         \(fkField.names.joined(separator: ", ")) -> \(fkValue)")
                        }
                    }
                }
                
                // Show relationships if any
                if !entity.relationshipSections.isEmpty {
                    print("      Relationships: \(entity.relationshipSections.count) sections")
                }
            }
        }
    }
    
    // MARK: - Demonstrate Query Capabilities
    
    private func demonstrateQueries(_ document: DBSoupDocument) {
        print("\n🔍 Query Examples:")
        
        // Find all entities with a specific field
        let entitiesWithEmail = findEntitiesWithField(document, fieldName: "Email")
        print("   Entities with 'Email' field: \(entitiesWithEmail.map { $0.name }.joined(separator: ", "))")
        
        // Find all entities with foreign keys
        let entitiesWithForeignKeys = findEntitiesWithForeignKeys(document)
        print("   Entities with foreign keys: \(entitiesWithForeignKeys.map { $0.name }.joined(separator: ", "))")
        
        // Find entities by data type
        let entitiesWithDateTime = findEntitiesWithDataType(document, dataType: "DateTime")
        print("   Entities with DateTime fields: \(entitiesWithDateTime.map { $0.name }.joined(separator: ", "))")
    }
    
    // MARK: - Helper Query Methods
    
    private func findEntitiesWithField(_ document: DBSoupDocument, fieldName: String) -> [Entity] {
        var result: [Entity] = []
        
        for section in document.schemaDefinition.moduleSections {
            for entity in section.entities {
                if entity.fields.contains(where: { $0.names.contains(fieldName) }) {
                    result.append(entity)
                }
            }
        }
        
        return result
    }
    
    private func findEntitiesWithForeignKeys(_ document: DBSoupDocument) -> [Entity] {
        var result: [Entity] = []
        
        for section in document.schemaDefinition.moduleSections {
            for entity in section.entities {
                let hasForeignKey = entity.fields.contains { field in
                    field.constraints.contains { $0.name == "FK" }
                }
                if hasForeignKey {
                    result.append(entity)
                }
            }
        }
        
        return result
    }
    
    private func findEntitiesWithDataType(_ document: DBSoupDocument, dataType: String) -> [Entity] {
        var result: [Entity] = []
        
        for section in document.schemaDefinition.moduleSections {
            for entity in section.entities {
                let hasDataType = entity.fields.contains { field in
                    switch field.dataType {
                    case .simple(let type):
                        return type == dataType
                    case .parametric(let type, _):
                        return type == dataType
                    default:
                        return false
                    }
                }
                if hasDataType {
                    result.append(entity)
                }
            }
        }
        
        return result
    }
}

// MARK: - Error Types

enum ExampleError: Error, LocalizedError {
    case fileNotFound(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "File not found: \(path)"
        }
    }
}

// MARK: - Main Entry Point

// Uncomment to run the example
// DBSoupExample().runExample() 
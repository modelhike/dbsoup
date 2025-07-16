import Foundation

// MARK: - Validation Errors

public enum DBSoupValidationError: Error, LocalizedError {
    case duplicateEntityName(String)
    case duplicateFieldName(String, entity: String)
    case invalidFieldPrefix(String, entity: String)
    case invalidDataType(String, entity: String, field: String)
    case invalidConstraint(String, entity: String, field: String)
    case missingPrimaryKey(String)
    case invalidForeignKey(String, entity: String, field: String)
    case circularReference(String)
    case invalidRelationship(String)
    case invalidCardinality(String)
    case missingRequiredEntity(String)
    case inconsistentRelationship(String)
    
    public var errorDescription: String? {
        switch self {
        case .duplicateEntityName(let name):
            return "Duplicate entity name: \(name)"
        case .duplicateFieldName(let field, let entity):
            return "Duplicate field name '\(field)' in entity '\(entity)'"
        case .invalidFieldPrefix(let prefix, let entity):
            return "Invalid field prefix '\(prefix)' in entity '\(entity)'"
        case .invalidDataType(let type, let entity, let field):
            return "Invalid data type '\(type)' for field '\(field)' in entity '\(entity)'"
        case .invalidConstraint(let constraint, let entity, let field):
            return "Invalid constraint '\(constraint)' for field '\(field)' in entity '\(entity)'"
        case .missingPrimaryKey(let entity):
            return "Missing primary key in entity '\(entity)'"
        case .invalidForeignKey(let fk, let entity, let field):
            return "Invalid foreign key '\(fk)' for field '\(field)' in entity '\(entity)'"
        case .circularReference(let description):
            return "Circular reference detected: \(description)"
        case .invalidRelationship(let description):
            return "Invalid relationship: \(description)"
        case .invalidCardinality(let description):
            return "Invalid cardinality: \(description)"
        case .missingRequiredEntity(let entity):
            return "Missing required entity: \(entity)"
        case .inconsistentRelationship(let description):
            return "Inconsistent relationship: \(description)"
        }
    }
}

// MARK: - Validation Results

public struct DBSoupValidationResult {
    public let isValid: Bool
    public let errors: [DBSoupValidationError]
    public let warnings: [String]
    
    public init(isValid: Bool, errors: [DBSoupValidationError], warnings: [String] = []) {
        self.isValid = isValid
        self.errors = errors
        self.warnings = warnings
    }
}

// MARK: - Validator

public class DBSoupValidator {
    private let document: DBSoupDocument
    private var errors: [DBSoupValidationError] = []
    private var warnings: [String] = []
    
    public init(document: DBSoupDocument) {
        self.document = document
    }
    
    public func validate() -> DBSoupValidationResult {
        errors.removeAll()
        warnings.removeAll()
        
        validateHeader()
        validateRelationships()
        validateSchema()
        validateComplexStructures()
        validateCrossReferences()
        
        return DBSoupValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    // MARK: - Header Validation
    
    private func validateHeader() {
        guard let header = document.header else {
            warnings.append("No header found in document")
            return
        }
        
        if header.filename.isEmpty {
            warnings.append("Empty filename in header")
        }
        
        if !header.filename.isValidIdentifier() {
            warnings.append("Header filename should be a valid identifier")
        }
    }
    
    // MARK: - Relationship Validation
    
    private func validateRelationships() {
        guard let relationships = document.relationshipDefinitions else {
            warnings.append("No relationship definitions found")
            return
        }
        
        let entityNames = getAllEntityNames()
        
        for relationship in relationships.relationships {
            validateRelationship(relationship, entityNames: entityNames)
        }
        
        // Check for circular references
        detectCircularReferences(relationships.relationships)
    }
    
    private func validateRelationship(_ relationship: Relationship, entityNames: Set<String>) {
        // Check if entities exist
        if !entityNames.contains(relationship.fromEntity) {
            errors.append(.missingRequiredEntity(relationship.fromEntity))
        }
        
        if !entityNames.contains(relationship.toEntity) {
            errors.append(.missingRequiredEntity(relationship.toEntity))
        }
        
        // Check via entity if present
        if let viaEntity = relationship.viaEntity {
            if !entityNames.contains(viaEntity) {
                errors.append(.missingRequiredEntity(viaEntity))
            }
        }
        
        // Validate cardinality consistency
        validateCardinalityConsistency(relationship)
    }
    
    private func validateCardinalityConsistency(_ relationship: Relationship) {
        // Check if cardinality matches nature
        switch (relationship.cardinality, relationship.nature) {
        case (.oneToOne, .some(.composition)), (.oneToOne, .some(.aggregation)):
            // Valid combinations
            break
        case (.oneToMany, .some(.composition)), (.oneToMany, .some(.aggregation)):
            // Valid combinations
            break
        case (.manyToMany, .some(.association)):
            // Valid combination
            break
        case (.manyToMany, _) where relationship.viaEntity == nil:
            warnings.append("Many-to-many relationship without via entity: \(relationship.fromEntity) -> \(relationship.toEntity)")
        default:
            break
        }
    }
    
    private func detectCircularReferences(_ relationships: [Relationship]) {
        var graph: [String: Set<String>] = [:]
        
        // Build dependency graph
        for relationship in relationships {
            if relationship.cardinality == .inheritance {
                graph[relationship.fromEntity, default: Set()].insert(relationship.toEntity)
            }
        }
        
        // Detect cycles using DFS
        var visited: Set<String> = []
        var recursionStack: Set<String> = []
        
        func hasCycle(_ entity: String) -> Bool {
            if recursionStack.contains(entity) {
                return true
            }
            
            if visited.contains(entity) {
                return false
            }
            
            visited.insert(entity)
            recursionStack.insert(entity)
            
            for neighbor in graph[entity] ?? [] {
                if hasCycle(neighbor) {
                    return true
                }
            }
            
            recursionStack.remove(entity)
            return false
        }
        
        for entity in graph.keys {
            if !visited.contains(entity) && hasCycle(entity) {
                errors.append(.circularReference("Inheritance cycle detected involving \(entity)"))
            }
        }
    }
    
    // MARK: - Schema Validation
    
    private func validateSchema() {
        let schema = document.schemaDefinition
        
        // Check for duplicate entity names
        var entityNames: Set<String> = []
        
        for section in schema.moduleSections {
            for entity in section.entities {
                if entityNames.contains(entity.name) {
                    errors.append(.duplicateEntityName(entity.name))
                } else {
                    entityNames.insert(entity.name)
                }
                
                validateEntity(entity)
            }
        }
    }
    
    private func validateEntity(_ entity: Entity) {
        validateEntityFields(entity)
        validatePrimaryKey(entity)
        validateForeignKeys(entity)
    }
    
    private func validateEntityFields(_ entity: Entity) {
        var fieldNames: Set<String> = []
        
        for field in entity.fields {
            // Check for duplicate field names
            for fieldName in field.names {
                if fieldNames.contains(fieldName) {
                    errors.append(.duplicateFieldName(fieldName, entity: entity.name))
                } else {
                    fieldNames.insert(fieldName)
                }
            }
            
            validateField(field, entity: entity)
        }
    }
    
    private func validateField(_ field: Field, entity: Entity) {
        // Validate field prefixes
        validateFieldPrefixes(field, entity: entity)
        
        // Validate data type
        validateDataType(field.dataType, field: field, entity: entity)
        
        // Validate constraints
        validateConstraints(field, entity: entity)
    }
    
    private func validateFieldPrefixes(_ field: Field, entity: Entity) {
        let prefixes = field.prefixes
        
        // Check for conflicting prefixes
        if prefixes.contains(.required) && prefixes.contains(.optional) {
            errors.append(.invalidFieldPrefix("Cannot have both required (*) and optional (-) prefixes", entity: entity.name))
        }
        
        // System fields should not be required
        if prefixes.contains(.required) && field.constraints.contains(where: { $0.name == "SYSTEM" }) {
            warnings.append("System field '\(field.names.joined(separator: ", "))' in entity '\(entity.name)' should not be required")
        }
    }
    
    private func validateDataType(_ dataType: DataType, field: Field, entity: Entity) {
        switch dataType {
        case .simple(let type):
            validateSimpleDataType(type, field: field, entity: entity)
        case .parametric(let type, let params):
            validateParametricDataType(type, params: params, field: field, entity: entity)
        case .array(let innerType):
            validateDataType(innerType, field: field, entity: entity)
        case .relationshipArray(let entityName, let cardinality):
            validateRelationshipArrayDataType(entityName, cardinality: cardinality, field: field, entity: entity)
        case .jsonObject(let fields):
            validateJSONObjectDataType(fields, field: field, entity: entity)
        case .embeddedEntity(let entityName):
            validateEmbeddedEntityDataType(entityName, field: field, entity: entity)
        }
    }
    
    private func validateSimpleDataType(_ type: String, field: Field, entity: Entity) {
        let validTypes = [
            "String", "Int", "Float", "Double", "Boolean", "DateTime", "Date", "Time",
            "UUID", "Guid", "ObjectId", "Binary", "JSON", "Text", "LongText",
            "Decimal", "Money", "Timestamp", "TinyInt", "SmallInt", "BigInt",
            "Bit", "VarBinary", "Image", "XML", "Geometry", "Geography",
            "Point", "Polygon", "LineString", "Buffer", "BinData"
        ]
        
        if !validTypes.contains(type) {
            warnings.append("Unknown data type '\(type)' for field '\(field.names.joined(separator: ", "))' in entity '\(entity.name)'")
        }
    }
    
    private func validateParametricDataType(_ type: String, params: [String], field: Field, entity: Entity) {
        switch type {
        case "String":
            if params.count != 1 || Int(params[0]) == nil {
                errors.append(.invalidDataType("String type requires single integer parameter", entity: entity.name, field: field.names.joined(separator: ", ")))
            }
        case "Decimal":
            if params.count != 2 || Int(params[0]) == nil || Int(params[1]) == nil {
                errors.append(.invalidDataType("Decimal type requires two integer parameters (precision, scale)", entity: entity.name, field: field.names.joined(separator: ", ")))
            }
        case "Enum":
            if params.isEmpty {
                errors.append(.invalidDataType("Enum type requires at least one value", entity: entity.name, field: field.names.joined(separator: ", ")))
            }
        default:
            warnings.append("Unknown parametric type '\(type)' for field '\(field.names.joined(separator: ", "))' in entity '\(entity.name)'")
        }
    }
    
    private func validateRelationshipArrayDataType(_ entityName: String, cardinality: Cardinality, field: Field, entity: Entity) {
        let allEntityNames = getAllEntityNames()
        
        if !allEntityNames.contains(entityName) {
            errors.append(.missingRequiredEntity(entityName))
        }
        
        // Validate cardinality
        if case .number(let max) = cardinality.max {
            if max < cardinality.min {
                errors.append(.invalidCardinality("Maximum cardinality cannot be less than minimum"))
            }
        }
        
        if cardinality.min < 0 {
            errors.append(.invalidCardinality("Minimum cardinality cannot be negative"))
        }
    }
    
    private func validateJSONObjectDataType(_ fields: [JSONField], field: Field, entity: Entity) {
        // Validate JSON field structure
        var jsonFieldNames: Set<String> = []
        
        for jsonField in fields {
            if jsonFieldNames.contains(jsonField.name) {
                errors.append(.duplicateFieldName(jsonField.name, entity: "\(entity.name).\(field.names.joined(separator: ", "))"))
            } else {
                jsonFieldNames.insert(jsonField.name)
            }
            
            validateDataType(jsonField.dataType, field: field, entity: entity)
        }
    }
    
    private func validateEmbeddedEntityDataType(_ entityName: String, field: Field, entity: Entity) {
        let allEntityNames = getAllEntityNames()
        
        if !allEntityNames.contains(entityName) {
            errors.append(.missingRequiredEntity(entityName))
        }
    }
    
    private func validateConstraints(_ field: Field, entity: Entity) {
        var constraintNames: Set<String> = []
        
        for constraint in field.constraints {
            if constraintNames.contains(constraint.name) {
                warnings.append("Duplicate constraint '\(constraint.name)' for field '\(field.names.joined(separator: ", "))' in entity '\(entity.name)'")
            } else {
                constraintNames.insert(constraint.name)
            }
            
            validateConstraint(constraint, field: field, entity: entity)
        }
    }
    
    private func validateConstraint(_ constraint: Constraint, field: Field, entity: Entity) {
        switch constraint.name {
        case "PK":
            if constraint.value != nil {
                warnings.append("Primary key constraint should not have a value")
            }
        case "FK":
            validateForeignKeyConstraint(constraint, field: field, entity: entity)
        case "UK", "INDEX", "IX":
            // Valid constraints
            break
        case "DEFAULT":
            if constraint.value == nil {
                errors.append(.invalidConstraint("DEFAULT constraint requires a value", entity: entity.name, field: field.names.joined(separator: ", ")))
            }
        case "ENUM":
            if constraint.value == nil {
                errors.append(.invalidConstraint("ENUM constraint requires values", entity: entity.name, field: field.names.joined(separator: ", ")))
            }
        case "SYSTEM", "AUTO", "AUTO_INCREMENT", "ENCRYPTED", "COMPRESSED":
            // Valid system constraints
            break
        default:
            warnings.append("Unknown constraint '\(constraint.name)' for field '\(field.names.joined(separator: ", "))' in entity '\(entity.name)'")
        }
    }
    
    private func validateForeignKeyConstraint(_ constraint: Constraint, field: Field, entity: Entity) {
        guard let value = constraint.value else {
            errors.append(.invalidConstraint("Foreign key constraint requires a value", entity: entity.name, field: field.names.joined(separator: ", ")))
            return
        }
        
        let components = value.components(separatedBy: ".")
        if components.count != 2 {
            errors.append(.invalidForeignKey("Foreign key format should be EntityName.fieldName", entity: entity.name, field: field.names.joined(separator: ", ")))
            return
        }
        
        let referencedEntity = components[0]
        let referencedField = components[1]
        
        let allEntityNames = getAllEntityNames()
        if !allEntityNames.contains(referencedEntity) {
            errors.append(.missingRequiredEntity(referencedEntity))
        }
        
        // TODO: Validate that referenced field exists in referenced entity
    }
    
    private func validatePrimaryKey(_ entity: Entity) {
        let primaryKeyFields = entity.fields.filter { field in
            field.constraints.contains { $0.name == "PK" }
        }
        
        if primaryKeyFields.isEmpty {
            errors.append(.missingPrimaryKey(entity.name))
        }
    }
    
    private func validateForeignKeys(_ entity: Entity) {
        for field in entity.fields {
            for constraint in field.constraints {
                if constraint.name == "FK" {
                    validateForeignKeyConstraint(constraint, field: field, entity: entity)
                }
            }
        }
    }
    
    // MARK: - Cross-Reference Validation
    
    private func validateCrossReferences() {
        // Validate that all referenced entities exist
        let allEntityNames = getAllEntityNames()
        
        // Check relationship definitions
        if let relationships = document.relationshipDefinitions {
            for relationship in relationships.relationships {
                if !allEntityNames.contains(relationship.fromEntity) {
                    errors.append(.missingRequiredEntity(relationship.fromEntity))
                }
                if !allEntityNames.contains(relationship.toEntity) {
                    errors.append(.missingRequiredEntity(relationship.toEntity))
                }
                if let viaEntity = relationship.viaEntity, !allEntityNames.contains(viaEntity) {
                    errors.append(.missingRequiredEntity(viaEntity))
                }
            }
        }
        
        // Check relationship consistency
        validateRelationshipConsistency()
    }
    
    private func validateRelationshipConsistency() {
        // Check if relationships defined in relationship section match field definitions
        // This is a more complex validation that would require additional logic
        warnings.append("Relationship consistency validation not yet implemented")
    }
    
    // MARK: - Complex Structure Validation

    // MARK: - Enhanced Validation

    private func validateComplexStructures() {
        let allEntities = getAllEntities()
        
        for entity in allEntities {
            validateEntityComplexity(entity)
            validateFieldComplexity(entity)
            validateSuspiciousPatterns(entity)
        }
    }
    
    private func validateEntityComplexity(_ entity: Entity) {
        // Check if entity has suspiciously few fields for a business entity
        if entity.fields.count < 3 && !entity.name.contains("Config") && !entity.name.contains("Setting") {
            warnings.append("Entity '\(entity.name)' has only \(entity.fields.count) fields - may be missing complex structures")
        }
        
        // Check for common missing patterns
        let fieldNames = entity.fields.map { $0.names.joined(separator: ", ").lowercased() }
        let commonComplexPatterns = [
            "items", "details", "options", "metadata", "config", "settings", 
            "stops", "locations", "addresses", "contacts", "tags", "categories",
            "permissions", "roles", "features", "attributes", "properties"
        ]
        
        // Look for patterns that suggest complex structures might be missing
        for pattern in commonComplexPatterns {
            if entity.name.lowercased().contains(pattern.dropLast()) { // "route" contains "stop" pattern
                let hasRelatedField = fieldNames.contains { $0.contains(pattern) }
                if !hasRelatedField {
                    warnings.append("Entity '\(entity.name)' may be missing '\(pattern)' field - check if complex array was omitted")
                }
            }
        }
    }
    
    private func validateFieldComplexity(_ entity: Entity) {
        for field in entity.fields {
            // Check for complex JSON that should be embedded entities
            if case .jsonObject(let jsonFields) = field.dataType {
                if jsonFields.count > 2 {
                    errors.append(DBSoupValidationError.invalidDataType(
                        "Complex JSON with \(jsonFields.count) fields should be converted to embedded entity",
                        entity: entity.name,
                        field: field.names.joined(separator: ", ")
                    ))
                }
            }
            
            // Check for array types that might be missing cardinality
            if case .array(let innerType) = field.dataType {
                if case .jsonObject(_) = innerType {
                    errors.append(DBSoupValidationError.invalidDataType(
                        "Array<JSON> should be converted to embedded entity relationship",
                        entity: entity.name,
                        field: field.names.joined(separator: ", ")
                    ))
                }
            }
            
            // Check for relationship arrays that reference missing entities
            if case .relationshipArray(let entityName, _) = field.dataType {
                if !entityExists(entityName) {
                    errors.append(DBSoupValidationError.missingRequiredEntity(entityName))
                }
            }
        }
    }
    
    private func validateSuspiciousPatterns(_ entity: Entity) {
        // Check for entities that typically have complex structures
        let entitiesWithComplexStructures = [
            "Route": ["stops", "waypoints", "segments"],
            "Order": ["items", "payments", "addresses"],
            "User": ["profiles", "preferences", "contacts"],
            "Product": ["variants", "categories", "attributes"],
            "Invoice": ["lineItems", "payments", "addresses"],
            "Document": ["sections", "attachments", "comments"],
            "Course": ["lessons", "assignments", "resources"],
            "Event": ["attendees", "sessions", "resources"]
        ]
        
        for (entityPattern, expectedFields) in entitiesWithComplexStructures {
            if entity.name.lowercased().contains(entityPattern.lowercased()) {
                let hasComplexField = expectedFields.contains { expectedField in
                    entity.fields.contains { field in
                        field.names.joined(separator: ", ").lowercased().contains(expectedField.lowercased())
                    }
                }
                
                if !hasComplexField {
                    warnings.append("Entity '\(entity.name)' may be missing expected complex fields: \(expectedFields.joined(separator: ", "))")
                }
            }
        }
    }
    
    private func entityExists(_ entityName: String) -> Bool {
        let allEntities = getAllEntities()
        return allEntities.contains { $0.name == entityName }
    }
    
    private func getAllEntities() -> [Entity] {
        return document.schemaDefinition.moduleSections.flatMap { $0.entities }
    }
    
    // MARK: - Helper Methods
    
    private func getAllEntityNames() -> Set<String> {
        var entityNames: Set<String> = []
        
        for section in document.schemaDefinition.moduleSections {
            for entity in section.entities {
                entityNames.insert(entity.name)
            }
        }
        
        return entityNames
    }
}

// MARK: - String Extension for Validation

extension String {
    func isValidIdentifier() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z][a-zA-Z0-9_]*$")
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil
    }
} 
import Foundation

public class DBSoupMermaidGenerator {
    private let document: DBSoupDocument
    
    public init(document: DBSoupDocument) {
        self.document = document
    }
    
    public func generateMermaid() -> String {
        let allEntities = getAllEntities()
        let allRelationships = getAllRelationships()
        
        var mermaid = """
        erDiagram
        
        """
        
        // Generate entity definitions
        for entity in allEntities {
            mermaid += generateEntityDefinition(entity: entity)
            mermaid += "\n"
        }
        
        // Generate relationships
        mermaid += "\n    %% Relationships\n"
        for relationship in allRelationships {
            mermaid += generateRelationship(relationship: relationship)
        }
        
        return mermaid
    }
    
    private func getAllEntities() -> [Entity] {
        var entities: [Entity] = []
        for moduleSection in document.schemaDefinition.moduleSections {
            entities.append(contentsOf: moduleSection.entities)
        }
        return entities
    }
    
    private func getAllRelationships() -> [Relationship] {
        return document.relationshipDefinitions?.relationships ?? []
    }
    
    private func generateEntityDefinition(entity: Entity) -> String {
        var definition = "    \(sanitizeEntityName(entity.name)) {\n"
        
        // Add fields
        for field in entity.fields {
            definition += generateFieldDefinition(field: field)
        }
        
        definition += "    }\n"
        return definition
    }
    
    private func generateFieldDefinition(field: Field) -> String {
        let fieldName = field.names.first ?? "unknown"
        let dataType = formatDataType(field.dataType)
        let constraints = formatConstraints(field: field)
        
        return "        \(formatDataType(field.dataType)) \(fieldName) \(constraints)\n"
    }
    
    private func formatDataType(_ dataType: DataType) -> String {
        switch dataType {
        case .simple(let type):
            return type
        case .parametric(let type, let params):
            return "\(type)(\(params.joined(separator: ", ")))"
        case .array(let innerType):
            return "Array_\(formatDataType(innerType))"
        case .jsonObject:
            return "JSON"
        case .relationshipArray(let type, _):
            return "Array_\(type)"
        case .embeddedEntity(let type):
            return type
        }
    }
    
    private func formatConstraints(field: Field) -> String {
        var constraints: [String] = []
        
        // Add prefix-based constraints
        if field.prefixes.contains(.required) {
            constraints.append("NOT_NULL")
        }
        
        // Add explicit constraints
        for constraint in field.constraints {
            switch constraint.name.uppercased() {
            case "PK":
                constraints.append("PK")
            case "FK":
                constraints.append("FK")
            case "UK", "UNIQUE":
                constraints.append("UK")
            case "INDEX":
                constraints.append("INDEX")
            case "ENCRYPTED":
                constraints.append("ENCRYPTED")
            case "DEFAULT":
                if let value = constraint.value {
                    constraints.append("DEFAULT_\(value)")
                } else {
                    constraints.append("DEFAULT")
                }
            case "ENUM":
                constraints.append("ENUM")
            case "SYSTEM":
                constraints.append("SYSTEM")
            case "SPATIAL":
                constraints.append("SPATIAL")
            case "CURRENCY":
                constraints.append("CURRENCY")
            default:
                constraints.append(constraint.name)
            }
        }
        
        return constraints.isEmpty ? "" : constraints.joined(separator: "_")
    }
    
    private func generateRelationship(relationship: Relationship) -> String {
        let fromEntity = sanitizeEntityName(relationship.fromEntity)
        let toEntity = sanitizeEntityName(relationship.toEntity)
        let cardinality = formatCardinality(relationship.cardinality)
        let label = formatRelationshipLabel(relationship)
        
        return "    \(fromEntity) \(cardinality) \(toEntity) : \"\(label)\"\n"
    }
    
    private func formatCardinality(_ cardinality: RelationshipCardinality) -> String {
        switch cardinality {
        case .oneToOne:
            return "||--||"
        case .oneToMany:
            return "||--o{"
        case .manyToMany:
            return "}o--o{"
        case .composition:
            return "||--o{"
        case .aggregation:
            return "||--o{"
        case .inheritance:
            return "||--||"
        }
    }
    
    private func formatRelationshipLabel(_ relationship: Relationship) -> String {
        if let comment = relationship.comment {
            return comment
        }
        
        let action = getRelationshipAction(relationship.cardinality)
        return "\(action)"
    }
    
    private func getRelationshipAction(_ cardinality: RelationshipCardinality) -> String {
        switch cardinality {
        case .oneToOne:
            return "relates to"
        case .oneToMany:
            return "has"
        case .manyToMany:
            return "relates to"
        case .composition:
            return "contains"
        case .aggregation:
            return "includes"
        case .inheritance:
            return "inherits"
        }
    }
    
    private func sanitizeEntityName(_ name: String) -> String {
        // Remove special characters that might cause issues in Mermaid
        return name.replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: ".", with: "_")
    }
}

// MARK: - Mermaid Configuration

public struct MermaidConfig {
    public let includeComments: Bool
    public let includeFieldTypes: Bool
    public let includeConstraints: Bool
    public let maxFieldsPerEntity: Int
    public let theme: MermaidTheme
    
    public init(includeComments: Bool = true, includeFieldTypes: Bool = true, includeConstraints: Bool = true, maxFieldsPerEntity: Int = 15, theme: MermaidTheme = .default) {
        self.includeComments = includeComments
        self.includeFieldTypes = includeFieldTypes
        self.includeConstraints = includeConstraints
        self.maxFieldsPerEntity = maxFieldsPerEntity
        self.theme = theme
    }
}

public enum MermaidTheme {
    case `default`
    case dark
    case neutral
    case base
    
    var themeDirective: String {
        switch self {
        case .default:
            return "%%{init: {'theme':'default'}}%%"
        case .dark:
            return "%%{init: {'theme':'dark'}}%%"
        case .neutral:
            return "%%{init: {'theme':'neutral'}}%%"
        case .base:
            return "%%{init: {'theme':'base'}}%%"
        }
    }
}

// MARK: - Enhanced Mermaid Generator

public class DBSoupMermaidEnhancedGenerator {
    private let document: DBSoupDocument
    private let config: MermaidConfig
    
    public init(document: DBSoupDocument, config: MermaidConfig = MermaidConfig()) {
        self.document = document
        self.config = config
    }
    
    public func generateMermaid() -> String {
        let allEntities = getAllEntities()
        let allRelationships = getAllRelationships()
        
        var mermaid = ""
        
        // Add theme directive
        mermaid += "\(config.theme.themeDirective)\n"
        
        mermaid += """
        erDiagram
        
        """
        
        // Add header comment if available
        if config.includeComments, let header = document.header {
            mermaid += "    %% Generated from: \(header.filename)\n"
        }
        
        // Generate entity definitions
        for entity in allEntities {
            mermaid += generateEntityDefinition(entity: entity)
            mermaid += "\n"
        }
        
        // Generate relationships
        if !allRelationships.isEmpty {
            mermaid += "\n    %% Relationships\n"
            for relationship in allRelationships {
                mermaid += generateRelationship(relationship: relationship)
            }
        }
        
        return mermaid
    }
    
    private func getAllEntities() -> [Entity] {
        var entities: [Entity] = []
        for moduleSection in document.schemaDefinition.moduleSections {
            entities.append(contentsOf: moduleSection.entities)
        }
        return entities
    }
    
    private func getAllRelationships() -> [Relationship] {
        return document.relationshipDefinitions?.relationships ?? []
    }
    
    private func generateEntityDefinition(entity: Entity) -> String {
        var definition = "    \(sanitizeEntityName(entity.name)) {\n"
        
        // Add entity comment if available
        if config.includeComments, let comment = entity.comment {
            definition += "        %% \(comment)\n"
        }
        
        // Add fields (limit to configured maximum)
        let fieldsToShow = Array(entity.fields.prefix(config.maxFieldsPerEntity))
        for field in fieldsToShow {
            definition += generateFieldDefinition(field: field)
        }
        
        // Add truncation note if needed
        if entity.fields.count > config.maxFieldsPerEntity {
            let remaining = entity.fields.count - config.maxFieldsPerEntity
            definition += "        String truncated_fields \"... and \(remaining) more fields\"\n"
        }
        
        definition += "    }\n"
        return definition
    }
    
    private func generateFieldDefinition(field: Field) -> String {
        let fieldName = field.names.first ?? "unknown"
        let dataType = config.includeFieldTypes ? formatDataType(field.dataType) : "String"
        let constraints = config.includeConstraints ? formatConstraints(field: field) : ""
        
        let constraintSuffix = constraints.isEmpty ? "" : "_\(constraints)"
        return "        \(dataType) \(fieldName)\(constraintSuffix)\n"
    }
    
    private func formatDataType(_ dataType: DataType) -> String {
        switch dataType {
        case .simple(let type):
            return type
        case .parametric(let type, let params):
            return "\(type)(\(params.joined(separator: "_")))"
        case .array(let innerType):
            return "Array_\(formatDataType(innerType))"
        case .jsonObject:
            return "JSON"
        case .relationshipArray(let type, _):
            return "Array_\(type)"
        case .embeddedEntity(let type):
            return type
        }
    }
    
    private func formatConstraints(field: Field) -> String {
        var constraints: [String] = []
        
        // Add prefix-based constraints
        if field.prefixes.contains(.required) {
            constraints.append("REQ")
        }
        if field.prefixes.contains(.indexed) {
            constraints.append("IDX")
        }
        if field.prefixes.contains(.sensitive) {
            constraints.append("SENS")
        }
        
        // Add explicit constraints
        for constraint in field.constraints {
            switch constraint.name.uppercased() {
            case "PK":
                constraints.append("PK")
            case "FK":
                constraints.append("FK")
            case "UK", "UNIQUE":
                constraints.append("UK")
            case "INDEX":
                constraints.append("IDX")
            case "ENCRYPTED":
                constraints.append("ENC")
            case "DEFAULT":
                constraints.append("DEF")
            case "ENUM":
                constraints.append("ENUM")
            case "SYSTEM":
                constraints.append("SYS")
            case "SPATIAL":
                constraints.append("SPAT")
            case "CURRENCY":
                constraints.append("CURR")
            default:
                constraints.append(constraint.name.prefix(4).uppercased())
            }
        }
        
        return constraints.isEmpty ? "" : constraints.joined(separator: "_")
    }
    
    private func generateRelationship(relationship: Relationship) -> String {
        let fromEntity = sanitizeEntityName(relationship.fromEntity)
        let toEntity = sanitizeEntityName(relationship.toEntity)
        let cardinality = formatCardinality(relationship.cardinality)
        let label = formatRelationshipLabel(relationship)
        
        return "    \(fromEntity) \(cardinality) \(toEntity) : \"\(label)\"\n"
    }
    
    private func formatCardinality(_ cardinality: RelationshipCardinality) -> String {
        switch cardinality {
        case .oneToOne:
            return "||--||"
        case .oneToMany:
            return "||--o{"
        case .manyToMany:
            return "}o--o{"
        case .composition:
            return "||--o{"
        case .aggregation:
            return "||--o{"
        case .inheritance:
            return "||--||"
        }
    }
    
    private func formatRelationshipLabel(_ relationship: Relationship) -> String {
        if let comment = relationship.comment {
            return comment
        }
        
        let action = getRelationshipAction(relationship.cardinality)
        return "\(action)"
    }
    
    private func getRelationshipAction(_ cardinality: RelationshipCardinality) -> String {
        switch cardinality {
        case .oneToOne:
            return "relates to"
        case .oneToMany:
            return "has"
        case .manyToMany:
            return "relates to"
        case .composition:
            return "contains"
        case .aggregation:
            return "includes"
        case .inheritance:
            return "inherits"
        }
    }
    
    private func sanitizeEntityName(_ name: String) -> String {
        // Remove special characters that might cause issues in Mermaid
        return name.replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: ".", with: "_")
    }
} 
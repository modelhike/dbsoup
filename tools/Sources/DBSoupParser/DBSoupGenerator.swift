import Foundation

// MARK: - Generator Configuration

public struct DBSoupGeneratorConfig {
    public let indentationSpaces: Int
    public let fieldNameWidth: Int
    public let dataTypeWidth: Int
    public let constraintColumnStart: Int
    public let includeComments: Bool
    public let sortEntitiesAlphabetically: Bool
    public let sortFieldsAlphabetically: Bool
    
    public init(
        indentationSpaces: Int = 4,
        fieldNameWidth: Int = 15,
        dataTypeWidth: Int = 20,
        constraintColumnStart: Int = 40,
        includeComments: Bool = true,
        sortEntitiesAlphabetically: Bool = false,
        sortFieldsAlphabetically: Bool = false
    ) {
        self.indentationSpaces = indentationSpaces
        self.fieldNameWidth = fieldNameWidth
        self.dataTypeWidth = dataTypeWidth
        self.constraintColumnStart = constraintColumnStart
        self.includeComments = includeComments
        self.sortEntitiesAlphabetically = sortEntitiesAlphabetically
        self.sortFieldsAlphabetically = sortFieldsAlphabetically
    }
    
    public static let `default` = DBSoupGeneratorConfig()
}

// MARK: - Generator

public class DBSoupGenerator {
    private let config: DBSoupGeneratorConfig
    private var output: [String] = []
    
    public init(config: DBSoupGeneratorConfig = .default) {
        self.config = config
    }
    
    public func generate(document: DBSoupDocument) -> String {
        output.removeAll()
        
        generateYAMLHeader()
        generateHeader(document.header)
        generateRelationshipDefinitions(document.relationshipDefinitions)
        generateSchemaDefinition(document.schemaDefinition)
        
        return output.joined(separator: "\n")
    }
    
    // MARK: - YAML Header Generation
    
    private func generateYAMLHeader() {
        output.append("---")
        output.append("@specs: https://www.dbsoup.com/SPECS.md")
        output.append("@Dbname: <App Dbname>")
        output.append("@ver: 0.1")
        output.append("---")
        output.append("")
    }
    
    // MARK: - Header Generation
    
    private func generateHeader(_ header: DBSoupHeader?) {
        guard let header = header else { return }
        
        output.append("@\(header.filename).dbsoup")
        output.append("")
    }
    
    // MARK: - Relationship Definitions Generation
    
    private func generateRelationshipDefinitions(_ relationshipDefs: RelationshipDefinitions?) {
        guard let relationshipDefs = relationshipDefs else { return }
        
        output.append("=== RELATIONSHIP DEFINITIONS ===")
        
        // Group relationships by cardinality
        let groupedRelationships = groupRelationshipsByCardinality(relationshipDefs.relationships)
        
        for (cardinalityGroup, relationships) in groupedRelationships {
            output.append("# \(cardinalityGroup)")
            
            for relationship in relationships {
                output.append(generateRelationshipLine(relationship))
            }
            
            output.append("")
        }
    }
    
    private func groupRelationshipsByCardinality(_ relationships: [Relationship]) -> [(String, [Relationship])] {
        var grouped: [String: [Relationship]] = [:]
        
        for relationship in relationships {
            let group: String
            switch relationship.cardinality {
            case .oneToOne:
                group = "One-to-One Relationships"
            case .oneToMany:
                group = "One-to-Many Relationships"
            case .manyToMany:
                group = "Many-to-Many Relationships"
            case .inheritance:
                group = "Inheritance Relationships"
            case .composition:
                group = "Composition Relationships"
            case .aggregation:
                group = "Aggregation Relationships"
            }
            
            grouped[group, default: []].append(relationship)
        }
        
        // Return in predefined order
        let orderedGroups = [
            "One-to-One Relationships",
            "One-to-Many Relationships",
            "Many-to-Many Relationships",
            "Inheritance Relationships",
            "Composition Relationships",
            "Aggregation Relationships"
        ]
        
        return orderedGroups.compactMap { group in
            guard let relationships = grouped[group], !relationships.isEmpty else { return nil }
            return (group, relationships)
        }
    }
    
    private func generateRelationshipLine(_ relationship: Relationship) -> String {
        var line = "\(relationship.fromEntity) -> \(relationship.toEntity) [\(relationship.cardinality.rawValue)]"
        
        if let nature = relationship.nature {
            line += " (\(nature.rawValue))"
        }
        
        if let viaEntity = relationship.viaEntity {
            line += " via \(viaEntity)"
        }
        
        if let comment = relationship.comment, config.includeComments {
            line += " # \(comment)"
        }
        
        return line
    }
    
    // MARK: - Schema Definition Generation
    
    private func generateSchemaDefinition(_ schemaDefinition: SchemaDefinition) {
        output.append("=== DATABASE SCHEMA ===")
        
        // Generate module list
        for module in schemaDefinition.modules {
            output.append("+ \(module)")
        }
        output.append("")
        
        // Generate module sections
        var sortedSections = schemaDefinition.moduleSections
        if config.sortEntitiesAlphabetically {
            sortedSections.sort { $0.name < $1.name }
        }
        
        for section in sortedSections {
            generateModuleSection(section)
        }
    }
    
    private func generateModuleSection(_ section: ModuleSection) {
        output.append("=== \(section.name) ===")
        output.append("")
        
        var sortedEntities = section.entities
        if config.sortEntitiesAlphabetically {
            sortedEntities.sort { $0.name < $1.name }
        }
        
        for entity in sortedEntities {
            generateEntity(entity)
        }
    }
    
    private func generateEntity(_ entity: Entity) {
        // Entity header
        var headerLine = entity.name
        if let comment = entity.comment, config.includeComments {
            headerLine += " # \(comment)"
        }
        output.append(headerLine)
        
        // Entity separator
        switch entity.type {
        case .standard:
            output.append("==========")
        case .embedded:
            output.append("/=======/")
        }
        
        // Entity fields
        var sortedFields = entity.fields
        if config.sortFieldsAlphabetically {
            sortedFields.sort { $0.names.first ?? "" < $1.names.first ?? "" }
        }
        
        for field in sortedFields {
            output.append(generateField(field))
        }
        
        // Relationship sections
        for relationshipSection in entity.relationshipSections {
            generateRelationshipSection(relationshipSection)
        }
        
        // Feature sections
        for featureSection in entity.featureSections {
            generateFeatureSection(featureSection)
        }
        
        output.append("")
    }
    
    private func generateField(_ field: Field) -> String {
        let prefixString = field.prefixes.map { $0.rawValue }.joined()
        let fieldNamesString = field.names.joined(separator: ", ")
        let dataTypeString = generateDataType(field.dataType)
        let constraintString = generateConstraints(field.constraints)
        
        // Calculate spacing
        let fieldPart = "\(prefixString) \(fieldNamesString)"
        let paddedFieldPart = fieldPart.padding(toLength: config.fieldNameWidth, withPad: " ", startingAt: 0)
        
        let typePart = ": \(dataTypeString)"
        let paddedTypePart = typePart.padding(toLength: config.dataTypeWidth, withPad: " ", startingAt: 0)
        
        var line = paddedFieldPart + paddedTypePart
        
        // Add constraints if present
        if !constraintString.isEmpty {
            let currentLength = line.count
            if currentLength < config.constraintColumnStart {
                line += String(repeating: " ", count: config.constraintColumnStart - currentLength)
            } else {
                line += " "
            }
            line += constraintString
        }
        
        // Add comment if present
        if let comment = field.comment, config.includeComments {
            line += " # \(comment)"
        }
        
        return line
    }
    
    private func generateDataType(_ dataType: DataType) -> String {
        switch dataType {
        case .simple(let type):
            return type
        case .parametric(let type, let params):
            return "\(type)(\(params.joined(separator: ", ")))"
        case .array(let innerType):
            return "Array<\(generateDataType(innerType))>"
        case .jsonObject(let fields):
            if fields.isEmpty {
                return "JSON"
            } else {
                let fieldStrings = fields.map { "\($0.name): \(generateDataType($0.dataType))" }
                return "JSON {\n\(fieldStrings.joined(separator: ",\n"))\n}"
            }
        case .relationshipArray(let entityName, let cardinality):
            return "\(entityName)[\(generateCardinality(cardinality))]"
        case .embeddedEntity(let entityName):
            return entityName
        }
    }
    
    private func generateCardinality(_ cardinality: Cardinality) -> String {
        let maxString: String
        switch cardinality.max {
        case .number(let max):
            maxString = "\(max)"
        case .unlimited:
            maxString = "*"
        }
        return "\(cardinality.min)..\(maxString)"
    }
    
    private func generateConstraints(_ constraints: [Constraint]) -> String {
        if constraints.isEmpty {
            return ""
        }
        
        let constraintStrings = constraints.map { constraint in
            if let value = constraint.value {
                return "\(constraint.name):\(value)"
            } else {
                return constraint.name
            }
        }
        
        return "[\(constraintStrings.joined(separator: ","))]"
    }
    
    private func generateRelationshipSection(_ section: RelationshipSection) {
        output.append("# RELATIONSHIPS")
        
        for relationship in section.relationships {
            output.append("@ relationships:: \(relationship)")
        }
        
        for detail in section.details {
            var line = "## \(detail.fromEntity).\(detail.fromField) -> \(detail.toEntity).\(detail.toField)"
            if let comment = detail.comment, config.includeComments {
                line += " # \(comment)"
            }
            output.append(line)
        }
        
        output.append("")
    }
    
    private func generateFeatureSection(_ section: FeatureSection) {
        output.append("# \(section.title)")
        
        for line in section.content {
            output.append(line)
        }
        
        output.append("")
    }
}

// MARK: - Pretty Printer

public class DBSoupPrettyPrinter {
    private let config: DBSoupGeneratorConfig
    
    public init(config: DBSoupGeneratorConfig = .default) {
        self.config = config
    }
    
    public func prettyPrint(_ document: DBSoupDocument) -> String {
        let generator = DBSoupGenerator(config: config)
        return generator.generate(document: document)
    }
    
    public func prettyPrintToFile(_ document: DBSoupDocument, path: String) throws {
        let content = prettyPrint(document)
        try content.write(toFile: path, atomically: true, encoding: .utf8)
    }
}

// MARK: - Statistics Generator

public struct DBSoupStatistics {
    public let totalEntities: Int
    public let standardEntities: Int
    public let embeddedEntities: Int
    public let totalFields: Int
    public let totalRelationships: Int
    public let moduleCount: Int
    public let modules: [String: Int] // Module name -> entity count
    public let dataTypes: [String: Int] // Data type -> usage count
    public let constraints: [String: Int] // Constraint -> usage count
    public let fieldPrefixes: [String: Int] // Prefix -> usage count
    
    public init(
        totalEntities: Int,
        standardEntities: Int,
        embeddedEntities: Int,
        totalFields: Int,
        totalRelationships: Int,
        moduleCount: Int,
        modules: [String: Int],
        dataTypes: [String: Int],
        constraints: [String: Int],
        fieldPrefixes: [String: Int]
    ) {
        self.totalEntities = totalEntities
        self.standardEntities = standardEntities
        self.embeddedEntities = embeddedEntities
        self.totalFields = totalFields
        self.totalRelationships = totalRelationships
        self.moduleCount = moduleCount
        self.modules = modules
        self.dataTypes = dataTypes
        self.constraints = constraints
        self.fieldPrefixes = fieldPrefixes
    }
}

public class DBSoupStatisticsGenerator {
    public init() {}
    
    public func generateStatistics(for document: DBSoupDocument) -> DBSoupStatistics {
        var totalEntities = 0
        var standardEntities = 0
        var embeddedEntities = 0
        var totalFields = 0
        var modules: [String: Int] = [:]
        var dataTypes: [String: Int] = [:]
        var constraints: [String: Int] = [:]
        var fieldPrefixes: [String: Int] = [:]
        
        // Count entities and fields
        for section in document.schemaDefinition.moduleSections {
            modules[section.name] = section.entities.count
            
            for entity in section.entities {
                totalEntities += 1
                
                switch entity.type {
                case .standard:
                    standardEntities += 1
                case .embedded:
                    embeddedEntities += 1
                }
                
                totalFields += entity.fields.count
                
                // Count data types and constraints
                for field in entity.fields {
                    countDataType(field.dataType, in: &dataTypes)
                    
                    for constraint in field.constraints {
                        constraints[constraint.name, default: 0] += 1
                    }
                    
                    for prefix in field.prefixes {
                        fieldPrefixes[prefix.rawValue, default: 0] += 1
                    }
                }
            }
        }
        
        let totalRelationships = document.relationshipDefinitions?.relationships.count ?? 0
        let moduleCount = document.schemaDefinition.moduleSections.count
        
        return DBSoupStatistics(
            totalEntities: totalEntities,
            standardEntities: standardEntities,
            embeddedEntities: embeddedEntities,
            totalFields: totalFields,
            totalRelationships: totalRelationships,
            moduleCount: moduleCount,
            modules: modules,
            dataTypes: dataTypes,
            constraints: constraints,
            fieldPrefixes: fieldPrefixes
        )
    }
    
    private func countDataType(_ dataType: DataType, in counter: inout [String: Int]) {
        switch dataType {
        case .simple(let type):
            counter[type, default: 0] += 1
        case .parametric(let type, _):
            counter[type, default: 0] += 1
        case .array(let innerType):
            counter["Array", default: 0] += 1
            countDataType(innerType, in: &counter)
        case .jsonObject(_):
            counter["JSON", default: 0] += 1
        case .relationshipArray(let entityName, _):
            counter[entityName, default: 0] += 1
        case .embeddedEntity(let entityName):
            counter[entityName, default: 0] += 1
        }
    }
    
    public func printStatistics(_ stats: DBSoupStatistics) -> String {
        var output: [String] = []
        
        output.append("=== DBSoup Statistics ===")
        output.append("")
        output.append("Entities:")
        output.append("  Total: \(stats.totalEntities)")
        output.append("  Standard: \(stats.standardEntities)")
        output.append("  Embedded: \(stats.embeddedEntities)")
        output.append("")
        output.append("Fields: \(stats.totalFields)")
        output.append("Relationships: \(stats.totalRelationships)")
        output.append("Modules: \(stats.moduleCount)")
        output.append("")
        
        if !stats.modules.isEmpty {
            output.append("Entities per Module:")
            for (module, count) in stats.modules.sorted(by: { $0.key < $1.key }) {
                output.append("  \(module): \(count)")
            }
            output.append("")
        }
        
        if !stats.dataTypes.isEmpty {
            output.append("Data Type Usage:")
            for (type, count) in stats.dataTypes.sorted(by: { $0.value > $1.value }) {
                output.append("  \(type): \(count)")
            }
            output.append("")
        }
        
        if !stats.constraints.isEmpty {
            output.append("Constraint Usage:")
            for (constraint, count) in stats.constraints.sorted(by: { $0.value > $1.value }) {
                output.append("  \(constraint): \(count)")
            }
            output.append("")
        }
        
        if !stats.fieldPrefixes.isEmpty {
            output.append("Field Prefix Usage:")
            for (prefix, count) in stats.fieldPrefixes.sorted(by: { $0.value > $1.value }) {
                output.append("  \(prefix): \(count)")
            }
        }
        
        return output.joined(separator: "\n")
    }
} 
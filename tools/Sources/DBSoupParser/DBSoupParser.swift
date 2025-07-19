import Foundation

// MARK: - Data Structures

/// Represents a parsed DBSoup document
public struct DBSoupDocument {
    public let header: DBSoupHeader?
    public let relationshipDefinitions: RelationshipDefinitions?
    public let schemaDefinition: SchemaDefinition
    public let comments: [String]
    
    public init(header: DBSoupHeader?, relationshipDefinitions: RelationshipDefinitions?, schemaDefinition: SchemaDefinition, comments: [String] = []) {
        self.header = header
        self.relationshipDefinitions = relationshipDefinitions
        self.schemaDefinition = schemaDefinition
        self.comments = comments
    }
}

/// Document header (@filename.dbsoup)
public struct DBSoupHeader {
    public let filename: String
    
    public init(filename: String) {
        self.filename = filename
    }
}

/// Relationship definitions section
public struct RelationshipDefinitions {
    public let relationships: [Relationship]
    
    public init(relationships: [Relationship]) {
        self.relationships = relationships
    }
}

/// Individual relationship definition
public struct Relationship {
    public let fromEntity: String
    public let toEntity: String
    public let cardinality: RelationshipCardinality
    public let nature: RelationshipNature?
    public let viaEntity: String?
    public let comment: String?
    
    public init(fromEntity: String, toEntity: String, cardinality: RelationshipCardinality, nature: RelationshipNature? = nil, viaEntity: String? = nil, comment: String? = nil) {
        self.fromEntity = fromEntity
        self.toEntity = toEntity
        self.cardinality = cardinality
        self.nature = nature
        self.viaEntity = viaEntity
        self.comment = comment
    }
}

/// Relationship cardinality types
public enum RelationshipCardinality: String, CaseIterable {
    case oneToOne = "1:1"
    case oneToMany = "1:M"
    case manyToMany = "M:N"
    case inheritance = "inheritance"
    case composition = "composition"
    case aggregation = "aggregation"
}

/// Relationship nature types
public enum RelationshipNature: String, CaseIterable {
    case composition = "composition"
    case aggregation = "aggregation"
    case association = "association"
    case inheritance = "inheritance"
    case dependency = "dependency"
}

/// Schema definition with modules and entities
public struct SchemaDefinition {
    public let modules: [String]
    public let moduleSections: [ModuleSection]
    
    public init(modules: [String], moduleSections: [ModuleSection]) {
        self.modules = modules
        self.moduleSections = moduleSections
    }
}

/// Module section containing entities
public struct ModuleSection {
    public let name: String
    public let description: String?
    public let entities: [Entity]
    
    public init(name: String, description: String? = nil, entities: [Entity]) {
        self.name = name
        self.description = description
        self.entities = entities
    }
}

/// Entity definition
public struct Entity {
    public let name: String
    public let type: EntityType
    public let fields: [Field]
    public let relationshipSections: [RelationshipSection]
    public let featureSections: [FeatureSection]
    public let comment: String?
    
    public init(name: String, type: EntityType, fields: [Field], relationshipSections: [RelationshipSection] = [], featureSections: [FeatureSection] = [], comment: String? = nil) {
        self.name = name
        self.type = type
        self.fields = fields
        self.relationshipSections = relationshipSections
        self.featureSections = featureSections
        self.comment = comment
    }
}

/// Entity type (standard or embedded)
public enum EntityType {
    case standard
    case embedded
}

/// Field definition
public struct Field {
    public let prefixes: [FieldPrefix]
    public let names: [String]
    public let dataType: DataType
    public let constraints: [Constraint]
    public let comment: String?
    
    public init(prefixes: [FieldPrefix], names: [String], dataType: DataType, constraints: [Constraint] = [], comment: String? = nil) {
        self.prefixes = prefixes
        self.names = names
        self.dataType = dataType
        self.constraints = constraints
        self.comment = comment
    }
}

/// Field prefix types
public enum FieldPrefix: String, CaseIterable {
    case required = "*"
    case optional = "-"
    case indexed = "!"
    case sensitive = "@"
    case masked = "~"
    case partitioned = ">"
    case audit = "$"
}

/// Data type definitions
public indirect enum DataType {
    case simple(String)
    case parametric(String, [String])
    case array(DataType)
    case jsonObject([JSONField])
    case relationshipArray(String, Cardinality)
    case embeddedEntity(String)
}

/// JSON field for JSON object types
public struct JSONField {
    public let name: String
    public let dataType: DataType
    
    public init(name: String, dataType: DataType) {
        self.name = name
        self.dataType = dataType
    }
}

/// Cardinality definition
public struct Cardinality {
    public let min: Int
    public let max: CardinalityMax
    
    public init(min: Int, max: CardinalityMax) {
        self.min = min
        self.max = max
    }
}

/// Maximum cardinality (number or unlimited)
public enum CardinalityMax {
    case number(Int)
    case unlimited
}

/// Constraint definition
public struct Constraint {
    public let name: String
    public let value: String?
    
    public init(name: String, value: String? = nil) {
        self.name = name
        self.value = value
    }
}

/// Relationship section
public struct RelationshipSection {
    let relationships: [String]
    let details: [RelationshipDetail]
    
    public init(relationships: [String], details: [RelationshipDetail]) {
        self.relationships = relationships
        self.details = details
    }
}

/// Relationship detail
public struct RelationshipDetail {
    let fromEntity: String
    let fromField: String
    let toEntity: String
    let toField: String
    let comment: String?
    
    public init(fromEntity: String, fromField: String, toEntity: String, toField: String, comment: String? = nil) {
        self.fromEntity = fromEntity
        self.fromField = fromField
        self.toEntity = toEntity
        self.toField = toField
        self.comment = comment
    }
}

/// Feature section
public struct FeatureSection {
    let title: String
    let content: [String]
    
    public init(title: String, content: [String]) {
        self.title = title
        self.content = content
    }
}

// MARK: - Parser Errors

public enum DBSoupParseError: Error, LocalizedError {
    case invalidHeader(String)
    case unexpectedToken(String, line: Int)
    case invalidRelationship(String, line: Int)
    case invalidEntity(String, line: Int)
    case invalidField(String, line: Int)
    case invalidDataType(String, line: Int)
    case invalidConstraint(String, line: Int)
    case unexpectedEndOfFile
    case invalidCardinality(String, line: Int)
    
    public var errorDescription: String? {
        switch self {
        case .invalidHeader(let msg):
            return "Invalid header: \(msg)"
        case .unexpectedToken(let token, let line):
            return "Unexpected token '\(token)' at line \(line)"
        case .invalidRelationship(let msg, let line):
            return "Invalid relationship at line \(line): \(msg)"
        case .invalidEntity(let msg, let line):
            return "Invalid entity at line \(line): \(msg)"
        case .invalidField(let msg, let line):
            return "Invalid field at line \(line): \(msg)"
        case .invalidDataType(let msg, let line):
            return "Invalid data type at line \(line): \(msg)"
        case .invalidConstraint(let msg, let line):
            return "Invalid constraint at line \(line): \(msg)"
        case .unexpectedEndOfFile:
            return "Unexpected end of file"
        case .invalidCardinality(let msg, let line):
            return "Invalid cardinality at line \(line): \(msg)"
        }
    }
}

// MARK: - Lexer

/// Simple lexer for tokenizing DBSoup content
public class DBSoupLexer {
    private let content: String
    private let lines: [String]
    private var currentLine = 0
    
    public init(content: String) {
        self.content = content
        self.lines = content.components(separatedBy: .newlines)
    }
    
    public func hasMoreLines() -> Bool {
        return currentLine < lines.count
    }
    
    public func peekLine() -> String? {
        guard hasMoreLines() else { return nil }
        return lines[currentLine]
    }
    
    public func peekNextLine() -> String? {
        guard currentLine + 1 < lines.count else { return nil }
        return lines[currentLine + 1]
    }
    
    public func nextLine() -> String? {
        guard hasMoreLines() else { return nil }
        let line = lines[currentLine]
        currentLine += 1
        return line
    }
    
    public func getCurrentLineNumber() -> Int {
        return currentLine + 1
    }
    
    public func skipEmptyLines() {
        while hasMoreLines() {
            if let line = peekLine(), line.trimmingCharacters(in: .whitespaces).isEmpty {
                _ = nextLine()
            } else {
                break
            }
        }
    }
    
    public func skipComments() {
        while hasMoreLines() {
            if let line = peekLine(), line.trimmingCharacters(in: .whitespaces).starts(with: "#") {
                _ = nextLine()
            } else {
                break
            }
        }
    }
    
    public func skipEmptyLinesAndComments() {
        while hasMoreLines() {
            if let line = peekLine() {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty || trimmed.starts(with: "#") {
                    _ = nextLine()
                } else {
                    break
                }
            } else {
                break
            }
        }
    }
}

// MARK: - Main Parser

/// Main DBSoup parser class
public class DBSoupParser {
    private let lexer: DBSoupLexer
    private var comments: [String] = []
    
    public init(content: String) {
        self.lexer = DBSoupLexer(content: content)
    }
    
    public func parse() throws -> DBSoupDocument {
        let header = try parseHeader()
        let relationshipDefinitions = try parseRelationshipDefinitions()
        let schemaDefinition = try parseSchemaDefinition()
        
        return DBSoupDocument(
            header: header,
            relationshipDefinitions: relationshipDefinitions,
            schemaDefinition: schemaDefinition,
            comments: comments
        )
    }
    
    // MARK: - Header Parsing
    
    private func parseHeader() throws -> DBSoupHeader? {
        guard let line = lexer.peekLine(),
              line.trimmingCharacters(in: .whitespaces).starts(with: "@") else {
            return nil
        }
        
        _ = lexer.nextLine()
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        
        if trimmed.hasSuffix(".dbsoup") {
            let filename = String(trimmed.dropFirst().dropLast(7)) // Remove @ and .dbsoup
            return DBSoupHeader(filename: filename)
        } else {
            throw DBSoupParseError.invalidHeader("Header must end with .dbsoup")
        }
    }
    
    // MARK: - Relationship Definitions Parsing
    
    private func parseRelationshipDefinitions() throws -> RelationshipDefinitions? {
        lexer.skipEmptyLinesAndComments()
        
        guard let line = lexer.peekLine(),
              line.trimmingCharacters(in: .whitespaces) == "=== RELATIONSHIP DEFINITIONS ===" else {
            return nil
        }
        
        _ = lexer.nextLine()
        lexer.skipEmptyLinesAndComments()
        
        var relationships: [Relationship] = []
        
        while lexer.hasMoreLines() {
            guard let line = lexer.peekLine() else { break }
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.starts(with: "=== DATABASE SCHEMA ===") {
                break
            }
            
            if trimmed.starts(with: "#") {
                // Skip section headers like "# One-to-Many Relationships"
                _ = lexer.nextLine()
                continue
            }
            
            if trimmed.isEmpty {
                _ = lexer.nextLine()
                continue
            }
            
            if let relationship = try parseRelationship(line: trimmed) {
                relationships.append(relationship)
            }
            
            _ = lexer.nextLine()
        }
        
        return RelationshipDefinitions(relationships: relationships)
    }
    
    private func parseRelationship(line: String) throws -> Relationship? {
        // Parse: "User -> Account [M:N] (association) via Member"
        let components = line.components(separatedBy: " -> ")
        guard components.count == 2 else { return nil }
        
        let fromEntity = components[0].trimmingCharacters(in: .whitespaces)
        let remaining = components[1]
        
        // Extract cardinality
        let cardinalityPattern = "\\[([^\\]]+)\\]"
        let cardinalityRegex = try NSRegularExpression(pattern: cardinalityPattern)
        let cardinalityMatches = cardinalityRegex.matches(in: remaining, options: [], range: NSRange(location: 0, length: remaining.count))
        
        guard let cardinalityMatch = cardinalityMatches.first else {
            throw DBSoupParseError.invalidRelationship("Missing cardinality", line: lexer.getCurrentLineNumber())
        }
        
        let cardinalityRange = Range(cardinalityMatch.range(at: 1), in: remaining)!
        let cardinalityString = String(remaining[cardinalityRange])
        
        guard let cardinality = RelationshipCardinality(rawValue: cardinalityString) else {
            throw DBSoupParseError.invalidCardinality("Unknown cardinality: \(cardinalityString)", line: lexer.getCurrentLineNumber())
        }
        
        // Extract to entity (before cardinality)
        let toEntityEnd = remaining.range(of: " [")?.lowerBound ?? remaining.endIndex
        let toEntity = String(remaining[..<toEntityEnd]).trimmingCharacters(in: .whitespaces)
        
        // Extract nature (optional)
        var nature: RelationshipNature?
        let naturePattern = "\\(([^\\)]+)\\)"
        let natureRegex = try NSRegularExpression(pattern: naturePattern)
        let natureMatches = natureRegex.matches(in: remaining, options: [], range: NSRange(location: 0, length: remaining.count))
        
        if let natureMatch = natureMatches.first {
            let natureRange = Range(natureMatch.range(at: 1), in: remaining)!
            let natureString = String(remaining[natureRange])
            nature = RelationshipNature(rawValue: natureString)
        }
        
        // Extract via entity (optional)
        var viaEntity: String?
        if let viaRange = remaining.range(of: " via ") {
            let viaStart = viaRange.upperBound
            let viaString = String(remaining[viaStart...]).trimmingCharacters(in: .whitespaces)
            // Remove any trailing comment
            if let commentStart = viaString.range(of: " #") {
                viaEntity = String(viaString[..<commentStart.lowerBound]).trimmingCharacters(in: .whitespaces)
            } else {
                viaEntity = viaString
            }
        }
        
        return Relationship(
            fromEntity: fromEntity,
            toEntity: toEntity,
            cardinality: cardinality,
            nature: nature,
            viaEntity: viaEntity
        )
    }
    
    // MARK: - Schema Definition Parsing
    
    private func parseSchemaDefinition() throws -> SchemaDefinition {
        lexer.skipEmptyLinesAndComments()
        
        guard let line = lexer.peekLine(),
              line.trimmingCharacters(in: .whitespaces) == "=== DATABASE SCHEMA ===" else {
            throw DBSoupParseError.unexpectedToken("Expected '=== DATABASE SCHEMA ==='", line: lexer.getCurrentLineNumber())
        }
        
        _ = lexer.nextLine()
        
        let modules = try parseModuleList()
        let moduleSections = try parseModuleSections()
        
        return SchemaDefinition(modules: modules, moduleSections: moduleSections)
    }
    
    private func parseModuleList() throws -> [String] {
        var modules: [String] = []
        
        lexer.skipEmptyLinesAndComments()
        
        while lexer.hasMoreLines() {
            guard let line = lexer.peekLine() else { break }
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.starts(with: "+") {
                let moduleName = String(trimmed.dropFirst()).trimmingCharacters(in: .whitespaces)
                // Remove inline comment if present
                let cleanModuleName = moduleName.components(separatedBy: " #")[0].trimmingCharacters(in: .whitespaces)
                modules.append(cleanModuleName)
                _ = lexer.nextLine()
            } else if trimmed.starts(with: "===") && trimmed.hasSuffix("===") {
                // Start of module section
                break
            } else if trimmed.starts(with: "#") || trimmed.isEmpty {
                _ = lexer.nextLine()
            } else {
                break
            }
        }
        
        return modules
    }
    
    private func parseModuleSections() throws -> [ModuleSection] {
        var sections: [ModuleSection] = []
        
        while lexer.hasMoreLines() {
            lexer.skipEmptyLinesAndComments()
            
            guard let line = lexer.peekLine() else { break }
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // More flexible module header parsing - handle variable equal signs
            if trimmed.starts(with: "=== ") {
                let section = try parseModuleSection()
                sections.append(section)
            } else {
                break
            }
        }
        
        return sections
    }
    
    private func parseModuleSection() throws -> ModuleSection {
        guard let line = lexer.nextLine() else {
            throw DBSoupParseError.unexpectedEndOfFile
        }
        
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.starts(with: "=== ") else {
            throw DBSoupParseError.unexpectedToken("Expected module section header", line: lexer.getCurrentLineNumber())
        }
        
        // Extract module name by removing equal signs from both sides
        let withoutStart = String(trimmed.dropFirst(4)) // Remove "=== "
        let components = withoutStart.components(separatedBy: "=")
        let moduleName = components[0].trimmingCharacters(in: .whitespaces)
        
        // Check for optional module description on the next line
        // Skip empty lines first
        while lexer.peekLine()?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            _ = lexer.nextLine()
        }
        
        var moduleDescription: String? = nil
        if let nextLine = lexer.peekLine()?.trimmingCharacters(in: .whitespaces),
           !nextLine.isEmpty && !nextLine.starts(with: "#") && !isEntityHeader(nextLine) {
            // This looks like a description line
            moduleDescription = lexer.nextLine()?.trimmingCharacters(in: .whitespaces)
        }
        
        let entities = try parseEntities()
        
        return ModuleSection(name: moduleName, description: moduleDescription, entities: entities)
    }
    
    private func isEntityHeader(_ line: String) -> Bool {
        // Check if line looks like an entity header (typically followed by ===)
        // or is a comment line starting with #
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.starts(with: "#") {
            return true
        }
        
        // Check if the next line is a separator line (starts with =)
        if let nextLine = lexer.peekNextLine()?.trimmingCharacters(in: .whitespaces),
           nextLine.starts(with: "=") && nextLine.count >= 5 {
            return true
        }
        
        return false
    }
    
    private func parseEntities() throws -> [Entity] {
        var entities: [Entity] = []
        
        while lexer.hasMoreLines() {
            lexer.skipEmptyLinesAndComments()
            
            guard let line = lexer.peekLine() else { break }
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // More flexible module header detection - handle variable equal signs
            if trimmed.starts(with: "=== ") {
                // Start of next module section
                break
            }
            
            if trimmed.starts(with: "#") || trimmed.isEmpty {
                _ = lexer.nextLine()
                continue
            }
            
            let entity = try parseEntity()
            entities.append(entity)
        }
        
        return entities
    }
    
    private func parseEntity() throws -> Entity {
        guard let line = lexer.nextLine() else {
            throw DBSoupParseError.unexpectedEndOfFile
        }
        
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        
        // Extract entity name and comment
        let components = trimmed.components(separatedBy: " #")
        let entityName = components[0].trimmingCharacters(in: .whitespaces)
        let comment = components.count > 1 ? components[1].trimmingCharacters(in: .whitespaces) : nil
        
        // Parse entity separator to determine type
        guard let separatorLine = lexer.nextLine() else {
            throw DBSoupParseError.unexpectedEndOfFile
        }
        
        let separatorTrimmed = separatorLine.trimmingCharacters(in: .whitespaces)
        let entityType: EntityType
        
        if separatorTrimmed.starts(with: "=") {
            entityType = .standard
        } else if separatorTrimmed.starts(with: "/") && separatorTrimmed.hasSuffix("/") {
            entityType = .embedded
        } else {
            throw DBSoupParseError.invalidEntity("Invalid entity separator", line: lexer.getCurrentLineNumber())
        }
        
        let fields = try parseFields()
        let relationshipSections = try parseRelationshipSections()
        let featureSections = try parseFeatureSections()
        
        return Entity(
            name: entityName,
            type: entityType,
            fields: fields,
            relationshipSections: relationshipSections,
            featureSections: featureSections,
            comment: comment
        )
    }
    
    // MARK: - Field Parsing
    
    private func parseFields() throws -> [Field] {
        var fields: [Field] = []
        
        while lexer.hasMoreLines() {
            guard let line = lexer.peekLine() else { break }
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Check for end of fields section
            if trimmed.starts(with: "#") || trimmed.isEmpty {
                break
            }
            
            if trimmed.starts(with: "=== ") && trimmed.hasSuffix(" ===") {
                // Start of next module section
                break
            }
            
            // Check if this is a field line (starts with field prefix)
            if let firstChar = trimmed.first,
               FieldPrefix.allCases.contains(where: { $0.rawValue == String(firstChar) }) {
                let field = try parseField()
                fields.append(field)
            } else {
                break
            }
        }
        
        return fields
    }
    
    private func parseField() throws -> Field {
        guard let line = lexer.nextLine() else {
            throw DBSoupParseError.unexpectedEndOfFile
        }
        
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        
        // Extract prefixes
        var prefixes: [FieldPrefix] = []
        var index = trimmed.startIndex
        
        while index < trimmed.endIndex {
            let char = String(trimmed[index])
            if let prefix = FieldPrefix(rawValue: char) {
                prefixes.append(prefix)
                index = trimmed.index(after: index)
            } else {
                break
            }
        }
        
        guard !prefixes.isEmpty else {
            throw DBSoupParseError.invalidField("Missing field prefix", line: lexer.getCurrentLineNumber())
        }
        
        let remaining = String(trimmed[index...]).trimmingCharacters(in: .whitespaces)
        
        // Split by colon to separate field names and data type
        let components = remaining.components(separatedBy: ":")
        guard components.count >= 2 else {
            throw DBSoupParseError.invalidField("Missing field type", line: lexer.getCurrentLineNumber())
        }
        
        // Parse field names
        let fieldNamesString = components[0].trimmingCharacters(in: .whitespaces)
        let fieldNames = fieldNamesString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        // Parse data type and constraints
        let typeAndConstraints = components[1...].joined(separator: ":").trimmingCharacters(in: .whitespaces)
        
        let (dataType, constraints, comment) = try parseDataTypeAndConstraints(typeAndConstraints)
        
        return Field(
            prefixes: prefixes,
            names: fieldNames,
            dataType: dataType,
            constraints: constraints,
            comment: comment
        )
    }
    
    private func parseDataTypeAndConstraints(_ input: String) throws -> (DataType, [Constraint], String?) {
        var workingInput = input
        var comment: String?
        
        // Extract inline comment first
        if let commentStart = workingInput.range(of: " #") {
            comment = String(workingInput[commentStart.upperBound...]).trimmingCharacters(in: .whitespaces)
            workingInput = String(workingInput[..<commentStart.lowerBound]).trimmingCharacters(in: .whitespaces)
        }
        
        // Extract constraints (everything in square brackets)
        var constraints: [Constraint] = []
        let constraintPattern = "\\[([^\\]]+)\\]"
        let constraintRegex = try NSRegularExpression(pattern: constraintPattern)
        let constraintMatches = constraintRegex.matches(in: workingInput, options: [], range: NSRange(location: 0, length: workingInput.count))
        
        for match in constraintMatches.reversed() {
            let constraintRange = Range(match.range(at: 1), in: workingInput)!
            let constraintString = String(workingInput[constraintRange])
            
            // Parse individual constraints
            let individualConstraints = constraintString.components(separatedBy: ",")
            for constraintStr in individualConstraints {
                let constraintParts = constraintStr.components(separatedBy: ":")
                let name = constraintParts[0].trimmingCharacters(in: .whitespaces)
                let value = constraintParts.count > 1 ? constraintParts[1...].joined(separator: ":").trimmingCharacters(in: .whitespaces) : nil
                constraints.append(Constraint(name: name, value: value))
            }
            
            // Remove constraint from working input
            let fullRange = Range(match.range(at: 0), in: workingInput)!
            workingInput.removeSubrange(fullRange)
        }
        
        // Parse data type
        let dataTypeString = workingInput.trimmingCharacters(in: .whitespaces)
        let dataType = try parseDataType(dataTypeString)
        
        return (dataType, constraints, comment)
    }
    
    private func parseDataType(_ input: String) throws -> DataType {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        
        // Array type: Array<Type>
        if trimmed.starts(with: "Array<") && trimmed.hasSuffix(">") {
            let innerType = String(trimmed.dropFirst(6).dropLast())
            let parsedInnerType = try parseDataType(innerType)
            return .array(parsedInnerType)
        }
        
        // Parametric type: Type(param1, param2)
        if let parenStart = trimmed.range(of: "("),
           trimmed.hasSuffix(")") {
            let typeName = String(trimmed[..<parenStart.lowerBound])
            let paramString = String(trimmed[parenStart.upperBound..<trimmed.index(before: trimmed.endIndex)])
            let params = paramString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            return .parametric(typeName, params)
        }
        
        // Relationship array type: EntityName[cardinality]
        if let bracketStart = trimmed.range(of: "["),
           trimmed.hasSuffix("]") {
            let entityName = String(trimmed[..<bracketStart.lowerBound])
            let cardinalityString = String(trimmed[bracketStart.upperBound..<trimmed.index(before: trimmed.endIndex)])
            let cardinality = try parseCardinality(cardinalityString)
            return .relationshipArray(entityName, cardinality)
        }
        
        // JSON object type
        if trimmed.starts(with: "JSON") {
            // For now, treat as simple JSON type
            // TODO: Parse JSON object structure if needed
            return .jsonObject([])
        }
        
        // Simple type or embedded entity
        return .simple(trimmed)
    }
    
    private func parseCardinality(_ input: String) throws -> Cardinality {
        let components = input.components(separatedBy: "..")
        guard components.count == 2 else {
            throw DBSoupParseError.invalidCardinality("Invalid cardinality format", line: lexer.getCurrentLineNumber())
        }
        
        guard let min = Int(components[0]) else {
            throw DBSoupParseError.invalidCardinality("Invalid minimum cardinality", line: lexer.getCurrentLineNumber())
        }
        
        let maxString = components[1]
        let max: CardinalityMax
        
        if maxString == "*" {
            max = .unlimited
        } else if let maxInt = Int(maxString) {
            max = .number(maxInt)
        } else {
            throw DBSoupParseError.invalidCardinality("Invalid maximum cardinality", line: lexer.getCurrentLineNumber())
        }
        
        return Cardinality(min: min, max: max)
    }
    
    // MARK: - Relationship Sections Parsing
    
    private func parseRelationshipSections() throws -> [RelationshipSection] {
        var sections: [RelationshipSection] = []
        
        while lexer.hasMoreLines() {
            guard let line = lexer.peekLine() else { break }
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed == "# RELATIONSHIPS" {
                let section = try parseRelationshipSection()
                sections.append(section)
            } else {
                break
            }
        }
        
        return sections
    }
    
    private func parseRelationshipSection() throws -> RelationshipSection {
        _ = lexer.nextLine() // consume "# RELATIONSHIPS"
        
        var relationships: [String] = []
        var details: [RelationshipDetail] = []
        
        while lexer.hasMoreLines() {
            guard let line = lexer.peekLine() else { break }
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.starts(with: "@ relationships::") {
                let relationshipText = String(trimmed.dropFirst(17)).trimmingCharacters(in: .whitespaces)
                relationships.append(relationshipText)
                _ = lexer.nextLine()
            } else if trimmed.starts(with: "## ") {
                // Parse relationship detail
                _ = lexer.nextLine()
                // TODO: Parse relationship details if needed
            } else if trimmed.starts(with: "#") && !trimmed.starts(with: "## ") {
                // Start of next section
                break
            } else if trimmed.isEmpty {
                _ = lexer.nextLine()
            } else {
                break
            }
        }
        
        return RelationshipSection(relationships: relationships, details: details)
    }
    
    // MARK: - Feature Sections Parsing
    
    private func parseFeatureSections() throws -> [FeatureSection] {
        var sections: [FeatureSection] = []
        
        while lexer.hasMoreLines() {
            guard let line = lexer.peekLine() else { break }
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.starts(with: "# ") && !trimmed.starts(with: "## ") && trimmed != "# RELATIONSHIPS" {
                let section = try parseFeatureSection()
                sections.append(section)
            } else {
                break
            }
        }
        
        return sections
    }
    
    private func parseFeatureSection() throws -> FeatureSection {
        guard let line = lexer.nextLine() else {
            throw DBSoupParseError.unexpectedEndOfFile
        }
        
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        let title = String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces)
        
        var content: [String] = []
        
        while lexer.hasMoreLines() {
            guard let line = lexer.peekLine() else { break }
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.starts(with: "#") || trimmed.starts(with: "=== ") {
                break
            }
            
            content.append(trimmed)
            _ = lexer.nextLine()
        }
        
        return FeatureSection(title: title, content: content)
    }
} 
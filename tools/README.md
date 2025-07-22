# DBSoup Swift Parser Toolkit

A comprehensive Swift library and command-line tool for parsing, validating, and generating DBSoup database schema files.

## Overview

The DBSoup Swift Parser Toolkit provides a complete solution for working with DBSoup format files in Swift applications. It includes:

- **Parser**: Parse DBSoup files into structured Swift objects
- **Validator**: Validate DBSoup documents against the specification
- **Formatter**: Format and prettify DBSoup files with consistent alignment and spacing
- **Statistics**: Analyze DBSoup documents and generate usage statistics
- **CLI Tool**: Command-line interface for all operations

## Features

### 🔍 Parser Capabilities
- **Complete Grammar Support**: Implements the full DBSoup EBNF grammar
- **Error Handling**: Detailed error messages with line numbers
- **Flexible Input**: Parse from strings, files, or streams
- **Memory Efficient**: Streaming lexer for large files
- **Relationship Parsing**: Full support for relationship definitions and cardinalities
- **Field Prefix Recognition**: Supports all field prefixes (*, -, !, @, ~, >, $)
- **Data Type Parsing**: Handles simple, parametric, array, and relationship types
- **Constraint Parsing**: Parses all constraint types with values

### ✅ Comprehensive Validation Engine

The validation engine performs extensive checks across multiple categories:

#### **Schema Structure Validation**
- **Entity Uniqueness**: Ensures no duplicate entity names across modules
- **Field Uniqueness**: Validates unique field names within each entity
- **Module Structure**: Validates proper module organization and naming
- **Header Validation**: Checks header format and filename validity

#### **Field Validation**
- **Prefix Validation**: Ensures valid field prefix combinations
  - Cannot have both required (*) and optional (-) prefixes
  - System fields should not be marked as required
- **Data Type Validation**: Validates all data types against known types
  - Simple types: String, Int, Float, Double, Boolean, DateTime, etc.
  - Parametric types: String(n), Decimal(p,s), Enum(values)
  - Array types: Array<Type> with recursive validation
  - Relationship types: EntityName[cardinality] with entity existence checks
- **Constraint Validation**: Validates constraint syntax and requirements
  - PRIMARY KEY (PK): No value required
  - FOREIGN KEY (FK): Must reference existing entity.field
  - UNIQUE (UK): Valid constraint format
  - INDEX (IX): Valid index definition
  - DEFAULT: Must have a value
  - ENUM: Must have enumerated values
  - SYSTEM, AUTO, ENCRYPTED: Valid system constraints

#### **Relationship Validation**
- **Entity Existence**: Ensures referenced entities exist in schema
- **Cardinality Consistency**: Validates relationship cardinalities match nature
- **Via Entity Validation**: Checks intermediate entities for M:N relationships
- **Circular Reference Detection**: Detects inheritance cycles using DFS algorithm
- **Relationship Nature Validation**: Ensures proper composition/aggregation/association usage

#### **Cross-Reference Validation**
- **Foreign Key Integrity**: Validates FK references point to existing entities and fields
- **Relationship Consistency**: Ensures relationship definitions match field definitions
- **Data Type Consistency**: Validates compatible data types in relationships

#### **Primary Key Validation**
- **Existence Check**: Every entity must have at least one primary key field
- **Constraint Validation**: Primary key constraints must be properly formatted

#### **Validation Output**
```swift
public struct DBSoupValidationResult {
    public let isValid: Bool
    public let errors: [DBSoupValidationError]    // Critical issues
    public let warnings: [String]                 // Best practice suggestions
}
```

**Example Validation Errors:**
- `duplicateEntityName("User")` - Entity "User" defined multiple times
- `missingPrimaryKey("Account")` - Entity "Account" has no primary key
- `invalidForeignKey("InvalidEntity.field", entity: "User", field: "accountId")` - FK references non-existent entity
- `circularReference("Inheritance cycle: User -> Manager -> User")` - Circular inheritance detected

### 📊 Comprehensive Analytics Engine

The analytics engine provides detailed insights into your DBSoup schema:

#### **Entity Analytics**
- **Total Entity Count**: Overall number of entities in schema
- **Entity Type Distribution**: Standard vs. embedded entities
- **Entities Per Module**: Breakdown by module organization
- **Entity Complexity**: Field count distribution across entities

#### **Field Analytics**
- **Total Field Count**: Overall number of fields across all entities
- **Field Prefix Distribution**: Usage statistics for each prefix type
  - Required fields (*): Count and percentage
  - Optional fields (-): Count and percentage  
  - Indexed fields (!): Count and percentage
  - Sensitive fields (@): Count and percentage
  - Masked fields (~): Count and percentage
  - Partitioned fields (>): Count and percentage
  - Audit fields ($): Count and percentage
- **Field Name Analysis**: Common field naming patterns
- **Field Density**: Average fields per entity

#### **Data Type Analytics**
- **Data Type Distribution**: Most commonly used data types
- **Parametric Type Usage**: Analysis of String(n), Decimal(p,s) usage
- **Array Type Analysis**: Usage of Array<Type> constructs
- **Relationship Type Metrics**: Entity reference patterns
- **Type Complexity**: Simple vs. complex type usage

#### **Constraint Analytics**
- **Constraint Usage**: Frequency of each constraint type
- **Primary Key Patterns**: Single vs. composite primary keys
- **Foreign Key Analysis**: Relationship connection patterns
- **Index Usage**: Indexing strategy analysis
- **Default Value Patterns**: Common default value usage
- **System Field Analysis**: Auto-generated field patterns

#### **Relationship Analytics**
- **Relationship Count**: Total number of defined relationships
- **Cardinality Distribution**: 1:1, 1:M, M:N relationship breakdown
- **Relationship Nature**: Composition, aggregation, association analysis
- **Via Entity Usage**: M:N relationship intermediate entity patterns
- **Relationship Complexity**: Average relationships per entity

#### **Module Analytics**
- **Module Organization**: Entity distribution across modules
- **Module Cohesion**: Related entity grouping analysis
- **Cross-Module Dependencies**: Inter-module relationship patterns
- **Module Size Analysis**: Optimal module size recommendations

#### **Quality Metrics**
- **Schema Completeness**: Percentage of fields with constraints
- **Relationship Coverage**: Entities with defined relationships
- **Naming Consistency**: Field and entity naming pattern analysis
- **Documentation Coverage**: Entities and fields with comments

#### **Analytics Output Example**
```swift
let statistics = statsGenerator.generateStatistics(for: document)

// Example output:
// totalEntities: 21
// standardEntities: 21, embeddedEntities: 0
// totalFields: 157
// totalRelationships: 23
// moduleCount: 6
// 
// modules: [
//   "Core": 4,
//   "Authentication": 3,
//   "Routes": 3,
//   "Logistics": 4,
//   "Audit": 4,
//   "Configuration": 3
// ]
//
// dataTypes: [
//   "String": 89,
//   "DateTime": 31,
//   "Int": 18,
//   "Boolean": 12,
//   "Double": 4,
//   "Decimal": 3
// ]
//
// constraints: [
//   "DEFAULT": 67,
//   "FK": 23,
//   "PK": 21,
//   "UK": 8,
//   "INDEX": 12,
//   "SYSTEM": 31,
//   "ENCRYPTED": 15
// ]
//
// fieldPrefixes: [
//   "*": 89,    // Required fields
//   "-": 68,    // Optional fields
//   "@": 15,    // Sensitive fields
//   "!": 12     // Indexed fields
// ]
```

### 📝 Advanced Code Generation

The generator provides sophisticated formatting and output capabilities:

#### **Formatting Features**
- **Configurable Field Widths**: Customizable column alignment
- **Constraint Alignment**: Proper spacing for readability
- **Comment Preservation**: Maintain or strip comments
- **Sorting Options**: Alphabetical sorting of entities and fields
- **Consistent Spacing**: Professional formatting standards

#### **Output Customization**
```swift
let config = DBSoupFormatterConfig(
    indentationSpaces: 4,              // Spaces for indentation
    fieldNameWidth: 20,                // Width for field names column
    dataTypeWidth: 25,                 // Width for data types column
    constraintColumnStart: 45,         // Start position for constraints
    includeComments: true,             // Include comments in output
    sortEntitiesAlphabetically: false, // Sort entities alphabetically
    sortFieldsAlphabetically: false    // Sort fields alphabetically
)
```

#### **Formatting Capabilities**
- **Pretty Printing**: Professional formatting with consistent alignment
- **Partial Formatting**: Format specific modules or entities
- **Format Validation**: Ensure output conforms to DBSoup specification
- **Round-trip Compatibility**: Parse → Format → Parse produces identical results

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/dbsoup-swift", from: "1.0.0")
]
```

### Manual Installation

1. Clone the repository
2. Copy the Swift files to your project
3. Import the modules as needed

## Usage

### Basic Parsing

```swift
import DBSoupParser

// Parse from string
let dbsoupContent = """
@example.dbsoup

=== RELATIONSHIP DEFINITIONS ===
# One-to-Many Relationships
User -> Post [1:M] (composition)
Account -> User [1:M] (aggregation)

=== DATABASE SCHEMA ===
+ Core
+ Blog

=== Core ===

User # User entity with authentication
==========
* id              : String                 [PK]
* username        : String(50)             [UK,INDEX]
@ password        : String                 [ENCRYPTED]
* email           : String                 [UK,INDEX]
* accountId       : String                 [FK:Account.id]
* isActive        : Boolean                [DEFAULT:true]
* createdAt       : DateTime               [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
* updatedAt       : DateTime               [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
- profile         : UserProfile            # Optional embedded profile
- preferences     : JSON                   # User preferences

Account # Account entity for organizations
==========
* id              : String                 [PK]
* name            : String(100)            [UK]
* email           : String                 [UK,INDEX]
* accountType     : Int                    [ENUM:1,2,3,4,5]
* isActive        : Boolean                [DEFAULT:true]
* createdAt       : DateTime               [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]

=== Blog ===

Post # Blog post entity
==========
* id              : String                 [PK]
* title           : String(200)            [INDEX]
* content         : Text                   
* authorId        : String                 [FK:User.id]
* status          : Int                    [ENUM:1,2,3,DEFAULT:1]
* publishedAt     : DateTime               
* createdAt       : DateTime               [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
* updatedAt       : DateTime               [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
- tags            : Tag[0..*]              # Optional tags
"""

let parser = DBSoupParser(content: dbsoupContent)
let document = try parser.parse()

// Access parsed structure
print("Header: \(document.header?.filename ?? "none")")
print("Modules: \(document.schemaDefinition.modules.count)")
print("Entities: \(document.schemaDefinition.moduleSections.reduce(0) { $0 + $1.entities.count })")
```

### Comprehensive Validation

```swift
import DBSoupParser

let validator = DBSoupValidator(document: document)
let result = validator.validate()

if result.isValid {
    print("✅ Document is valid")
} else {
    print("❌ Validation errors:")
    for error in result.errors {
        print("  • \(error.localizedDescription)")
    }
}

if !result.warnings.isEmpty {
    print("⚠️  Warnings:")
    for warning in result.warnings {
        print("  • \(warning)")
    }
}

// Example validation output:
// ❌ Validation errors:
//   • Missing primary key in entity 'UserProfile'
//   • Invalid foreign key 'NonExistentEntity.field' for field 'invalidRef' in entity 'User'
//   • Duplicate entity name: 'User'
//   • Circular reference detected: Inheritance cycle involving Manager
// 
// ⚠️  Warnings:
//   • No header found in document
//   • System field 'createdAt' in entity 'User' should not be required
//   • Unknown data type 'CustomType' for field 'customField' in entity 'User'
//   • Many-to-many relationship without via entity: User -> Role
```

### Advanced Formatting with Custom Configuration

```swift
import DBSoupParser

let config = DBSoupFormatterConfig(
    fieldNameWidth: 20,
    dataTypeWidth: 25,
    constraintColumnStart: 45,
    includeComments: true,
    sortEntitiesAlphabetically: true,
    sortFieldsAlphabetically: true
)

    let formatter = DBSoupFormatter(config: config)
let formattedOutput = formatter.format(document: document)

// Example formatted output:
// @example.dbsoup
// 
// === RELATIONSHIP DEFINITIONS ===
// # One-to-Many Relationships
// Account -> User [1:M] (aggregation)
// User -> Post [1:M] (composition)
// 
// === DATABASE SCHEMA ===
// + Blog
// + Core
// 
// === Blog ===
// 
// Post                     # Blog post entity
// ==========
// * authorId          : String                     [FK:User.id]
// * content           : Text                       
// * createdAt         : DateTime                   [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
// * id                : String                     [PK]
// * publishedAt       : DateTime                   
// * status            : Int                        [ENUM:1,2,3,DEFAULT:1]
// - tags              : Tag[0..*]                  # Optional tags
// * title             : String(200)                [INDEX]
// * updatedAt         : DateTime                   [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]

print(formattedOutput)
```

### Detailed Statistics Generation

```swift
import DBSoupParser

let statsGenerator = DBSoupStatisticsGenerator()
let statistics = statsGenerator.generateStatistics(for: document)

// Access detailed statistics
print("=== Schema Overview ===")
print("Total Entities: \(statistics.totalEntities)")
print("Standard Entities: \(statistics.standardEntities)")
print("Embedded Entities: \(statistics.embeddedEntities)")
print("Total Fields: \(statistics.totalFields)")
print("Total Relationships: \(statistics.totalRelationships)")
print("Modules: \(statistics.moduleCount)")

print("\n=== Data Type Analysis ===")
let sortedDataTypes = statistics.dataTypes.sorted { $0.value > $1.value }
for (index, (dataType, count)) in sortedDataTypes.enumerated() {
    let percentage = Double(count) / Double(statistics.totalFields) * 100
    print("\(index + 1). \(dataType): \(count) (\(String(format: "%.1f", percentage))%)")
}

print("\n=== Constraint Analysis ===")
let sortedConstraints = statistics.constraints.sorted { $0.value > $1.value }
for (index, (constraint, count)) in sortedConstraints.enumerated() {
    print("\(index + 1). \(constraint): \(count)")
}

print("\n=== Field Prefix Analysis ===")
let sortedPrefixes = statistics.fieldPrefixes.sorted { $0.value > $1.value }
for (prefix, count) in sortedPrefixes {
    let prefixName = fieldPrefixName(prefix)
    let percentage = Double(count) / Double(statistics.totalFields) * 100
    print("\(prefixName): \(count) (\(String(format: "%.1f", percentage))%)")
}

print("\n=== Module Distribution ===")
for (module, count) in statistics.modules.sorted(by: { $0.key < $1.key }) {
    let percentage = Double(count) / Double(statistics.totalEntities) * 100
    print("\(module): \(count) entities (\(String(format: "%.1f", percentage))%)")
}

// Generate comprehensive report
let report = statsGenerator.printStatistics(statistics)
print("\n=== Full Report ===")
print(report)

// Helper function
func fieldPrefixName(_ prefix: String) -> String {
    switch prefix {
    case "*": return "Required"
    case "-": return "Optional"
    case "!": return "Indexed"
    case "@": return "Sensitive"
    case "~": return "Masked"
    case ">": return "Partitioned"
    case "$": return "Audit"
    default: return "Unknown"
    }
}
```

### Advanced Query Operations

```swift
import DBSoupParser

// Query entities by characteristics
func findEntitiesWithField(_ document: DBSoupDocument, fieldName: String) -> [Entity] {
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

// Find entities with specific constraints
func findEntitiesWithConstraint(_ document: DBSoupDocument, constraint: String) -> [Entity] {
    var result: [Entity] = []
    
    for section in document.schemaDefinition.moduleSections {
        for entity in section.entities {
            if entity.fields.contains(where: { field in
                field.constraints.contains { $0.name == constraint }
            }) {
                result.append(entity)
            }
        }
    }
    
    return result
}

// Find relationship patterns
func analyzeRelationshipPatterns(_ document: DBSoupDocument) -> [String: Int] {
    guard let relationships = document.relationshipDefinitions else { return [:] }
    
    return Dictionary(grouping: relationships.relationships) { relationship in
        if let nature = relationship.nature {
            return "\(relationship.cardinality.rawValue) (\(nature.rawValue))"
        } else {
            return relationship.cardinality.rawValue
        }
    }.mapValues { $0.count }
}

// Usage examples
let entitiesWithEmail = findEntitiesWithField(document, fieldName: "email")
let entitiesWithFK = findEntitiesWithConstraint(document, constraint: "FK")
let relationshipPatterns = analyzeRelationshipPatterns(document)

print("Entities with email field: \(entitiesWithEmail.map { $0.name })")
print("Entities with foreign keys: \(entitiesWithFK.map { $0.name })")
print("Relationship patterns: \(relationshipPatterns)")
```

## Command Line Interface

### Installation

```bash
swift build -c release
cp .build/release/dbsoup /usr/local/bin/
```

### Usage

```bash
# Parse a DBSoup file
dbsoup parse schema.dbsoup

# Validate a DBSoup file
dbsoup validate schema.dbsoup

# Format a DBSoup file
dbsoup format schema.dbsoup formatted.dbsoup

# Generate statistics
dbsoup stats schema.dbsoup

# Generate SVG diagram
dbsoup svg schema.dbsoup --output diagram.svg

# Show help
dbsoup help
```

### Detailed CLI Examples

#### Parse Command Output
```bash
$ dbsoup parse roadwarrior.dbsoup
✅ Successfully parsed DBSoup file: roadwarrior.dbsoup

📋 Header: @roadwarrior.dbsoup
🔗 Relationships: 23
   • 1:M: 21
   • M:N: 2
📦 Modules: Core, Authentication, Routes, Logistics, Audit, Configuration
🏗️ Total Entities: 21
📝 Total Fields: 157

Module Structure:
  Core: 4 entities
    🏗️ Account (26 fields)
    🏗️ User (36 fields)
    🏗️ Org (11 fields)
    🏗️ Member (18 fields)
  Authentication: 3 entities
    🏗️ RefreshTokens (12 fields)
    🏗️ ApiAuth (14 fields)
    🏗️ FedExAuth (15 fields)
  Routes: 3 entities
    🏗️ Route (43 fields)
    🏗️ Site (23 fields)
    🏗️ Schedule (17 fields)
  Logistics: 4 entities
    🏗️ Purchases (17 fields)
    🏗️ PurchaseLog (13 fields)
    🏗️ Stats (11 fields)
    🏗️ History (11 fields)
  Audit: 4 entities
    🏗️ Log (11 fields)
    🏗️ UserNote (11 fields)
    🏗️ UserNoteLog (9 fields)
  Configuration: 3 entities
    🏗️ Config (11 fields)
    🏗️ UserPref (11 fields)
    🏗️ BlobInfo (13 fields)
    🏗️ Install (12 fields)
```

#### Validate Command Output
```bash
$ dbsoup validate roadwarrior.dbsoup
✅ DBSoup file is valid: roadwarrior.dbsoup

⚠️  Warnings:
  ⚠️  Relationship consistency validation not yet implemented
  ⚠️  System field 'CD' in entity 'Account' should not be required
  ⚠️  System field 'LU' in entity 'Account' should not be required

📊 Summary: 0 errors, 3 warnings

🔍 Validation Details:
  ✅ Header validation: PASSED
  ✅ Entity uniqueness: PASSED (21 unique entities)
  ✅ Field uniqueness: PASSED (157 unique fields)
  ✅ Primary key validation: PASSED (21 entities with PK)
  ✅ Foreign key validation: PASSED (23 valid FK references)
  ✅ Relationship validation: PASSED (23 valid relationships)
  ✅ Circular reference check: PASSED (no cycles detected)
  ✅ Data type validation: PASSED (all types valid)
  ✅ Constraint validation: PASSED (157 constraints validated)
```

#### Stats Command Output
```bash
$ dbsoup stats roadwarrior.dbsoup
📊 DBSoup Statistics for: roadwarrior.dbsoup

=== DBSoup Statistics ===

Entities:
  Total: 21
  Standard: 21
  Embedded: 0

Fields: 157
Relationships: 23
Modules: 6

Entities per Module:
  Audit: 4
  Authentication: 3
  Configuration: 3
  Core: 4
  Logistics: 4
  Routes: 3

Data Type Usage:
  String: 89 (56.7%)
  DateTime: 31 (19.7%)
  Int: 18 (11.5%)
  Boolean: 12 (7.6%)
  Double: 4 (2.5%)
  Decimal: 2 (1.3%)
  Text: 1 (0.6%)

Constraint Usage:
  DEFAULT: 67 (42.7%)
  FK: 23 (14.6%)
  PK: 21 (13.4%)
  SYSTEM: 31 (19.7%)
  INDEX: 12 (7.6%)
  UK: 8 (5.1%)
  ENCRYPTED: 15 (9.6%)
  ENUM: 6 (3.8%)

Field Prefix Usage:
  * (Required): 89 (56.7%)
  - (Optional): 68 (43.3%)
  @ (Sensitive): 15 (9.6%)
  ! (Indexed): 12 (7.6%)

🔗 Relationship Analysis:
  One-to-Many: 21 (91.3%)
  Many-to-Many: 2 (8.7%)
  
  By Nature:
    Composition: 18 (78.3%)
    Aggregation: 3 (13.0%)
    Association: 2 (8.7%)

📈 Quality Metrics:
  Constraint Coverage: 89.2% (140/157 fields have constraints)
  Primary Key Coverage: 100% (21/21 entities have PK)
  Foreign Key Density: 14.6% (23/157 fields are FK)
  Comment Coverage: 85.7% (18/21 entities have comments)
```

#### Format Command Output
```bash
$ dbsoup format roadwarrior.dbsoup formatted.dbsoup
✅ Formatted DBSoup file saved to: formatted.dbsoup

📝 Formatting applied:
  • Field names aligned to 20 characters
  • Data types aligned to 25 characters
  • Constraints start at column 45
  • Comments preserved
  • Consistent spacing applied
  • Professional formatting standards applied

📊 Changes made:
  • 157 fields reformatted
  • 21 entities aligned
  • 23 relationships organized
  • 6 modules structured
```

#### SVG Generation Command Output
```bash
$ dbsoup svg roadwarrior.dbsoup --output diagram.svg
✅ SVG diagram saved to: diagram.svg

🎨 SVG Features Generated:
  • Entity boxes with gradient backgrounds (standard vs embedded entities)
  • **Professional blue-grey background** by default (#ecf0f1)
  • **Alphabetical entity sorting** for easy scanning and navigation
  • **⚡ Instant hover tooltips** for FK and embedded fields (0.1s response)
  • **Clickable foreign key navigation** with hyperlinks to referenced entities
  • **Clickable embedded entity navigation** with hyperlinks to embedded entities
  • **Clickable relationship legend** with entity names linking to their definitions
  • Color-coded field types:
    **Standard Entity Fields:**
    - Required: Orange (#ffa502)
    - Optional: Gray (#c7c7c7) 
    - Indexed: Blue (#5352ed)
    - Sensitive: Red (#ff4757)
    - Foreign Key: Purple (#e056fd) **[Clickable + Instant Tooltip]**
    - **Embedded Entity Reference: Bright Yellow (#ffeb3b) [Clickable + Instant Tooltip]**
    
    **Embedded Entity Fields (Consistent with Standard):**
    - Required: Orange (#ffa502) - same as standard
    - Optional: Gray (#c7c7c7) - same as standard  
    - Indexed: Blue (#5352ed) - same as standard
    - Sensitive: Red (#ff4757) - same as standard
    - Foreign Key: Purple (#e056fd) **[Clickable + Instant Tooltip]** - same as standard
    - **Embedded Entity Reference: Bright Yellow (#ffeb3b) [Clickable + Instant Tooltip]** - same as standard
  • Relationship lines with cardinality indicators
  • Module grouping with headers
  • Curved relationship connections
  • Professional styling with consistent fonts
  • Scalable vector graphics for any size

📊 Generated Elements:
  • 21 entity boxes
  • 23 relationship lines
  • 6 module headers
  • 157 field entries
  • **Relationship legend with dark background** (visible on any background)
  • Custom markers for different cardinalities
  • Responsive layout optimized for readability
```

**Example without output path:**
```bash
$ dbsoup svg roadwarrior.dbsoup
✅ SVG diagram saved to: roadwarrior.svg
```

**Features:**
- Professional database diagram visualization
- Automatic layout with intelligent entity positioning
- Color-coded field types for easy identification
- **Relationship legend with dark background** - visible on any background color
- **Configurable background colors** - transparent, light grey, blue-grey, warm grey, or custom
- Relationship visualization with proper cardinality indicators
- Module-based organization for large schemas
- High-quality SVG output suitable for documentation
- **Fully zoomable SVG** - zoom beyond 100% in web browsers
- Scalable graphics that work at any size
- Can be embedded in web pages, documents, or presentations

📋 **For complete color reference, see [SVG Color Reference Guide](./SVG_COLOR_REFERENCE.md)**

### Background Color Options

The SVG generator supports configurable background colors for enhanced visual appeal:

```swift
// Default blue-grey background (professional look)
let generator = DBSoupSVGGenerator(document: document)

// Other predefined background colors
let transparent = DBSoupSVGGenerator.withTransparentBackground(document: document)
let lightGrey = DBSoupSVGGenerator.withLightGreyBackground(document: document)
let warmGrey = DBSoupSVGGenerator.withWarmGreyBackground(document: document)

// Custom background color
let custom = DBSoupSVGGenerator(document: document, backgroundColor: "#f0f8ff")
```

**Background Color Options:**
- **Blue-Grey (#ecf0f1)** - **Default**, professional look, complements the color scheme
- **Light Grey (#f5f5f5)** - Maximum contrast, entities really pop
- **Warm Grey (#f8f9fa)** - Clean, modern, perfect for documentation
- **Transparent** - No background, works with any page background

**Benefits of Default Blue-Grey Background:**
- ✅ **Professional appearance** - Subtle blue tint complements the color scheme
- ✅ **Better contrast** - Dark entities stand out clearly
- ✅ **Print-friendly** - Provides context when printed
- ✅ **Documentation-ready** - Works well in technical documentation
- ✅ **Relationship legend compatibility** - Dark legend background remains visible

## API Reference

### Core Classes

#### `DBSoupParser`
Main parser class for converting DBSoup text to structured objects.

```swift
class DBSoupParser {
    init(content: String)
    func parse() throws -> DBSoupDocument
}
```

**Error Handling:**
- Throws `DBSoupParseError` with detailed line number information
- Provides context for syntax errors and invalid constructs

#### `DBSoupValidator`
Validates DBSoup documents against the specification.

```swift
class DBSoupValidator {
    init(document: DBSoupDocument)
    func validate() -> DBSoupValidationResult
}
```

**Validation Categories:**
- Schema structure validation
- Field and constraint validation
- Relationship integrity checks
- Cross-reference validation
- Circular reference detection

#### `DBSoupFormatter`
Formats and prettifies DBSoup text from parsed structures.

```swift
class DBSoupFormatter {
    init(config: DBSoupFormatterConfig = .default)
    func format(document: DBSoupDocument) -> String
}
```

**Configuration Options:**
- Customizable field widths and alignment
- Comment inclusion/exclusion
- Sorting options for entities and fields
- Indentation preferences

#### `DBSoupStatisticsGenerator`
Analyzes DBSoup documents and generates usage statistics.

```swift
class DBSoupStatisticsGenerator {
    func generateStatistics(for document: DBSoupDocument) -> DBSoupStatistics
    func printStatistics(_ stats: DBSoupStatistics) -> String
}
```

**Statistics Categories:**
- Entity and field metrics
- Data type distribution
- Constraint usage patterns
- Relationship analysis
- Module organization metrics

#### `DBSoupSVGGenerator`
Generates professional SVG diagrams from DBSoup documents.

```swift
class DBSoupSVGGenerator {
    init(document: DBSoupDocument, backgroundColor: String? = "#ecf0f1")  // Default: Blue-Grey
    func generateSVG() -> String
    func saveToFile(path: String) throws
    
    // Background color presets
    static let backgroundColors: BackgroundColors
    
    // Convenience initializers
    static func withTransparentBackground(document: DBSoupDocument) -> DBSoupSVGGenerator
    static func withLightGreyBackground(document: DBSoupDocument) -> DBSoupSVGGenerator
    static func withBlueGreyBackground(document: DBSoupDocument) -> DBSoupSVGGenerator
    static func withWarmGreyBackground(document: DBSoupDocument) -> DBSoupSVGGenerator
}
```

**Configuration Options:**
- Layout spacing and positioning
- Color schemes for field types
- Entity and relationship styling
- Font and size preferences
- **Background color options** (transparent, light grey, blue-grey, warm grey, custom colors)
- Background and gradient options

**SVG Features:**
- Entity boxes with gradient backgrounds (standard vs embedded entities)
- **Alphabetical entity sorting** for easy scanning and navigation
- **⚡ Instant hover tooltips** for foreign key and embedded entity fields (0.1s response time)
- **Clickable foreign key navigation** with hyperlinks to referenced entities
- **Clickable embedded entity navigation** with hyperlinks to embedded entities
- **Clickable relationship legend** with entity names linking to their definitions
- **Entity IDs** for direct navigation (e.g., `#EntityName`)
- Color-coded field types for easy identification
  - Standard entity fields: Orange/gray/blue/red/purple color scheme
  - Embedded entity fields: Purple-tinted color scheme with italic styling
  - **Embedded entity references: Consistent bright yellow highlighting**
    - Bright yellow: All embedded entity references use the same color for consistency
      - Standard entity → embedded entity
      - Embedded entity → embedded entity
- **Interactive foreign key links** that navigate to referenced entities
- **Interactive embedded entity links** that navigate to embedded entities
- **Interactive relationship legend** that shows all schema relationships
- Relationship lines with cardinality indicators
- Module grouping with headers
- Curved relationship connections
- Professional styling with consistent fonts
- Scalable vector graphics for any size

### Data Structures

#### `DBSoupDocument`
Root structure representing a parsed DBSoup file.

```swift
struct DBSoupDocument {
    let header: DBSoupHeader?                           // Optional @filename.dbsoup
    let relationshipDefinitions: RelationshipDefinitions? // Optional relationship section
    let schemaDefinition: SchemaDefinition             // Required schema section
    let comments: [String]                              // Document-level comments
}
```

#### `Entity`
Represents a database entity (table/collection).

```swift
struct Entity {
    let name: String                                    // Entity name
    let type: EntityType                                // .standard or .embedded
    let fields: [Field]                                 // Entity fields
    let relationshipSections: [RelationshipSection]    // Relationship definitions
    let featureSections: [FeatureSection]              // Additional features
    let comment: String?                                // Entity comment
}
```

#### `Field`
Represents a field within an entity.

```swift
struct Field {
    let prefixes: [FieldPrefix]                         // Field prefixes (*, -, !, @, ~, >, $)
    let names: [String]                                 // Field names (comma-separated)
    let dataType: DataType                              // Field data type
    let constraints: [Constraint]                       // Field constraints
    let comment: String?                                // Field comment
}
```

#### `DataType`
Comprehensive data type system supporting all DBSoup types.

```swift
enum DataType {
    case simple(String)                                 // String, Int, Boolean, etc.
    case parametric(String, [String])                   // String(50), Decimal(10,2)
    case array(DataType)                                // Array<String>
    case jsonObject([JSONField])                        // JSON with structure
    case relationshipArray(String, Cardinality)        // EntityName[1..*]
    case embeddedEntity(String)                         // Single entity reference
}
```

#### `Constraint`
Field constraint with optional value.

```swift
struct Constraint {
    let name: String                                    // Constraint name (PK, FK, etc.)
    let value: String?                                  // Optional constraint value
}
```

#### `Relationship`
Relationship definition between entities.

```swift
struct Relationship {
    let fromEntity: String                              // Source entity
    let toEntity: String                                // Target entity
    let cardinality: RelationshipCardinality           // 1:1, 1:M, M:N
    let nature: RelationshipNature?                     // composition, aggregation, etc.
    let viaEntity: String?                              // Intermediate entity for M:N
    let comment: String?                                // Relationship comment
}
```

### Error Types

#### `DBSoupParseError`
Parsing-related errors with line numbers.

```swift
enum DBSoupParseError: Error {
    case invalidHeader(String)
    case unexpectedToken(String, line: Int)
    case invalidRelationship(String, line: Int)
    case invalidEntity(String, line: Int)
    case invalidField(String, line: Int)
    case invalidDataType(String, line: Int)
    case invalidConstraint(String, line: Int)
    case unexpectedEndOfFile
    case invalidCardinality(String, line: Int)
}
```

#### `DBSoupValidationError`
Validation-related errors with context.

```swift
enum DBSoupValidationError: Error {
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
}
```

## Testing

### Run Test Suite

```bash
swift test
```

### Run Built-in Tests

```swift
import DBSoupParser

let test = DBSoupTest()
test.runAllTests()
```

### Test Categories

The test suite covers:

1. **Basic Parsing Tests**
   - Simple document parsing
   - Header extraction
   - Module structure parsing
   - Entity definition parsing

2. **Relationship Parsing Tests**
   - Relationship definition parsing
   - Cardinality parsing
   - Nature and via entity parsing
   - Complex relationship scenarios

3. **Field Parsing Tests**
   - Field prefix recognition
   - Multiple field names
   - Data type parsing
   - Constraint parsing
   - Comment extraction

4. **Data Type Tests**
   - Simple data types
   - Parametric types
   - Array types
   - Relationship types
   - JSON object types

5. **Validation Tests**
   - Schema validation
   - Constraint validation
   - Relationship validation
   - Error detection
   - Warning generation

6. **Generation Tests**
   - Format consistency
   - Round-trip compatibility
   - Custom configuration
   - Output validation

7. **Statistics Tests**
   - Metric calculation
   - Distribution analysis
   - Report generation
   - Accuracy validation

### Example Test Output

```
🧪 Running DBSoup Parser Tests
==============================

📋 Basic Parsing
-----------------
  ✅ Parse simple DBSoup document
  ✅ Extract header information
  ✅ Parse module structure
  ✅ Parse entity definitions

📋 Relationship Parsing
-----------------------
  ✅ Parse relationship definitions
  ✅ Parse cardinality specifications
  ✅ Parse relationship nature
  ✅ Parse via entity references

📋 Field Parsing
----------------
  ✅ Parse field definitions with various prefixes
  ✅ Parse multiple field names
  ✅ Parse data types
  ✅ Parse constraints
  ✅ Parse field comments

📋 Data Type Parsing
--------------------
  ✅ Parse various data types
  ✅ Parse parametric types
  ✅ Parse array types
  ✅ Parse relationship types

📋 Validation
-------------
  ✅ Validate DBSoup document with missing primary key
  ✅ Detect circular references
  ✅ Validate foreign key references
  ✅ Check constraint validity

📋 Formatting
-------------
  ✅ Format DBSoup from parsed document
  ✅ Maintain format consistency
  ✅ Apply custom configuration
  ✅ Preserve comments

📋 Statistics
-------------
  ✅ Generate statistics for DBSoup document
  ✅ Calculate distributions
  ✅ Analyze relationships
  ✅ Generate reports

📊 Test Summary
===============
Total Tests: 21
Passed: 21
Failed: 0

🎉 All tests passed!
```

## Configuration

### Formatter Configuration

```swift
let config = DBSoupFormatterConfig(
    indentationSpaces: 4,                    // Spaces for indentation
    fieldNameWidth: 20,                      // Width for field names column
    dataTypeWidth: 25,                       // Width for data types column
    constraintColumnStart: 45,               // Start position for constraints
    includeComments: true,                   // Include comments in output
    sortEntitiesAlphabetically: false,       // Sort entities alphabetically
    sortFieldsAlphabetically: false          // Sort fields alphabetically
)
```

### Validation Configuration

The validator uses built-in rules but can be extended:

```swift
// Custom validation rules can be added by extending the validator
extension DBSoupValidator {
    func validateCustomRules() -> [String] {
        var warnings: [String] = []
        
        // Custom validation logic
        for section in document.schemaDefinition.moduleSections {
            for entity in section.entities {
                // Check for naming conventions
                if !entity.name.first?.isUppercase ?? false {
                    warnings.append("Entity '\(entity.name)' should start with uppercase")
                }
                
                // Check for audit fields
                let hasAuditFields = entity.fields.contains { field in
                    field.names.contains("createdAt") || field.names.contains("updatedAt")
                }
                if !hasAuditFields {
                    warnings.append("Entity '\(entity.name)' missing audit fields")
                }
            }
        }
        
        return warnings
    }
}
```

## Advanced Features

### Custom Data Types

Extend the parser to support custom data types:

```swift
extension DBSoupParser {
    func parseCustomDataType(_ input: String) -> DataType? {
        // Add custom data type parsing logic
        if input.starts(with: "CustomType") {
            // Parse custom type parameters
            return .simple("CustomType")
        }
        return nil
    }
}
```

### Plugin Architecture

The toolkit supports extensions through protocols:

```swift
protocol DBSoupPlugin {
    func processDocument(_ document: DBSoupDocument) -> DBSoupDocument
    func validateDocument(_ document: DBSoupDocument) -> [String]
    func generateOutput(_ document: DBSoupDocument) -> String
}

class CustomPlugin: DBSoupPlugin {
    func processDocument(_ document: DBSoupDocument) -> DBSoupDocument {
        // Custom processing logic
        return document
    }
    
    func validateDocument(_ document: DBSoupDocument) -> [String] {
        // Custom validation logic
        return []
    }
    
    func generateOutput(_ document: DBSoupDocument) -> String {
        // Custom output generation
        return ""
    }
}
```

### Performance Optimization

For large schemas, consider:

```swift
// Streaming parser for large files
class StreamingDBSoupParser {
    func parseIncrementally(_ stream: InputStream) throws -> DBSoupDocument {
        // Implement streaming parsing for memory efficiency
    }
}

// Parallel validation for better performance
class ParallelDBSoupValidator {
    func validateConcurrently(_ document: DBSoupDocument) -> DBSoupValidationResult {
        // Implement parallel validation
    }
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

### Development Guidelines

- Follow Swift naming conventions
- Add comprehensive tests for new features
- Update documentation for API changes
- Maintain backward compatibility
- Use meaningful commit messages

### Code Style

- Use 4 spaces for indentation
- Follow SwiftLint recommendations
- Add documentation comments for public APIs
- Keep functions focused and single-purpose
- Use meaningful variable names

## License

MIT License - see LICENSE file for details.

## Support

- **Documentation**: Check the `docs/` directory for detailed specifications
- **Issues**: Report bugs and feature requests on GitHub
- **Examples**: See the `examples/` directory for usage examples
- **Discussions**: Join our community discussions for help and feedback

## Changelog

### Version 1.0.0
- Initial release
- Complete DBSoup grammar support
- Comprehensive validation engine
- Advanced analytics and statistics
- Professional CLI tool
- Extensive test suite
- Full documentation

### Roadmap

#### Version 1.1.0 (Planned)
- SQL DDL generation from DBSoup
- MongoDB schema generation
- Entity relationship diagram generation
- Migration script generation
- Performance optimizations

#### Version 1.2.0 (Planned)
- Plugin architecture
- Custom data type support
- Schema comparison tools
- Version control integration
- Enhanced analytics dashboard

#### Version 2.0.0 (Future)
- GUI application
- Visual schema editor
- Real-time collaboration
- Cloud synchronization
- Advanced query builder 
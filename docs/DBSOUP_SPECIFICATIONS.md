# DBSoup Technical Specifications

## 1. File Format Structure

### 1.1 YAML Header (Optional)

Every DBSoup file can optionally start with a YAML header containing metadata:

```dbsoup
---
@specs: https://www.dbsoup.com/SPECS.md
@ver: 0.1
---
```

#### YAML Header Fields

- **@specs**: URL to the DBSoup specifications (for reference and validation)
- **@ver**: Version of the DBSoup format being used (semantic versioning)

The YAML header is parsed by DBSoup tools and the version is displayed in generated SVG diagrams.

#### Version Display

  When present, the version from the YAML header is displayed in the generated SVG diagram above the relationship legend box, formatted as "Db Schema v[version]".

#### Version Display Customization

The version label text can be customized using the `schemaVersionLabel` property:

```swift
// Default behavior
DBSoupSVGGenerator.schemaVersionLabel = "Db Schema v"  // Default: "Db Schema v0.1"

// Custom labels
DBSoupSVGGenerator.schemaVersionLabel = "Database v"   // Displays: "Database v0.1"
DBSoupSVGGenerator.schemaVersionLabel = "Schema "      // Displays: "Schema 0.1"  
DBSoupSVGGenerator.schemaVersionLabel = "Version "     // Displays: "Version 0.1"
DBSoupSVGGenerator.schemaVersionLabel = ""             // Displays: "0.1" (version only)
```

## 2. Database-as-Code

DBSoup is designed as a database-as-code format, bringing modern software development practices to database schema management.

### 2.1 Core Principles

- **Version Control Integration:** DBSoup files are plain text, making them perfect for Git-based version control
- **Code Review Workflow:** Schema changes are reviewed through pull requests
- **CI/CD Pipeline:** Automated validation and testing of schema changes
- **Infrastructure as Code:** DBSoup files serve as source of truth for database provisioning
- **Schema Migration:** Generate migration scripts by comparing DBSoup versions
- **Documentation Generation:** Auto-generate API docs and ERD diagrams
- **Test Environment Setup:** Use DBSoup files to create test databases

### 2.2 Complete Document Structure

**Every DBSoup file should follow this recommended structure:**

```dbsoup
---
@specs: https://www.dbsoup.com/SPECS.md
@ver: 0.1
---

@filename.dbsoup

# === SCHEMA ARCHITECTURE OVERVIEW ===
# Database Purpose: [Brief description of system purpose]
# Domain: [Business domain - e.g., E-commerce, Logistics, CRM]
# Architecture Pattern: [Microservice, Monolith, Domain-driven, etc.]
# 
# == MODULE BREAKDOWN ==
# Core Entities (X entities, Y fields)
#   - Brief description of core business entities
# Authentication (X entities, Y fields) 
#   - User management and security systems
# [Additional modules...]
#
# == KEY ARCHITECTURAL FEATURES ==
# - Multi-tenant architecture with Account segregation
# - Soft delete patterns with IsDeleted flags  
# - Comprehensive audit trails with timestamp tracking
# - Spatial indexing for geographic data
# - Security: PII protection and field encryption
# - Scalability: Partitioning and performance optimization
#
# == DATA DISTRIBUTION ==
# [X] total fields across [Y] entities
# [Primary pattern description] ([dominant type] fields, [%])
# [Secondary pattern description] ([secondary type] fields, [%])
# [Business insight] ([business-relevant type] fields for [purpose])

=== RELATIONSHIP DEFINITIONS ===
[Relationship declarations...]

=== DATABASE SCHEMA ===
[Module and entity definitions...]
```

### 1.3 Workflow Example

```bash
# 1. Create a feature branch for schema changes
git checkout -b feature/add-user-preferences

# 2. Edit the schema file (user.dbsoup) - including architecture overview
@user.dbsoup

# === SCHEMA ARCHITECTURE OVERVIEW ===
# Database Purpose: User management and personalization system
# Domain: User Experience Management
# Architecture Pattern: Domain-driven design with CQRS

# 3. Validate schema changes
dbsoup lint user.dbsoup

# 4. Generate migration script
dbsoup diff main feature/add-user-preferences --to=sql > migrations/add_preferences.sql

# 5. Create pull request
git add user.dbsoup migrations/add_preferences.sql
git commit -m "feat: add user preferences"
git push origin feature/add-user-preferences
```

## 2. Core Syntax Specification

### 2.1 Formatting Standards

**DBSoup uses a standardized tab-formatted layout for optimal readability and consistency:**

#### 2.1.1 Field Formatting Rules

```dbsoup
EntityName
==========
* field_name    : DataType                  [constraints]
- optional_field: DataType                  [constraints]
@ indexed_field : DataType                  [IX,constraints]
```

**Formatting specifications:**
- **Field names**: Left-aligned, padded to ~15 characters with spaces
- **Data types**: Aligned starting at position ~16
- **Constraints**: Right-aligned starting at position ~40
- **Separators**: Use `====` (not `============`) for cleaner appearance
- **Embedded entities**: Use `/=============/` with extra length for visibility
- **Consistency**: All entities in a file should use identical column alignment

#### 2.1.2 Entity Header Formatting

```dbsoup
# Standard entities
EntityName
==========

# Embedded entities (longer separator for distinction)
EmbeddedEntityName
/=================/
```

#### 2.1.3 Alignment Examples

**Correct tab-formatted layout:**
```dbsoup
User
====
* _id           : UUID                      [PK]
* username      : String(50)                [UK,IX]
@ password_hash : String(255)               [ENCRYPTED]
- profile_data  : JSON
- created_at    : DateTime                  [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
```

**Incorrect formatting (deprecated):**
```dbsoup
User
============
* _id : UUID [PK] # Too compact, hard to read
* username : String(50) [UK,IX] # Inconsistent spacing
@ password_hash : String(255) [ENCRYPTED] # Not aligned
- profile_data : JSON # Column alignment lost
- created_at : DateTime [SYSTEM,DEFAULT:CURRENT_TIMESTAMP] # Too long
```

#### 2.1.4 Benefits of Tab-Formatted Layout

- **Readability**: Structured like a table, easy to scan
- **Maintainability**: Consistent formatting across all schemas
- **Professionalism**: Clean, documentation-ready appearance
- **Tool Support**: Easier for editors to auto-format and validate
- **Git Diffs**: Better diff visualization with aligned columns

### 2.2 Relationship Definitions Section

The DBSoup format now includes a dedicated relationships definition section that appears before the schema definition. This section provides a parsable format for documenting different types of relationships between database entities.

#### 2.2.1 Relationship Definition Syntax

```dbsoup
=== RELATIONSHIP DEFINITIONS ===
# One-to-One Relationships
User -> UserProfile [1:1] (composition)
Customer -> Address [1:1] (aggregation)

# One-to-Many Relationships
User -> Order [1:M] (composition)
Category -> Product [1:M] (aggregation)

# Many-to-Many Relationships
User -> Role [M:N] (association) via UserRole
Product -> Tag [M:N] (association) via ProductTag

# Inheritance Relationships
Vehicle -> Car [inheritance]
Vehicle -> Truck [inheritance]

# Composition Relationships
Order -> OrderItem [composition] // Child cannot exist without parent
Invoice -> LineItem [composition]

# Aggregation Relationships
Department -> Employee [aggregation] // Child can exist without parent
Course -> Student [aggregation]
```

#### 2.2.2 Relationship Cardinality

| Cardinality | Description | Example |
|-------------|-------------|---------|
| `[1:1]` | One-to-One | User -> UserProfile |
| `[1:M]` | One-to-Many | User -> Order |
| `[M:N]` | Many-to-Many | User -> Role via UserRole |
| `[inheritance]` | IS-A relationship | Vehicle -> Car |
| `[composition]` | Strong ownership | Order -> OrderItem |
| `[aggregation]` | Weak ownership | Department -> Employee |

#### 2.2.3 Relationship Nature

| Nature | Description | Lifecycle |
|--------|-------------|-----------|
| `composition` | Strong ownership, child cannot exist without parent | Cascade delete |
| `aggregation` | Weak ownership, child can exist independently | No cascade |
| `association` | Loose coupling, typically many-to-many | Reference only |
| `inheritance` | IS-A relationship, polymorphic | Shared attributes |
| `dependency` | Temporary relationship, one uses another | No ownership |

#### 2.2.4 Junction Tables

For many-to-many relationships, specify the junction table using the `via` keyword:

```dbsoup
User -> Role [M:N] (association) via UserRole
Product -> Category [M:N] (association) via ProductCategory
```

### 2.3 Comment Support

DBSoup supports comprehensive commenting to document schemas effectively:

#### 2.3.1 Full-Line Comments
```dbsoup
# This is a full-line comment
# Comments can appear anywhere in the document
* field : Type
```

#### 2.3.2 Inline Comments
```dbsoup
* field : Type [constraints] # This is an inline comment
EntityName # Comment after entity name
User -> Profile [1:1] # Comment after relationship
+ Module Name # Comment after module declaration
```

#### 2.3.3 Comment Rules
- **Full-line comments**: Start with `#` at beginning of line
- **Inline comments**: Use ` #` (space + hash) after content
- **Placement**: Comments allowed anywhere in the document
- **Nested comments**: Not supported (no `/* */` style)
- **Escaping**: Use quotes to include `#` in string values

### 2.4 Field Prefixes

| Prefix | Meaning | Usage |
|--------|---------|-------|
| `*` | Required/Primary | Non-nullable fields, primary keys |
| `-` | Optional | Nullable fields |
| `!` | Indexed | Fields with database indexes |
| `@` | Sensitive | Encrypted or PII data |
| `~` | Masked | Data masking patterns applied |
| `>` | Partitioned | Partitioning or sharding keys |
| `$` | Audit | Audit trails and security logging |

### 2.5 System-Generated Fields

System-generated fields are indicated using constraints rather than prefixes:

```dbsoup
- created_at    : DateTime                  [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
- updated_at    : DateTime                  [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
- full_name     : String                    [COMPUTED:first_name + ' ' + last_name]
- id            : Int                       [AUTO_INCREMENT]
- status        : String                    [AUTO,DEFAULT:'active']
```

Common system field constraints:
- `[SYSTEM]` - Managed by the database system
- `[AUTO]` - Automatically generated
- `[COMPUTED:expr]` - Calculated from other fields
- `[AUTO_INCREMENT]` - Auto-incrementing values
- `[IDENTITY(s,i)]` - Identity with seed/increment (SQL Server)
- `[GENERATED]` - Generated by database trigger/function

### 2.6 Entity Types

```dbsoup
# Standard Entity (Independent table/collection)
EntityName
==========
* field         : Type                      [constraints]

# Embedded Entity (Nested/child entity)
EmbeddedEntity
/=============/
* field         : Type                      [constraints]
```

### 2.7 Relationship Notation

```dbsoup
# One-to-One (Required)
* profile : UserProfile

# One-to-One (Optional)
- profile : UserProfile

# One-to-Many (Required)
* items : OrderItem[1..*]

# One-to-Many (Optional)
- comments : Comment[0..*]

# Many-to-Many
- tags : Tag[0..*]
```

### 2.7 Constraint Syntax

```dbsoup
[PK]                    # Primary Key
[FK:Entity.field]       # Foreign Key
[UK]                    # Unique Key
[IX]                    # Basic Index
[DEFAULT:value]         # Default Value
[COMPUTED:expr]         # Computed Field
[VALIDATE:rule]         # Validation Rule
[ENCRYPT:algorithm]     # Encryption
[AUDIT]                 # Audit Trail
```

### 2.8 Data Types

#### Basic Types
```dbsoup
String          # Variable-length text
String(n)       # Fixed-length text
Int             # Integer
Float           # Floating point
Boolean         # True/false
DateTime        # Date and time
UUID            # Unique identifier
```

#### Complex Types
```dbsoup
Array<Type>     # Array of values
JSON            # JSON object
JSONB           # Binary JSON
XML             # XML document
Buffer          # Binary data
```

## 3. Validation Rules

### 3.1 Entity Rules
- Must have a unique name
- Must have at least one field
- Must have exactly one primary key
- Cannot have duplicate field names

### 3.2 Field Rules
- Names must be unique within entity
- Must have valid prefix
- Must have valid type
- Constraints must be valid for type

### 3.3 Relationship Rules
- Foreign keys must reference valid entities
- Cardinality must be valid
- Circular dependencies must be documented

## 4. File Organization

### 4.1 File Structure
```dbsoup
@database-name.dbsoup
===
DATABASE SCHEMA
===============
+ Module1
+ Module2

=== Module1 ===
Optional module description providing context about the module's purpose.

EntityName
============
* field : Type
```

### 4.2 Module Descriptions

Module descriptions are **optional single-line** descriptions that appear immediately after the module header. They provide context and documentation for the module's purpose:

```dbsoup
=== Core ===
Multi-tenant user and organization management with account-based data segregation.

Account # Main account entity
==========
* _id : ObjectId [PK]
* Email : String [UK]
```

**Requirements:**
- **Single line only** - no multi-line descriptions allowed
- **Optional** - modules can have no description
- Must appear immediately after module header (after any blank lines)

**Guidelines:**
- Keep descriptions concise (one sentence preferred)
- Focus on the module's business purpose 
- Mention key architectural patterns if relevant
- Use present tense and professional language

### 4.3 Naming Conventions
- Entity names: PascalCase
- Field names: camelCase
- Module names: PascalCase
- File names: kebab-case.dbsoup

## 5. Tooling Integration

### 5.1 Command Line Interface
```bash
dbsoup init                     # Create new schema
dbsoup lint schema.dbsoup      # Validate schema
dbsoup diff old.dbsoup new.dbsoup  # Compare versions
dbsoup export --format=sql     # Generate SQL
dbsoup import --from=mongodb   # Import from MongoDB
```

### 5.2 CI/CD Integration
```yaml
# Example GitHub Actions workflow
name: Validate Schema
on: [pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Validate DBSoup
        run: |
          dbsoup lint **/*.dbsoup
          dbsoup diff origin/main HEAD
```

## 6. Migration Management

### 6.1 Change Detection
```bash
# Generate detailed change report
dbsoup diff --detailed old.dbsoup new.dbsoup

# Generate SQL migration
dbsoup diff --to=sql old.dbsoup new.dbsoup
```

### 6.2 Change Types
- Add entity
- Remove entity
- Add field
- Remove field
- Modify field type
- Add constraint
- Remove constraint
- Add relationship
- Remove relationship

## 7. Security Considerations

### 7.1 Sensitive Data Handling
- Use `@` prefix for encrypted fields (full protection)
- Use `~` prefix for masked fields (partial obfuscation)
- Use `$` prefix for audit trails and security logging
- Document compliance requirements
- Specify encryption/masking algorithms

### 7.2 Access Control
- Document row-level security
- Specify field-level permissions
- Define audit requirements

## 8. Performance Patterns

### 8.1 Indexing
```dbsoup
! simple_index : Type [IX]
! compound_index : Type [CIX:field1,field2]
! partial_index : Type [PIX:condition]
```

### 8.2 Partitioning
```dbsoup
> partition_key : Type [PARTITION:strategy]
> shard_key : Type [SHARD:hash]
```

### 8.3 Audit and Security Logging
```dbsoup
$ audit_trail : JSON [AUDIT:full]
$ security_log : JSON [AUDIT:security]
$ compliance_record : JSON [AUDIT:compliance]
```

### 8.4 Caching
```dbsoup
% cached_field : Type [CACHED:strategy]
% computed_cache : Type [CACHED,TTL:3600]
```

## 9. Versioning

### 9.1 Schema Version
```dbsoup
@version: 1.2.0
@timestamp: 2024-03-15T10:00:00Z
@author: team-name
```

### 9.2 Change Tracking
```dbsoup
# Added in v1.2.0
+ new_field : Type

# Deprecated in v1.2.0
- old_field : Type [DEPRECATED]
```

## 10. Best Practices

1. **Version Control**
   - Commit DBSoup files with related code changes
   - Use meaningful commit messages
   - Review schema changes carefully

2. **Documentation**
   - Add comments for complex relationships
   - Document business rules
   - Explain non-obvious constraints

3. **Testing**
   - Validate schema changes before commit
   - Test migrations in staging
   - Verify data integrity

4. **Security**
   - Mark sensitive fields appropriately
   - Document encryption requirements
   - Specify access controls

5. **Performance**
   - Document indexing strategies
   - Specify partitioning schemes
   - Note caching requirements 
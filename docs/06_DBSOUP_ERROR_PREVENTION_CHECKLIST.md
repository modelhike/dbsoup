# DBSoup Error Prevention Checklist

## Overview

This checklist helps prevent the most common errors when converting database schemas to DBSoup format. Use this document in conjunction with the complete documentation suite for best results.

**Related Documents:**
- [Database Schema to DBSoup Guide](./01_DATABASE_SCHEMA_TO_DBSOUP_GUIDE.md) - Main conversion guide
- [Database Types and Mappings](./02_DATABASE_TYPES_AND_MAPPINGS.md) - Complete type conversion reference
- [Embedded Entities and Templates](./03_EMBEDDED_ENTITIES_AND_TEMPLATES.md) - Entity patterns and templates
- [AI Decision Framework](./04_AI_DECISION_FRAMEWORK.md) - AI processing logic and decision trees
- [Comprehensive Quality Checklist](./05_COMPREHENSIVE_QUALITY_CHECKLIST.md) - 138-point quality validation

## 🚨 CRITICAL ERROR PREVENTION

### #1 Most Common Error: System Field Prefixes

❌ **NEVER USE `_` PREFIX FOR SYSTEM FIELDS**
```dbsoup
_ created_at : DateTime [SYSTEM]  # WRONG - DON'T DO THIS
_ updated_at : DateTime [SYSTEM]  # WRONG - DON'T DO THIS
_ id : Int [AUTO]                 # WRONG - DON'T DO THIS
```

✅ **CORRECT - Use regular prefixes with constraint annotations:**
```dbsoup
- created_at    : DateTime                  [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
- updated_at    : DateTime                  [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
* id            : Int                       [PK,AUTO_INCREMENT]
```

**Rule:** System characteristics are expressed through constraint annotations `[SYSTEM]`, `[AUTO]`, `[COMPUTED:expr]`, never through special prefixes.

**For complete system field guidance, see [Database Types and Mappings](./02_DATABASE_TYPES_AND_MAPPINGS.md)**

## Quick Reference: Field Prefixes

| Prefix | Use For | Example |
|--------|---------|---------|
| `*` | Required/Primary fields | `* user_id : UUID [PK]` |
| `-` | Optional fields | `- phone : String` |
| `!` | Indexed fields | `! email : String [IX]` |
| `@` | Sensitive/Encrypted fields | `@ password : String [ENCRYPTED]` |
| `~` | Masked fields | `~ ssn : String [MASK:XXX-XX-####]` |
| `>` | Partitioned fields | `> tenant_id : String [PARTITION:hash]` |
| `$` | Audit fields | `$ audit_log : JSON [AUDIT:full]` |

**For complete field prefix decision logic, see [AI Decision Framework](./04_AI_DECISION_FRAMEWORK.md)**

## System Field Conversion Table

| Field Pattern | Common Names | Correct DBSoup Notation |
|---------------|--------------|-------------------------|
| Creation timestamp | `created_at`, `CD`, `created_date` | `- created_at    : DateTime [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]` |
| Update timestamp | `updated_at`, `LU`, `last_updated` | `- updated_at    : DateTime [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]` |
| Auto-increment ID | `id`, `seq`, `auto_id` | `- id            : Int      [AUTO_INCREMENT]` |
| UUID primary key | `_id`, `uuid`, `guid` | `* _id           : UUID     [PK,AUTO]` |
| Computed fields | `full_name`, `total_amount` | `- full_name     : String   [COMPUTED:first+' '+last]` |
| Version/revision | `version`, `revision`, `v` | `- version       : Int      [SYSTEM,DEFAULT:1]` |

**For complete type mapping tables, see [Database Types and Mappings](./02_DATABASE_TYPES_AND_MAPPINGS.md)**

## #2 Critical Error: Complex JSON Not Converted to Embedded Entities

❌ **WRONG - Complex JSON arrays and objects:**
```dbsoup
- items : Array<JSON> [{
    id: String,
    name: String,
    quantity: Int
}]

- metadata : JSON {
    title: String,
    description: String,
    tags: Array<String>,
    settings: {
        enabled: Boolean,
        priority: Int
    }
}
```

✅ **CORRECT - Convert to embedded entities:**
```dbsoup
- items : OrderItem[0..*]
- metadata : Metadata

OrderItem
/=======/
* id : String [PK]
* parent_id : String [FK:Order._id]
* name : String
* quantity : Int

Metadata
/=======/
* _id : String [PK]
* parent_id : String [FK:Entity._id]
* title : String
* description : String
* tags : Array<String>
- settings : MetadataSettings

MetadataSettings
/=======/
* _id : String [PK]
* metadata_id : String [FK:Metadata._id]
* enabled : Boolean
* priority : Int
```

**For complete embedded entity patterns, see [Embedded Entities and Templates](./03_EMBEDDED_ENTITIES_AND_TEMPLATES.md)**

## #3 Critical Error: Missing Relationships Definition Section

❌ **WRONG - No relationships section:**
```dbsoup
@database.dbsoup

=== DATABASE SCHEMA ===
+ User Management

=== User Management ====
User
============
* user_id : UUID [PK]
- profile_id : UUID [FK:UserProfile.id]
```

✅ **CORRECT - Include relationships definition:**
```dbsoup
@database.dbsoup

=== RELATIONSHIP DEFINITIONS ===
# One-to-One Relationships
User -> UserProfile [1:1] (composition)

# One-to-Many Relationships
User -> Order [1:M] (composition)

=== DATABASE SCHEMA ===
+ User Management

=== User Management ====
User
============
* user_id : UUID [PK]
- profile : UserProfile
```

## Pre-Conversion Checklist

□ **Source Understanding**
- [ ] Understand source schema format (SQL, NoSQL, JSON, etc.)
- [ ] Identify all system-generated fields
- [ ] Map out all relationships between entities
- [ ] Note any special constraints or business rules
- [ ] Review database-specific features (indexes, partitioning, etc.)

□ **DBSoup Specification Review**
- [ ] Reviewed [Database Schema to DBSoup Guide](./01_DATABASE_SCHEMA_TO_DBSOUP_GUIDE.md)
- [ ] Understand field prefix system (`*`, `-`, `!`, `@`, `~`, `>`, `$`)
- [ ] Confirmed system characteristics use constraint annotations
- [ ] Reviewed embedded entity conversion rules
- [ ] Verified no use of deprecated `_` prefix notation

## During Conversion Checklist

□ **Field Processing**
- [ ] Used `*` for required/primary fields (non-nullable)
- [ ] Used `-` for optional fields (nullable)
- [ ] Used `!` for indexed fields (frequently searched)
- [ ] Used `@` for sensitive/encrypted fields (PII, passwords)
- [ ] Used `~` for masked fields (data masking patterns)
- [ ] Used `>` for partitioned/sharded fields (distribution keys)
- [ ] Used `$` for audit/security logging fields (compliance)
- [ ] **NEVER used `_` prefix** - not part of DBSoup specification

□ **System Field Handling**
- [ ] System-generated fields use regular prefixes
- [ ] Added `[SYSTEM]` constraint for system-managed fields
- [ ] Added `[AUTO]` constraint for auto-generated fields
- [ ] Added `[COMPUTED:expr]` constraint for calculated fields
- [ ] Added proper `[DEFAULT:value]` annotations

□ **Complex Data Structure Conversion** **⚠️ CRITICAL - See [Complex Array Conversion Guide](./07_COMPLEX_ARRAY_CONVERSION_GUIDE.md)**
- [ ] **MANDATORY: Scanned entire JSON schema for ALL array fields**
- [ ] **MANDATORY: Converted ALL Array<JSON> to embedded entities**
- [ ] **MANDATORY: Validated business entities have expected complex arrays**
- [ ] **MANDATORY: Processed nested objects within arrays recursively**
- [ ] Converted complex JSON (>2 properties) to embedded entities
- [ ] Converted nested objects to embedded entities
- [ ] Kept only simple configuration JSON (≤2 primitive properties)
- [ ] Added proper cardinality notation for embedded entity relationships
- [ ] **Validated Route entities have stops field**
- [ ] **Validated Order entities have items field**
- [ ] **Validated User entities have expected profile/preference fields**
- [ ] **Validated Product entities have variant/category fields**

□ **Relationships Documentation**
- [ ] Created relationships definition section at document start
- [ ] Documented all major entity relationships
- [ ] Specified relationship cardinality (1:1, 1:M, M:N)
- [ ] Identified relationship nature (composition, aggregation, association)
- [ ] Documented junction tables for M:N relationships

## Post-Conversion Validation

□ **Schema Structure**
- [ ] All entities have proper header format with `============` fence
- [ ] All embedded entities use `/=======/` fence notation
- [ ] All fields have proper prefix, name, type, and constraints
- [ ] No orphaned or undefined references
- [ ] Relationships definition section is complete and accurate

□ **Relationship Validation**
- [ ] All foreign key references point to valid entities
- [ ] Cardinality notation is correct for arrays `[0..*]`, `[1..*]`
- [ ] Single entity relationships use field prefixes (no brackets)
- [ ] Many-to-many relationships properly specified
- [ ] Junction tables defined where needed

□ **Constraint Verification**
- [ ] All constraint syntax is valid
- [ ] Primary keys marked with `[PK]`
- [ ] Unique constraints marked with `[UK]`
- [ ] Indexes marked with `[IX]`
- [ ] Foreign keys marked with `[FK:Entity.field]`
- [ ] System fields use `[SYSTEM]` annotation

□ **Quality Assurance**
- [ ] Run through [Comprehensive Quality Checklist](./05_COMPREHENSIVE_QUALITY_CHECKLIST.md)
- [ ] Check embedded entity completeness
- [ ] Verify data type mappings
- [ ] Validate security and compliance annotations
- [ ] Confirm performance optimization markings

## Critical Error Patterns to Avoid

❌ **CRITICAL ERRORS:**
1. Using `_` prefix for system fields
2. Forgetting constraint annotations for system characteristics
3. Missing primary key specifications
4. Not converting complex JSON to embedded entities
5. Missing relationships definition section
6. Incorrect cardinality notation for arrays
7. Invalid foreign key references

❌ **SYNTAX ERRORS:**
1. Wrong fence notation (`=====` vs `============`)
2. Missing or incorrect constraint bracket format
3. Inconsistent field naming conventions
4. Missing colons in field definitions
5. Incorrect data type capitalization
6. Using brackets for single entity relationships

❌ **STRUCTURAL ERRORS:**
1. Complex Array<JSON> not converted to embedded entities
2. Missing embedded entity primary keys
3. Missing parent-child FK relationships in embedded entities
4. Inconsistent cardinality specifications
5. Missing business logic documentation

## Emergency Fix Patterns

**System field prefix errors:**
```dbsoup
# Wrong:
_ created_at : DateTime [SYSTEM]

# Fix:
- created_at : DateTime [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
```

**Missing constraint annotations:**
```dbsoup
# Wrong:
* id : Int [PK]

# Fix:
* id : Int [PK,AUTO_INCREMENT]
```

**Complex JSON not converted:**
```dbsoup
# Wrong:
- items : Array<JSON> [{ id: String, name: String }]

# Fix:
- items : OrderItem[0..*]

OrderItem
/=======/
* id : String [PK]
* parent_id : String [FK:Order._id]
* name : String
```

**Incorrect cardinality:**
```dbsoup
# Wrong (arrays need brackets):
- items : OrderItem

# Fix (for arrays):
- items : OrderItem[0..*]

# Wrong (single entities don't need brackets):
- profile : UserProfile[1..1]

# Fix (for single entities):
- profile : UserProfile
```

**Missing relationships definition:**
```dbsoup
# Add to document start:
=== RELATIONSHIP DEFINITIONS ===
# Document all major relationships here
User -> UserProfile [1:1] (composition)
User -> Order [1:M] (composition)
Product -> Category [M:N] (association) via ProductCategory
```

## Database-Specific Error Prevention

### SQL Databases
- [ ] Don't use `_` prefix for auto-increment fields
- [ ] Map SQL types correctly (see [Database Types and Mappings](./02_DATABASE_TYPES_AND_MAPPINGS.md))
- [ ] Document all indexes and constraints
- [ ] Handle computed columns with `[COMPUTED:expr]`

### MongoDB
- [ ] Use `ObjectId` type for `_id` fields
- [ ] Convert document arrays to embedded entities
- [ ] Document validation rules with `[VALIDATE:rule]`
- [ ] Mark Atlas features with appropriate annotations

### PostgreSQL
- [ ] Handle JSONB correctly (convert complex to embedded entities)
- [ ] Document array types properly
- [ ] Note custom types and extensions

### SQL Server
- [ ] Document Identity columns with `[IDENTITY]`
- [ ] Handle spatial types correctly
- [ ] Note FILESTREAM usage

**For complete database-specific guidance, see [Database Types and Mappings](./02_DATABASE_TYPES_AND_MAPPINGS.md)**

## Integration with Quality Assurance

This error prevention checklist works in conjunction with:
- [Comprehensive Quality Checklist](./05_COMPREHENSIVE_QUALITY_CHECKLIST.md) - 138-point validation
- [AI Decision Framework](./04_AI_DECISION_FRAMEWORK.md) - Systematic processing logic
- [Embedded Entities and Templates](./03_EMBEDDED_ENTITIES_AND_TEMPLATES.md) - Conversion patterns

**Use this checklist before, during, and after any DBSoup conversion to ensure accuracy and compliance with the official specification.** 
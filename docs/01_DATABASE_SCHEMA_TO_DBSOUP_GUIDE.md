# Database Schema to DBSoup Format Guide

## Overview

This guide provides a systematic approach to convert database schemas from any format (SQL DDL, MongoDB schemas, PDFs, documentation) into the standardized **DBSoup** format. The DBSoup format is a human-readable, structured notation system for documenting database schemas with entities, fields, relationships, and constraints.

**Related Documents:**
- [DBSoup Technical Specifications](./DBSOUP_SPECIFICATIONS.md) - Complete syntax specifications
- [Database Types and Mappings](./02_DATABASE_TYPES_AND_MAPPINGS.md) - Data type conversion reference
- [Embedded Entities and Templates](./03_EMBEDDED_ENTITIES_AND_TEMPLATES.md) - Entity patterns and templates
- [AI Decision Framework](./04_AI_DECISION_FRAMEWORK.md) - AI processing logic and decision trees
- [Comprehensive Quality Checklist](./05_COMPREHENSIVE_QUALITY_CHECKLIST.md) - 138-point quality validation
- [DBSoup Error Prevention Checklist](./06_DBSOUP_ERROR_PREVENTION_CHECKLIST.md) - Common error prevention
- [Complex Array Conversion Guide](./07_COMPLEX_ARRAY_CONVERSION_GUIDE.md) - **CRITICAL: Prevents missing complex structures**

### What is DBSoup?

DBSoup is a plaintext format that captures:
- **Entities** (tables, collections, documents)
- **Fields** with precise data types and constraints
- **Relationships** between entities
- **Database-specific features** (indexes, validation, etc.)
- **Enterprise features** (security, compliance, performance)

### Target Audience

This guide is designed for:
- **AI systems** that need to process database schemas systematically
- **Database architects** documenting complex systems
- **DevOps engineers** creating infrastructure documentation
- **Developers** needing clear schema references

## Quick Start for AI Systems

### Purpose
Convert any database schema (from PDFs, ERDs, documentation, or codebases) into DBSoup plaintext format for comprehensive documentation.

### ⚠️ CRITICAL: Most Common Error Prevention

**NEVER use `_` prefix for system-generated fields!** This is the #1 mistake when converting to DBSoup.

❌ **WRONG:**
```dbsoup
_ created_at : DateTime [SYSTEM]
_ updated_at : DateTime [SYSTEM]
```

✅ **CORRECT:**
```dbsoup
- created_at : DateTime [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
- updated_at : DateTime [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
```

**Rule:** System characteristics are expressed through constraint annotations `[SYSTEM]`, `[AUTO]`, `[COMPUTED:expr]`, never through special prefixes.

### Basic Pattern Recognition
Refer to [DBSOUP_SPECIFICATIONS.md](./DBSOUP_SPECIFICATIONS.md) for complete syntax specifications. Here's a quick overview of what to look for:

#### Schema Architecture Overview Section
**MANDATORY**: Before any technical definitions, include a comprehensive architecture overview as structured comments:

```dbsoup
@filename.dbsoup

# === SCHEMA ARCHITECTURE OVERVIEW ===
# Database Purpose: [One-line description of system purpose]
# Domain: [Business domain - e.g., E-commerce, Logistics, CRM, Healthcare]
# Architecture Pattern: [Microservice, Monolith, Domain-driven, Event-sourced, etc.]
# 
# == MODULE BREAKDOWN ==
# Core Entities (X entities, Y fields)
#   - [Brief description focusing on primary business entities]
# Authentication (X entities, Y fields) 
#   - [Security and user management systems]
# Business Logic (X entities, Y fields)
#   - [Domain-specific processing and workflows]
# Audit (X entities, Y fields)
#   - [Logging, tracking, and compliance systems]
# Configuration (X entities, Y fields)
#   - [System settings and preferences]
#
# == KEY ARCHITECTURAL FEATURES ==
# - [Security implementation: PII protection, encryption patterns]
# - [Scalability features: partitioning, indexing strategies]
# - [Data patterns: soft deletes, audit trails, versioning]
# - [Integration: API authentication, external service connections]
# - [Compliance: GDPR, audit requirements, data retention]
#
# == DATA DISTRIBUTION ==
# [X] total fields across [Y] entities
# [Dominant characteristic] ([primary type] fields, [%])
# [Secondary characteristic] ([secondary type] fields, [%])
# [Business pattern insight] ([business type] fields for [purpose])
```

**Purpose**: This overview enables stakeholders to understand the system at a glance before diving into technical details. The data distribution section reveals the schema's composition and primary data patterns.

#### Relationship Definition Section
After the architecture overview, create a global relationship definitions section:

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
```

This provides a parsable overview of all entity relationships in the database.

#### Field Prefix Quick Reference

| Prefix | Meaning | When to Use | Example |
|--------|---------|-------------|---------|
| `*` | Required/Primary | Cannot be null, essential | `* user_id : Guid [PK]` |
| `-` | Optional | Can be null | `- phone : String` |
| `!` | Indexed | Has database index | `! email : String [IX]` |
| `@` | Sensitive/Encrypted | Contains PII or encrypted data | `@ password : String [ENCRYPTED]` |
| `~` | Masked | Has data masking patterns | `~ ssn : String [MASK:XXX-XX-####]` |
| `>` | Partitioned | Partitioning or sharding keys | `> tenant_id : String [PARTITION:hash]` |
| `$` | Audit | Audit trails and security logging | `$ audit_log : JSON [AUDIT:full]` |

#### System Field Patterns

| Field Pattern | Common Names | Correct DBSoup Notation |
|---------------|--------------|-------------------------|
| Creation timestamp | `created_at`, `CD`, `created_date` | `- created_at : DateTime [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]` |
| Update timestamp | `updated_at`, `LU`, `last_updated` | `- updated_at : DateTime [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]` |
| Auto-increment ID | `id`, `seq`, `auto_id` | `- id : Int [AUTO_INCREMENT]` |
| UUID primary key | `_id`, `uuid`, `guid` | `* _id : UUID [PK,AUTO]` |
| Computed fields | `full_name`, `total_amount` | `- full_name : String [COMPUTED:first+' '+last]` |
| Version/revision | `version`, `revision`, `v` | `- version : Int [SYSTEM,DEFAULT:1]` |

### Decision Framework Summary

**For complete decision trees and AI processing logic, see [AI Decision Framework](./04_AI_DECISION_FRAMEWORK.md)**

#### Field Prefix Decision (Simplified)
```
Step 1: Choose the BASE PREFIX (ignoring system characteristics):
IF field is primary key OR cannot be null → use *
ELIF field is optional OR can be null → use -
ELIF field has index → use !
ELIF field is sensitive/encrypted → use @
ELIF field is masked → use ~
ELIF field is partitioned/sharded → use >
ELIF field is audit/security logging → use $
ELSE → use - (default to optional)

Step 2: Add constraint annotations for system characteristics:
IF field is auto-generated → add [SYSTEM] or [AUTO]
IF field is computed → add [COMPUTED:expression]
IF field is unique → add [UK]
IF field is deprecated → add [DEPRECATED]
```

#### Complex Data Structure Decision

**⚠️ CRITICAL: Complex arrays are frequently missed during conversion. See [Complex Array Conversion Guide](./07_COMPLEX_ARRAY_CONVERSION_GUIDE.md) for complete instructions.**

```
IF field is Array<JSON> with ANY complex properties → MANDATORY: convert to embedded entity
IF field is JSON with >2 properties → convert to embedded entity
IF field represents a business entity → use embedded entity
IF field is reusable across entities → use embedded entity
IF field has nested objects → convert to embedded entity
IF field is simple array (Array<String>) → keep as Array<Type>
IF field is simple JSON (≤2 primitive properties) → keep as JSON
ELSE → convert to embedded entity
```

#### Common Missing Complex Arrays

**These entities typically have complex arrays that are often missed:**
- **Route** → `stops`, `waypoints`, `segments`
- **Order** → `items`, `payments`, `addresses`
- **User** → `profiles`, `preferences`, `contacts`
- **Product** → `variants`, `categories`, `attributes`
- **Invoice** → `lineItems`, `payments`, `addresses`
- **Document** → `sections`, `attachments`, `comments`

**For detailed embedded entity patterns and conversion rules, see [Embedded Entities and Templates](./03_EMBEDDED_ENTITIES_AND_TEMPLATES.md)**

## Core Notation System

### Formatting Standards

**DBSoup uses tab-formatted layout for optimal readability:**

```dbsoup
EntityName
==========
* field_name    : DataType                  [constraints]
- optional_field: DataType                  [constraints]
@ indexed_field : DataType                  [IX,constraints]
```

**Key formatting rules:**
- Field names padded to ~15 characters with spaces
- Data types aligned in column starting at position ~16
- Constraints aligned in rightmost column starting at position ~40
- Use `====` separator (not `============`) for cleaner appearance
- Consistent spacing creates table-like readability

### Entity Types
| Entity Type | Notation | When to Use | Example |
|-------------|----------|-------------|---------|
| **Standard Entity** | `EntityName` + `====` | Independent tables/collections | `User`, `Order`, `Product` |
| **Embedded Entity** | `EntityName` + `/====/` | Nested/child entities, complex arrays | `Stop`, `OrderItem`, `Address` |

### Core Constraint Annotations
| Annotation | Meaning | Example |
|------------|---------|---------|
| `[PK]` | Primary key | `* id : UUID [PK]` |
| `[FK:Entity.field]` | Foreign key | `- user_id : UUID [FK:User.id]` |
| `[UK]` | Unique key | `! email : String [UK]` |
| `[IX]` | Basic index | `! name : String [IX]` |
| `[CIX:(field1,field2)]` | Compound index | `! name,email : String [CIX:(name,email)]` |
| `[PIX:(condition)]` | Partial index | `! active_users : String [PIX:(status='active')]` |
| `[DEFAULT:value]` | Default value | `- status : String [DEFAULT:'active']` |
| `[ENUM:(values)]` | Enumerated values | `* status : String [ENUM:("active","inactive")]` |

### System and Computed Field Constraints
| Annotation | Meaning | Example |
|------------|---------|---------|
| `[SYSTEM]` | System-managed field | `- created_at : DateTime [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]` |
| `[AUTO]` | Auto-generated (generic) | `- transaction_id : String [AUTO]` |
| `[AUTO_INCREMENT]` | Auto-incrementing integer | `* id : Int [AUTO_INCREMENT]` |
| `[GENERATED]` | Database trigger/function generated | `- full_name : String [GENERATED]` |
| `[COMPUTED:expr]` | Computed from other fields | `- full_name : String [COMPUTED:first+' '+last]` |
| `[DERIVED]` | Derived from external sources | `- external_ref : String [DERIVED]` |
| `[IMMUTABLE]` | Cannot change after creation | `- created_id : String [IMMUTABLE]` |

### Security and Privacy Constraints
| Annotation | Meaning | Example |
|------------|---------|---------|
| `[ENCRYPTED]` | Field is encrypted | `@ password : String [ENCRYPTED]` |
| `[ENCRYPT:algorithm]` | Encryption with algorithm | `@ secret : String [ENCRYPT:AES256]` |
| `[PII]` | Personal identifiable info | `@ ssn : String [PII]` |
| `[MASK:pattern]` | Data masking | `~ ssn : String [MASK:XXX-XX-####]` |
| `[AUDIT]` | Audit trail | `$ changes : JSON [AUDIT:full]` |
| `[RLS:policy]` | Row-level security | `$ secure_data : JSON [RLS:user_policy]` |

### Performance and Data Constraints
| Annotation | Meaning | Example |
|------------|---------|---------|
| `[SPATIAL]` | Spatial/geographic index | `* lat : Double [SPATIAL]` |
| `[PARTITION:strategy]` | Partitioning key | `> tenant_id : String [PARTITION:hash]` |
| `[SHARD:strategy]` | Sharding key | `> user_id : String [SHARD:range]` |
| `[CACHE]` | Enable caching | `% data : JSON [CACHE]` |
| `[CACHED:strategy]` | Caching strategy | `% data : JSON [CACHED:redis]` |
| `[TTL:duration]` | Time-to-live | `% temp_data : JSON [TTL:3600]` |
| `[REPLICATE:strategy]` | Replication strategy | `& data : String [REPLICATE:master-slave]` |
| `[FEDERATED]` | Federated/distributed system | `& distributed_data : String [FEDERATED]` |
| `[BASE64]` | Base64 encoded data | `- image : String [BASE64]` |
| `[CURRENCY]` | Monetary value | `* price : Decimal [CURRENCY]` |
| `[COMPRESSED]` | Compressed data | `- content : String [COMPRESSED]` |
| `[COLLATION:rule]` | Text collation | `@ text : String [COLLATION:utf8_general_ci]` |
| `[COLLATE:collation]` | Collation (alternative) | `@ name : String [COLLATE:utf8_unicode_ci]` |
| `[CHARSET:encoding]` | Character set | `@ text : String [CHARSET:utf8mb4]` |
| `[TIMEZONE:zone]` | Timezone specification | `@ timestamp : DateTime [TIMEZONE:UTC]` |
| `[PRECISION:digits]` | Numeric precision | `* amount : Decimal [PRECISION:2]` |

### Validation and Business Rules
| Annotation | Meaning | Example |
|------------|---------|---------|
| `[VALIDATE:rule]` | Validation rule | `* email : String [VALIDATE:required,email]` |
| `[CHECK:condition]` | Check constraint | `- age : Int [CHECK:age >= 18]` |
| `[DEPRECATED]` | Deprecated field | `- old_field : String [DEPRECATED]` |

### Database-Specific Constraints
| Annotation | Meaning | Example |
|------------|---------|---------|
| `[IDENTITY:(seed,incr)]` | Identity with seed/increment | `* id : Int [IDENTITY:(1,1)]` |
| `[VIRTUAL:expr]` | Virtual computed field | `- age : Int [VIRTUAL:YEAR(NOW())-birth_year]` |
| `[STORED:expr]` | Stored computed field | `- total : Decimal [STORED:price*quantity]` |
| `[COMPRESS:algorithm]` | Compression with algorithm | `- content : Text [COMPRESS:gzip]` |
| `[BACKUP:strategy]` | Backup strategy | `* critical : String [BACKUP:realtime]` |
| `[MONITOR:threshold]` | Monitoring threshold | `@ performance : Float [MONITOR:>1000ms]` |

### MongoDB-Specific Constraints
| Annotation | Meaning | Example |
|------------|---------|---------|
| `[ATLAS:feature]` | MongoDB Atlas feature | `@ content : String [ATLAS:search-index]` |
| `[REALM:setting]` | MongoDB Realm setting | `* user_id : String [REALM:partition-key]` |
| `[CHANGE:stream]` | Change stream config | `@ updates : JSON [CHANGE:fullDocument]` |
| `[TRANSACTION:setting]` | Transaction setting | `* amount : Decimal [TRANSACTION:majority]` |
| `[TIMESERIES:field]` | Time series designation | `* timestamp : DateTime [TIMESERIES:timeField]` |
| `[READ:preference]` | Read preference | `& cached_data : String [READ:secondary]` |
| `[WRITE:concern]` | Write concern | `* critical : String [WRITE:majority]` |
| `[MULTIKEY]` | Multikey index | `! tags : Array<String> [MULTIKEY]` |
| `[SPARSE]` | Sparse index | `! optional_field : String [SPARSE]` |
| `[HASHED]` | Hashed index | `! shard_key : String [HASHED]` |
| `[TEXT]` | Text index | `! content : String [TEXT]` |

**For complete constraint reference, see [Database Types and Mappings](./02_DATABASE_TYPES_AND_MAPPINGS.md)**

### Comment Support

DBSoup supports comprehensive commenting:

#### Full-Line Comments
```dbsoup
# This is a full-line comment
# Can appear anywhere in the document
* user_id : UUID [PK]
```

#### Inline Comments
```dbsoup
* user_id : UUID [PK] # Primary key for users
- email : String [UK] # Must be unique across system
```

## Simple Example

### Basic Entity
```dbsoup
@user-management.dbsoup

=== RELATIONSHIP DEFINITIONS ===
# One-to-One Relationships
User -> UserProfile [1:1] (composition)

# One-to-Many Relationships
User -> Address [1:M] (aggregation)

=== DATABASE SCHEMA ===
+ User Management

=== User Management ====
User
====
* _id           : UUID                      [PK]
* username      : String(50)                [UK]
* email         : String(100)               [UK,PII]
@ password_hash : String(255)               [ENCRYPTED]
* is_active     : Boolean                   [DEFAULT:true]
- created_at    : DateTime                  [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
- updated_at    : DateTime                  [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
- profile       : UserProfile

UserProfile
/==========/
* _id           : UUID                      [PK]
* user_id       : UUID                      [FK:User._id]
- bio           : Text
- avatar_url    : String
- phone         : String(20)                [PII]
- website       : String
```

## Step-by-Step Process

### Step 1: Analyze Input Schema
1. Identify database type (SQL/MongoDB/Other)
2. List all tables/collections
3. Identify all relationships between entities
4. Group related entities into modules

### Step 2: Create Relationships Definition
1. Identify all entity-to-entity relationships
2. Classify relationship types (1:1, 1:M, M:N, inheritance)
3. Document junction tables for M:N relationships
4. Specify relationship nature (composition, aggregation, association)

### Step 3: Apply Field Conversion
1. For each field, determine appropriate prefix
2. Map data types using conversion tables
3. Add constraint annotations
4. Convert complex JSON to embedded entities

### Step 4: Validate Output
- [ ] Every entity has a primary key marked with `*`
- [ ] All relationships are documented
- [ ] Field types are consistent
- [ ] System fields use constraint annotations (not prefixes)
- [ ] Complex JSON converted to embedded entities
- [ ] Constraints are documented in `[brackets]`

**For complete validation checklist, see [Comprehensive Quality Checklist](./05_COMPREHENSIVE_QUALITY_CHECKLIST.md)**

## Database-Specific Processing

### SQL Databases
```
IF see "CREATE TABLE" → SQL Database
IF see "PRIMARY KEY" → Mark with * and [PK]
IF see "FOREIGN KEY" → Mark with [FK:Table.field]
IF see "UNIQUE" → Mark with ! and [UK]
IF see "INDEX" → Mark with @ and [IX]
IF see "NOT NULL" → Use * prefix
IF see "NULL" allowed → Use - prefix
```

### MongoDB
```
IF see ObjectId → MongoDB Database
IF see nested objects → Convert to embedded entities
IF see arrays → Use Array<Type> or embedded entities
IF see validation schema → Add [VALIDATE:rule]
IF see indexes → Mark with @ and [IX:type]
```

**For complete database-specific instructions, see [Database Types and Mappings](./02_DATABASE_TYPES_AND_MAPPINGS.md)**

## Templates

### Basic SQL Entity Template
```dbsoup
EntityName
==========
* _id           : ID                        [PK]
* required_field: DataType                  [constraints]
- optional_field: DataType                  [constraints]
- created_at    : DateTime                  [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
- updated_at    : DateTime                  [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
! indexed_field : DataType                  [IX]
```

### Basic MongoDB Entity Template
```dbsoup
EntityName
==========
* _id           : ObjectId                  [PK]
* required_field: DataType                  [VALIDATE:required]
- optional_field: DataType
- simple_config : JSON
! indexed_field : DataType                  [IX:type]
```

**For complete template library, see [Embedded Entities and Templates](./03_EMBEDDED_ENTITIES_AND_TEMPLATES.md)**

## Key Principles

### CRITICAL: Embedded Entities Over JSON
**Always prefer embedded entities over JSON structures** for any complex data.

#### When to Use JSON (Very Limited Cases)
- Simple configuration objects with ≤2 primitive properties
- Raw unstructured data (logs, free-form text)
- Dynamic schemas where structure cannot be predetermined

#### When to Convert to Embedded Entities (Default Behavior)
- ANY Array<JSON> with structured objects
- ANY JSON with >2 properties
- ANY nested objects within JSON
- ANY business-meaningful data structures
- ANY reusable data patterns

### System Field Handling
**NEVER use `_` prefix for system-generated fields.**

System characteristics are expressed through constraint annotations:
- `[SYSTEM]` - Managed by the database system
- `[AUTO]` - Automatically generated
- `[COMPUTED:expr]` - Calculated from other fields

## Error Prevention

### Most Common Mistakes
1. **Using `_` prefix** for system fields → Use regular prefixes with `[SYSTEM]` annotation
2. **Missing relationships** → Always document foreign key relationships
3. **Complex JSON** → Convert to embedded entities
4. **Missing primary keys** → Every entity needs a primary key with `*` prefix
5. **Inconsistent type mappings** → Use standardized type conversion tables

**For complete error prevention guide, see [DBSoup Error Prevention Checklist](./06_DBSOUP_ERROR_PREVENTION_CHECKLIST.md)**

## Quality Assurance

This guide works in conjunction with a comprehensive quality checklist covering:
- Structure Quality (15 points)
- Documentation Quality (10 points)
- Relationships Quality (10 points)
- Data Accuracy (20 points)
- Embedded Entity Quality (15 points)
- Security and Compliance (10 points)
- Performance and Scalability (10 points)
- Enterprise Features (10 points)
- And more...

**For complete quality validation, see [Comprehensive Quality Checklist](./05_COMPREHENSIVE_QUALITY_CHECKLIST.md)**

## Getting Help

- **Syntax Questions**: See [DBSoup Technical Specifications](./DBSOUP_SPECIFICATIONS.md)
- **Type Conversion**: See [Database Types and Mappings](./02_DATABASE_TYPES_AND_MAPPINGS.md)
- **Embedded Entities**: See [Embedded Entities and Templates](./03_EMBEDDED_ENTITIES_AND_TEMPLATES.md)
- **AI Processing**: See [AI Decision Framework](./04_AI_DECISION_FRAMEWORK.md)
- **Quality Issues**: See [Comprehensive Quality Checklist](./05_COMPREHENSIVE_QUALITY_CHECKLIST.md)
- **Error Prevention**: See [DBSoup Error Prevention Checklist](./06_DBSOUP_ERROR_PREVENTION_CHECKLIST.md)

## Summary

DBSoup provides a systematic approach to database schema documentation that is:
- **Human-readable** - Clear plaintext format
- **Machine-parsable** - Structured for AI processing
- **Comprehensive** - Covers all database features
- **Standardized** - Consistent notation across database types
- **Enterprise-ready** - Includes security, compliance, and performance features

The modular documentation structure ensures that each aspect of the conversion process is thoroughly covered while maintaining manageable document sizes for both human and AI consumption.
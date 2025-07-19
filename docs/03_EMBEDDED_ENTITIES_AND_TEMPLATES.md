# Embedded Entities and Templates for DBSoup

## Overview

This document provides comprehensive guidance on embedded entities, templates, and complex data structure conversion in DBSoup format. It serves as a reference for handling nested data, arrays, and complex relationships.

**Related Documents:**
- [Database Schema to DBSoup Guide](./01_DATABASE_SCHEMA_TO_DBSOUP_GUIDE.md) - Main conversion guide
- [Database Types and Mappings](./02_DATABASE_TYPES_AND_MAPPINGS.md) - Type conversion reference
- [AI Decision Framework](./04_AI_DECISION_FRAMEWORK.md) - Decision logic for AI systems

## Complete DBSoup Document Template

### Standard Document Structure

Every DBSoup file should include a comprehensive architecture overview before technical definitions:

```dbsoup
@systemname.dbsoup

# === SCHEMA ARCHITECTURE OVERVIEW ===
# Database Purpose: Comprehensive logistics and route optimization platform
# Domain: Transportation & Logistics Management
# Architecture Pattern: Domain-driven design with multi-tenant architecture
# 
# == MODULE BREAKDOWN ==
# Core Entities (4 entities, 95 fields)
#   - Account, User, Org, Member - Multi-tenant user management
# Routes (5 entities, 117 fields) 
#   - Route, Site, Schedule, Stop, StopAddOn - Route planning and optimization
# Authentication (3 entities, 37 fields)
#   - RefreshTokens, ApiAuth, FedExAuth - Security and API integration
# Logistics (4 entities, 52 fields)
#   - Purchases, PurchaseLog, Stats, History - Business transactions and analytics  
# Audit (3 entities, 31 fields)
#   - Log, UserNote, UserNoteLog - Comprehensive audit trails
# Configuration (4 entities, 46 fields)
#   - Config, UserPref, BlobInfo, Install - System configuration and file management
#
# == KEY ARCHITECTURAL FEATURES ==
# - Multi-tenant architecture with Account-based segregation
# - Comprehensive security with encrypted fields and PII protection
# - Soft delete patterns with IsDeleted flags across all entities
# - Audit trails with system-generated timestamps (CD/LU)
# - Spatial indexing for geographic route optimization
# - Performance optimization with strategic indexing and partitioning
# - Integration support for external APIs (FedEx, payment systems)
# - Mobile-first design with offline synchronization capabilities
#
# == DATA DISTRIBUTION ==
# 399 total fields across 23 entities
# String-heavy schema (155 string fields, 38.8%)
# Rich temporal data (65 DateTime fields, 16.3%)
# Extensive business logic (85 Int fields for enums/flags)

=== RELATIONSHIP DEFINITIONS ===
# One-to-Many Relationships  
Account -> User [1:M] (composition)
User -> Route [1:M] (composition)
Route -> Stop [1:M] (composition)

# Many-to-Many Relationships
User -> Account [M:N] (association) via Member

=== DATABASE SCHEMA ===
+ Core
+ Routes  
+ Authentication
+ Logistics
+ Audit
+ Configuration

=== Core ===
[Entity definitions...]
```

### Architecture Overview Template Patterns

#### E-commerce System Example
```dbsoup  
@ecommerce.dbsoup

# === SCHEMA ARCHITECTURE OVERVIEW ===
# Database Purpose: Multi-vendor e-commerce platform with inventory management
# Domain: E-commerce & Retail
# Architecture Pattern: Microservices with event sourcing
#
# == MODULE BREAKDOWN ==
# Core (5 entities, 80 fields)
#   - User, Vendor, Product, Category, Brand - Core business entities
# Orders (4 entities, 65 fields)
#   - Order, OrderItem, Payment, Shipping - Transaction processing
# Inventory (3 entities, 45 fields) 
#   - Inventory, Stock, Warehouse - Stock management
# Reviews (2 entities, 25 fields)
#   - Review, Rating - Customer feedback system
#
# == KEY ARCHITECTURAL FEATURES ==
# - Event sourcing for order processing and inventory updates
# - Multi-vendor support with vendor-specific product catalogs
# - Real-time inventory synchronization across warehouses
# - Advanced search with Elasticsearch integration
# - Payment processing with PCI-DSS compliance
# - Mobile-responsive design with PWA capabilities
#
# == DATA DISTRIBUTION ==
# 214 total fields across 14 entities
# Content-focused schema (125 string fields, 58.4%)
# Financial precision emphasis (35 Decimal fields, 16.4%)
# Moderate business logic (25 Int fields for status/quantities)
```

#### Healthcare System Example  
```dbsoup
@healthcare.dbsoup

# === SCHEMA ARCHITECTURE OVERVIEW ===
# Database Purpose: Electronic Health Records (EHR) system with patient management
# Domain: Healthcare & Medical Records
# Architecture Pattern: HIPAA-compliant microservices with blockchain audit
#
# == MODULE BREAKDOWN ==  
# Patient (6 entities, 120 fields)
#   - Patient, MedicalHistory, Insurance, Emergency - Patient demographics
# Clinical (8 entities, 200 fields)
#   - Appointment, Visit, Diagnosis, Treatment - Clinical workflows
# Security (4 entities, 50 fields)
#   - AuditLog, AccessControl, Consent, Encryption - HIPAA compliance
#
# == KEY ARCHITECTURAL FEATURES ==
# - HIPAA compliance with comprehensive audit trails
# - End-to-end encryption for all PHI (Protected Health Information)
# - Role-based access control with fine-grained permissions
# - Blockchain-based audit trail for regulatory compliance
# - Integration with HL7 FHIR standard for interoperability
# - Zero-trust security model with multi-factor authentication
#
# == DATA DISTRIBUTION ==
# 370 total fields across 18 entities
# Documentation-heavy schema (245 string/text fields, 66.2%)
# Time-critical operations (85 DateTime fields, 23.0%)
# Consent and compliance focus (25 Boolean fields for permissions)
```

## Embedded Entity Patterns

### 1. Entity Type Notations
| Entity Type | Notation | When to Use | Example |
|-------------|----------|-------------|---------|
| **Standard Entity** | `EntityName` + `==========` | Independent tables/collections | `User`, `Order`, `Product` |
| **Embedded Entity** | `EntityName` + `/=======/` | Nested/child entities, complex arrays | `Stop`, `OrderItem`, `Address` |

### 2. Complex Array Conversion

When encountering complex JSON arrays with multiple properties, automatically convert to embedded entities for better readability and maintainability.

| Recognition Pattern | Conversion Action | Example |
|---------------------|-------------------|---------|
| `Array<JSON>` with >3 properties | Extract to embedded entity | `stops: Stop[1..*]` |
| Nested objects with business meaning | Create embedded entity | `address: Address[1..1]` |
| Reusable structures across entities | Promote to embedded entity | `contact: ContactInfo[0..1]` |

### 3. Embedded Entity Notation

| Pattern | Notation | Usage |
|---------|----------|-------|
| **Standard Entity** | `EntityName` + `==========` | Independent collections/tables |
| **Embedded Entity** | `EntityName` + `/=======/` | Child/nested entities |
| **Relationship Array** | `EntityName[cardinality]` | Parent-child relationships |

### 4. Cardinality Specifications

**Single Entity Relationships (No Brackets Required)**
- Use field prefix (`*` or `-`) to indicate required/optional
- No cardinality brackets needed for single entity relationships

**Array Entity Relationships (Brackets Required)**
- Use cardinality brackets `[min..max]` for array relationships
- Combine with field prefix to indicate required/optional arrays

| Cardinality | Meaning | Field Prefix | Example Use Case |
|-------------|---------|------------- |------------------|
| `EntityName` (no brackets) | Exactly one (required single) | `*` | Primary address, user profile |
| `EntityName` (no brackets) | Zero or one (optional single) | `-` | Optional profile photo, backup contact |
| `EntityName[1..*]` | One or more (required array) | `*` | Order must have items, route must have stops |
| `EntityName[0..*]` | Zero or more (optional array) | `-` | Optional comments, attachments |
| `EntityName[1..5]` | Fixed range (with limits) | `*` or `-` | Maximum 5 phone numbers, 1-3 photos |
| `EntityName[2..10]` | Specific range | `*` or `-` | Team members (2-10), product images (2-10) |

### 5. Advanced Embedded Patterns

#### Multi-Level Nesting with Various Cardinalities
```dbsoup
Order
==========
* orderId         : String                    [PK]
- items           : OrderItem[1..*]           # Required: order must have items
- payments        : Payment[0..*]             # Optional: may have no payments yet
- shippingAddress : Address                   # Required: exactly one shipping address (default)
- billingAddress  : Address                   # Optional: may use shipping address
- notes           : OrderNote[0..5]           # Optional: max 5 notes allowed

OrderItem
/=======/
* itemId          : String                    [PK]
* orderId         : String                    [FK:Order.orderId]
- addOns          : ItemAddOn[0..*]           # Optional: item may have no add-ons
- customizations  : Customization[0..3]       # Optional: max 3 customizations

ItemAddOn
/=======/
* addOnId         : String                    [PK] 
* itemId          : String                    [FK:OrderItem.itemId]
* type            : String                    
* price           : Decimal                   

Address
/=======/
* addressId       : String                    [PK]
* orderId         : String                    [FK:Order.orderId]
* street          : String                    
* city            : String                    
* state           : String                    
* zipCode         : String                    
```

#### Polymorphic Embedded Entities
```dbsoup
Document
==========
* docId           : String                    [PK]
- attachments     : Attachment[0..*]          

Attachment
/=======/
* attachmentId    : String                    [PK]
* docId           : String                    [FK:Document.docId]
* type            : Enum(image,video,audio,document)
* metadata        : JSON                      {
    # Image-specific fields when type='image'
        width: Int,
        height: Int,
        format: String,
    # Video-specific fields when type='video'
        duration: Int,
        codec: String,
    resolution: String
}
```

#### Temporal Embedded Entities
```dbsoup
Product
==========
* productId       : String                    [PK]
- priceHistory    : PriceHistory[0..*]        

PriceHistory
/=======/
* priceId         : String                    [PK]
* productId       : String                    [FK:Product.productId]
* price           : Decimal                   
* currency        : String                    
* effectiveDate   : DateTime                  
* expiryDate      : DateTime                  
* reason          : String                    
```

### 6. Conversion Rules and Decision Logic

```python
def should_convert_to_embedded_entity(field):
    """Advanced logic for embedded entity conversion"""
    if field.type == "Array<JSON>":
        properties = count_json_properties(field.structure)
        complexity_score = calculate_complexity_score(field.structure)
        
        # Convert if complex enough
        if properties > 3 or complexity_score > 10:
            return True
            
        # Check if represents business entity
        if is_business_entity(field.name):
            return True
            
        # Check if reusable across entities
        if is_reusable_structure(field.structure):
            return True
    
    elif field.type == "JSON":
        properties = count_json_properties(field.structure)
        complexity_score = calculate_complexity_score(field.structure)
        
        # Convert single JSON objects if complex enough
        if properties > 5 or complexity_score > 15:
            return True
            
        # Check if represents business entity
        if is_business_entity(field.name):
            return True
    
    return False

def determine_embedded_cardinality(field):
    """Determine cardinality for embedded entity relationship"""
    is_required = field.is_required or field.prefix == "*"
    is_array = field.type.startswith("Array")
    has_size_limits = field.has_size_constraints()
    
    if has_size_limits:
        min_size = field.min_size or (1 if is_required else 0)
        max_size = field.max_size or "*"
        return f"[{min_size}..{max_size}]"
    elif is_array:
        return "[1..*]" if is_required else "[0..*]"
    else:
        return ""  # Single entities use field prefix (* or -) instead of cardinality brackets

def calculate_complexity_score(structure):
    """Calculate complexity score for JSON structure"""
    score = 0
    for field in structure.fields:
        if field.type == "JSON":
            score += 3  # Nested objects add complexity
        elif field.type.startswith("Array"):
            score += 2  # Arrays add complexity
        elif field.has_constraints():
            score += 1  # Constraints add complexity
        else:
            score += 0.5  # Simple fields
    return score
```

## Template Library

### 1. DBSoup File Template with Relationships Definition
```dbsoup
@database-name.dbsoup

=== RELATIONSHIP DEFINITIONS ===
# One-to-One Relationships
User -> UserProfile [1:1] (composition)
Customer -> Address [1:1] (aggregation)

# One-to-Many Relationships
User -> Order [1:M] (composition)
Category -> Product [1:M] (aggregation)
Order -> OrderItem [1:M] (composition)

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

=== DATABASE SCHEMA ===
+ User Management
+ Core Business Logic
+ Configuration

=== User Management ====
```

### 2. Basic SQL Entity Template
```dbsoup
EntityName # Brief description of entity purpose
==========
* _id            : ID                        [PK] # Primary identifier
* required_field : DataType                  [constraints] # Description of required field
- optional_field : DataType                  [constraints] # Description of optional field
# System tracking fields
- created_at     : DateTime                  [SYSTEM,DEFAULT:CURRENT_TIMESTAMP] # Record creation time
- updated_at     : DateTime                  [SYSTEM] # Last modification time
# Indexed fields for performance
! indexed_field  : DataType                  [IX] # Frequently searched field
- unique_field   : DataType                  [UK] # Must be unique across records

# RELATIONSHIPS
@ relationships:: Entity relates to Other (1:M) # Relationship description
## Entity.foreignKey -> Other.primaryKey # FK relationship detail
#
```

### 3. Basic MongoDB Entity Template  
```dbsoup
EntityName # Main collection purpose and description
==========
* _id            : ObjectId                  [PK] # MongoDB document identifier
* required_field : DataType                  [VALIDATE:required] # Must be provided
- optional_field : DataType                  # Can be null or missing
# Simple configuration (acceptable as JSON)
- simple_config  : JSON                      {
    setting1: Boolean,
    setting2: String
} # Only for ≤2 primitive properties
- complex_nested : NestedEntity              # Convert complex objects to embedded entities (optional single)
- array_field    : Array<DataType>           # Simple array of primitives
- complex_children : ChildEntity[1..*]       # Complex array as embedded entities
! indexed_field  : DataType                  [IX:type] # Indexed for performance

NestedEntity # Embedded document for complex nested data
/=======/
* _id            : ObjectId                  [PK] # Embedded entity identifier
* parent_id      : ObjectId                  [FK:EntityName._id] # Reference to parent document
* field1         : DataType                  # First nested field
* field2         : DataType                  # Second nested field
- additional_field : DataType                # Optional nested field

# MongoDB Features
@ search_field   : String                    [ATLAS:search-index] # Full-text search enabled
#
```

### 4. Embedded Entity Template
```dbsoup
ChildEntity
/=======/
* child_id       : String                    [PK]
* parent_id      : String                    [FK:EntityName._id]
* required_field : DataType                  [VALIDATE:required]
- optional_field : DataType                  
- nested_data    : JSON                      {
    simple_field: DataType,
    another_field: DataType
}
- created_at     : DateTime                  [SYSTEM,DEFAULT:NOW()]
- updated_at     : DateTime                  [SYSTEM]
```

### 5. Advanced SQL Server Template
```dbsoup
EntityName
==========
* _id             : ID                       [PK,IDENTITY(1,1)]
* name            : String(100)              [UK]
^ full_name       : String                   [COMPUTED:first_name + ' ' + last_name]
* location        : Geography                [IX:spatial]
* xml_data        : XML                      
* hierarchy_path  : HierarchyID              
& replicated_field : String                  [REPLICATE:merge]
_ row_version     : RowVersion               
! created_date    : DateTime2                [IX,DEFAULT:SYSDATETIME()]
< large_data      : VarBinary                [FILESTREAM]
```

### 6. Advanced PostgreSQL Template
```dbsoup
EntityName
==========
* _id            : UUID                      [PK,DEFAULT:gen_random_uuid()]
* name           : String(100)               [UK]
* tags           : Array<String>             [IX:gin]
* metadata       : JSONB                     [IX:gin]
* coordinates    : Point                     [IX:gist]
* date_range     : DateRange                 
* status         : CustomEnum                [DEFAULT:'active']
! search_vector  : TSVector                  [FIX:to_tsvector('english', content)]
- created_at     : Timestamp                 [DEFAULT:NOW()]
```

### 7. Advanced MongoDB Template
```dbsoup
EntityName
==========
* _id            : ObjectId                  [PK]
* name           : String                    [VALIDATE:required,minLength:1]
- nested_docs    : NestedDocument[1..*]      # Convert complex nested objects
- array_items    : ArrayItem[0..*]           # Convert complex arrays to embedded entities
! search_field   : String                    [ATLAS:search-index,analyzer:'standard']
! geo_location   : GeoJSON                   [IX:2dsphere]
! tags           : Array<String>             [IX:multikey]
> shard_key      : String                    [SHARD:hashed]
- created_at     : DateTime                  [IX:1,TTL:2592000]

NestedDocument
/=======/
* _id            : ObjectId                  [PK]
* parent_id      : ObjectId                  [FK:EntityName._id]
* field1         : String                    [VALIDATE:required]
- sub_entity     : SubEntity                 # Optional single

SubEntity
/=======/
* _id            : ObjectId                  [PK]
* nested_doc_id  : ObjectId                  [FK:NestedDocument._id]
* subfield       : Number                    [VALIDATE:min:0]

ArrayItem
/=======/
* _id            : ObjectId                  [PK]
* parent_id      : ObjectId                  [FK:EntityName._id]
* type           : String                    
* value          : Number                    
- metadata       : ItemMetadata              # Optional single

ItemMetadata
/=======/
* _id            : ObjectId                  [PK]
* array_item_id  : ObjectId                  [FK:ArrayItem._id]
* created        : DateTime                  
* updated        : DateTime                  
```

## Complex Array Conversion Examples

### Required Array (1..*)
```dbsoup
BEFORE (complex JSON array):
- items : Array<JSON> [{
    itemId: String,
    name: String,
    quantity: Int,
    price: Decimal
}]

AFTER (embedded entity relationship):
- items : OrderItem[1..*]

OrderItem
/=======/
* itemId         : String                    [PK]
* orderId        : String                    [FK:Order._id]
* name           : String                    
* quantity       : Int                       
* price          : Decimal                   
```

### Optional Array (0..*)
```dbsoup
BEFORE (optional complex array):
- comments : Array<JSON> [{
    commentId: String,
    text: String,
    authorId: String,
    timestamp: DateTime
}]

AFTER (embedded entity relationship):
- comments : Comment[0..*]

Comment
/=======/
* commentId      : String                    [PK]
* postId         : String                    [FK:Post._id]
* text           : String                    
* authorId       : String                    [FK:User._id]
* timestamp      : DateTime                  
```

### Optional Single
```dbsoup
BEFORE (optional complex object):
- profile : JSON {
    bio: String,
    website: String,
    location: String,
    avatar: String
}

AFTER (embedded entity relationship):
- profile : UserProfile  # Optional single (no brackets needed)

UserProfile
/=======/
* profileId      : String                    [PK]
* userId         : String                    [FK:User._id]
- bio            : String                    
- website        : String                    
- location       : String                    
- avatar         : String                    
```

### Required Single
```dbsoup
BEFORE (required complex object):
* address : JSON {
    street: String,
    city: String,
    state: String,
    zipCode: String
}

AFTER (embedded entity relationship):
* address : Address  # Required single (no brackets needed)

Address
/=======/
* addressId      : String                    [PK]
* customerId     : String                    [FK:Customer._id]
* street         : String                    
* city           : String                    
* state          : String                    
* zipCode        : String                    
```

## Complete Cardinality Example

```dbsoup
User
==========
* userId         : String                    [PK]
* username       : String                    [UK]
* email          : String                    [UK]
- profile        : UserProfile               # Optional: single profile
- addresses      : Address[1..*]             # Required: at least one address
- phoneNumbers   : PhoneNumber[0..3]         # Optional: max 3 phone numbers
- socialProfiles : SocialProfile[0..*]       # Optional: unlimited social profiles
- preferences    : UserPreference            # Required: exactly one preference set (default)

UserProfile
/=======/
* profileId      : String                    [PK]
* userId : String [FK:User.userId]
- bio : String
- website : String
- avatar : String

Address
/=======/
* addressId : String [PK]
* userId : String [FK:User.userId]
* type : Enum(home,work,other)
* street : String
* city : String
* state : String
* zipCode : String

PhoneNumber
/=======/
* phoneId : String [PK]
* userId : String [FK:User.userId]
* type : Enum(mobile,home,work)
* number : String
* isPrimary : Boolean

SocialProfile
/=======/
* socialId : String [PK]
* userId : String [FK:User.userId]
* platform : Enum(twitter,linkedin,facebook,instagram)
* handle : String
* url : String

UserPreference
/=======/
* preferenceId : String [PK]
* userId : String [FK:User.userId]
* theme : Enum(light,dark,auto)
* language : String
* timezone : String
* notifications : JSON {
    email: Boolean,
    sms: Boolean,
    push: Boolean
}
```

## Migration Patterns

When converting existing schemas to use embedded entities:

1. **Backward Compatibility**: Maintain both formats during transition
2. **Incremental Conversion**: Convert one complex field at a time
3. **Validation**: Ensure no data loss during conversion
4. **Documentation**: Update all references to use new notation
5. **Cardinality Assessment**: Evaluate business rules to determine correct cardinality

## Decision Trees for Complex Data Structures

### JSON to Embedded Entity Decision Tree
```
IF field is Array<JSON> with ANY complex properties → convert to embedded entity
IF field is JSON with >2 properties → convert to embedded entity
IF field represents a business entity → use embedded entity
IF field is reusable across entities → use embedded entity
IF field has nested objects → convert to embedded entity
IF field is simple array (Array<String>) → keep as Array<Type>
IF field is simple JSON (≤2 primitive properties) → keep as JSON
ELSE → convert to embedded entity
```

### Cardinality Assignment Decision Tree
```
IF field is required AND can have multiple values → use [1..*]
IF field is optional AND can have multiple values → use [0..*]
IF field is required AND single value → use * prefix with EntityName (no brackets)
IF field is optional AND single value → use - prefix with EntityName (no brackets)
IF field has specific limits → use [min..max] (e.g., [1..5], [0..3])
```

### Embedded Entity Conversion Rules
```
WHEN to create embedded entity (ALWAYS prefer embedded entities over JSON):
- JSON array with ANY complex objects
- Nested objects with >2 properties  
- ANY business-meaningful data structure
- Reusable data structures
- Business entities (Address, Contact, etc.)
- Objects containing other objects (nested structures)
- Objects with mixed data types

ONLY keep as JSON when:
- Simple configuration objects (≤2 primitive properties)
- Raw unstructured data
- Dynamic schema requirements

HOW to convert:
1. Extract JSON structure to new embedded entity
2. Use /=======/ notation for embedded entities
3. Replace original field with EntityName[cardinality]
4. Add proper foreign key relationships
5. Maintain all original constraints
6. Convert nested JSON within embedded entities recursively

CARDINALITY determination:
- Required array → * EntityName[1..*]
- Optional array → - EntityName[0..*]  
- Required single → * EntityName (no brackets needed)
- Optional single → - EntityName (no brackets needed)
- With limits → EntityName[min..max] (use appropriate prefix)
```

## Key Principles for Embedded Entity Usage

### CRITICAL RULE: Minimize JSON, Maximize Embedded Entities

**Always prefer embedded entities over JSON structures** for any complex data. The DBSoup format is designed to provide clear, structured representations of data relationships.

### When to Use JSON (Very Limited Cases)
- **Simple configuration objects** with ≤2 primitive properties
- **Raw unstructured data** (logs, free-form text)
- **Dynamic schemas** where structure cannot be predetermined

### When to Convert to Embedded Entities (Default Behavior)
- **ANY Array<JSON>** with structured objects
- **ANY JSON** with >2 properties
- **ANY nested objects** within JSON
- **ANY business-meaningful data structures**
- **ANY reusable data patterns**
- **ANY objects with mixed data types**

### Validation Rules
1. **No complex JSON structures** - convert to embedded entities
2. **All Array<JSON>** must become embedded entity relationships
3. **Nested objects** must become embedded entities
4. **JSON should be rare** - only for simple configurations or truly unstructured data
5. **Embedded entities** should have proper primary keys and foreign key relationships

Following these principles ensures that DBSoup documentation is consistent, maintainable, and provides clear data structure representation for all stakeholders. 
# Database Types and Mappings for DBSoup

## Overview

This document provides comprehensive data type mappings and database-specific instructions for converting schemas to DBSoup format. It serves as a reference for AI systems and developers working with different database engines.

**Related Documents:**
- [Database Schema to DBSoup Guide](./01_DATABASE_SCHEMA_TO_DBSOUP_GUIDE.md) - Main conversion guide
- [DBSoup Technical Specifications](./DBSOUP_SPECIFICATIONS.md) - Technical specifications
- [AI Decision Framework](./04_AI_DECISION_FRAMEWORK.md) - AI processing logic

## Quick Reference: Entity Type Notations

| Entity Type | Notation | When to Use | Example |
|-------------|----------|-------------|---------|
| **Standard Entity** | `EntityName` + `==========` | Independent tables/collections | `User`, `Order`, `Product` |
| **Embedded Entity** | `EntityName` + `/=======/` | Nested/child entities, complex arrays | `Stop`, `OrderItem`, `Address` |

## Complete Data Type Mapping Rules

### SQL to DBSoup Mapping
| SQL Type | DBSoup Type | Notes |
|----------|---------------|--------|
| `VARCHAR(n)` | `String(n)` | With length |
| `CHAR(n)` | `String(n)` | Fixed length |
| `TEXT` | `Text` | Long text |
| `LONGTEXT` | `LongText` | Very long text |
| `CLOB` | `Text` | Character large object |
| `INT` | `Int` | Standard integer |
| `TINYINT` | `TinyInt` | Small integer (-128 to 127) |
| `SMALLINT` | `SmallInt` | Small integer (-32,768 to 32,767) |
| `BIGINT` | `BigInt` | Large integer |
| `FLOAT` | `Float` | Floating point |
| `REAL` | `Float` | Real number |
| `DOUBLE` | `Double` | Double precision |
| `DECIMAL(p,s)` | `Decimal(p,s)` | With precision |
| `NUMERIC(p,s)` | `Decimal(p,s)` | Numeric with precision |
| `MONEY` | `Money` | Currency values |
| `DATETIME` | `DateTime` | Date and time |
| `DATETIME2` | `DateTime2` | High precision date/time |
| `DATETIMEOFFSET` | `DateTimeOffset` | Date/time with timezone |
| `DATE` | `Date` | Date only |
| `TIME` | `Time` | Time only |
| `TIMESTAMP` | `Timestamp` | System timestamp |
| `BOOLEAN` | `Boolean` | True/false |
| `BIT` | `Bit` | Single bit |
| `UUID` | `UUID` | Unique identifier |
| `GUID` | `Guid` | Global unique identifier |
| `JSON` | `JSON` | JSON object |
| `JSONB` | `JSONB` | Binary JSON (PostgreSQL) |
| `XML` | `XML` | XML document |
| `BLOB` | `Buffer` | Binary large object |
| `VARBINARY` | `VarBinary` | Variable binary |
| `IMAGE` | `Image` | Image binary data |
| `GEOMETRY` | `Geometry` | Spatial geometry |
| `GEOGRAPHY` | `Geography` | Geographic data |
| `POINT` | `Point` | Spatial point |
| `POLYGON` | `Polygon` | Spatial polygon |
| `LINESTRING` | `LineString` | Spatial line |
| `HIERARCHYID` | `HierarchyID` | Hierarchical data |
| `ROWVERSION` | `RowVersion` | Row versioning |
| `SQL_VARIANT` | `SqlVariant` | Variable data type |
| `ENUM(values)` | `Enum(values)` | Enumerated values |
| `SET(values)` | `Set(values)` | Set of values |

### MongoDB to DBSoup Mapping  
| MongoDB Type | DBSoup Type | Notes |
|--------------|---------------|--------|
| `ObjectId` | `ObjectId` | MongoDB unique identifier |
| `String` | `String` | Text field |
| `Number` | `Int` or `Double` | Depends on usage |
| `Array` | `Array<Type>` | With element type |
| `Object` | `JSON` | Nested document |
| `Date` | `DateTime` | Date field |
| `Boolean` | `Boolean` | True/false |
| `BinData` | `BinData` | Binary data in MongoDB |
| `Code` | `Code` | JavaScript code |
| `CodeWScope` | `CodeWScope` | JavaScript with scope |
| `MinKey` | `MinKey` | Minimum key value |
| `MaxKey` | `MaxKey` | Maximum key value |
| `Regex` | `Regex` | Regular expression |
| `Symbol` | `Symbol` | Symbol type |
| `Undefined` | `Undefined` | Undefined value |
| `DBRef` | `DBRef` | Database reference |
| `Timestamp` | `Timestamp` | MongoDB timestamp |
| `Decimal128` | `Decimal128` | 128-bit decimal |
| `Long` | `Long` | 64-bit integer |
| `Double` | `Double` | Double precision float |
| `GeoJSON` | `GeoJSON` | Geographic JSON data |

## Database-Specific Instructions

### For SQL Databases

#### Recognition Patterns:
```
IF see "CREATE TABLE" → SQL Database
IF see "PRIMARY KEY" → Mark with * and [PK]
IF see "FOREIGN KEY" → Mark with [FK:Table.field]
IF see "UNIQUE" → Mark with ! and [UK]
IF see "INDEX" → Mark with @ and [IX]
IF see "NOT NULL" → Use * prefix
IF see "NULL" allowed → Use - prefix
```

#### Processing Steps:
1. Extract table name → Entity name
2. Extract column definitions → Field definitions
3. Map SQL types to DBSoup types
4. Identify constraints and indexes
5. Find foreign key relationships
6. Document in DBSoup format

### For MongoDB

#### Recognition Patterns:
```
IF see ObjectId → MongoDB Database
IF see nested objects → Use JSON structure
IF see arrays → Use Array<Type>
IF see validation schema → Add [VALIDATE:rule]
IF see indexes → Mark with @ and [IX:type]
IF see Atlas features → Mark with [ATLAS:feature]
```

#### Processing Steps:
1. Extract collection name → Entity name
2. Analyze document structure → Field definitions
3. Map MongoDB types to DBSoup types
4. Identify indexes and validation
5. Document Atlas/cloud features
6. Structure nested documents clearly

### For SQL Server

#### Recognition Patterns:
```
IF see HIERARCHYID → SQL Server Database
IF see ROWVERSION → Mark with [ROWVERSION]
IF see COMPUTED → Mark with ^ and [COMPUTED]
IF see GEOGRAPHY/GEOMETRY → Use spatial types
IF see XML → Use XML data type
IF see IDENTITY → Mark with [IDENTITY(seed,increment)]
IF see FILESTREAM → Mark with [FILESTREAM]
```

#### Processing Steps:
1. Extract table name → Entity name
2. Identify SQL Server specific types
3. Map computed columns to ^ prefix
4. Document spatial and XML features
5. Note identity specifications
6. Handle hierarchical data patterns

### For PostgreSQL

#### Recognition Patterns:
```
IF see JSONB → PostgreSQL Database
IF see ARRAY[] → Use Array<Type>
IF see SERIAL → Mark with [AUTO_INCREMENT]
IF see GIN/GIST indexes → Mark with [FIX]
IF see RANGE types → Use specialized types
IF see ENUM → Create custom enum types
IF see EXTENSION → Note extensions used
```

#### Processing Steps:
1. Extract table/relation name → Entity name
2. Handle JSONB and array fields
3. Map PostgreSQL specific types
4. Document advanced indexing (GIN, GIST)
5. Note custom types and extensions
6. Handle range and domain types

### For Oracle

#### Recognition Patterns:
```
IF see NUMBER → Oracle Database
IF see CLOB/BLOB → Use Text/Buffer types
IF see XMLTYPE → Use XML type
IF see PARTITION BY → Mark with [PARTITION]
IF see CONNECT BY → Note hierarchical queries
IF see SEQUENCE → Mark with [SEQUENCE]
IF see MATERIALIZED VIEW → Note view patterns
```

#### Processing Steps:
1. Extract table name → Entity name
2. Map Oracle NUMBER to appropriate types
3. Handle LOB types appropriately
4. Document partitioning strategies
5. Note hierarchical and XML features
6. Handle sequences and materialized views

## Advanced Constraint Notations

### Core Constraint Notations
| Notation | Meaning | Example |
|----------|---------|---------|
| `[PK]` | Primary key | `* id : UUID [PK]` |
| `[FK:Entity.field]` | Foreign key | `- user_id : UUID [FK:User.id]` |
| `[UK]` | Unique key | `! email : String [UK]` |
| `[IX]` | Basic index | `! name : String [IX]` |
| `[CIX]` | Composite index | `! field1,field2 : String [CIX]` |
| `[PIX:(condition)]` | Partial index | `! status : String [PIX:(WHERE active=true)]` |
| `[FIX]` | Functional index | `! email : String [FIX:lower(email)]` |
| `[UIX]` | Unique index | `! code : String [UIX]` |
| `[CK:condition]` | Check constraint | `- age : Int [CK:age >= 18]` |
| `[CHECK:condition]` | Check constraint | `- age : Int [CHECK:age >= 18]` |
| `[DEFAULT:value]` | Default value | `- status : String [DEFAULT:'active']` |
| `[AUTO_INCREMENT]` | Auto-incrementing | `* id : Int [AUTO_INCREMENT]` |
| `[IDENTITY(s,i)]` | Identity with seed/increment | `* id : Int [IDENTITY(1,1)]` |

### Advanced Constraint Notations
| Notation | Meaning | Example |
|----------|---------|---------|
| `[COMPUTED:expr]` | Computed field | `^ full_name : String [COMPUTED:first+' '+last]` |
| `[VIRTUAL:expr]` | Virtual field | `^ age : Int [VIRTUAL:YEAR(NOW())-birth_year]` |
| `[STORED:expr]` | Stored computed field | `^ total : Decimal [STORED:price*quantity]` |
| `[PARTITION:strategy]` | Partitioning strategy | `> date_field : Date [PARTITION:monthly]` |
| `[SHARD:key]` | Sharding key | `> user_id : String [SHARD:hash]` |
| `[REPLICATE:strategy]` | Replication strategy | `& data : String [REPLICATE:master-slave]` |
| `[FEDERATED]` | Federated/distributed system | `& distributed_data : String [FEDERATED]` |
| `[COMPRESS:algorithm]` | Compression | `< content : Text [COMPRESS:gzip]` |
| `[COMPRESSED]` | Compressed data | `- data : String [COMPRESSED]` |
| `[ENCRYPT:algorithm]` | Encryption | `@ password : String [ENCRYPT:AES256]` |
| `[ENCRYPTED]` | Encrypted field | `@ password : String [ENCRYPTED]` |
| `[MASK:pattern]` | Data masking | `~ ssn : String [MASK:XXX-XX-####]` |
| `[PII]` | Personal identifiable information | `@ ssn : String [PII]` |
| `[RLS:policy]` | Row-level security | `$ secure_data : JSON [RLS:user_policy]` |
| `[AUDIT:level]` | Audit level | `$ changes : JSON [AUDIT:full]` |
| `[SPATIAL]` | Spatial/geographic index | `* lat : Double [SPATIAL]` |
| `[BASE64]` | Base64 encoded data | `- image : String [BASE64]` |
| `[CURRENCY]` | Monetary value | `* price : Decimal [CURRENCY]` |
| `[CACHE]` | Enable caching | `% data : JSON [CACHE]` |
| `[CACHED:strategy]` | Caching strategy | `% data : JSON [CACHED:redis]` |
| `[GENERATED]` | Generated by database | `- full_name : String [GENERATED]` |
| `[DERIVED]` | Derived from external sources | `- external_id : String [DERIVED]` |
| `[IMMUTABLE]` | Cannot be changed after creation | `- created_id : String [IMMUTABLE]` |
| `[PRECISION:digits]` | Numeric precision | `* amount : Decimal [PRECISION:2]` |
| `[DEPRECATED]` | Deprecated field | `- old_field : String [DEPRECATED]` |
| `[BACKUP:strategy]` | Backup strategy | `* critical : String [BACKUP:realtime]` |
| `[MONITOR:threshold]` | Monitoring | `@ performance : Float [MONITOR:>1000ms]` |
| `[COLLATE:collation]` | Collation | `@ name : String [COLLATE:utf8_unicode_ci]` |
| `[COLLATION:rule]` | Text collation rule | `@ text : String [COLLATION:utf8_general_ci]` |
| `[CHARSET:encoding]` | Character set | `@ text : String [CHARSET:utf8mb4]` |
| `[TIMEZONE:zone]` | Timezone | `@ timestamp : DateTime [TIMEZONE:UTC]` |

### MongoDB-Specific Notations
| Notation | Meaning | Example |
|----------|---------|---------|
| `[VALIDATE:rule]` | MongoDB validation | `* email : String [VALIDATE:required,email]` |
| `[ATLAS:feature]` | MongoDB Atlas feature | `@ content : String [ATLAS:search-index]` |
| `[REALM:setting]` | MongoDB Realm setting | `* user_id : String [REALM:partition-key]` |
| `[CHANGE:stream]` | Change stream config | `@ updates : JSON [CHANGE:fullDocument]` |
| `[TRANSACTION:setting]` | Transaction setting | `* amount : Decimal [TRANSACTION:majority]` |
| `[TIMESERIES:field]` | Time series designation | `* timestamp : DateTime [TIMESERIES:timeField]` |
| `[READ:preference]` | Read preference | `& cached_data : String [READ:secondary]` |
| `[WRITE:concern]` | Write concern | `* critical : String [WRITE:majority]` |
| `[MULTIKEY]` | Multikey index | `! tags : Array<String> [IX:1,MULTIKEY]` |
| `[SPARSE]` | Sparse index | `! optional_field : String [IX:1,SPARSE]` |
| `[TTL:seconds]` | Time to live | `! expires : DateTime [IX:1,TTL:3600]` |
| `[HASHED]` | Hashed index | `! shard_key : String [IX:hashed]` |
| `[TEXT]` | Text index | `! content : String [IX:text]` |
| `[WILDCARD]` | Wildcard index | `! dynamic : JSON [IX:wildcard]` |
| `[PARTIAL:filter]` | Partial index | `! status : String [IX:1,PARTIAL:{active:true}]` |
| `[COMPOUND:fields]` | Compound index | `@ field1,field2 : String [IX:compound]` |

## Database Engine Decision Logic

### Input Recognition Algorithm
```python
def identify_database_type(input_text):
    """Identify database type from input schema"""
    if "CREATE TABLE" in input_text or "ALTER TABLE" in input_text:
        return "SQL"
    elif "ObjectId" in input_text or "db.collection" in input_text:
        return "MongoDB"
    elif "PRIMARY KEY" in input_text:
        return "SQL"
    elif "HIERARCHYID" in input_text or "ROWVERSION" in input_text:
        return "SQL_Server"
    elif "JSONB" in input_text or "ARRAY[]" in input_text:
        return "PostgreSQL"
    elif "NUMBER" in input_text or "CLOB" in input_text:
        return "Oracle"
    elif "AUTO_INCREMENT" in input_text and "ENGINE=" in input_text:
        return "MySQL"
    else:
        return analyze_field_patterns(input_text)

def analyze_field_patterns(input_text):
    """Analyze field patterns to determine database type"""
    patterns = {
        "MongoDB": ["_id", "ObjectId", "ISODate", "NumberLong"],
        "PostgreSQL": ["SERIAL", "JSONB", "ARRAY", "BIGSERIAL"],
        "SQL_Server": ["NVARCHAR", "UNIQUEIDENTIFIER", "DATETIME2"],
        "Oracle": ["VARCHAR2", "NUMBER", "DATE", "TIMESTAMP"],
        "MySQL": ["AUTO_INCREMENT", "LONGTEXT", "DATETIME"]
    }
    
    scores = {}
    for db_type, pattern_list in patterns.items():
        scores[db_type] = sum(1 for pattern in pattern_list if pattern in input_text)
    
    return max(scores, key=scores.get) if max(scores.values()) > 0 else "Generic_SQL"
```

### Complex Type Processing
```python
def process_complex_types(field_type, database_type):
    """Process complex data types based on database"""
    if database_type == "MongoDB":
        if field_type == "ObjectId":
            return "ObjectId"
        elif field_type == "Array":
            element_type = determine_element_type()
            if should_convert_to_embedded_entity(element_type):
                return create_embedded_entity_relationship(element_type)
            else:
                return f"Array<{element_type}>"
        elif field_type == "Object":
            if should_convert_to_embedded_entity(field_type):
                return create_embedded_entity_relationship(field_type)
            else:
                return "JSON"
        elif field_type == "BinData":
            return "BinData"
        elif field_type == "GeoJSON":
            return "GeoJSON"
    
    elif database_type == "SQL_Server":
        if field_type == "HIERARCHYID":
            return "HierarchyID"
        elif field_type == "GEOGRAPHY":
            return "Geography"
        elif field_type == "GEOMETRY":
            return "Geometry"
        elif field_type == "XML":
            return "XML"
        elif field_type == "ROWVERSION":
            return "RowVersion"
    
    elif database_type == "PostgreSQL":
        if field_type == "JSONB":
            return "JSONB"
        elif field_type.startswith("ARRAY"):
            return "Array<extract_element_type()>"
        elif field_type == "TSVECTOR":
            return "TSVector"
        elif field_type == "GEOMETRY":
            return "Geometry"
        elif field_type == "POINT":
            return "Point"
    
    elif database_type == "Oracle":
        if field_type == "CLOB":
            return "Text"
        elif field_type == "BLOB":
            return "Buffer"
        elif field_type == "XMLTYPE":
            return "XML"
        elif field_type == "NUMBER":
            return "Decimal"
    
    return map_standard_sql_type(field_type)

def map_standard_sql_type(field_type):
    """Map standard SQL types to DBSoup types"""
    mapping = {
        "VARCHAR": "String",
        "CHAR": "String",
        "TEXT": "Text",
        "INT": "Int",
        "INTEGER": "Int",
        "BIGINT": "BigInt",
        "SMALLINT": "SmallInt",
        "TINYINT": "TinyInt",
        "DECIMAL": "Decimal",
        "NUMERIC": "Decimal",
        "FLOAT": "Float",
        "DOUBLE": "Double",
        "REAL": "Float",
        "DATETIME": "DateTime",
        "DATE": "Date",
        "TIME": "Time",
        "TIMESTAMP": "Timestamp",
        "BOOLEAN": "Boolean",
        "BOOL": "Boolean",
        "BIT": "Bit",
        "BINARY": "Buffer",
        "VARBINARY": "VarBinary",
        "BLOB": "Buffer",
        "UUID": "UUID",
        "GUID": "Guid"
    }
    
    # Handle parameterized types
    if "(" in field_type:
        base_type = field_type.split("(")[0].upper()
        params = field_type.split("(")[1].rstrip(")").split(",")
        
        if base_type in mapping:
            mapped_type = mapping[base_type]
            if base_type in ["VARCHAR", "CHAR", "STRING"]:
                return f"{mapped_type}({params[0]})"
            elif base_type in ["DECIMAL", "NUMERIC"]:
                if len(params) == 2:
                    return f"{mapped_type}({params[0]},{params[1]})"
                else:
                    return f"{mapped_type}({params[0]})"
            else:
                return mapped_type
    
    return mapping.get(field_type.upper(), field_type)
```

## Migration and Conversion Patterns

### Schema Migration Rules
When converting from one database to another through DBSoup:

1. **SQL → MongoDB**: 
   - Primary keys become `_id : ObjectId`
   - Foreign keys become embedded documents or references
   - Indexes become MongoDB indexes with appropriate types

2. **MongoDB → SQL**:
   - ObjectId becomes `UUID` or `GUID`
   - Embedded documents become separate tables with foreign keys
   - Arrays become junction tables for complex types

3. **Cross-Database Compatibility**:
   - Use generic types where possible
   - Document database-specific features in comments
   - Maintain constraint information for migration

### Type Conversion Safety Rules
```python
def safe_type_conversion(source_type, target_db):
    """Ensure safe type conversion between databases"""
    conversions = {
        "SQL_to_MongoDB": {
            "VARCHAR": "String",
            "INT": "NumberInt",
            "BIGINT": "NumberLong",
            "DECIMAL": "Decimal128",
            "DATETIME": "Date",
            "BOOLEAN": "Boolean",
            "UUID": "ObjectId"
        },
        "MongoDB_to_SQL": {
            "String": "VARCHAR",
            "NumberInt": "INT",
            "NumberLong": "BIGINT",
            "Decimal128": "DECIMAL",
            "Date": "DATETIME",
            "Boolean": "BOOLEAN",
            "ObjectId": "UUID"
        }
    }
    
    conversion_key = f"{source_type}_to_{target_db}"
    return conversions.get(conversion_key, {}).get(source_type, source_type)
```

## Reference Quick Cards

### Field Prefix Quick Reference
| Prefix | Meaning | Database Support |
|--------|---------|------------------|
| `*` | Required/Primary | All databases |
| `-` | Optional | All databases |
| `!` | Indexed | All databases |
| `@` | Sensitive/Encrypted | All databases |
| `~` | Masked | All databases |
| `>` | Partitioned | All databases |
| `$` | Audit | All databases |

### Common System Fields
| Field Pattern | SQL Example | MongoDB Example | DBSoup Format |
|---------------|-------------|-----------------|---------------|
| Primary Key | `id INT PRIMARY KEY` | `_id: ObjectId` | `* _id : ObjectId [PK]` |
| Created Date | `created_at DATETIME DEFAULT NOW()` | `created_at: ISODate()` | `- created_at : DateTime [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]` |
| Updated Date | `updated_at DATETIME` | `updated_at: ISODate()` | `- updated_at : DateTime [SYSTEM]` |
| Version | `version INT DEFAULT 1` | `version: NumberInt(1)` | `- version : Int [SYSTEM,DEFAULT:1]` |
| Status | `status VARCHAR(20) DEFAULT 'active'` | `status: "active"` | `- status : String [DEFAULT:'active']` |

This comprehensive reference ensures accurate conversion between different database systems while maintaining the semantic meaning of the original schema. 
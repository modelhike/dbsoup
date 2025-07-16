# AI Decision Framework for DBSoup Conversion

## Overview

This document provides a systematic decision framework for AI systems to convert database schemas to DBSoup format. It includes decision trees, validation rules, and error prevention strategies specifically designed for automated processing.

**Related Documents:**
- [Database Schema to DBSoup Guide](./01_DATABASE_SCHEMA_TO_DBSOUP_GUIDE.md) - Main conversion guide
- [Database Types and Mappings](./02_DATABASE_TYPES_AND_MAPPINGS.md) - Type conversion reference
- [Embedded Entities and Templates](./03_EMBEDDED_ENTITIES_AND_TEMPLATES.md) - Entity structure patterns

## Quick Start AI Decision Framework

### Step 1: Pattern Recognition and Field Prefix Decision

#### Simplified Decision Tree for Field Prefixes

⚠️ **CRITICAL RULE: NEVER use special prefixes for system characteristics!**

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
IF field is derived from external sources → add [DERIVED]
IF field has audit trails → add [AUDIT]
IF field is cached → add [CACHED]
IF field is immutable → add [IMMUTABLE]
IF field is replicated → add [REPLICATE]
IF field is compressed → add [COMPRESS]
IF field is partitioned → add [PARTITION]
IF field is federated → add [FEDERATED]
```

### Step 2: System Field Decision Examples

```
created_at field (auto-generated timestamp, optional):
Step 1: Optional → use -
Step 2: Auto-generated → add [SYSTEM]
Result: - created_at : DateTime [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]

id field (auto-increment, primary key):
Step 1: Primary key → use *
Step 2: Auto-generated → add [AUTO]
Result: * id : Int [PK,AUTO_INCREMENT]

version field (system-managed, required):
Step 1: Required → use *
Step 2: System-managed → add [SYSTEM]
Result: * version : Int [SYSTEM,DEFAULT:1]

full_name field (computed, optional):
Step 1: Optional → use -
Step 2: Computed → add [COMPUTED:expression]
Result: - full_name : String [COMPUTED:first_name+' '+last_name]
```

### Step 3: Complex Data Structure Decision Tree

**⚠️ CRITICAL: For complete complex array conversion guide, see [Complex Array Conversion Guide](./07_COMPLEX_ARRAY_CONVERSION_GUIDE.md)**

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

### Step 3.1: Mandatory Complex Array Detection

**RULE:** Any JSON array with structured objects MUST be converted to embedded entities.

```javascript
function mustConvertToEmbeddedEntity(field) {
    // MANDATORY: ANY array with object items
    if (field.type === "array" && field.items && field.items.type === "object") {
        return true;
    }
    
    // MANDATORY: ANY array with properties in items
    if (field.type === "array" && field.items && field.items.properties && 
        Object.keys(field.items.properties).length > 0) {
        return true;
    }
    
    // MANDATORY: ANY array with nested objects
    if (field.type === "array" && hasNestedObjects(field.items)) {
        return true;
    }
    
    return false;
}
```

### Step 3.2: Business Entity Pattern Validation

**Common entities that MUST have complex arrays:**
```javascript
const mandatoryComplexArrays = {
    "Route": ["stops", "waypoints", "segments"],
    "Order": ["items", "payments", "addresses"],
    "User": ["profiles", "preferences", "contacts"],
    "Product": ["variants", "categories", "attributes"],
    "Invoice": ["lineItems", "payments", "addresses"],
    "Document": ["sections", "attachments", "comments"],
    "Course": ["lessons", "assignments", "resources"],
    "Event": ["attendees", "sessions", "resources"]
};

function validateBusinessEntityArrays(entity) {
    const expectedArrays = mandatoryComplexArrays[entity.name] || [];
    const warnings = [];
    
    for (const expectedArray of expectedArrays) {
        const hasArrayField = entity.fields.some(field => 
            field.name.toLowerCase().includes(expectedArray.toLowerCase())
        );
        
        if (!hasArrayField) {
            warnings.push(`MISSING COMPLEX ARRAY: Entity '${entity.name}' missing '${expectedArray}' field`);
        }
    }
    
    return warnings;
}
```

### Step 4: Cardinality Assignment Decision Tree

```
IF field is required AND can have multiple values → use [1..*]
IF field is optional AND can have multiple values → use [0..*]
IF field is required AND single value → use * prefix with EntityName (no brackets)
IF field is optional AND single value → use - prefix with EntityName (no brackets)
IF field has specific limits → use [min..max] (e.g., [1..5], [0..3])
```

## Step-by-Step AI Process

### Step 1: Analyze Input Schema
```
1. Identify database type (SQL/MongoDB/Other)
2. List all tables/collections
3. Identify all relationships between entities
4. Group related entities into modules
5. For each entity:
   - List all fields
   - Identify data types
   - Note constraints
   - Find relationships
```

### Step 1.5: Create Relationships Definition Section
Before documenting individual entities, create a comprehensive relationships overview:

```
1. Identify all entity-to-entity relationships
2. Classify relationship types:
   - One-to-One (1:1)
   - One-to-Many (1:M) 
   - Many-to-Many (M:N)
   - Inheritance
   - Composition vs Aggregation
3. Document junction tables for M:N relationships
4. Specify relationship nature (composition, aggregation, association)
5. Create parsable relationship definitions section
```

#### Relationship Classification Logic:
```
IF parent entity controls child lifecycle → composition
ELIF child can exist independently → aggregation
ELIF entities share attributes/behavior → inheritance
ELIF temporary/usage relationship → dependency
ELSE → association
```

### Step 2: Apply Decision Framework

#### For Each Field, Ask:
1. **Is it required?** → Use `*` prefix
2. **Is it optional?** → Use `-` prefix  
3. **Is it system-generated?** → Use `_` prefix
4. **Is it indexed?** → Add `@` marker
5. **Is it unique?** → Add `!` marker
6. **Contains sensitive data?** → Add `~` or `#` marker

#### For Data Types, Ask:
1. **What's the source type?** → Use mapping table
2. **Does it have constraints?** → Add length/precision
3. **Is it an array/collection?** → Use Array<Type>
4. **Is it a nested object?** → Use JSON with structure

### Step 3: Structure Documentation

#### Module Organization Logic:
```
IF entities relate to users/accounts → "User Management"
ELIF entities relate to core business → "Core Business Logic"  
ELIF entities relate to config/settings → "Configuration"
ELIF entities relate to files/media → "File Management"
ELIF entities relate to audit/logs → "Audit & Logging"
ELSE group by business domain
```

### Step 4: Validate Output

#### Validation Checklist:
- [ ] Every entity has a primary key marked with `*`
- [ ] All relationships are documented
- [ ] Field types are consistent
- [ ] Required fields use `*`, optional use `-`
- [ ] System fields use `_`
- [ ] Indexes are marked with `@`
- [ ] Constraints are documented in `[brackets]`

## AI Processing Algorithms

### Field Prefix Determination
```python
def get_field_prefix(field_info):
    """Simplified field prefix logic - only core prefixes"""
    if field_info.is_primary_key:
        return "*"
    elif field_info.is_required or field_info.not_null:
        return "*"
    elif field_info.is_indexed:
        return "@"
    elif field_info.is_encrypted or field_info.is_sensitive:
        return "#"
    else:
        return "-"  # default to optional

def get_field_constraints(field_info):
    """Extract constraint annotations for special field types"""
    constraints = []
    
    # Add existing constraints
    if field_info.constraints:
        constraints.extend(field_info.constraints)
    
    # Add special annotations
    if field_info.is_auto_generated or field_info.is_system:
        constraints.append("SYSTEM")
    elif field_info.is_computed or field_info.is_calculated:
        constraints.append("COMPUTED")
    
    if field_info.is_unique:
        constraints.append("UK")
    if field_info.is_deprecated:
        constraints.append("DEPRECATED")
    if field_info.is_derived:
        constraints.append("DERIVED")
    if field_info.is_audited:
        constraints.append("AUDIT")
    if field_info.is_cached:
        constraints.append("CACHED")
    if field_info.is_immutable:
        constraints.append("IMMUTABLE")
    if field_info.is_replicated:
        constraints.append("REPLICATE")
    if field_info.is_compressed:
        constraints.append("COMPRESS")
    if field_info.is_partitioned:
        constraints.append("PARTITION")
    if field_info.is_federated:
        constraints.append("FEDERATED")
    
    return constraints
```

### Embedded Entity Conversion Logic
```python
def should_convert_to_embedded_entity(field_info):
    """Determine if field should be converted to embedded entity - PREFER embedded entities over JSON"""
    if field_info.type == "Array<JSON>":
        # Convert ALL complex arrays to embedded entities
        json_properties = count_json_properties(field_info)
        return json_properties > 0  # Convert any structured array
    elif field_info.type == "JSON":
        json_properties = count_json_properties(field_info)
        has_nested_objects = has_nested_json_objects(field_info)
        
        # Convert if >2 properties OR has nested objects OR mixed types
        if json_properties > 2 or has_nested_objects or has_mixed_data_types(field_info):
            return True
        
        # Keep only simple configuration objects as JSON
        return not is_simple_config_object(field_info)
    elif is_business_entity(field_info.name):
        return True
    elif is_reusable_structure(field_info):
        return True
    else:
        return False

def is_simple_config_object(field_info):
    """Check if JSON object is simple configuration (≤2 primitive properties)"""
    if field_info.type != "JSON":
        return False
    
    properties = count_json_properties(field_info)
    if properties > 2:
        return False
    
    # All properties must be primitive types
    for prop in field_info.json_structure:
        if prop.type in ["JSON", "Array", "Object"]:
            return False
    
    return True

def has_nested_json_objects(field_info):
    """Check if JSON contains nested objects"""
    if field_info.type != "JSON":
        return False
        
    for prop in field_info.json_structure:
        if prop.type in ["JSON", "Object"]:
            return True
    
    return False

def has_mixed_data_types(field_info):
    """Check if JSON has complex mix of data types"""
    if field_info.type != "JSON":
        return False
    
    types_found = set()
    for prop in field_info.json_structure:
        types_found.add(prop.type)
    
    # Consider mixed if has more than 2 different types
    return len(types_found) > 2
```

### Cardinality Determination
```python
def determine_cardinality(field_info):
    """Determine appropriate cardinality for embedded entity relationship"""
    is_required = field_info.is_required or field_info.prefix == "*"
    is_array = field_info.type.startswith("Array")
    is_single = not is_array
    has_limits = field_info.has_size_constraints()
    
    if has_limits:
        min_val = field_info.min_size or (1 if is_required else 0)
        max_val = field_info.max_size or "*"
        return f"[{min_val}..{max_val}]"
    elif is_array:
        return "[1..*]" if is_required else "[0..*]"
    elif is_single:
        return ""  # Single entities don't need cardinality brackets - use field prefix instead
    else:
        return "[0..*]"  # default fallback
```

### Database Type Recognition
```python
def identify_database_type(schema_text):
    """Identify database type from input schema"""
    if "CREATE TABLE" in schema_text or "ALTER TABLE" in schema_text:
        return "SQL"
    elif "ObjectId" in schema_text or "db.collection" in schema_text:
        return "MongoDB"
    elif "PRIMARY KEY" in schema_text:
        return "SQL"
    elif "HIERARCHYID" in schema_text or "ROWVERSION" in schema_text:
        return "SQL_Server"
    elif "JSONB" in schema_text or "ARRAY[]" in schema_text:
        return "PostgreSQL"
    elif "NUMBER" in schema_text or "CLOB" in schema_text:
        return "Oracle"
    elif "AUTO_INCREMENT" in schema_text and "ENGINE=" in schema_text:
        return "MySQL"
    else:
        return analyze_field_patterns(schema_text)

def analyze_field_patterns(schema_text):
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
        scores[db_type] = sum(1 for pattern in pattern_list if pattern in schema_text)
    
    return max(scores, key=scores.get) if max(scores.values()) > 0 else "Generic_SQL"
```

### Relationship Processing
```python
def generate_relationships_definition(parsed_schema):
    """Generate relationships definition section"""
    relationships = []
    
    # Group relationships by type
    one_to_one = filter_relationships(parsed_schema.relationships, "1:1")
    one_to_many = filter_relationships(parsed_schema.relationships, "1:M")
    many_to_many = filter_relationships(parsed_schema.relationships, "M:N")
    inheritance = filter_relationships(parsed_schema.relationships, "inheritance")
    
    # Generate relationship definitions
    relationships.append("=== RELATIONSHIP DEFINITIONS ===")
    
    if one_to_one:
        relationships.append("# One-to-One Relationships")
        for rel in one_to_one:
            nature = determine_relationship_nature(rel)
            relationships.append(f"{rel.parent} -> {rel.child} [1:1] ({nature})")
    
    if one_to_many:
        relationships.append("# One-to-Many Relationships")
        for rel in one_to_many:
            nature = determine_relationship_nature(rel)
            relationships.append(f"{rel.parent} -> {rel.child} [1:M] ({nature})")
    
    if many_to_many:
        relationships.append("# Many-to-Many Relationships")
        for rel in many_to_many:
            junction = find_junction_table(rel)
            relationships.append(f"{rel.parent} -> {rel.child} [M:N] (association) via {junction}")
    
    if inheritance:
        relationships.append("# Inheritance Relationships")
        for rel in inheritance:
            relationships.append(f"{rel.parent} -> {rel.child} [inheritance]")
    
    return '\n'.join(relationships)

def determine_relationship_nature(relationship):
    """Determine if relationship is composition, aggregation, or association"""
    if relationship.cascade_delete:
        return "composition"
    elif relationship.optional_child:
        return "aggregation"
    else:
        return "association"
```

## Complete AI Workflow

### Input → Output Process:

1. **Parse Input**
   ```python
   def parse_input(schema_text):
       database_type = identify_database_type(schema_text)
       entities = extract_entities(schema_text)
       fields = extract_fields(schema_text)
       constraints = extract_constraints(schema_text)
       relationships = extract_relationships(schema_text)
       return ParsedSchema(database_type, entities, fields, constraints, relationships)
   ```

2. **Apply Rules**
   ```python
   def apply_transformation_rules(parsed_schema):
       for entity in parsed_schema.entities:
           entity.fields = [transform_field(f, parsed_schema.database_type) 
                           for f in entity.fields]
           entity.constraints = transform_constraints(entity.constraints)
           entity.relationships = transform_relationships(entity.relationships)
       return parsed_schema
   ```

3. **Structure Output**
   ```python
   def structure_output(transformed_schema):
       output = []
       output.append(generate_header(transformed_schema))
       
       # Add relationships definition section
       relationships_def = generate_relationships_definition(transformed_schema)
       if relationships_def:
           output.append(relationships_def)
           output.append("")  # Add blank line
       
       # Add schema definition
       output.append("=== DATABASE SCHEMA ===")
       module_list = generate_module_list(transformed_schema.entities)
       output.append(module_list)
       
       for module in group_into_modules(transformed_schema.entities):
           output.append(generate_module_header(module))
           for entity in module.entities:
               output.append(generate_entity_definition(entity))
           output.append(generate_relationships_section(module))
       
       return '\n'.join(output)
   ```

4. **Validate**
   ```python
   def validate_output(output_text):
       entities = parse_dbsoup(output_text)
       all_errors = []
       all_warnings = []
       
       # Validate relationships definition section
       relationships_errors = validate_relationships_definition(output_text)
       all_errors.extend(relationships_errors)
       
       for entity in entities:
           errors, warnings = validate_entity(entity)
           all_errors.extend(errors)
           all_warnings.extend(warnings)
       
       if all_errors:
           raise ValidationError(all_errors)
       
       return all_warnings
   ```

5. **Format**
   ```python
   def format_output(validated_text):
       lines = validated_text.split('\n')
       formatted_lines = []
       
       for line in lines:
           if line.startswith('==='):
               formatted_lines.append(line)
           elif line.startswith('# '):
               formatted_lines.append(line)
           elif line.startswith('* ') or line.startswith('- ') or line.startswith('@ '):
               formatted_lines.append(line)
           else:
               formatted_lines.append(line)
       
       return '\n'.join(formatted_lines)
   ```

## AI Self-Validation Rules

### Entity Validation
```python
def validate_entity(entity):
    errors = []
    warnings = []
    
    # Check for primary key
    primary_keys = [f for f in entity.fields if f.prefix == "*" and "[PK]" in f.constraints]
    if not primary_keys:
        errors.append("Missing primary key")
    elif len(primary_keys) > 1:
        warnings.append("Multiple primary keys found - check if composite key intended")
    
    # Check relationship documentation
    foreign_keys = [f for f in entity.fields if "[FK:" in str(f.constraints)]
    if foreign_keys and not entity.relationships:
        errors.append("Foreign keys found but relationships not documented")
    
    # Check for system fields
    system_fields = [f for f in entity.fields if f.prefix == "_"]
    if not system_fields:
        warnings.append("No system fields found - consider adding created_at/updated_at")
    
    # Check for security fields
    sensitive_fields = [f for f in entity.fields if f.prefix in ["#", "~", "$"]]
    if sensitive_fields and not has_audit_trail(entity):
        warnings.append("Sensitive fields found but no audit trail")
    
    # Check for performance fields
    indexed_fields = [f for f in entity.fields if f.prefix == "@"]
    if not indexed_fields:
        warnings.append("No indexed fields found - consider performance implications")
    
    # Check for complex JSON that should be embedded entities
    complex_json_fields = [f for f in entity.fields if should_be_embedded_entity(f)]
    if complex_json_fields:
        errors.append(f"Complex JSON fields found that MUST be embedded entities: {[f.name for f in complex_json_fields]}")
    
    # Check for proper embedded entity relationships
    relationship_fields = [f for f in entity.fields if has_relationship_array_notation(f)]
    for field in relationship_fields:
        if not has_corresponding_embedded_entity(field, entity.module):
            errors.append(f"Relationship field {field.name} references missing embedded entity")
    
    # Check for JSON usage - should only be simple configuration objects
    json_fields = [f for f in entity.fields if f.type == "JSON"]
    for field in json_fields:
        if not is_simple_config_object(field):
            errors.append(f"JSON field {field.name} is too complex and should be converted to embedded entity")
    
    # Check MongoDB specific validations
    if entity.database_type == "MongoDB":
        objectid_fields = [f for f in entity.fields if f.type == "ObjectId"]
        if not objectid_fields:
            warnings.append("MongoDB collection without ObjectId field")
        
        validation_fields = [f for f in entity.fields if "[VALIDATE:" in str(f.constraints)]
        if not validation_fields:
            warnings.append("MongoDB collection without validation rules")
    
    return errors, warnings
```

### Relationship Validation
```python
def validate_relationships_definition(output_text):
    """Validate the relationships definition section"""
    errors = []
    
    # Check if relationships section exists
    if "=== RELATIONSHIP DEFINITIONS ===" not in output_text:
        errors.append("Missing relationships definition section")
        return errors
    
    # Extract relationships section
    lines = output_text.split('\n')
    in_relationships_section = False
    relationship_lines = []
    
    for line in lines:
        if line.strip() == "=== RELATIONSHIP DEFINITIONS ===":
            in_relationships_section = True
            continue
        elif line.strip().startswith("=== ") and in_relationships_section:
            break
        elif in_relationships_section:
            relationship_lines.append(line)
    
    # Validate relationship syntax
    for line in relationship_lines:
        line = line.strip()
        if line and not line.startswith('#') and '->' in line:
            if not validate_relationship_syntax(line):
                errors.append(f"Invalid relationship syntax: {line}")
    
    return errors

def validate_relationship_syntax(line):
    """Validate individual relationship line syntax"""
    import re
    # Pattern: Entity -> Entity [cardinality] (nature) via JunctionTable
    pattern = r'^[A-Z]\w*\s*->\s*[A-Z]\w*\s*\[(1:1|1:M|M:N|inheritance|composition|aggregation)\](\s*\([^)]+\))?(\s*via\s*[A-Z]\w*)?$'
    return re.match(pattern, line) is not None
```

### Error Prevention for AI

#### Common AI Mistakes to Avoid:

1. **Wrong Prefixes**
   - ❌ Using `-` for primary keys
   - ✅ Always use `*` for primary keys
   - ❌ Using `*` for nullable fields
   - ✅ Use `-` for optional fields

2. **Missing Relationships**
   - ❌ Not documenting foreign keys
   - ✅ Always add relationship section
   - ❌ Missing cardinality information
   - ✅ Specify relationship type (1:1, 1:M, M:N)

3. **Inconsistent Types**
   - ❌ Mixing `String` and `Text` randomly
   - ✅ Use mapping rules consistently
   - ❌ Wrong MongoDB type mappings
   - ✅ Use ObjectId for MongoDB IDs

4. **Missing Constraints**
   - ❌ Ignoring indexes and unique constraints
   - ✅ Document all constraints in brackets
   - ❌ Missing default values
   - ✅ Document defaults with [DEFAULT:value]

5. **Incomplete Enterprise Features**
   - ❌ Ignoring security annotations
   - ✅ Document encryption with # prefix
   - ❌ Missing audit trails
   - ✅ Document audit with $ prefix

6. **Performance Oversights**
   - ❌ Not documenting critical indexes
   - ✅ Mark performance-critical fields with @
   - ❌ Missing partitioning information
   - ✅ Document partitioning with > prefix

## Example AI Processing Walk-Through

### Input Recognition:
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_active_users (is_active, created_at)
);
```

### AI Processing Logic:
1. **Recognize**: SQL table named "users"
2. **Identify fields**: id, username, email, password_hash, created_at, updated_at, is_active
3. **Apply rules**: 
   - id: PRIMARY KEY → `* _id : UUID [PK]`
   - username: NOT NULL + UNIQUE + INDEX → `* ! username : String(50) [UK,IX]`
   - email: NOT NULL + INDEX → `* ! email : String(100) [IX]`
   - password_hash: NOT NULL + sensitive → `@ password_hash : String(255) [ENCRYPTED]`
   - created_at: DEFAULT + system → `- created_at : DateTime [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]`
   - updated_at: system field → `- updated_at : DateTime [SYSTEM]`
   - is_active: DEFAULT + INDEX → `! is_active : Boolean [IX,DEFAULT:true]`

### AI Output:
```dbsoup
User
==========
* _id            : UUID                      [PK]
* ! username     : String(50)               [UK,IX]
* ! email        : String(100)              [IX]
@ password_hash  : String(255)              [ENCRYPTED]
- created_at     : DateTime                  [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]
- updated_at     : DateTime                  [SYSTEM]
! is_active      : Boolean                   [IX,DEFAULT:true]
```

## Performance Optimization for AI Processing

### Batch Processing Strategy
```python
def process_schema_batch(schema_files):
    """Process multiple schema files efficiently"""
    results = []
    
    # Pre-analyze all files to determine processing order
    file_analysis = [analyze_schema_complexity(f) for f in schema_files]
    
    # Sort by complexity (simple first)
    sorted_files = sorted(zip(schema_files, file_analysis), key=lambda x: x[1].complexity)
    
    for file_path, analysis in sorted_files:
        try:
            result = process_single_schema(file_path, analysis)
            results.append(result)
        except Exception as e:
            results.append(ErrorResult(file_path, str(e)))
    
    return results

def analyze_schema_complexity(schema_file):
    """Analyze schema complexity for processing optimization"""
    with open(schema_file, 'r') as f:
        content = f.read()
    
    complexity_score = 0
    complexity_score += content.count('CREATE TABLE') * 2
    complexity_score += content.count('FOREIGN KEY') * 3
    complexity_score += content.count('INDEX') * 1
    complexity_score += content.count('JSON') * 4
    complexity_score += content.count('ARRAY') * 3
    
    return ComplexityAnalysis(
        file_path=schema_file,
        complexity=complexity_score,
        entity_count=content.count('CREATE TABLE'),
        relationship_count=content.count('FOREIGN KEY'),
        has_complex_types=('JSON' in content or 'ARRAY' in content)
    )
```

This comprehensive AI decision framework provides systematic processing logic while maintaining the accuracy and completeness required for DBSoup conversion. 
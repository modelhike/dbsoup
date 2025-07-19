# DBSoup SVG Color Reference Guide

## Overview
This guide provides a complete reference for all color codes used in DBSoup SVG diagrams, including field types, entity styles, and embedded entity highlighting.

## ✨ Color Consistency Update (v2.0)
**Important**: As of the latest update, **embedded entity fields now use the same colors as standard entity fields** for better visual consistency. This eliminates the previous purple-tinted color scheme for embedded entities, making the diagram easier to read and understand.

**Key Changes:**
- Optional fields (`-` prefix) are now **gray** in both standard and embedded entities (was purple in embedded entities)
- Required fields (`*` prefix) use the **same orange** shade in both entity types
- **Embedded entity references** now use **consistent bright yellow** regardless of context (was darker yellow for embedded→embedded references)
- All field types maintain consistent colors regardless of entity type

## Entity Type Colors

### Standard Entities
- **Background**: Dark gradient (#1a1a1a to #2d2d2d)
- **Header**: Blue gradient (#4a90e2 to #357abd)
- **Border**: Solid gray (#444444)
- **Title**: White text, regular font (16px)

### Embedded Entities
- **Background**: Brown/purple gradient (#2c1810 to #3d221a)
- **Header**: Purple gradient (#8e44ad to #6c3483)
- **Border**: Purple dashed (#8e44ad, stroke-dasharray: 8,4)
- **Title**: White text, italic font (15px)

### Relationship Legend
- **Background**: Dark blue-gray gradient (#2c3e50 to #34495e)
- **Header**: Red gradient (#e74c3c to #c0392b)
- **Border**: Dashed blue-gray (#34495e, stroke-dasharray: 8,4)
- **Title**: White text, bold font (14px)
- **Text**: Light gray text (#ecf0f1, 11px) with strong shadows

## Field Type Colors

### Standard Entity Fields
| Field Type | Color | Hex Code | Usage |
|------------|-------|----------|-------|
| **Required** | Orange | `#ffa502` | Fields with `*` prefix |
| **Optional** | Gray | `#c7c7c7` | Fields with `-` prefix |
| **Indexed** | Blue | `#5352ed` | Fields with `!` prefix |
| **Sensitive** | Red | `#ff4757` | Fields with `@` prefix |
| **Foreign Key** | Purple | `#e056fd` | Fields with `[FK:...]` constraint **[Clickable]** |
| **🆕 Embedded Entity Reference** | **Bright Yellow** | `#ffeb3b` | Standard entity fields referencing embedded entities **[Clickable]** |

### Embedded Entity Fields
| Field Type | Color | Hex Code | Usage |
|------------|-------|----------|-------|
| **Required** | Orange | `#ffa502` | Fields with `*` prefix (same as standard) |
| **Optional** | Gray | `#c7c7c7` | Fields with `-` prefix (same as standard) |
| **Indexed** | Blue | `#5352ed` | Fields with `!` prefix (same as standard) |
| **Sensitive** | Red | `#ff4757` | Fields with `@` prefix (same as standard) |
| **Foreign Key** | Purple | `#e056fd` | Fields with `[FK:...]` constraint **[Clickable]** (same as standard) |
| **🆕 Embedded Entity Reference** | **Bright Yellow** | `#ffeb3b` | Embedded entity fields referencing embedded entities **[Clickable]** (same as standard) |

## Embedded Entity Reference Color Logic
- **Bright Yellow (#ffeb3b)**: All embedded entity references use the same bright yellow color for consistency
  - Standard entity → embedded entity references  
  - Embedded entity → embedded entity references

## Color Priority System
When multiple attributes apply to a field, colors are assigned in this priority order:

1. **Embedded Entity Reference** (Bright Yellow) - Highest priority
2. **Foreign Key** (Purple)
3. **Sensitive** (Red)
4. **Required** (Orange)
5. **Indexed** (Blue)
6. **Optional** (Gray) - Lowest priority

## Visual Examples

### Standard Entity Example
```
User
====
* _id        : ObjectId     [PK]           # Orange (required)
- email      : String       [UK]           # Gray (optional)
! name       : String       [IX]           # Blue (indexed)
@ password   : String       [ENCRYPTED]    # Red (sensitive)
- profile_id : ObjectId     [FK:Profile.id] # Purple (foreign key)
- address    : Address                     # ✨ Bright Yellow (#ffeb3b) - standard entity → embedded entity
```

### Embedded Entity Example
```
Address
/=======/
* _id        : ObjectId     [PK]           # Orange (required, same shade as standard)
- street     : String                      # Gray (optional, same as standard)
! city       : String       [IX]           # Blue (indexed, same as standard)
- contact    : ContactInfo                 # ✨ Bright Yellow (#ffeb3b) - embedded entity → embedded entity (same as standard)
```

## Usage Guidelines

### When Colors Are Applied
- **Embedded Entity Reference**: Automatically detected when field type matches an embedded entity name
  - **Bright Yellow**: All embedded entity references use consistent bright yellow color
    - Standard entity field → embedded entity (e.g., `User.address: Address`)
    - Embedded entity field → embedded entity (e.g., `Address.contact: ContactInfo`)
  - **Interactive**: Embedded entity fields are clickable hyperlinks that navigate to referenced entities
  - **Format Detection**: Automatically analyzes field data type to create `<a href="#EntityName">` links
- **Foreign Key**: When field has `[FK:Entity.field]` constraint
  - **Interactive**: Foreign key fields are clickable hyperlinks that navigate to referenced entities
  - **Format Detection**: Automatically parses `[FK:EntityName.fieldName]` to create `<a href="#EntityName">` links
- **Sensitive**: When field has `@` prefix (for passwords, tokens, etc.)
- **Required**: When field has `*` prefix
- **Indexed**: When field has `!` prefix
- **Optional**: When field has `-` prefix (default fallback)

### Color Accessibility
- All colors have sufficient contrast against dark backgrounds
- Yellow highlighting ensures embedded entity references are immediately visible
  - Consistent bright yellow (#ffeb3b) for all embedded entity references
- Consistent coloring across all entity types maintains clear visual hierarchy
- **Relationship legend has dark background** that's visible on any background color
- **High contrast text** with shadows ensures readability on all backgrounds
- Consistent color scheme across all entity types

## Interactive Navigation Features

### Alphabetical Entity Sorting
- **Entities are automatically sorted alphabetically** for easy scanning and navigation
- Example order: `Account → ApiAuth → BlobInfo → ... → UserPref`
- Makes it easier to find specific entities in large schemas

### Clickable Foreign Key Navigation
- **Foreign key fields are clickable hyperlinks** that navigate to referenced entities
- **Link Format**: `<a href="#EntityName">field_name</a>`
- **Target Format**: Each entity has an HTML ID: `<g id="EntityName">`
- **Detection**: Automatically detects `[FK:EntityName.fieldName]` constraint format
- **Color**: Foreign key fields maintain their purple color scheme while being clickable

### Entity IDs
- **Every entity has an HTML ID** for direct navigation
- **Format**: `id="EntityName"` on the entity's SVG group element
- **Usage**: Allows direct linking to specific entities (e.g., `diagram.svg#User`)
- **Navigation**: Enables foreign key links to jump directly to referenced entities

### Clickable Relationship Legend
- **Entity names in the relationship legend are clickable** and navigate to their definitions
- **From Entity** and **To Entity** columns contain clickable entity names
- **Navigation**: Click any entity name in the legend to jump to that entity
- **Display**: Shows all relationships defined in the schema with their cardinality types

### Interactive Examples
```
# Foreign key and embedded entity navigation
User
====
- profile_id : ObjectId     [FK:Profile.id]    # Purple, clickable → jumps to Profile entity
- address    : Address                         # Yellow, clickable → jumps to Address embedded entity

# Target entity with ID
Profile
=======
* _id        : ObjectId     [PK]              # Entity has id="Profile" for navigation

# Target embedded entity with ID
Address
/======/
* _id        : ObjectId     [PK]              # Entity has id="Address" for navigation
- street     : String
- city       : String
- contact    : ContactInfo                    # Bright yellow, clickable → jumps to ContactInfo
```

## Implementation Notes
- Colors are defined in SVG CSS classes for easy customization
- **Field colors are now consistent** across standard and embedded entities for improved readability
- **Entity box styling remains distinct** (embedded entities keep their purple-themed borders and headers for visual differentiation)

## Migration Summary (v2.0)
The color consistency update ensures that field meanings are immediately clear regardless of entity type:

**Before**: Embedded entities used purple-tinted colors that differed from standard entities
**After**: All field types use identical colors in both standard and embedded entities

This change improves diagram readability and eliminates confusion about field semantics based on entity type.
- Embedded entity field detection includes cross-reference validation for accurate hyperlink generation
- Colors are applied through CSS classes in the generated SVG output
- **SVG is fully zoomable** - includes width/height attributes + viewBox + preserveAspectRatio
- **Scalable CSS** ensures proper zooming behavior in all browsers
- **Background colors are configurable** - blue-grey (default), transparent, light grey, warm grey, or custom
- **Default blue-grey background** provides professional appearance with excellent contrast
- **Grey backgrounds enhance contrast** - dark entities stand out more against light backgrounds
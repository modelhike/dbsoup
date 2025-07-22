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
| **Foreign Key** | Purple | `#e056fd` | Fields with `[FK:...]` constraint **[Clickable + Instant Tooltip]** |
| **🆕 Embedded Entity Reference** | **Bright Yellow** | `#ffeb3b` | Standard entity fields referencing embedded entities **[Clickable + Instant Tooltip]** |

## 🏷️ Attribute Tag Colors

The DBSoup SVG generator displays field constraints as compact, color-coded attribute tags next to field names. Each constraint type has its own distinct color scheme:

### Attribute Tag Color Palette
| Tag Type | Background | Border | Text Color | Usage |
|----------|------------|--------|------------|-------|
| **Foreign Key** | `#8e24aa` | `#8e24aa` | `#cccccc` | `[FK:Entity.field]` constraints **[Clickable]** - muted gray text on dark purple for subtle professional appearance |
| **App/JSON** | `rgba(46, 204, 113, 0.8)` | `#27ae60` | `#ffffff` | `[app:field]`, `[json:field]` field mapping constraints - white text on solid green for maximum legibility |
| **Enum** | `rgba(41, 128, 185, 0.15)` | `#2980b9` | `#2980b9` | `[ENUM:values]` constraints **[Hover Tooltip]** |
| **System** | `rgba(52, 73, 94, 0.15)` | `#34495e` | `#999999` | `[SYSTEM]`, `[AUTO]` constraints (except CURRENT_TIMESTAMP) |
| **Encrypted** | `rgba(255, 71, 87, 0.15)` | `#ff4757` | `#c0392b` | `[ENCRYPTED]` constraints |
| **Default** | `rgba(211, 84, 0, 0.15)` | `#d35400` | `#d35400` | `[DEFAULT:value]` constraints, including `• now` for CURRENT_TIMESTAMP |

### Attribute Tag Features
- **Compact Design**: Small, rounded tags (11px font, 12px height) that don't overwhelm field text
- **Smart Sizing**: Dynamic width based on content with 6px padding
- **Interactive Elements**: 
  - FK tags are clickable for navigation
  - Enum tags show hover tooltips with valid values
  - Default tags use special symbols (• for CURRENT_TIMESTAMP datetime fields)
- **Visual Hierarchy**: Tags complement field colors without conflicting

### Embedded Entity Fields
| Field Type | Color | Hex Code | Usage |
|------------|-------|----------|-------|
| **Required** | Orange | `#ffa502` | Fields with `*` prefix (same as standard) |
| **Optional** | Gray | `#c7c7c7` | Fields with `-` prefix (same as standard) |
| **Indexed** | Blue | `#5352ed` | Fields with `!` prefix (same as standard) |
| **Sensitive** | Red | `#ff4757` | Fields with `@` prefix (same as standard) |
| **Foreign Key** | Purple | `#e056fd` | Fields with `[FK:...]` constraint **[Clickable + Instant Tooltip]** (same as standard) |
| **🆕 Embedded Entity Reference** | **Bright Yellow** | `#ffeb3b` | Embedded entity fields referencing embedded entities **[Clickable + Instant Tooltip]** (same as standard) |

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

## 🎨 Color Legend Organization

The generated SVG diagrams include a comprehensive color legend organized into two distinct sections:

### Field Level Colors (Circle Swatches)
Displays the color coding for field prefixes and field types:
- **Required Fields** (Orange circle): Fields with `*` prefix
- **Optional Fields** (Gray circle): Fields with `-` prefix  
- **Indexed Fields** (Blue circle): Fields with `!` prefix
- **Sensitive Fields** (Red circle): Fields with `@` prefix
- **Foreign Key Fields** (Purple circle): Fields with `[FK:...]` constraint
- **Embedded Entity References** (Yellow circle): Fields referencing embedded entities

### Field Attribute Colors (Rectangle Swatches)
Displays the color coding for attribute tags that appear next to fields:
- **Foreign Key Attributes** (Dark purple rectangle with muted gray text): `[fk - EntityName]` tags with subtle professional appearance
- **App/JSON Attributes** (Solid green rectangle with white text): `[app: field]`, `[json: field]` field mapping tags with maximum legibility
- **Enum Attributes** (Blue rectangle): `[enum]` tags with hover tooltips
- **System Attributes** (Dark gray rectangle): `[• now]`, `[auto]`, `[sys]` tags
- **Encrypted Attributes** (Red rectangle): `[encrypted]` tags
- **Default Value Attributes** (Orange rectangle): `[default]` tags

### Legend Visual Design
- **Professional Headers**: "Field Level Colors" and "Field Attribute Colors" in dark gray (#666666)
- **Clear Differentiation**: Circles for field-level, rectangles for attribute-level
- **Consistent Spacing**: Proper alignment and spacing between legend items
- **Comprehensive Coverage**: All color codes used in the diagram are documented

## Implementation Notes
- Colors are defined in SVG CSS classes for easy customization
- **Field colors are now consistent** across standard and embedded entities for improved readability
- **Entity box styling remains distinct** (embedded entities keep their purple-themed borders and headers for visual differentiation)
- **Dual-purpose color legend** separates field-level and attribute-level color meanings for clarity

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

---

### Related Documentation
For complete information about **instant hover tooltips**, **clickable navigation**, and other interactive features, see:
- 🎨 **[SVG Interactive Features Guide](10_SVG_INTERACTIVE_FEATURES.md)** - Comprehensive guide to all interactive SVG features including instant tooltips
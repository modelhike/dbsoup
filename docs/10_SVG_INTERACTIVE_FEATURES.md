# DBSoup SVG Interactive Features Guide

## Overview
This guide covers the interactive and navigation features of DBSoup SVG diagrams, including alphabetical sorting, clickable foreign key navigation, and enhanced visual styling.

## 🔤 Alphabetical Entity Sorting

### Feature Description
- **All entities are automatically sorted alphabetically** for easy scanning and navigation
- Improves usability in large schemas with many entities
- Makes it easier to locate specific entities quickly

### Example Order
```
Account → ApiAuth → BlobInfo → Driver → Route → Stop → Team → User → UserPref
```

### Benefits
- **Predictable Layout**: Entities always appear in the same order
- **Easy Scanning**: Developers can quickly find entities by name
- **Consistent Experience**: Same layout across different schema versions

## 🔗 Clickable Navigation

### Feature Description
- **Foreign key fields are clickable hyperlinks** that navigate directly to referenced entities
- **Embedded entity fields are clickable hyperlinks** that navigate directly to embedded entities
- Automatically detects `[FK:EntityName.fieldName]` constraint format for foreign keys
- Automatically detects embedded entity references by field data type
- Generates `<a href="#EntityName">` links for seamless navigation

### Technical Implementation
- **Link Format**: `<a href="#EntityName">field_name</a>`
- **Target Format**: Each entity has an HTML ID: `<g id="EntityName">`
- **Foreign Key Detection**: Parses `[FK:EntityName.fieldName]` constraints
- **Embedded Entity Detection**: Analyzes field data type against embedded entity names
- **Color Preservation**: Maintains purple (FK) and yellow (embedded) color schemes while being clickable

### Examples

#### Foreign Key Navigation
```dbsoup
# Source entity with foreign key
User
====
* _id        : ObjectId     [PK]
- profile_id : ObjectId     [FK:Profile.id]    # Purple, clickable → jumps to Profile
- team_id    : ObjectId     [FK:Team.id]       # Purple, clickable → jumps to Team

# Target entity with navigation ID
Profile
=======
* _id        : ObjectId     [PK]              # Entity has id="Profile" for navigation
- name       : String
- settings   : JSON
```

#### Embedded Entity Navigation
```dbsoup
# Source entity with embedded entity field
Route
=====
* _id        : ObjectId     [PK]
- name       : String
- stops      : Stop [0..*]                    # Yellow, clickable → jumps to Stop embedded entity
- address    : Address                        # Yellow, clickable → jumps to Address embedded entity

# Target embedded entity with navigation ID
Stop
/====/
* _id        : ObjectId     [PK]              # Entity has id="Stop" for navigation
- name       : String
- location   : String
- addon      : StopAddOn                      # Bright yellow, clickable → jumps to StopAddOn

# Nested embedded entity
StopAddOn
/========/
* _id        : ObjectId     [PK]              # Entity has id="StopAddOn" for navigation
- type       : String
- details    : JSON
```

### Usage in Browser
1. **Click any foreign key field** (purple) to jump to the referenced entity
2. **Click any embedded entity field** (yellow) to jump to the embedded entity
3. **Use browser back button** to return to previous location
4. **Direct linking**: Use `diagram.svg#EntityName` for direct navigation

## 🎨 Enhanced Visual Styling

### Entity Type Distinction
- **Standard Entities**: Dark gradient background, blue header, solid gray border
- **Embedded Entities**: Brown/purple gradient background, purple header, dashed purple border
- **Relationship Legend**: Dark blue-gray gradient background, red header, dashed border

### Background Color Options
- **Blue-Grey (#ecf0f1)**: **Default**, professional look, complements the color scheme
- **Light Grey (#f5f5f5)**: Maximum contrast, entities really pop
- **Warm Grey (#f8f9fa)**: Clean, modern, perfect for documentation
- **Transparent**: No background, works with any page background
- **Custom Colors**: Any hex color code for specific branding needs

### Field Color Hierarchy
#### Standard Entity Fields
- **Embedded Entity Reference**: Bright Yellow (#ffeb3b) - Highest priority
- **Foreign Key**: Purple (#e056fd) **[Clickable]**
- **Sensitive**: Red (#ff4757)
- **Required**: Orange (#ffa502)
- **Indexed**: Blue (#5352ed)
- **Optional**: Gray (#c7c7c7) - Lowest priority

#### Embedded Entity Fields (Consistent with Standard)
- **Embedded Entity Reference**: Bright Yellow (#ffeb3b) **[Clickable]** - Highest priority
- **Foreign Key**: Purple (#e056fd) **[Clickable]** - same as standard
- **Sensitive**: Red (#ff4757) - same as standard  
- **Required**: Orange (#ffa502) - same as standard
- **Indexed**: Blue (#5352ed) - same as standard
- **Optional**: Gray (#c7c7c7) - Lowest priority, same as standard

## 🧭 Navigation Examples

### Large Schema Navigation
```
# In a schema with 23 entities, you can:
1. Scroll to find "User" (alphabetically sorted)
2. Click "profile_id" field (purple) to jump to "Profile" entity
3. Click "team_id" field (purple) to jump to "Team" entity
4. Click "address" field (yellow) to jump to "Address" embedded entity
5. Use browser back button to return to "User"
```

### Relationship Legend Navigation
- **Entity names in the relationship legend are clickable** and navigate to their respective entities
- The relationship legend displays all relationships defined in the schema
- **From Entity** and **To Entity** columns contain clickable entity names
- **Relationship** column shows the relationship type (1:1, 1:M, M:N, etc.)

### Example Relationship Legend
```
Relationships
=============
From Entity    To Entity     Relationship
User          → Profile      1:1 (composition)
Account       → User         1:M (composition)
Route         → Stop         1:M (composition)
```
All entity names in the "From Entity" and "To Entity" columns are clickable links.

### Direct Entity Access
```html
<!-- Direct URL navigation -->
<a href="roadwarrior.svg#User">Jump to User entity</a>
<a href="roadwarrior.svg#Profile">Jump to Profile entity</a>
<a href="roadwarrior.svg#Team">Jump to Team entity</a>
```

## 🚀 Benefits for Large Schemas

### Improved Usability
- **Quick Entity Location**: Alphabetical sorting makes entities predictable
- **Relationship Navigation**: Click foreign keys to explore entity relationships
- **Visual Hierarchy**: Color coding highlights important field types
- **Relationship Legend Visibility**: Dark background ensures readability on any background color

### Development Workflow
- **Schema Exploration**: Click through relationships to understand data flow
- **Documentation**: Interactive diagrams serve as living documentation
- **Code Review**: Easier to navigate complex schema changes

### Real-World Example
```
Roadwarrior Schema (23 entities):
- Start at "User" entity
- Click "profile_id" → jumps to "Profile" entity
- Click "team_id" → jumps to "Team" entity
- Click "account_id" → jumps to "Account" entity
- Navigate through entire schema via foreign key relationships
```

## 📊 Feature Summary

| Feature | Description | Benefit |
|---------|-------------|---------|
| **Alphabetical Sorting** | Entities sorted A-Z | Predictable layout, easy scanning |
| **Clickable Foreign Keys** | FK fields link to referenced entities | Interactive navigation |
| **Clickable Embedded Entities** | Embedded entity fields link to embedded entities | Complete interactive navigation |
| **Clickable Relationship Legend** | Entity names in relationship legend are clickable | Navigate through schema relationships |
| **Entity IDs** | HTML IDs for direct navigation | Deep linking support |
| **Color Hierarchy** | Priority-based field coloring | Visual importance indication |
| **Interactive Links** | Hyperlinks maintain styling | Seamless user experience |
| **Relationship Legend** | Dark background with high contrast | Visible on any background color |
| **Unlimited Zoom** | SVG can be zoomed beyond 100% | Detailed inspection of large schemas |
| **Background Colors** | Configurable background colors | Professional appearance and better contrast |

## 🔧 Technical Details

### SVG Structure
```html
<!-- Fully zoomable SVG configuration -->
<svg xmlns="http://www.w3.org/2000/svg" 
     width="800" 
     height="600" 
     viewBox="0 0 800 600"
     preserveAspectRatio="xMidYMid meet">
  <!-- Scalable CSS -->
  <style>
    svg { max-width: none !important; height: auto !important; }
  </style>
  
  <!-- Entity with ID for navigation -->
  <g id="User" class="entity-group">
    <!-- Entity content -->
    <text>
      <!-- Foreign key with clickable link -->
      <a href="#Profile">profile_id</a>
    </text>
  </g>
</svg>
```

### CSS Classes
- `.entity-group`: Container for each entity
- `.foreign-key-field`: Styling for foreign key fields
- `.embedded-entity-field`: Styling for embedded entity references
- `.clickable-link`: Styling for interactive links

### Browser Compatibility
- **Modern Browsers**: Full support for SVG hyperlinks and unlimited zooming
- **Mobile Devices**: Touch-friendly navigation with pinch-to-zoom
- **Print**: Links remain visible in printed versions
- **Zoom Support**: Can zoom beyond 100% in all major browsers

## 📋 Usage Guidelines

### Best Practices
1. **Use descriptive entity names** for better navigation
2. **Consistent FK constraint format**: `[FK:EntityName.fieldName]`
3. **Test navigation links** in browser after generation
4. **Consider entity organization** for optimal user experience

### Schema Organization
- **Group related entities** logically (alphabetical sorting will override)
- **Use clear naming conventions** for entities and fields
- **Document complex relationships** with appropriate constraints

## 🎯 Next Steps

### For Developers
1. **Generate SVG diagrams** with `dbsoup svg schema.dbsoup`
2. **Choose background color** for professional appearance
3. **Open in browser** to test interactive navigation
4. **Embed in documentation** for team reference
5. **Use for code reviews** to visualize schema changes

### For Documentation
1. **Link to specific entities** using `#EntityName` anchors
2. **Create navigation guides** for complex schemas
3. **Use as living documentation** that updates with schema changes
4. **Share interactive diagrams** with stakeholders

---

*This guide covers the enhanced interactive features of DBSoup SVG generation. For complete color reference, see [SVG Color Reference Guide](09_SVG_COLOR_REFERENCE.md).* 

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

### Relationship Legend Navigation
- **Entity names in the relationship legend are clickable** and navigate to their respective entities
- The relationship legend displays all relationships defined in the schema
- **From Entity** and **To Entity** columns contain clickable entity names
- **Relationship** column shows the relationship type (1:1, 1:M, M:N, etc.)

### Example Relationship Legend
```
Relationships
=============
From Entity    To Entity     Relationship
User          → Profile      1:1 (composition)
Account       → User         1:M (composition)
Route         → Stop         1:M (composition)
```
All entity names in the "From Entity" and "To Entity" columns are clickable links. 
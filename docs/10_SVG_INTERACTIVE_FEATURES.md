# DBSoup SVG Interactive Features Guide

## Overview
This guide covers the interactive and navigation features of DBSoup SVG diagrams, including alphabetical sorting, instant hover tooltips, clickable foreign key navigation, and enhanced visual styling.

## 🚀 Quick Feature Reference

### 📁 New: Module-Based Organization
- **Entities grouped by functional modules** with clear visual separation
- **Optional single-line module descriptions** provide context and purpose
- **Swimlane separators** between modules for easy scanning
- **Standard entities first, then embedded entities** within each module

### ⚡ Instant Hover Tooltips
- **0.1-second response time** - no more waiting for slow browser tooltips!  
- **Hover over purple FK fields** → entity name appears instantly
- **Hover over yellow embedded fields** → entity name appears instantly
- **Professional styling** with centered positioning and smart boundaries

### 🔗 Interactive Navigation  
- **Click purple FK fields** → jump directly to referenced entity
- **Click yellow embedded fields** → jump directly to embedded entity
- **Module-based sorting** for logical entity organization
- **Browser back button** support for easy navigation

## 📁 Module-Based Organization

### Feature Description
- **Entities are organized by functional modules** instead of simple alphabetical order
- **Optional single-line descriptions** provide concise context about each module's purpose
- **Visual separation** with subtle left border accents and swimlane separators
- **Logical grouping** that reflects the actual architecture of your system

### Module Structure
Each module displays:
1. **Module Header** - Left border accent with module name
2. **Module Description** - Optional explanatory text in smaller gray font
3. **Standard Entities** - Regular entities in alphabetical order
4. **Embedded Entities** - Embedded entities in alphabetical order (if any)
5. **Swimlane Separator** - Dashed line between modules

### Example Organization
```
📁 Core Module
   "Multi-tenant user and organization management..."
   ├── Account (standard entity)
   ├── Member (standard entity)
   ├── Org (standard entity)
   └── User (standard entity)
   
   - - - - - - (swimlane separator)
   
📁 Routes Module  
   "Route planning, scheduling, and optimization..."
   ├── Route (standard entity)
   ├── Schedule (standard entity)  
   ├── Site (standard entity)
   ├── Stop (embedded entity)
   └── StopAddOn (embedded entity)
```

### DBSoup File Format
Add optional single-line descriptions after module headers:

```dbsoup
=== Core ===
Multi-tenant user and organization management with account-based data segregation.

Account # Main account entity
==========
* _id : ObjectId [PK]
* Email : String [UK]
```

**Requirements:**
- **Single line only** - no multi-line descriptions 
- Must be concise and descriptive
- Appears immediately after module header

### Visual Design
- **Module Headers**: Thin blue left border (4px) with dark text
- **Module Descriptions**: Smaller gray text below module name
- **Swimlanes**: Dashed horizontal lines between modules
- **Entity Flow**: Standard entities → embedded entities within modules

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
1. **Hover over any foreign key field** (purple) for instant entity name tooltip
2. **Hover over any embedded entity field** (yellow) for instant entity name tooltip  
3. **Click any foreign key field** (purple) to jump to the referenced entity
4. **Click any embedded entity field** (yellow) to jump to the embedded entity
5. **Use browser back button** to return to previous location
6. **Direct linking**: Use `diagram.svg#EntityName` for direct navigation

## 🏷️ Attribute Tag Interactive System

### Feature Description
DBSoup SVG diagrams now include **compact, color-coded attribute tags** that display field constraints as interactive elements next to field names. These tags provide instant visual feedback and interactive functionality.

### Tag Types and Interactions

#### Foreign Key Tags (Purple)
- **Visual**: `[fk - EntityName]` with purple styling
- **Interactive**: Clickable navigation to referenced entity
- **Hover**: Instant tooltip showing entity name
- **Special**: Uses consistent font (11px) and minimal padding for compactness

#### Enum Constraint Tags (Blue)  
- **Visual**: `[enum]` with blue styling
- **Interactive**: Hover tooltip shows all valid enum values
- **Format**: "Valid values: value1, value2, value3"
- **Performance**: Instant 0.1s fade-in tooltip

#### System Attribute Tags (Dark Gray)
- **Visual**: Special symbols like `[• now]` for datetime fields
- **Features**: Uses bright dot (•) instead of distracting clock icon
- **Purpose**: Quick identification of auto-generated fields
- **Color**: Lighter gray text (#999999) for better legibility

#### Other Tag Types
- **Encrypted Tags**: `[encrypted]` in red, matching sensitive field colors
- **Default Value Tags**: `[default]` in orange for fields with default values

### Interactive Features
- **Hover Effects**: Subtle brightness boost with smooth 0.2s transitions
- **Navigation**: FK tags navigate using `#EntityName` anchors
- **Tooltips**: Professional dark background with white text and drop shadows
- **Visual Feedback**: Cursor changes to pointer for clickable elements

## ⚡ Instant Hover Tooltips

### Feature Description
- **Instant custom tooltips** for foreign key, embedded entity fields, and attribute tags
- **0.1-second fade-in** replaces slow browser tooltips (500-1000ms delay)
- **Professional design** with rounded corners, shadows, and proper alignment
- **Smart positioning** with automatic boundary detection
- **Clean entity names** without verbose information

### Technical Implementation

#### Custom CSS Tooltip System
```css
.tooltip-bg {
    visibility: hidden;
    opacity: 0;
    fill: rgba(44, 62, 80, 0.95);     /* Professional dark background */
    rx: 6;                            /* Rounded corners */
    filter: drop-shadow(0 2px 8px rgba(0, 0, 0, 0.4));  /* Subtle shadow */
    transition: opacity 0.1s ease-in; /* INSTANT appearance! */
}

.tooltip-text {
    visibility: hidden;
    opacity: 0;
    font-family: 'Segoe UI', Arial, sans-serif;
    font-size: 12px;
    font-weight: 500;
    fill: white;
    text-anchor: middle;              /* Perfect centering */
    transition: opacity 0.1s ease-in;
}

a:hover + .tooltip-group .tooltip-bg,
a:hover + .tooltip-group .tooltip-text {
    visibility: visible;
    opacity: 1;                       /* Shows immediately on hover */
}
```

#### SVG Structure
```html
<!-- Interactive field with instant tooltip -->
<a href="#Account">
    <text class="field-text foreign-key interactive-field">-ParentId: String [FK]</text>
</a>
<g class="tooltip-group">
    <rect x="93" y="224" width="72" height="20" class="tooltip-bg"/>
    <text x="129" y="238" text-anchor="middle" class="tooltip-text">Account</text>
</g>
```

### Smart Positioning Features

#### Automatic Centering
- **Field Analysis**: Calculates field text width for proper centering
- **Tooltip Centering**: Positions tooltip center relative to field center
- **Boundary Detection**: Prevents tooltips from extending outside entity boundaries
- **Consistent Spacing**: 8px clearance above fields for optimal readability

#### Positioning Algorithm
```swift
// Center tooltip relative to field text
let fieldCenterX = position.x + padding + (fieldTextWidth / 2)
var tooltipX = fieldCenterX - (tooltipWidth / 2)

// Ensure tooltip stays within entity boundaries
let minX = position.x + 5
let maxX = position.x + position.width - tooltipWidth - 5
tooltipX = max(minX, min(tooltipX, maxX))

// Position above field with proper spacing
let tooltipY = fieldY - tooltipHeight - 8
```

### User Experience Benefits

#### Timeline Comparison
| Action | Before (Browser Tooltips) | After (Instant Tooltips) |
|--------|---------------------------|---------------------------|
| **Hover starts** | No feedback | Immediate color change + glow |
| **0.1 seconds** | Still nothing | Tooltip fully visible! ✅ |
| **0.5 seconds** | Still waiting... | Information already consumed |
| **1.0 seconds** | Finally shows tooltip | User likely clicked already |

#### Visual Feedback Layers
1. **Immediate (0ms)**: Cursor changes to pointer
2. **Instant (100ms)**: Color transition + glow effect  
3. **Immediate (100ms)**: Tooltip fades in
4. **Progressive**: Rich information without delay

### Examples

#### Foreign Key Tooltip
```dbsoup
User
====
- account_id : ObjectId     [FK:Account.id]    # Hover shows "Account" instantly
- profile_id : ObjectId     [FK:Profile.id]    # Hover shows "Profile" instantly
```

#### Embedded Entity Tooltip  
```dbsoup
Route
=====
- stops      : Stop [0..*]                    # Hover shows "Stop" instantly
- address    : Address                        # Hover shows "Address" instantly
```

### Visual Design

#### Professional Appearance
- **Background**: Semi-transparent dark blue-gray (95% opacity)
- **Text**: Clean white text with professional font (`Segoe UI`)
- **Corners**: 6px rounded corners for modern look
- **Shadow**: Subtle drop shadow for depth and separation
- **Size**: Auto-calculated width, minimum 60px, consistent 20px height

#### Consistency Features
- **Uniform styling** across all interactive fields
- **Smart width calculation** based on entity name length
- **Minimum dimensions** prevent tiny tooltips
- **Perfect text centering** using `text-anchor="middle"`
- **Boundary awareness** keeps tooltips within entity boxes

### Integration with Hover Effects

#### Enhanced Interactive Experience
- **Color Changes**: Purple → Bright Pink for FK, Yellow → Bright Yellow for embedded
- **Glow Effects**: Subtle drop-shadow and brightness boost on hover  
- **Smooth Transitions**: 0.2s for color changes, 0.1s for tooltip appearance
- **Cursor Indication**: Pointer cursor shows clickability
- **No Visual Clutter**: Clean design without distracting underlines

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
2. Hover "profile_id" field (purple) → instant "Profile" tooltip appears
3. Click "profile_id" field (purple) to jump to "Profile" entity
4. Hover "team_id" field (purple) → instant "Team" tooltip appears  
5. Click "team_id" field (purple) to jump to "Team" entity
6. Hover "address" field (yellow) → instant "Address" tooltip appears
7. Click "address" field (yellow) to jump to "Address" embedded entity
8. Use browser back button to return to "User"
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
# Instant tooltips + foreign key and embedded entity navigation
User
====
- profile_id : ObjectId     [FK:Profile.id]    # Purple: hover="Profile" tooltip, click=jump to Profile
- address    : Address                         # Yellow: hover="Address" tooltip, click=jump to Address

# Target entity with ID
Profile
=======
* _id        : ObjectId     [PK]              # Entity has id="Profile" for navigation
- settings   : UserSettings                   # Yellow: hover="UserSettings" tooltip

# Target embedded entity with ID
Address
/======/
* _id        : ObjectId     [PK]              # Entity has id="Address" for navigation
- street     : String
- city       : String
- contact    : ContactInfo                    # Bright yellow: hover="ContactInfo" tooltip, click=jump

# Complete user experience:
# 1. Hover over "profile_id" → "Profile" tooltip appears in 0.1s
# 2. Click "profile_id" → jumps directly to Profile entity
# 3. Hover over "contact" → "ContactInfo" tooltip appears in 0.1s  
# 4. Click "contact" → jumps to ContactInfo embedded entity
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
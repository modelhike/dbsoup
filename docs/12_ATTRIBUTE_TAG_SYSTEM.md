# DBSoup Attribute Tag System Guide

## Overview
The DBSoup SVG generator now includes a sophisticated attribute tag system that displays field constraints as compact, color-coded tags next to field names. This system provides instant visual feedback about field properties without cluttering the diagram.

## 🏷️ Attribute Tag Features

### Visual Design Philosophy
- **Compact**: Small, rounded tags that don't overwhelm the field text
- **Legible**: Carefully sized fonts with proper padding and alignment
- **Color-Coded**: Each constraint type has a distinct color for quick recognition
- **Interactive**: Hover effects and tooltips for additional information
- **Aligned**: Tags align with field text for clean presentation

### Tag Categories

#### 1. **Foreign Key Tags** (Muted Gray on Dark Purple)
- **Display**: `fk - EntityName` (lowercase)
- **Color**: Dark purple background (`#8e24aa`) with dark purple border (`#8e24aa`) and **muted gray text (`#cccccc`)**
- **Special Features**:
  - Always shows full entity name for clarity
  - Uses optimized font (11px) and minimal padding for compactness
  - Clickable navigation to referenced entity
  - Instant hover tooltip showing entity name
  - **Subtle elegance**: Muted gray text provides excellent readability without brightness
  - **Professional appearance**: Solid dark background creates a confident, modern look
  - **Easy on the eyes**: Softer gray text reduces visual strain while maintaining clarity

```dbsoup
- user_id : ObjectId [FK:User._id]  # Displays: [fk - User]
```

#### 2. **App/JSON Field Tags** (Green with White Text)
- **Display**: `app: field` or `json: field` (lowercase with field mapping)
- **Color**: Solid green background (`rgba(46, 204, 113, 0.8)`) with green border (`#27ae60`) and **white text (`#ffffff`)**
- **Special Features**:
  - Shows application field mapping or JSON field names
  - High contrast white text ensures maximum legibility
  - Professional solid green background for clear visibility
  - Consistent with modern UI design patterns

```dbsoup
- UserId : String [APP:OrgId]  # Displays: [app: OrgId]
- uid : String [JSON:uid]      # Displays: [json: uid]
```

#### 3. **Enum Constraint Tags** (Blue)
- **Display**: `enum` (lowercase)
- **Color**: Blue background (`#2980b9`) with blue border
- **Special Features**:
  - Hover tooltip shows all valid enum values
  - Format: "Valid values: value1, value2, value3"
  - Interactive tooltip with professional styling

```dbsoup
- status : String [ENUM:active,inactive,pending]  # Displays: [enum] + hover tooltip
```

#### 4. **System Attribute Tags** (Dark Gray)
- **Display**: Various system indicators with icons/symbols
- **Color**: Dark gray background (`#34495e`) with lighter gray text (`#999999`)
- **Special Indicators**:
  - `auto` - For auto-increment or auto-generated fields
  - `sys` - For other system-managed fields

```dbsoup
- id : Int [AUTO_INCREMENT]  # Displays: [auto]
- updated_at : DateTime [SYSTEM]  # Displays: [sys]
```

#### 4a. **Special Case: Datetime Default Tags** (Orange)
- **Display**: `• now` - Uses bright dot symbol for easy identification
- **Color**: Orange background (`#d35400`) matching default value styling
- **Logic**: CURRENT_TIMESTAMP represents a default value, so uses default tag colors

```dbsoup
- created_at : DateTime [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]  # Displays: [• now] in orange
```

#### 4. **Encrypted Attribute Tags** (Red)
- **Display**: `encrypted` (lowercase)
- **Color**: Red background (`#ff4757`) matching sensitive field colors
- **Purpose**: Matches sensitive field styling for consistency

```dbsoup
@ password : String [ENCRYPTED]  # Displays: [encrypted]
```

#### 5. **Default Value Tags** (Orange)
- **Display**: `default` (lowercase) or special symbols for datetime defaults
- **Color**: Orange background (`#d35400`) with orange text
- **Purpose**: Indicates fields with default values
- **Special Symbol**: `• now` for CURRENT_TIMESTAMP datetime defaults

```dbsoup
- status : String [DEFAULT:active]  # Displays: [default]
- created_at : DateTime [DEFAULT:CURRENT_TIMESTAMP]  # Displays: [• now]
```

## 🎨 Visual Specifications

### Tag Dimensions and Spacing
- **Font Size**: 11px for all tag types (consistent sizing)
- **Tag Height**: 12px (10px for FK tags)
- **Padding**: 6px horizontal, minimal vertical
- **Border Radius**: 3px for modern rounded corners
- **Spacing**: 3px gap between multiple tags
- **Alignment**: Top-aligned with field text

### Color Palette
| Tag Type | Background | Border | Text Color |
|----------|------------|---------|------------|
| **Foreign Key** | `rgba(224, 86, 253, 0.08)` | `#e056fd` | `#7CB342` *(olive green - muted complementary color to purple)* |
| **Enum** | `rgba(41, 128, 185, 0.15)` | `#2980b9` | `#2980b9` |
| **System** | `rgba(52, 73, 94, 0.15)` | `#34495e` | `#999999` |
| **Encrypted** | `rgba(255, 71, 87, 0.15)` | `#ff4757` | `#c0392b` |
| **Default** | `rgba(211, 84, 0, 0.15)` | `#d35400` | `#d35400` |

### Typography
- **Font Family**: System font stack (`-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif`)
- **Font Weight**: 600 (semi-bold) for better readability at small sizes
- **Text Transform**: Lowercase for all constraint keys
- **Anti-aliasing**: Optimized for small text rendering

## 🔄 Interactive Features

### Hover Effects
- **Color Enhancement**: Subtle brightness boost on hover
- **Opacity Changes**: From 0.8 to 1.0 opacity on hover
- **Smooth Transitions**: 0.2s ease-in-out for all hover effects

### Tooltips (Enum Tags Only)
- **Activation**: Hover over enum tags
- **Content**: "Valid values: value1, value2, value3"
- **Styling**:
  - Dark background (`rgba(44, 62, 80, 0.95)`)
  - White text with drop shadow
  - Rounded corners (6px radius)
  - Instant appearance (0.1s fade-in)
  - Auto-sizing based on content length

### Navigation (FK Tags Only)
- **Clickable**: FK tags are clickable links
- **Target**: Navigate to referenced entity using `#EntityName` anchors
- **Visual Feedback**: Cursor changes to pointer on hover

## 📍 Tag Positioning System

### Alignment Rules
- **Vertical**: Top-aligned with field text baseline
- **Horizontal**: Positioned after field text with 4px gap
- **Multiple Tags**: 3px spacing between consecutive tags
- **Overflow**: Tags wrap gracefully if they exceed container width

### Responsive Behavior
- **Width Calculation**: Dynamic width based on text content
- **Minimum Width**: 18px to prevent tiny tags
- **Maximum Width**: No limit, but optimized spacing for common lengths
- **Height Consistency**: Fixed height per tag type for visual alignment

## 🎯 Implementation Details

### Constraint Detection Logic
```swift
// Simplified constraint detection
func getSmartDisplayText(constraint: String, value: String) -> (String, TagCategory) {
    switch constraint {
    case "FK":
        // Extract entity name from value
        let entityName = extractEntityName(from: value)
        return ("fk - \(entityName)", .constraint)
    case "ENUM":
        return ("enum", .constraint)
    case "SYSTEM":
        if value == "CURRENT_TIMESTAMP" {
            return ("• now", .default)  // Uses default styling since it's a default value
        }
        return ("sys", .system)
    case "ENCRYPTED":
        return ("encrypted", .encrypted)
    case "DEFAULT":
        return ("default", .default)
    default:
        return (constraint.lowercased(), .constraint)
    }
}
```

### CSS Class Structure
```css
/* Base tag styles */
.tag-constraint { 
    fill: rgba(41, 128, 185, 0.15); 
    stroke: #2980b9; 
    stroke-width: 0.4; 
}
.tag-constraint-text { 
    fill: #2980b9; 
    font-weight: 600; 
    font-size: 11px; 
}

/* FK-specific overrides */
.tag-fk { 
    /* Inherits from base with FK-specific adjustments */ 
}
.tag-fk-text { 
    font-size: 10px; /* Smaller for FK tags */ 
}

/* Hover effects */
.constraint-tag:hover {
    opacity: 1.0;
    filter: brightness(1.1);
    transition: all 0.2s ease-in-out;
}
```

### SVG Structure
```svg
<!-- Field with attribute tags -->
<g class="field-group">
    <text class="field-text" x="20" y="100">- user_id: ObjectId</text>
    
    <!-- FK Tag -->
    <g class="constraint-tag">
        <rect x="180" y="92" width="56" height="12" 
              class="tag-fk" rx="3"/>
        <text x="208" y="102" 
              class="tag-fk-text">fk - User</text>
    </g>
    
    <!-- Enum Tag with Tooltip -->
    <g class="constraint-tag-with-tooltip">
        <rect x="240" y="92" width="34" height="12" 
              class="tag-constraint" rx="3"/>
        <text x="257" y="102" 
              class="tag-constraint-text">enum</text>
        
        <!-- Tooltip (hidden by default) -->
        <g class="tooltip-group">
            <rect x="200" y="75" width="120" height="20" 
                  class="tooltip-bg" rx="6"/>
            <text x="260" y="89" 
                  class="tooltip-text">Valid values: active, inactive</text>
        </g>
    </g>
</g>
```

## 🎛️ Configuration Options

### Customizable Properties
- **Font Size**: Adjustable per tag type
- **Color Scheme**: Full color palette customization
- **Spacing**: Gap between tags and padding within tags
- **Border Properties**: Width, radius, and style
- **Hover Effects**: Duration and intensity of transitions
- **Tooltip Styling**: Background, text color, and positioning

### Performance Optimizations
- **CSS Classes**: Shared styles reduce SVG file size
- **Efficient Layout**: Calculated positioning minimizes reflows
- **Smart Rendering**: Only render tags for fields with constraints
- **Lightweight Animations**: CSS transitions instead of JavaScript

## 📋 Usage Guidelines

### Best Practices
1. **Constraint Priority**: Most important constraints should appear first
2. **Color Consistency**: Maintain color scheme across all diagrams
3. **Readability**: Ensure tags don't overwhelm field text
4. **Accessibility**: High contrast colors for all tag types
5. **Performance**: Limit excessive tags on single fields

### Common Patterns
```dbsoup
# Multiple constraints - shows most important tags
@ email : String [UK,ENCRYPTED,IX]  # Shows: [encrypted] (highest priority)

# FK with enum - shows both tags
- status : StatusEnum [FK:Status._id,ENUM:active,inactive]  # Shows: [fk - Status] [enum]

# System field with default
- created_at : DateTime [SYSTEM,DEFAULT:CURRENT_TIMESTAMP]  # Shows: [• now]
```

## 🔧 Maintenance and Updates

### Version History
- **v1.0**: Initial attribute tag implementation with basic colors
- **v1.1**: Added FK special handling and hover effects
- **v1.2**: Implemented enum tooltips and navigation
- **v1.3**: Refined font sizes and spacing
- **v1.4**: Updated system attribute icons (clock → dot)
- **v1.5**: Added encrypted tag type and color consistency

### Future Enhancements
- **Custom Tag Types**: Support for user-defined constraint categories
- **Tag Themes**: Predefined color schemes (dark mode, high contrast, etc.)
- **Advanced Tooltips**: Rich HTML tooltips with examples and documentation
- **Tag Filtering**: Hide/show specific tag types for focused views
- **Export Options**: Tag information in JSON/XML for external tools

---

*This guide covers the complete attribute tag system implementation. For color codes and visual examples, see [SVG Color Reference Guide](09_SVG_COLOR_REFERENCE.md). For interactive features, see [SVG Interactive Features Guide](10_SVG_INTERACTIVE_FEATURES.md).* 
import Foundation

public class DBSoupSVGGenerator {
    private let document: DBSoupDocument
    private let backgroundColor: String?
    
    public init(document: DBSoupDocument, backgroundColor: String? = "#ecf0f1") {
        self.document = document
        self.backgroundColor = backgroundColor
    }
    
    // MARK: - Background Color Presets
    
    /// Recommended background colors for professional appearance
    public static let backgroundColors = BackgroundColors()
    
    public struct BackgroundColors {
        public let transparent: String? = nil
        public let lightGrey = "#f5f5f5"
        public let mediumGrey = "#e8e8e8"
        public let blueGrey = "#ecf0f1"      // Default background color
        public let warmGrey = "#f8f9fa"
        public let documentWhite = "#ffffff"
    }
    
    // MARK: - Convenience Initializers
    
    /// Creates SVG generator with transparent background (no background color)
    public static func withTransparentBackground(document: DBSoupDocument) -> DBSoupSVGGenerator {
        return DBSoupSVGGenerator(document: document, backgroundColor: backgroundColors.transparent)
    }
    
    /// Creates SVG generator with light grey background (recommended for maximum contrast)
    public static func withLightGreyBackground(document: DBSoupDocument) -> DBSoupSVGGenerator {
        return DBSoupSVGGenerator(document: document, backgroundColor: backgroundColors.lightGrey)
    }
    
    /// Creates SVG generator with blue-grey background (default, professional look)
    public static func withBlueGreyBackground(document: DBSoupDocument) -> DBSoupSVGGenerator {
        return DBSoupSVGGenerator(document: document, backgroundColor: backgroundColors.blueGrey)
    }
    
    /// Creates SVG generator with warm grey background (recommended for documentation)
    public static func withWarmGreyBackground(document: DBSoupDocument) -> DBSoupSVGGenerator {
        return DBSoupSVGGenerator(document: document, backgroundColor: backgroundColors.warmGrey)
    }
    
    public func generateSVG() -> String {
        let allEntities = getAllEntities()
        let allRelationships = getAllRelationships()
        
        // Calculate layout with dynamic sizing and legend space
        let layout = calculateDynamicLayout(entities: allEntities, relationships: allRelationships)
        
        var svg = """
        <svg xmlns="http://www.w3.org/2000/svg" 
             width="\(layout.totalWidth)" 
             height="\(layout.totalHeight)" 
             viewBox="0 0 \(layout.totalWidth) \(layout.totalHeight)"
             preserveAspectRatio="xMidYMid meet">
        <defs>
            <linearGradient id="headerGradient" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" style="stop-color:#4a90e2;stop-opacity:1" />
                <stop offset="100%" style="stop-color:#357abd;stop-opacity:1" />
            </linearGradient>
            <linearGradient id="entityGradient" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" style="stop-color:#1a1a1a;stop-opacity:1" />
                <stop offset="100%" style="stop-color:#2d2d2d;stop-opacity:1" />
            </linearGradient>
            <linearGradient id="embeddedHeaderGradient" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" style="stop-color:#8e44ad;stop-opacity:1" />
                <stop offset="100%" style="stop-color:#6c3483;stop-opacity:1" />
            </linearGradient>
            <linearGradient id="embeddedEntityGradient" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" style="stop-color:#2c1810;stop-opacity:1" />
                <stop offset="100%" style="stop-color:#3d221a;stop-opacity:1" />
            </linearGradient>
            <linearGradient id="legendGradient" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" style="stop-color:#2c3e50;stop-opacity:1" />
                <stop offset="100%" style="stop-color:#34495e;stop-opacity:1" />
            </linearGradient>
            <linearGradient id="legendHeaderGradient" x1="0%" y1="0%" x2="0%" y2="100%">
                <stop offset="0%" style="stop-color:#e74c3c;stop-opacity:1" />
                <stop offset="100%" style="stop-color:#c0392b;stop-opacity:1" />
            </linearGradient>
        </defs>
        <style>
        svg { max-width: none !important; height: auto !important; }
        .entity-box { fill: url(#entityGradient); stroke: #444444; stroke-width: 2; }
        .entity-header { fill: url(#headerGradient); stroke: #444444; stroke-width: 2; }
        .entity-title { font-family: Arial, sans-serif; font-size: 16px; font-weight: bold; fill: white; }
        .embedded-entity-box { fill: url(#embeddedEntityGradient); stroke: #8e44ad; stroke-width: 2; stroke-dasharray: 8,4; }
        .embedded-entity-header { fill: url(#embeddedHeaderGradient); stroke: #8e44ad; stroke-width: 2; stroke-dasharray: 8,4; }
        .embedded-entity-title { font-family: Arial, sans-serif; font-size: 15px; font-weight: bold; fill: white; font-style: italic; }
        .field-text { font-family: 'Courier New', monospace; font-size: 12px; }
        .embedded-field-text { font-family: 'Courier New', monospace; font-size: 11px; font-style: italic; }
        .required { fill: #ffa502; }
        .optional { fill: #c7c7c7; }
        .indexed { fill: #5352ed; }
        .sensitive { fill: #ff4757; }
        .foreign-key { fill: #e056fd; }
        .embedded-entity-field { fill: #ffeb3b; }
        .embedded-required { fill: #e67e22; }
        .embedded-optional { fill: #a569bd; }
        .embedded-indexed { fill: #8e44ad; }
        .embedded-sensitive { fill: #e74c3c; }
        .embedded-foreign-key { fill: #c39bd3; }
        .embedded-entity-field { fill: #ffeb3b; }
        .embedded-embedded-entity-field { fill: #fdd835; }
        .legend-box { fill: url(#legendGradient); stroke: #34495e; stroke-width: 3; stroke-dasharray: 8,4; opacity: 1; }
        .legend-header { fill: url(#legendHeaderGradient); stroke: #c0392b; stroke-width: 2; }
        .legend-title { font-family: Arial, sans-serif; font-size: 14px; font-weight: bold; fill: white; text-shadow: 2px 2px 4px rgba(0,0,0,0.8); }
        .legend-text { font-family: 'Courier New', monospace; font-size: 11px; fill: #ecf0f1; font-weight: bold; text-shadow: 1px 1px 3px rgba(0,0,0,0.9); }
        .legend-row { fill: none; stroke: #7f8c8d; stroke-width: 1; opacity: 0.8; stroke-dasharray: 2,2; }
        </style>
        
        """
        
        // Add background if specified
        if let bgColor = backgroundColor {
            svg += """
            <rect x="0" y="0" width="\(layout.totalWidth)" height="\(layout.totalHeight)" fill="\(bgColor)" opacity="1"/>
            
            """
        }
        
        // Generate entities
        for entity in allEntities {
            svg += generateEntityBox(entity: entity, layout: layout)
        }
        
        // Generate relationships legend
        if !allRelationships.isEmpty {
            svg += generateRelationshipsLegend(relationships: allRelationships, layout: layout)
        }
        
        svg += "</svg>"
        return svg
    }
    
    private func getAllEntities() -> [Entity] {
        var entities: [Entity] = []
        for moduleSection in document.schemaDefinition.moduleSections {
            entities.append(contentsOf: moduleSection.entities)
        }
        // Sort entities alphabetically by name for better scanning
        return entities.sorted { $0.name < $1.name }
    }
    
    private func getAllRelationships() -> [Relationship] {
        return document.relationshipDefinitions?.relationships ?? []
    }
    
    private func generateEntityBox(entity: Entity, layout: SVGLayout) -> String {
        guard let position = layout.entityPositions[entity.name] else {
            return ""
        }
        
        let headerHeight = 35
        let fieldHeight = 18
        let padding = 12
        
        // Determine styles based on entity type
        let isEmbedded = entity.type == .embedded
        let entityBoxClass = isEmbedded ? "embedded-entity-box" : "entity-box"
        let entityHeaderClass = isEmbedded ? "embedded-entity-header" : "entity-header"
        let entityTitleClass = isEmbedded ? "embedded-entity-title" : "entity-title"
        let fieldTextClass = isEmbedded ? "embedded-field-text" : "field-text"
        
        var svg = """
        <g id="\(entity.name)">
        <!-- Entity container -->
        <rect x="\(position.x)" y="\(position.y)" width="\(position.width)" height="\(position.height)" class="\(entityBoxClass)" rx="8"/>
        
        <!-- Entity header -->
        <rect x="\(position.x)" y="\(position.y)" width="\(position.width)" height="\(headerHeight)" class="\(entityHeaderClass)" rx="8"/>
        
        <!-- Entity comment above title -->
        """
        
        if let comment = entity.comment {
            svg += """
            <text x="\(position.x + position.width/2)" y="\(position.y + 12)" class="\(fieldTextClass)" text-anchor="middle" style="font-style: italic; fill: white; font-size: 11px; font-weight: normal;">\(comment)</text>
            
            """
        }
        
        svg += """
        <!-- Entity title -->
        <text x="\(position.x + position.width/2)" y="\(position.y + (entity.comment != nil ? 27 : 22))" class="\(entityTitleClass)" text-anchor="middle">\(entity.name)</text>
        
        """
        
        // Generate ALL fields (no truncation)
        let startY = position.y + headerHeight + 15
        for (index, field) in entity.fields.enumerated() {
            let fieldY = startY + (index * fieldHeight)
            let fieldText = formatFieldText(field: field)
            let fieldClass = getFieldClass(field: field, isEmbedded: isEmbedded)
            
            // Check if this is a foreign key field for navigation
            if let referencedEntity = getForeignKeyReference(field: field) {
                svg += """
                <a href="#\(referencedEntity)" style="cursor: pointer;">
                    <text x="\(position.x + padding)" y="\(fieldY)" class="\(fieldTextClass) \(fieldClass)">\(fieldText)</text>
                </a>
                
                """
            } else if let embeddedEntity = getEmbeddedEntityReference(field: field) {
                svg += """
                <a href="#\(embeddedEntity)" style="cursor: pointer;">
                    <text x="\(position.x + padding)" y="\(fieldY)" class="\(fieldTextClass) \(fieldClass)">\(fieldText)</text>
                </a>
                
                """
            } else {
                svg += """
                <text x="\(position.x + padding)" y="\(fieldY)" class="\(fieldTextClass) \(fieldClass)">\(fieldText)</text>
                
                """
            }
        }
        
        svg += "</g>\n"
        return svg
    }
    
    private func getFieldClass(field: Field, isEmbedded: Bool = false) -> String {
        let prefix = isEmbedded ? "embedded-" : ""
        
        // Check for embedded entity field first (highest priority for color)
        if case .embeddedEntity(_) = field.dataType {
            return "\(prefix)embedded-entity-field"
        } else if case .relationshipArray(_, _) = field.dataType {
            return "\(prefix)embedded-entity-field"
        } else if isEmbeddedEntityReference(field: field) {
            return "\(prefix)embedded-entity-field"
        } else if field.constraints.contains(where: { $0.name.hasPrefix("FK") }) {
            return "\(prefix)foreign-key"
        } else if field.prefixes.contains(.sensitive) {
            return "\(prefix)sensitive"
        } else if field.prefixes.contains(.required) {
            return "\(prefix)required"
        } else if field.prefixes.contains(.indexed) {
            return "\(prefix)indexed"
        } else {
            return "\(prefix)optional"
        }
    }
    
    private func isEmbeddedEntityReference(field: Field) -> Bool {
        let allEntities = getAllEntities()
        let embeddedEntityNames = allEntities.filter { $0.type == .embedded }.map { $0.name }
        
        // Check if field data type references an embedded entity
        switch field.dataType {
        case .simple(let typeName):
            return embeddedEntityNames.contains(typeName)
        case .relationshipArray(let typeName, _):
            return embeddedEntityNames.contains(typeName)
        case .array(let innerType):
            if case .simple(let innerTypeName) = innerType {
                return embeddedEntityNames.contains(innerTypeName)
            }
            return false
        default:
            return false
        }
    }
    
    private func getForeignKeyReference(field: Field) -> String? {
        // Check if field has a foreign key constraint
        for constraint in field.constraints {
            if constraint.name == "FK" {
                // Extract referenced entity name from constraint value
                // Format: EntityName.fieldName
                if let value = constraint.value,
                   let dotIndex = value.firstIndex(of: ".") {
                    let entityName = String(value[..<dotIndex])
                    return entityName
                }
            }
        }
        return nil
    }
    
    private func getEmbeddedEntityReference(field: Field) -> String? {
        let allEntities = getAllEntities()
        let embeddedEntityNames = allEntities.filter { $0.type == .embedded }.map { $0.name }
        
        // Check if field data type references an embedded entity
        switch field.dataType {
        case .simple(let typeName):
            return embeddedEntityNames.contains(typeName) ? typeName : nil
        case .embeddedEntity(let typeName):
            return typeName
        case .relationshipArray(let typeName, _):
            return embeddedEntityNames.contains(typeName) ? typeName : nil
        case .array(let innerType):
            if case .simple(let innerTypeName) = innerType {
                return embeddedEntityNames.contains(innerTypeName) ? innerTypeName : nil
            } else if case .embeddedEntity(let innerTypeName) = innerType {
                return innerTypeName
            }
            return nil
        default:
            return nil
        }
    }
    
    private func formatFieldText(field: Field) -> String {
        let prefixText = field.prefixes.map { $0.rawValue }.joined()
        let nameText = field.names.joined(separator: ", ")
        let typeText = formatDataType(field.dataType)
        let constraintText = field.constraints.map { $0.name }.joined(separator: ", ")
        
        var result = "\(prefixText)\(nameText): \(typeText)"
        if !constraintText.isEmpty {
            result += " [\(constraintText)]"
        }
        return result
    }
    
    private func formatDataType(_ dataType: DataType) -> String {
        switch dataType {
        case .simple(let type):
            return type
        case .parametric(let type, let params):
            return "\(type)(\(params.joined(separator: ", ")))"
        case .array(let innerType):
            return "[\(formatDataType(innerType))]"
        case .jsonObject:
            return "JSON"
        case .relationshipArray(let type, _):
            return "[\(type)]"
        case .embeddedEntity(let type):
            return type
        }
    }
    
    // MARK: - Layout Calculation
    
    private func calculateDynamicLayout(entities: [Entity], relationships: [Relationship]) -> SVGLayout {
        var layout = SVGLayout()
        let basePadding = 40
        let entityPadding = 60
        let legendPadding = 30
        let maxEntitiesPerRow = 3
        
        var entityPositions: [String: EntityPosition] = [:]
        var currentX = basePadding
        var currentY = basePadding
        var currentRowHeight = 0
        var entitiesInCurrentRow = 0
        
        // Place entities in rows
        for entity in entities {
            let dimensions = calculateEntityDimensions(entity: entity)
            
            // Check if we need a new row
            if entitiesInCurrentRow >= maxEntitiesPerRow {
                currentX = basePadding
                currentY += currentRowHeight + entityPadding
                currentRowHeight = 0
                entitiesInCurrentRow = 0
            }
            
            let position = EntityPosition(
                x: currentX,
                y: currentY,
                width: dimensions.width,
                height: dimensions.height
            )
            entityPositions[entity.name] = position
            
            // Update for next entity
            currentX += dimensions.width + entityPadding
            currentRowHeight = max(currentRowHeight, dimensions.height)
            entitiesInCurrentRow += 1
        }
        
        // Calculate entities area dimensions
        let maxX = entityPositions.values.map { $0.x + $0.width }.max() ?? 0
        let entitiesBottomY = currentY + currentRowHeight
        
        // Calculate legend dimensions and position
        let legendWidth = 400
        let legendHeight = calculateLegendHeight(relationships: relationships)
        let legendX = maxX + legendPadding
        let legendY = basePadding
        
        // Set layout properties
        layout.entityPositions = entityPositions
        layout.legendX = legendX
        layout.legendY = legendY
        layout.legendWidth = legendWidth
        layout.legendHeight = legendHeight
        layout.totalWidth = max(maxX + basePadding, legendX + legendWidth + basePadding)
        layout.totalHeight = max(entitiesBottomY + basePadding, legendY + legendHeight + basePadding)
        
        return layout
    }
    
    private func calculateEntityDimensions(entity: Entity) -> (width: Int, height: Int) {
        let headerHeight = 35
        let fieldHeight = 18
        let padding = 12
        let minWidth = 280
        
        // Calculate width based on longest field text
        let maxFieldWidth = entity.fields.map { field in
            let fieldText = formatFieldText(field: field)
            return fieldText.count * 8 + padding * 2 // Approximate character width
        }.max() ?? 0
        
        let titleWidth = entity.name.count * 12 + padding * 2
        let commentWidth = entity.comment != nil ? (entity.comment!.count * 8 + padding * 2) : 0
        let width = max(minWidth, max(maxFieldWidth, max(titleWidth, commentWidth)))
        
        // Calculate height based on field count (comment is now in header area)
        let fieldsHeight = entity.fields.count * fieldHeight
        let height = headerHeight + fieldsHeight + 30 // Extra padding
        
        return (width: width, height: height)
    }
    
    private func calculateLegendHeight(relationships: [Relationship]) -> Int {
        if relationships.isEmpty {
            return 0
        }
        
        let headerHeight = 30
        let rowHeight = 20
        let padding = 20
        
        return headerHeight + (relationships.count * rowHeight) + padding
    }
    
    private func generateRelationshipsLegend(relationships: [Relationship], layout: SVGLayout) -> String {
        guard !relationships.isEmpty else { return "" }
        
        let x = layout.legendX
        let y = layout.legendY
        let width = layout.legendWidth
        let height = layout.legendHeight
        let headerHeight = 30
        let rowHeight = 20
        let padding = 10
        
        var legend = """
        <g class="legend">
            <rect x="\(x)" y="\(y)" width="\(width)" height="\(height)" class="legend-box"/>
            <rect x="\(x)" y="\(y)" width="\(width)" height="\(headerHeight)" class="legend-header"/>
            <text x="\(x + width/2)" y="\(y + headerHeight/2 + 5)" class="legend-title" text-anchor="middle">Relationships</text>
        
        """
        
        // Column headers
        let col1X = x + padding
        let col2X = x + width/3
        let col3X = x + 2*width/3
        let headerY = y + headerHeight + 15
        
        legend += """
            <text x="\(col1X)" y="\(headerY)" class="legend-text" font-weight="bold">From Entity</text>
            <text x="\(col2X)" y="\(headerY)" class="legend-text" font-weight="bold">To Entity</text>
            <text x="\(col3X)" y="\(headerY)" class="legend-text" font-weight="bold">Relationship</text>
        
        """
        
        // Header separator line
        legend += """
            <line x1="\(x + 5)" y1="\(headerY + 5)" x2="\(x + width - 5)" y2="\(headerY + 5)" class="legend-row"/>
        
        """
        
        // Relationship rows
        for (index, relationship) in relationships.enumerated() {
            let rowY = headerY + 15 + (index * rowHeight)
            
            let relationshipText = formatRelationshipForLegend(relationship)
            
            legend += """
                <a href="#\(relationship.fromEntity)" style="cursor: pointer;">
                    <text x="\(col1X)" y="\(rowY)" class="legend-text">\(relationship.fromEntity)</text>
                </a>
                <a href="#\(relationship.toEntity)" style="cursor: pointer;">
                    <text x="\(col2X)" y="\(rowY)" class="legend-text">\(relationship.toEntity)</text>
                </a>
                <text x="\(col3X)" y="\(rowY)" class="legend-text">\(relationshipText)</text>
            
            """
        }
        
        legend += "</g>\n"
        return legend
    }
    
    private func formatRelationshipForLegend(_ relationship: Relationship) -> String {
        var text = relationship.cardinality.rawValue
        if let comment = relationship.comment {
            text += " (\(comment))"
        }
        return text
    }
}

// MARK: - Layout Data Structures

struct SVGLayout {
    var entityPositions: [String: EntityPosition] = [:]
    var legendX: Int = 0
    var legendY: Int = 0
    var legendWidth: Int = 0
    var legendHeight: Int = 0
    var totalWidth: Int = 0
    var totalHeight: Int = 0
}

struct EntityPosition {
    let x: Int
    let y: Int
    let width: Int
    let height: Int
} 
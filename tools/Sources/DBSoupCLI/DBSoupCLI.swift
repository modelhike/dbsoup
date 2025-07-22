import Foundation
import DBSoupParser

// MARK: - CLI Commands

enum CLICommand {
    case parse(filePath: String)
    case validate(filePath: String)
    case format(filePath: String, outputPath: String?)
    case stats(filePath: String)
    case svg(filePath: String, outputPath: String?)
    case mermaid(filePath: String, outputPath: String?)
    case help
}

// MARK: - CLI Error Types

enum CLIError: Error, LocalizedError {
    case invalidArguments
    case fileNotFound(String)
    case invalidCommand(String)
    case parseError(String)
    case fileWriteError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidArguments:
            return "Invalid arguments provided"
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .invalidCommand(let command):
            return "Invalid command: \(command)"
        case .parseError(let message):
            return "Parse error: \(message)"
        case .fileWriteError(let message):
            return "File write error: \(message)"
        }
    }
}

// MARK: - Command Line Interface

class DBSoupCLI {
    private let arguments: [String]
    
    init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    func run() {
        do {
            let command = try parseCommand()
            try executeCommand(command)
        } catch let error as CLIError {
            printError(error.localizedDescription)
            exit(1)
        } catch {
            printError("Unexpected error: \(error)")
            exit(1)
        }
    }
    
    private func parseCommand() throws -> CLICommand {
        guard arguments.count >= 2 else {
            return .help
        }
        
        let command = arguments[1]
        
        switch command {
        case "parse":
            guard arguments.count >= 3 else {
                throw CLIError.invalidArguments
            }
            return .parse(filePath: arguments[2])
            
        case "validate":
            guard arguments.count >= 3 else {
                throw CLIError.invalidArguments
            }
            return .validate(filePath: arguments[2])
            
        case "format":
            guard arguments.count >= 3 else {
                throw CLIError.invalidArguments
            }
            let outputPath = arguments.count >= 4 ? arguments[3] : nil
            return .format(filePath: arguments[2], outputPath: outputPath)
            
        case "stats":
            guard arguments.count >= 3 else {
                throw CLIError.invalidArguments
            }
            return .stats(filePath: arguments[2])
            
        case "svg":
            guard arguments.count >= 3 else {
                throw CLIError.invalidArguments
            }
            let outputPath = parseOutputPath(from: arguments, startingAt: 3)
            return .svg(filePath: arguments[2], outputPath: outputPath)
            
        case "mermaid":
            guard arguments.count >= 3 else {
                throw CLIError.invalidArguments
            }
            let outputPath = parseOutputPath(from: arguments, startingAt: 3)
            return .mermaid(filePath: arguments[2], outputPath: outputPath)
            
        case "help", "--help", "-h":
            return .help
            
        default:
            throw CLIError.invalidCommand(command)
        }
    }
    
    private func executeCommand(_ command: CLICommand) throws {
        switch command {
        case .parse(let filePath):
            try parsefile(filePath)
            
        case .validate(let filePath):
            try validateFile(filePath)
            
        case .format(let filePath, let outputPath):
            try formatFile(filePath, outputPath: outputPath)
            
        case .stats(let filePath):
            try generateStats(filePath)
            
        case .svg(let filePath, let outputPath):
            try generateSVG(filePath, outputPath: outputPath)
            
        case .mermaid(let filePath, let outputPath):
            try generateMermaid(filePath, outputPath: outputPath)
            
        case .help:
            printHelp()
        }
    }
    
    // MARK: - Command Implementations
    
    private func parsefile(_ filePath: String) throws {
        let document = try loadAndParseFile(filePath)
        
        print("✅ Successfully parsed DBSoup file: \(filePath)")
        print("")
        
        // Print basic information
        if let header = document.header {
            print("Header: @\(header.filename).dbsoup")
        }
        
        if let relationships = document.relationshipDefinitions {
            print("Relationships: \(relationships.relationships.count)")
        }
        
        print("Modules: \(document.schemaDefinition.moduleSections.count)")
        
        let totalEntities = document.schemaDefinition.moduleSections.reduce(0) { $0 + $1.entities.count }
        print("Total Entities: \(totalEntities)")
        
        let totalFields = document.schemaDefinition.moduleSections.reduce(0) { total, section in
            total + section.entities.reduce(0) { $0 + $1.fields.count }
        }
        print("Total Fields: \(totalFields)")
        
        print("")
        print("Module Structure:")
        for section in document.schemaDefinition.moduleSections {
            print("  \(section.name): \(section.entities.count) entities")
            for entity in section.entities {
                let typeIcon = entity.type == .standard ? "🏗️" : "🔗"
                print("    \(typeIcon) \(entity.name) (\(entity.fields.count) fields)")
            }
        }
    }
    
    private func validateFile(_ filePath: String) throws {
        let document = try loadAndParseFile(filePath)
        let validator = DBSoupValidator(document: document)
        let result = validator.validate()
        
        if result.isValid {
            print("✅ DBSoup file is valid: \(filePath)")
        } else {
            print("❌ DBSoup file has validation errors: \(filePath)")
            print("")
            print("Errors:")
            for error in result.errors {
                print("  • \(error.localizedDescription)")
            }
        }
        
        if !result.warnings.isEmpty {
            print("")
            print("Warnings:")
            for warning in result.warnings {
                print("  ⚠️  \(warning)")
            }
        }
        
        print("")
        print("Summary: \(result.errors.count) errors, \(result.warnings.count) warnings")
    }
    
    private func formatFile(_ filePath: String, outputPath: String?) throws {
        let document = try loadAndParseFile(filePath)
        
        let config = DBSoupFormatterConfig(
            fieldNameWidth: 20,
            dataTypeWidth: 25,
            constraintColumnStart: 45,
            includeComments: true
        )
        
        let formatter = DBSoupFormatter(config: config)
        let formattedContent = formatter.format(document: document)
        
        if let outputPath = outputPath {
            do {
                try formattedContent.write(toFile: outputPath, atomically: true, encoding: .utf8)
                print("✅ Formatted DBSoup file saved to: \(outputPath)")
            } catch {
                throw CLIError.fileWriteError("Failed to write to \(outputPath): \(error)")
            }
        } else {
            print("=== Formatted DBSoup ===")
            print(formattedContent)
        }
    }
    
    private func generateStats(_ filePath: String) throws {
        let document = try loadAndParseFile(filePath)
        let statsGenerator = DBSoupStatisticsGenerator()
        let statistics = statsGenerator.generateStatistics(for: document)
        
        print("📊 DBSoup Statistics for: \(filePath)")
        print("")
        print(statsGenerator.printStatistics(statistics))
    }
    
    // MARK: - Helper Methods
    
    private func parseOutputPath(from arguments: [String], startingAt index: Int) -> String? {
        guard index < arguments.count - 1 else { return nil }
        
        for i in index..<arguments.count {
            if arguments[i] == "--output" || arguments[i] == "-o" {
                if i + 1 < arguments.count {
                    return arguments[i + 1]
                }
            }
        }
        return nil
    }
    
    private func generateSVG(_ filePath: String, outputPath: String?) throws {
        let (document, rawContent) = try loadAndParseFileWithContent(filePath)
        let svgGenerator = DBSoupSVGGenerator(document: document, rawContent: rawContent)
        let svg = svgGenerator.generateSVG()
        
        if let outputPath = outputPath {
            do {
                try svg.write(toFile: outputPath, atomically: true, encoding: .utf8)
                print("✅ SVG diagram saved to: \(outputPath)")
            } catch {
                throw CLIError.fileWriteError("Failed to write SVG to \(outputPath): \(error)")
            }
        } else {
            // Default output path
            let defaultPath = filePath.replacingOccurrences(of: ".dbsoup", with: ".svg")
            do {
                try svg.write(toFile: defaultPath, atomically: true, encoding: .utf8)
                print("✅ SVG diagram saved to: \(defaultPath)")
            } catch {
                throw CLIError.fileWriteError("Failed to write SVG to \(defaultPath): \(error)")
            }
        }
    }
    
    private func generateMermaid(_ filePath: String, outputPath: String?) throws {
        let document = try loadAndParseFile(filePath)
        let mermaidGenerator = DBSoupMermaidEnhancedGenerator(document: document)
        let mermaid = mermaidGenerator.generateMermaid()
        
        if let outputPath = outputPath {
            do {
                try mermaid.write(toFile: outputPath, atomically: true, encoding: .utf8)
                print("✅ Mermaid diagram saved to: \(outputPath)")
            } catch {
                throw CLIError.fileWriteError("Failed to write Mermaid to \(outputPath): \(error)")
            }
        } else {
            // Default output path
            let defaultPath = filePath.replacingOccurrences(of: ".dbsoup", with: ".mmd")
            do {
                try mermaid.write(toFile: defaultPath, atomically: true, encoding: .utf8)
                print("✅ Mermaid diagram saved to: \(defaultPath)")
            } catch {
                throw CLIError.fileWriteError("Failed to write Mermaid to \(defaultPath): \(error)")
            }
        }
    }
    
    private func loadAndParseFile(_ filePath: String) throws -> DBSoupDocument {
        // Check if file exists
        guard FileManager.default.fileExists(atPath: filePath) else {
            throw CLIError.fileNotFound(filePath)
        }
        
        // Read file content
        let content: String
        do {
            content = try String(contentsOfFile: filePath, encoding: .utf8)
        } catch {
            throw CLIError.fileNotFound("Could not read file: \(filePath)")
        }
        
        // Parse the content
        let parser = DBSoupParser(content: content)
        do {
            return try parser.parse()
        } catch let parseError as DBSoupParseError {
            throw CLIError.parseError(parseError.localizedDescription)
        } catch {
            throw CLIError.parseError("Unknown parse error: \(error)")
        }
    }
    
    private func loadAndParseFileWithContent(_ filePath: String) throws -> (DBSoupDocument, String) {
        // Check if file exists
        guard FileManager.default.fileExists(atPath: filePath) else {
            throw CLIError.fileNotFound(filePath)
        }
        
        // Read file content
        let content: String
        do {
            content = try String(contentsOfFile: filePath, encoding: .utf8)
        } catch {
            throw CLIError.fileNotFound("Could not read file: \(filePath)")
        }
        
        // Parse the content
        let parser = DBSoupParser(content: content)
        do {
            let document = try parser.parse()
            return (document, content)
        } catch let parseError as DBSoupParseError {
            throw CLIError.parseError(parseError.localizedDescription)
        } catch {
            throw CLIError.parseError("Unknown parse error: \(error)")
        }
    }
    
    private func printHelp() {
        print("DBSoup Parser CLI Tool")
        print("======================")
        print("")
        print("USAGE:")
        print("  dbsoup <command> [options]")
        print("")
        print("COMMANDS:")
        print("  parse <file>           Parse a DBSoup file and show basic information")
        print("  validate <file>        Validate a DBSoup file against specification")
        print("  format <file> [output] Format a DBSoup file with consistent styling")
        print("  stats <file>           Generate statistics for a DBSoup file")
        print("  svg <file> [options]   Generate SVG diagram of the database schema")
        print("  mermaid <file> [options] Generate Mermaid ER diagram of the database schema")
        print("  help                   Show this help message")
        print("")
        print("OPTIONS:")
        print("  --output, -o <file>    Specify output file path (for svg command)")
        print("")
        print("EXAMPLES:")
        print("  dbsoup parse schema.dbsoup")
        print("  dbsoup validate schema.dbsoup")
        print("  dbsoup format schema.dbsoup formatted.dbsoup")
        print("  dbsoup stats schema.dbsoup")
        print("  dbsoup svg schema.dbsoup --output diagram.svg")
        print("  dbsoup svg schema.dbsoup  # outputs to schema.svg")
        print("  dbsoup mermaid schema.dbsoup --output diagram.mmd")
        print("  dbsoup mermaid schema.dbsoup  # outputs to schema.mmd")
        print("")
        print("For more information, visit: https://github.com/your-org/dbsoup")
    }
    
    private func printError(_ message: String) {
        print("❌ Error: \(message)", to: &standardError)
    }
}

// MARK: - Standard Error Extension

extension FileHandle: TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        self.write(data)
    }
}

private var standardError = FileHandle.standardError

// MARK: - Main Entry Point

// Entry point is now in main.swift 
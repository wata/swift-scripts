import Foundation
import ArgumentParser

struct CSV2Keychain: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A Swift command-line tool for importing csv into keychain",
        subcommands: [Import.self])

    init() {}
}

// MARK: - Commands

struct Credentials {
    let name: String
    let `protocol`: String
    let path: String
    let username: String
    let password: String

    init?(csvRow: String) {
        let columns = csvRow.components(separatedBy: ",")
        guard columns.count == 4 else { return nil }

        name = columns[0]
        let url = columns[1]
        guard
            let components = URLComponents(string: url),
            let scheme = components.scheme
            else { return nil }
        `protocol` = scheme.replacingOccurrences(of: "https", with: "htps")
        path = components.path
        username = columns[2]
        password = columns[3]
    }
}

struct Import: ParsableCommand, Debuggable {
    static let configuration = CommandConfiguration(abstract: "Import items into a keychain")

    @Argument(help: "The path to csv file")
    private var path: String

    @Flag(name: .shortAndLong, help: "Update item if it already exists (if omitted, the item cannot already exist)")
    private var update: Bool

    @Flag(name: .long, help: "Show extra logging for debugging purposes")
    var verbose: Bool

    private func addItem(credentials: Credentials) {
        var command = [
            "security", "add-internet-password",
            "-l", "\(credentials.name) (\(credentials.username))",
            "-s", credentials.name,
            "-p", credentials.path,
            "-a", credentials.username,
            "-t", "form",
            "-r", credentials.protocol,
            "-T", "/Applications/Safari.app",
            "-w", credentials.password
        ]

        if update {
            command.append("-U")
        }

        execute(command)
    }

    func run() throws {
        do {
            let csv = try String(contentsOfFile: path).trimmingCharacters(in: .whitespacesAndNewlines)
            let rows = csv.components(separatedBy: .newlines)
            rows.enumerated().forEach { (index, row) in
                guard index > 0 else { return } // Skip heading
                guard let credentials = Credentials(csvRow: row) else {
                    debugPrint("Skip row \(index)")
                    return
                }
                debugPrint("Adding row \(index)...")
                addItem(credentials: credentials)
                debugPrint("\(index) complete")
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Helpers

private protocol Debuggable {
    var verbose: Bool { get }
}

extension Debuggable {
    func debugPrint(_ message: String) {
        guard verbose else { return }
        print(message)
    }
}

private func execute(_ command: [String]) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = command
    let outputPipe = Pipe()
    process.standardOutput = outputPipe
    do {
        try process.run()
    } catch let error {
        print(error.localizedDescription)
    }

    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    guard
        let text = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
        !text.isEmpty
        else { return }
    print(text)
}

CSV2Keychain.main()

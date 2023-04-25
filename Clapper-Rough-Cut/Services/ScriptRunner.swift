//
//  ShellRunner.swift
//  Clapper Rough-Cut
//
//  Created by andrewoch on 10.04.2023.
//

import Foundation

class ScriptRunner {
    static func shell(_ args: [String]) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.arguments =  args
        task.launchPath = "usr/bin/env"
        task.standardInput = nil
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
    
    @discardableResult
    static func safeShell(_ args: [String]) throws -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.arguments =  args
        task.executableURL = URL(fileURLWithPath: "usr/bin/env")
        task.standardInput = nil

        try task.run()
        task.waitUntilExit()

        var data = pipe.fileHandleForReading.readDataToEndOfFile()
        var output = String(data: data, encoding: .utf8)!

        return output
    }
    
    
    
    @discardableResult
    static func safeShell(command: String, args: [String]) throws -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.arguments =  args
        task.executableURL = URL(fileURLWithPath: command)
        task.standardInput = nil

        try task.run()
        task.waitUntilExit()

        var data = pipe.fileHandleForReading.readDataToEndOfFile()
        var output = String(data: data, encoding: .utf8)!

        return output
    }

}

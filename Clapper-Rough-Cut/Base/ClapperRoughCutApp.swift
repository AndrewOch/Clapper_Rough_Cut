import SwiftUI
import PythonKit
import AppKit
import Python

@main
struct ClapperRoughCutApp: App {
    init() {
        let venvPath = setupPythonEnvironment()
        initializePython(venvPath: venvPath)
    }

    var body: some Scene {
        DocumentGroup(newDocument: { ClapperRoughCutDocument() }) { file in
            ContentView()
                .environmentObject(file.document)
                .focusedSceneValue(\.document, .getOnly(file.document))
        }
        .commands {
            ClapperRoughCutCommands()
        }
        Settings {
            SettingsView()
        }
    }
}

extension ClapperRoughCutApp {
    func setupPythonEnvironment() -> String {
        let fileManager = FileManager.default
        guard let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("Cannot find Application Support directory")
        }
        
        let appDirectory = appSupportDir.appendingPathComponent("Clapper Rough-Cut")
        if !fileManager.fileExists(atPath: appDirectory.path) {
            do {
                try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                fatalError("Unable to create directory: \(error)")
            }
        }
        
        let venvPath = appDirectory.appendingPathComponent("pythonvenv")
        createVirtualEnvironment(at: venvPath.path)
        installRequirements(pythonPath: "\(venvPath.path)/bin/python3.10", venvPath: venvPath.path)
        return venvPath.path
    }

    func createVirtualEnvironment(at path: String) {
        let python310Path = "/usr/local/bin/python3.10"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: python310Path)
        process.arguments = ["-m", "venv", path]
        runProcess(process)

        // Активируем виртуальную среду, устанавливая переменные окружения вручную
        setenv("PATH", "\(path)/bin:\(ProcessInfo.processInfo.environment["PATH"] ?? "")", 1)
        setenv("VIRTUAL_ENV", path, 1)
    }


    func installRequirements(pythonPath: String, venvPath: String) {
        guard let requirementsPath = Bundle.main.path(forResource: "requirements", ofType: "txt") else {
            print("No requirements.txt found. Skipping dependency installation.")
            return
        }

        var process = Process()
        process.executableURL = URL(fileURLWithPath: pythonPath)
        let nullFileURL = URL(fileURLWithPath: "/dev/null")
        process.standardOutput = FileHandle(forWritingAtPath: nullFileURL.path)
        process.arguments = ["-m", "pip", "install", "-r", requirementsPath]
        runProcess(process)

        guard let stdLibPath = Bundle.main.path(forResource: "python-stdlib", ofType: nil),
              let libDynloadPath = Bundle.main.path(forResource: "python-stdlib/lib-dynload", ofType: nil)
        else {
            print("Error setting up Python Libraries!")
            return
        }
        setenv("PYTHONHOME", "\(stdLibPath)", 1)
        setenv("PYTHONPATH", "\(stdLibPath):\(libDynloadPath):\(venvPath)/lib/python3.10/site-packages", 1)
    }

    func runProcess(_ process: Process) {
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            print("Error: \(error)")
        }
    }
    
    func isVirtualEnvironmentActivated() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", "if [ -n \"$VIRTUAL_ENV\" ]; then echo \"1\"; else echo \"0\"; fi"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        process.launch()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return output == "1"
    }

    func initializePython(venvPath: String) {
        if isVirtualEnvironmentActivated() {
            print("Виртуальная среда активирована.")
        } else {
            print("Виртуальная среда не активирована.")
        }
        if (Py_IsInitialized() == 0) {
            venvPath.withCString { cString in
                guard let pythonHome = Py_DecodeLocale(cString, nil) else {
                    fatalError("Unable to decode Python home path.")
                }
                defer { PyMem_RawFree(pythonHome) }

                Py_SetPythonHome(pythonHome)
                Py_Initialize()
            }
        }
        do {
            let numpyModule = try Python.attemptImport("numpy")
            let numpyPath = numpyModule.__file__
            
            print("NumPy is being imported from: \(numpyPath)")
        } catch {
            print("Error importing NumPy: \(error)")
        }
        
//        PythonLibrary.useVersion(3, 10)
        let sys = Python.import("sys")
        print("Python Version: \(sys.version_info.major).\(sys.version_info.minor)")
        print("Python Encoding: \(sys.getdefaultencoding().upper())")
        print("Python Path: \(sys.path)")

        _ = Python.import("math")
//        _ = Python.import("numpy")
    }
}

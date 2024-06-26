import AppKit
import UniformTypeIdentifiers

protocol ScriptFileOperations {
    func addScriptFile()
}

// MARK: - Script File Operations
extension ClapperRoughCutDocument: ScriptFileOperations {
    public func addScriptFile() {
        registerUndo()
        let dialog = NSOpenPanel()
        dialog.title                   = "Choose script file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.allowsMultipleSelection = false
        dialog.allowedContentTypes     = [UTType("org.openxmlformats.wordprocessingml.document")!, UTType(filenameExtension: "pages")!, .text]

        guard (dialog.runModal() == NSApplication.ModalResponse.OK) else { return }
        guard let result = dialog.url else { return }
        do {
            let fileContent = try String(contentsOf: result, encoding: .utf8)
            project.scriptFile = ScriptFile(url: result, text: fileContent)
        } catch let error as NSError {
            print("Script error: \(error.localizedDescription)")
        }
    }
}

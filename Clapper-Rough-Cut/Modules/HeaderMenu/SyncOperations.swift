protocol SyncOperations {
    func syncAllByTimecode()
    func syncAllByWaveform()
    func syncByTimecode(scenes: [FileSystemElement])
    func syncByWaveform(scenes: [FileSystemElement])
}

extension ClapperRoughCutDocument: SyncOperations {
    func syncAllByTimecode() {
        let scenes = project.fileSystem.allElements(where: { $0.isScene && $0.syncResult != nil })
        syncByTimecode(scenes: scenes)
    }

    func syncAllByWaveform() {
        let scenes = project.fileSystem.allElements(where: { $0.isScene && $0.syncResult != nil })
        syncByWaveform(scenes: scenes)
    }

    func syncByTimecode(scenes: [FileSystemElement]) {
        guard let audioSynchronizer = audioSynchronizer else {
            return
        }
        registerUndo()
        audioSynchronizer.syncByTimecode(scenes: scenes) { result in
            guard let result = result else { return }
            self.project.fileSystem.updateElement(withID: result.id, newValue: result)
        }
    }

    func syncByWaveform(scenes: [FileSystemElement]) {
        guard let audioSynchronizer = audioSynchronizer else {
            return
        }
        registerUndo()
        audioSynchronizer.syncByWaveform(scenes: scenes) { result in
            guard let result = result else { return }
            self.project.fileSystem.updateElement(withID: result.id, newValue: result)
        }
    }
}

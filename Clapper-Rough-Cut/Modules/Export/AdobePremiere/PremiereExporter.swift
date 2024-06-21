import Foundation

class PremiereExporter: ProjectExporter {
    func exportScene(scene: FileSystemElement, elements: [FileSystemElement], to url: URL, fps: Double = 25) {
        let sortedElements = elements.sorted { $0.matchingAccuracy > $1.matchingAccuracy }
        let premiereBin = createPremiereBin(from: sortedElements)
        let premiereSequence = createPremiereSequence(scene: scene, from: sortedElements, fps: fps)
        let premiereProject = PremiereProject(name: scene.title, bins: [premiereBin, PremiereBin(name: "Sequences", children: [premiereSequence])])
        let xmlDocument = premiereProject.toXML()

        do {
            let xmlData = xmlDocument.xmlData(options: .nodePrettyPrint)
            try xmlData.write(to: url.appendingPathComponent(scene.title).appendingPathExtension("xml"))
        } catch {
            print("Failed to write XML data: \(error)")
        }
    }

    private func createPremiereSequence(scene: FileSystemElement, from elements: [FileSystemElement], fps: Double) -> PremiereSequence {
        var clips = [PremiereClip]()
        var startTime = 0

        for element in elements {
            guard let url = element.url else { continue }

            let duration = Int(element.duration ?? 0 * fps)
            let endTime = startTime + duration

            let file = PremiereFile(
                id: UUID().uuidString,
                name: element.title,
                pathurl: url.absoluteString,
                duration: duration,
                width: 1920,
                height: 1080,
                pixelAspectRatio: "square",
                samplerate: 48000
            )
            let markers = createMarkers(from: element.subtitles, fps: fps)

            let clip = PremiereClip(
                id: element.id.uuidString,
                name: element.title,
                start: startTime,
                end: endTime,
                inPoint: 0,
                outPoint: duration,
                file: file,
                markers: markers
            )

            clips.append(clip)
            startTime = endTime
        }

        return PremiereSequence(name: scene.title, clips: clips)
    }

    private func createPremiereBin(from elements: [FileSystemElement]) -> PremiereBin {
        var files = [PremiereFile]()

        for element in elements {
            guard let url = element.url else { continue }

            let duration = Int(element.duration ?? 0 * 25) // 25 is default fps here
            let file = PremiereFile(
                id: UUID().uuidString,
                name: element.title,
                pathurl: url.absoluteString,
                duration: duration,
                width: 1920,
                height: 1080,
                pixelAspectRatio: "square",
                samplerate: 48000
            )

            files.append(file)
        }

        return PremiereBin(name: "Files", children: files)
    }

    private func createMarkers(from subtitles: [Subtitle]?, fps: Double) -> [PremiereMarker] {
        guard let subtitles = subtitles else { return [] }

        var markers = [PremiereMarker]()

        for subtitle in subtitles {
            if subtitle.accuracy == 0 {
                let startMarker = PremiereMarker(
                    inPoint: Int(subtitle.startTime * fps),
                    outPoint: Int(subtitle.endTime * fps),
                    name: "Не по сценарию!",
                    comment: "Можно удалить",
                    type: "Comment"
                )

                markers.append(startMarker)
            }
        }

        return markers
    }
}

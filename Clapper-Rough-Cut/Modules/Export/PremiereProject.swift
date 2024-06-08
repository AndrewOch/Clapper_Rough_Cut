import Foundation

class PremiereProject {
    var name: String
    var sequences: [PremiereSequence]
    
    init(name: String, sequences: [PremiereSequence]) {
        self.name = name
        self.sequences = sequences
    }
    
    func toXML() -> XMLDocument {
        let root = XMLElement(name: "xmeml")
        root.setAttributesWith(["version": "4"])
        
        let projectElement = XMLElement(name: "project")
        let nameElement = XMLElement(name: "name", stringValue: name)
        projectElement.addChild(nameElement)
        
        let childrenElement = XMLElement(name: "children")
        for sequence in sequences {
            childrenElement.addChild(sequence.toXMLElement())
        }
        projectElement.addChild(childrenElement)
        root.addChild(projectElement)
        
        return XMLDocument(rootElement: root)
    }
}

class PremiereSequence {
    var name: String
    var clips: [PremiereClip]
    
    init(name: String, clips: [PremiereClip]) {
        self.name = name
        self.clips = clips
    }
    
    func toXMLElement() -> XMLElement {
        let sequenceElement = XMLElement(name: "sequence")
        let nameElement = XMLElement(name: "name", stringValue: name)
        sequenceElement.addChild(nameElement)
        
        let mediaElement = XMLElement(name: "media")
        let videoElement = XMLElement(name: "video")
        let trackElement = XMLElement(name: "track")
        
        for clip in clips {
            trackElement.addChild(clip.toXMLElement())
        }
        
        videoElement.addChild(trackElement)
        mediaElement.addChild(videoElement)
        sequenceElement.addChild(mediaElement)
        
        return sequenceElement
    }
}

class PremiereClip {
    var id: String
    var name: String
    var start: Int
    var end: Int
    var inPoint: Int
    var outPoint: Int
    var file: PremiereFile
    var markers: [PremiereMarker]
    
    init(id: String, name: String, start: Int, end: Int, inPoint: Int, outPoint: Int, file: PremiereFile, markers: [PremiereMarker] = []) {
        self.id = id
        self.name = name
        self.start = start
        self.end = end
        self.inPoint = inPoint
        self.outPoint = outPoint
        self.file = file
        self.markers = markers
    }
    
    func toXMLElement() -> XMLElement {
        let clipElement = XMLElement(name: "clipitem")
        clipElement.setAttributesWith(["id": id])
        
        let nameElement = XMLElement(name: "name", stringValue: name)
        let startElement = XMLElement(name: "start", stringValue: "\(start)")
        let endElement = XMLElement(name: "end", stringValue: "\(end)")
        let inElement = XMLElement(name: "in", stringValue: "\(inPoint)")
        let outElement = XMLElement(name: "out", stringValue: "\(outPoint)")
        
        let fileElement = file.toXMLElement()
        
        clipElement.addChildren([nameElement, startElement, endElement, inElement, outElement, fileElement])
        
        for marker in markers {
            clipElement.addChild(marker.toXMLElement())
        }
        
        return clipElement
    }
}

class PremiereFile {
    var name: String
    var pathurl: String
    
    init(name: String, pathurl: String) {
        self.name = name
        self.pathurl = pathurl
    }
    
    func toXMLElement() -> XMLElement {
        let fileElement = XMLElement(name: "file")
        let nameElement = XMLElement(name: "name", stringValue: name)
        let pathurlElement = XMLElement(name: "pathurl", stringValue: pathurl)
        fileElement.addChildren([nameElement, pathurlElement])
        return fileElement
    }
}

class PremiereMarker {
    var inPoint: Int
    var outPoint: Int
    var name: String
    var comment: String
    var type: String
    
    init(inPoint: Int, outPoint: Int, name: String, comment: String, type: String) {
        self.inPoint = inPoint
        self.outPoint = outPoint
        self.name = name
        self.comment = comment
        self.type = type
    }
    
    func toXMLElement() -> XMLElement {
        let markerElement = XMLElement(name: "marker")
        let inElement = XMLElement(name: "in", stringValue: "\(inPoint)")
        let outElement = XMLElement(name: "out", stringValue: "\(outPoint)")
        let nameElement = XMLElement(name: "name", stringValue: name)
        let commentElement = XMLElement(name: "comment", stringValue: comment)
        let typeElement = XMLElement(name: "type", stringValue: type)
        
        markerElement.addChildren([inElement, outElement, nameElement, commentElement, typeElement])
        return markerElement
    }
}

extension XMLElement {
    func addChildren(_ children: [XMLElement]) {
        for child in children {
            self.addChild(child)
        }
    }
}

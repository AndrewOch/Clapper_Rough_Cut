import Foundation

class PremiereProject {
    var name: String
    var bins: [PremiereBin]
    
    init(name: String, bins: [PremiereBin]) {
        self.name = name
        self.bins = bins
    }
    
    func toXML() -> XMLDocument {
        let root = XMLElement(name: "xmeml")
        root.setAttributesWith(["version": "4"])
        
        let projectElement = XMLElement(name: "project")
        let nameElement = XMLElement(name: "name", stringValue: name)
        projectElement.addChild(nameElement)
        
        let childrenElement = XMLElement(name: "children")
        for bin in bins {
            childrenElement.addChild(bin.toXMLElement())
        }
        projectElement.addChild(childrenElement)
        root.addChild(projectElement)
        
        let importOptions = XMLElement(name: "importoptions")
        importOptions.addChildren([
            XMLElement(name: "createnewproject", stringValue: "FALSE"),
            XMLElement(name: "defsequencepresetname", stringValue: "useFirstClipSettings"),
            XMLElement(name: "displaynonfatalerrors", stringValue: "TRUE"),
            XMLElement(name: "filterreconnectmediafiles", stringValue: "TRUE"),
            XMLElement(name: "filterincludemarkers", stringValue: "TRUE"),
            XMLElement(name: "filterincludeeffects", stringValue: "TRUE"),
            XMLElement(name: "filterincludesequencesettings", stringValue: "FALSE")
        ])
        root.addChild(importOptions)
        
        let xmlDocument = XMLDocument(rootElement: root)
        xmlDocument.characterEncoding = "UTF-8"
        xmlDocument.version = "1.0"
        
        return xmlDocument
    }
}

class PremiereBin {
    var name: String
    var children: [PremiereElement] // PremiereElement - это общий протокол для всех элементов
    
    init(name: String, children: [PremiereElement]) {
        self.name = name
        self.children = children
    }
    
    func toXMLElement() -> XMLElement {
        let binElement = XMLElement(name: "bin")
        let nameElement = XMLElement(name: "name", stringValue: name)
        binElement.addChild(nameElement)
        
        let childrenElement = XMLElement(name: "children")
        for child in children {
            childrenElement.addChild(child.toXMLElement())
        }
        binElement.addChild(childrenElement)
        
        return binElement
    }
}

protocol PremiereElement {
    func toXMLElement() -> XMLElement
}

class PremiereSequence: PremiereElement {
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

class PremiereClip: PremiereElement {
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

class PremiereFile: PremiereElement {
    var id: String
    var name: String
    var pathurl: String
    var duration: Int
    var width: Int
    var height: Int
    var pixelAspectRatio: String
    var samplerate: Int
    
    init(id: String, name: String, pathurl: String, duration: Int, width: Int, height: Int, pixelAspectRatio: String, samplerate: Int) {
        self.id = id
        self.name = name
        self.pathurl = pathurl
        self.duration = duration
        self.width = width
        self.height = height
        self.pixelAspectRatio = pixelAspectRatio
        self.samplerate = samplerate
    }
    
    func toXMLElement() -> XMLElement {
        let fileElement = XMLElement(name: "file")
        fileElement.setAttributesWith(["id": id])
        
        let nameElement = XMLElement(name: "name", stringValue: name)
        let pathurlElement = XMLElement(name: "pathurl", stringValue: "file://localhost\(pathurl)")
        let durationElement = XMLElement(name: "duration", stringValue: "\(duration)")
        
        let rateElement = XMLElement(name: "rate")
        let ntscElement = XMLElement(name: "ntsc", stringValue: "FALSE")
        let timebaseElement = XMLElement(name: "timebase", stringValue: "25")
        rateElement.addChildren([ntscElement, timebaseElement])
        
        let mediaElement = XMLElement(name: "media")
        
        let videoElement = XMLElement(name: "video")
        let samplecharacteristicsElement = XMLElement(name: "samplecharacteristics")
        let widthElement = XMLElement(name: "width", stringValue: "\(width)")
        let heightElement = XMLElement(name: "height", stringValue: "\(height)")
        let pixelaspectratioElement = XMLElement(name: "pixelaspectratio", stringValue: pixelAspectRatio)
        samplecharacteristicsElement.addChildren([widthElement, heightElement, pixelaspectratioElement])
        videoElement.addChild(samplecharacteristicsElement)
        
        let audioElement = XMLElement(name: "audio")
        let channelcountElement = XMLElement(name: "channelcount", stringValue: "2")
        let audiosamplecharacteristicsElement = XMLElement(name: "samplecharacteristics")
        let depthElement = XMLElement(name: "depth", stringValue: "16")
        let samplerateElement = XMLElement(name: "samplerate", stringValue: "\(samplerate)")
        audiosamplecharacteristicsElement.addChildren([depthElement, samplerateElement])
        audioElement.addChildren([channelcountElement, audiosamplecharacteristicsElement])
        
        mediaElement.addChildren([videoElement, audioElement])
        
        fileElement.addChildren([nameElement, pathurlElement, durationElement, rateElement, mediaElement])
        return fileElement
    }
}

class PremiereMarker: PremiereElement {
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

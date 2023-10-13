import SwiftUI

enum SystemImage: String {
    case doc = "doc"
    case folder = "folder"
    case xmark = "xmark"
    case film = "film"
    case rectangleAndPencilAndEllipsis = "rectangle.and.pencil.and.ellipsis"
    case filmStack = "film.stack"
    case squareAndArrowDown = "square.and.arrow.down"
    case rectanglePortraitAndArrowRight = "rectangle.portrait.and.arrow.right"
    case plus = "plus"
    case chevronRight = "chevron.right"
    case chevronDown = "chevron.down"
    case mic = "mic"
    case micFill = "mic.fill"
    case videoSquare = "video.square"
    case videoFill = "video.fill"
    case videoSquareFill = "video.square.fill"
    case folderFill = "folder.fill"
    case command = "command"
    case shift = "shift"
    case control = "control"
    case option = "option"
    case gearshape = "gearshape"
    case person = "person"
    case rectangleStack = "rectangle.stack"
    case rectangleStackFill = "rectangle.stack.fill"

    var imageView: Image {
        Image(systemName: self.rawValue)
    }
}

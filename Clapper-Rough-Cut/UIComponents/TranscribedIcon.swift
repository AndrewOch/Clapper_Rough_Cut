import SwiftUI

struct TranscribedIcon: View {
    var body: some View {
        SystemImage.rectangleAndPencilAndEllipsis.imageView
    }
}

struct VideoClassificationIcon: View {
    var body: some View {
        SystemImage.textBelowPhoto.imageView
    }
}

struct AudioClassificationIcon: View {
    var body: some View {
        SystemImage.waveformCircle.imageView
    }
}

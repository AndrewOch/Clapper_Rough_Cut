import SwiftUI
import AVKit

struct MediaPlayerView: View {
    @Binding var element: FileSystemElement
    @State private var player: CustomVideoPlayer?
    @State private var isPlaying = false

    var body: some View {
        VStack {
            player?
                .playbackControls(false)
            controls
        }
        .onAppear {
            if let url = element.url {
                player = CustomVideoPlayer(url: url, playing: $isPlaying)
            }
        }
        .onChange(of: self.element) { newValue in
            if let url = newValue.url {
                player = CustomVideoPlayer(url: url, playing: $isPlaying)
            }
        }
    }

    var controls: some View {
        HStack(alignment: .center, spacing: 20) {
                ImageButton<ImageButtonSystemStyle>(image: SystemImage.backwardFill.imageView,
                                                    enabled: .constant(true),
                                                    action: { player?.toStart() })
                ImageButton<ImageButtonSystemStyle>(image: SystemImage.goBackward5.imageView,
                                                    enabled: .constant(true),
                                                    action: { player?.backwards5sec() })
                ImageButton<ImageButtonSystemStyle>(image: isPlaying ? SystemImage.pauseFill.imageView : SystemImage.playFill.imageView,
                                                    enabled: .constant(true),
                                                    action: { isPlaying.toggle() })
                ImageButton<ImageButtonSystemStyle>(image: SystemImage.goForward5.imageView,
                                                    enabled: .constant(true),
                                                    action: { player?.forward5sec() })
                ImageButton<ImageButtonSystemStyle>(image: SystemImage.forwardFill.imageView,
                                                    enabled: .constant(true),
                                                    action: { player?.toEnd() })
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
}

public struct CustomVideoPlayer {
    var videoURL: URL
    var showsPlaybackControls: Bool = true
    var isMuted: Binding<Bool>
    var videoGravity: AVLayerVideoGravity = .resizeAspect
    var loop: Binding<Bool> = .constant(false)
    var isPlaying: Binding<Bool>

    private var _toStart: Bool = false
    private var _toEnd: Bool = false
    private var _seekBack: Bool = false
    private var _seekForward: Bool = false

    public init(url: URL, playing: Binding<Bool> = .constant(false), muted: Binding<Bool> = .constant(false)) {
        videoURL = url
        isPlaying = playing
        isMuted = muted
    }

    mutating func toStart() {
        _toStart = true
    }

    mutating func toEnd() {
        _toEnd = true
    }

    mutating func backwards5sec() {
        _seekBack = true
    }

    mutating func forward5sec() {
        _seekForward = true
    }
}

extension CustomVideoPlayer: NSViewRepresentable {
    public func makeNSView(context: Context) -> AVPlayerView {
        let videoView = AVPlayerView()
        videoView.player = AVPlayer(url: videoURL)
        let videoCoordinator = context.coordinator
        videoCoordinator.player = videoView.player
        videoCoordinator.url = videoURL
        videoCoordinator.customPlayer = self
        return videoView
    }

    public func updateNSView(_ videoView: AVPlayerView, context: Context) {
        if videoURL != context.coordinator.url {
            videoView.player = AVPlayer(url: videoURL)
            context.coordinator.player = videoView.player
            context.coordinator.url = videoURL
        }
        if showsPlaybackControls {
            videoView.controlsStyle = .inline
        } else {
            videoView.controlsStyle = .none
        }
        videoView.player?.isMuted = isMuted.wrappedValue
        videoView.player?.volume = isMuted.wrappedValue ? 0 : 1
        videoView.videoGravity = videoGravity
        context.coordinator.togglePlay(isPlaying: isPlaying.wrappedValue)
        if _toStart { context.coordinator.toStart() }
        if _toEnd { context.coordinator.toEnd() }
        if _seekBack { context.coordinator.fiveSecBack() }
        if _seekForward { context.coordinator.fiveSecForward() }
    }

    public func makeCoordinator() -> VideoCoordinator {
        return VideoCoordinator(video: self)
    }
}

extension CustomVideoPlayer {
    // MARK: - Coordinator
    public class VideoCoordinator: NSObject {
        var customPlayer: CustomVideoPlayer?
        let video: CustomVideoPlayer
        var timeObserver: Any?
        var url: URL?
        var player: AVPlayer?

        init(video: CustomVideoPlayer){
            self.video = video
            super.init()
        }

        @objc public func updateStatus() {
            if let player = player {
                video.isPlaying.wrappedValue = player.rate > 0
            } else {
                video.isPlaying.wrappedValue = false
            }
        }

        func toStart() {
            player?.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
            customPlayer?._toStart = false
        }

        func fiveSecBack() {
            player?.seek(to: (player?.currentTime() ?? CMTime(seconds: 0, preferredTimescale: 1)) - CMTime(seconds: 5, preferredTimescale: 1))
            customPlayer?._seekBack = false
        }

        func fiveSecForward() {
            player?.seek(to: (player?.currentTime() ?? CMTime(seconds: 0, preferredTimescale: 1)) + CMTime(seconds: 5, preferredTimescale: 1))
            customPlayer?._seekForward = false
        }

        func toEnd() {
            let duration = player?.currentItem?.duration
            player?.seek(to: duration ?? .zero)
            customPlayer?._toEnd = false
        }

        func togglePlay(isPlaying: Bool) {
            if isPlaying {
                if player?.currentItem?.duration == player?.currentTime() {
                    player?.seek(to: .zero)
                    player?.play()
                }
                player?.play()
            } else {
                player?.pause()
            }
        }
    }
}

// MARK: - Modifiers
extension CustomVideoPlayer {
    public func playbackControls(_ value: Bool) -> CustomVideoPlayer {
        var new = self
        new.showsPlaybackControls = value
        return new
    }

    public func isMuted(_ value: Bool) -> CustomVideoPlayer {
        return isMuted(.constant(value))
    }

    public func isMuted(_ value: Binding<Bool>) -> CustomVideoPlayer {
        var new = self
        new.isMuted = value
        return new
    }

    public func isPlaying(_ value: Bool) -> CustomVideoPlayer {
        let new = self
        new.isPlaying.wrappedValue = value
        return new
    }

    public func isPlaying(_ value: Binding<Bool>) -> CustomVideoPlayer {
        var new = self
        new.isPlaying = value
        return new
    }

    public func videoGravity(_ value: AVLayerVideoGravity) -> CustomVideoPlayer {
        var new = self
        new.videoGravity = value
        return new
    }

    public func loop(_ value: Bool) -> CustomVideoPlayer {
        self.loop.wrappedValue = value
        return self
    }

    public func loop(_ value: Binding<Bool>) -> CustomVideoPlayer {
        var new = self
        new.loop = value
        return new
    }
}

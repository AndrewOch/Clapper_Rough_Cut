import SwiftUI
import AVKit

struct MediaPlayerView: View {
    @Binding var element: FileSystemElement
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @Binding var currentTime: Double
    @State private var isDragging = false

    var body: some View {
        VStack(spacing: 0) {
            if let player = player {
                CustomAVPlayerView(player: player)
                    .overlay {
                        VStack(spacing: 2) {
                            Spacer()
                            if let duration = player.currentItem?.duration.seconds, duration.isFinite, duration > 0.0 {
                                HStack {
                                    CustomBindedLabel<BodySmallStyle>(text: .getOnly(Formatter.formatDuration(duration: currentTime)))
                                        .foregroundColor(Asset.white.swiftUIColor)
                                    Spacer()
                                    CustomBindedLabel<BodySmallStyle>(text: .getOnly("-\(Formatter.formatDuration(duration: (duration - currentTime)))"))
                                        .foregroundColor(Asset.white.swiftUIColor)
                                }
                                .padding(.horizontal)
                                Slider(value: $currentTime, in: 0.0...duration, onEditingChanged: { editing in
                                    isDragging = editing
                                })
                                .onChange(of: currentTime) { _ in
                                    if isDragging {
                                        player.seek(to: CMTime(seconds: currentTime, preferredTimescale: 1))
                                    }
                                }
                            }
                        }
                        .offset(y: 8)
                    }
            }
            controls
        }
        .onAppear {
            if let url = element.url {
                player = AVPlayer(url: url)
                configurePlayerObserver()
            }
        }
        .onChange(of: self.element) { newValue in
            if let url = newValue.url {
                player = AVPlayer(url: url)
                configurePlayerObserver()
            }
        }
    }

    private var controls: some View {
        HStack(alignment: .center, spacing: 20) {
            ImageButton<ImageButtonSystemStyle>(image: SystemImage.backwardFill.imageView,
                                                enabled: .constant(true),
                                                action: { toStart() })
            ImageButton<ImageButtonSystemStyle>(image: SystemImage.goBackward5.imageView,
                                                enabled: .constant(true),
                                                action: { fiveSecBack() })
            ImageButton<ImageButtonSystemStyle>(image: isPlaying ? SystemImage.pauseFill.imageView : SystemImage.playFill.imageView,
                                                enabled: .constant(true),
                                                action: { togglePlay() })
            ImageButton<ImageButtonSystemStyle>(image: SystemImage.goForward5.imageView,
                                                enabled: .constant(true),
                                                action: { fiveSecForward() })
            ImageButton<ImageButtonSystemStyle>(image: SystemImage.forwardFill.imageView,
                                                enabled: .constant(true),
                                                action: { toEnd() })
        }
        .padding(.top, 16)
        .padding(.bottom, 20)
    }

    func toStart() {
        player?.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
    }

    func fiveSecBack() {
        player?.seek(to: (player?.currentTime() ?? CMTime(seconds: 0, preferredTimescale: 1)) - CMTime(seconds: 5, preferredTimescale: 1))
    }

    func fiveSecForward() {
        player?.seek(to: (player?.currentTime() ?? CMTime(seconds: 0, preferredTimescale: 1)) + CMTime(seconds: 5, preferredTimescale: 1))
    }

    func toEnd() {
        let duration = player?.currentItem?.duration
        player?.seek(to: duration ?? .zero)
    }

    func togglePlay() {
        isPlaying.toggle()
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

    private func configurePlayerObserver() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: nil) { _ in
            isPlaying = false
        }
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 30), queue: .main) { time in
            self.currentTime = time.seconds
        }
    }
}

struct CustomAVPlayerView: NSViewRepresentable {
    var player: AVPlayer

    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.controlsStyle = .none
        view.player = player
        return view
    }

    public func updateNSView(_ videoView: AVPlayerView, context: Context) {
        videoView.player = player
    }
}

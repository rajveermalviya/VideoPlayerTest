//
//  ContentView.swift
//  VideoPlayerTest
//
//  Created by Rajesh Malviya on 13/04/24.
//

import SwiftUI
import AVKit

class PlayerObserver: NSObject {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges), let playerItem = object as? AVPlayerItem {
            if let timeRanges = playerItem.loadedTimeRanges.map({ $0.timeRangeValue }) as? [CMTimeRange] {
                let loadedSeconds = timeRanges.reduce(0.0) { $0 + CMTimeGetSeconds($1.duration) }
                let loadedTime = formatSecondsToHMS(loadedSeconds)
                print("Loaded Time: \(loadedTime)")
            }
        }
    }

    private func formatSecondsToHMS(_ seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: seconds) ?? ""
    }
}

struct ContentView: View {
    private let player: AVPlayer
    private let playerObserver = PlayerObserver()

    init() {
//        let headers: [String: String] = authHeader(email: "", apiKey: "")
        let headers: [String: String] = [:]
        let asset = AVURLAsset(
//            url: URL(string: "https://chat.zulip.org/user_uploads/2/89/vqMGSRsv-GMfJ418Icdf5T_F/Coffee-Run-Blender-Open-Movie.mp4")!,
//            url: URL(string: "https://chat.zulip.org/user_uploads/2/16/lLp5Fa4MKxYwpds2pc4wdUTx/Big-Buck-Bunny.mp4")!,
//            url: URL(string: "https://chat.zulip.org/user_uploads/2/78/_KoRecCHZTFrVtyTKCkIh5Hq/Big-Buck-Bunny.webm")!,
            url: URL(string: "https://f000.backblazeb2.com/file/rm-zulip-video-test/Big-Buck-Bunny.mp4")!,
//            url: URL(string: "https://f000.backblazeb2.com/file/rm-zulip-video-test/bbb_sunflower_1080p_30fps_normal.mp4")!,
            options: [
                "AVURLAssetHTTPHeaderFieldsKey": headers,
            ])
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        playerItem.addObserver(playerObserver,
            forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: [.new, .initial], context: nil)
    }

    var body: some View {
        VideoPlayer(player: player)
            .onDisappear {
                player.currentItem?.removeObserver(playerObserver, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
            }
    }
}

func authHeader(email: String, apiKey: String) -> [String: String] {
    let key = "\(email):\(apiKey)".data(using: .utf8)
    let keyBase64 = key?.base64EncodedString() ?? ""
    return ["Authorization": "Basic \(keyBase64)"]
}

#Preview {
    ContentView()
}

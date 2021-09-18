//
//  VlcPlayerView.swift
//  VLCTester
//
//  Created by ShayBC on 18/09/21.
//

import SwiftUI
import AVFoundation

class VlcPlayerView: UIView, VLCMediaPlayerDelegate, ObservableObject
{
    @Published var currentTimeString: String = "00:00"
    @Published var videoLength: Int32 = 100 // setting some positive value to avoid div by zero and NAN exceptions
    @Published var videoCurrentTime: Int32 = 0
    @Published var percentagePlayedSoFar: Float = 0.0
    @Published var videoLengthString: String = "--:--"

    let mediaPlayer: VLCMediaPlayer = VLCMediaPlayer()
    
    private var playerTimeChangedNotification: NSObjectProtocol?
    private var playerStateChangedNotification: NSObjectProtocol?

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        if !Config.videoURLString.isEmpty
        {
            mediaPlayer.media = VLCMedia(url: URL(string: Config.videoURLString)!)
            mediaPlayer.setDeinterlaceFilter(nil) // this should reduce memory consumption due to VLC bug
            mediaPlayer.delegate = self
            mediaPlayer.drawable = self
            
            playerStateChangedNotification = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: VLCMediaPlayerStateChanged), object: mediaPlayer, queue: nil,
                                   using: self.playerStateChanged)

            playerTimeChangedNotification = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: VLCMediaPlayerTimeChanged), object: mediaPlayer, queue: nil, using: self.playerTimeChanged)
            
            mediaPlayer.play()
        }
    }
    
    func unregisterObservers()
    {
        NotificationCenter.default.removeObserver(playerTimeChangedNotification as Any)
        NotificationCenter.default.removeObserver(playerStateChangedNotification as Any)
    }
    
    deinit
    {
        print("Player has been destroyed")
    }
    
    public func startPlayer()
    {
        mediaPlayer.audio.isMuted = false
        mediaPlayer.audio.volume = 100
        mediaPlayer.play()
    }

    public func stopPlayer()
    {
        mediaPlayer.stop()
        unregisterObservers()
        Config.player = nil
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
      super.layoutSubviews()
    }
    
    func playerStateChanged(_ notification: Notification)
    {
        videoLength = mediaPlayer.media.length.intValue
        videoLengthString = mediaPlayer.media.length.stringValue
    }
    
    func playerTimeChanged(_ notification: Notification)
    {
        currentTimeString = mediaPlayer.time.stringValue
        videoCurrentTime = mediaPlayer.time.intValue
        percentagePlayedSoFar = Float(videoCurrentTime) / Float(videoLength)
    }
}

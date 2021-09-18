//
//  VlcPlayerCopyView.swift
//  VLCTester
//
//  Created by ShayBC on 18/09/21.
//

import SwiftUI
import AVFoundation

class VlcPlayerCopyView: UIView, VLCMediaPlayerDelegate
{
    let mediaPlayer: VLCMediaPlayer = VLCMediaPlayer()
    private var isFirstPlay: Bool = true // this trick is to overcome VLC bug that first play event never received
    private var playerStateChangedNotification: NSObjectProtocol?

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        if !Config.videoURLString.isEmpty
        {
            mediaPlayer.setDeinterlaceFilter(nil) // this should reduce memory consumption due to VLC bug
            mediaPlayer.media = Config.player?.mediaPlayer.media
            mediaPlayer.delegate = self
            mediaPlayer.drawable = self

            playerStateChangedNotification = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: VLCMediaPlayerStateChanged), object: mediaPlayer, queue: nil,
                                   using: self.playerStateChanged)

            mediaPlayer.audio.isMuted = true
            mediaPlayer.play()
        }
    }
    
    func unregisterObservers()
    {
        NotificationCenter.default.removeObserver(playerStateChangedNotification as Any)
    }
    
    deinit
    {
        print("deinit()")
    }

    public func stopPlayer()
    {
        mediaPlayer.stop()
        unregisterObservers()
        Config.playerCopy = nil
    }

    required init?(coder: NSCoder)
    {
      fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews()
    {
        super.layoutSubviews()
    }
    
    func playerStateChanged(_ notification: Notification)
    {
        if(mediaPlayer.state == VLCMediaPlayerState.buffering && isFirstPlay)
        {
            isFirstPlay = false
            self.mediaPlayer.time = Config.player!.mediaPlayer.time
        }
    }
}

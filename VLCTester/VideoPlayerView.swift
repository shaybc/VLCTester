//
//  VideoPlayerView.swift
//  VLCTester
//
//  Created by ShayBC on 18/09/21.
//

import SwiftUI
import GameController

struct VideoPlayerView: View {
    @State var isShowInfoPanel: Bool = false
    
    func playPauseVideo()
    {
        if(Config.player?.mediaPlayer.isPlaying ?? true)
        {
            Config.player?.mediaPlayer.pause()
            isShowInfoPanel = true
        }
        else
        {
            Config.player?.mediaPlayer.play()
            isShowInfoPanel = false
        }
    }
    
    var body: some View {
        
        ZStack
        {
            VlcPlayer()
                .edgesIgnoringSafeArea(.all)
                .onDisappear
                {
                    Config.player?.stopPlayer()
                }
            
                .fullScreenCover(isPresented: $isShowInfoPanel)
                {
                    VStack(spacing: 0)
                    {
                        /* media info panel */
                        HStack(spacing: 0)
                        {
                            VStack(spacing: 0)
                            {
                                // place holder
                            }
                            .frame(maxWidth: UIScreen.screenWidth - 40, maxHeight: 350, alignment: Alignment.leading)
                            .background(Color.white)
                            .cornerRadius(40, corners: [.bottomLeft, .bottomRight])
                        }
                        .frame(maxWidth: .infinity, alignment: Alignment.top)
                        
                        /* playback progress */
                        VideoProgressBar(isShowInfoPanel: $isShowInfoPanel)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: Alignment.leading)
                    .edgesIgnoringSafeArea(.all)
                }
        }

        .focusable()
        
        // on press action
        .onLongPressGesture(minimumDuration: 0.01, perform:
        {
            playPauseVideo()
        })
        
        .onPlayPauseCommand
        {
            playPauseVideo()
        }
    }
}

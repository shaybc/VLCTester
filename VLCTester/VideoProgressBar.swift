//
//  VideoProgressBar.swift
//  VLCTester
//
//  Created by ShayBC on 18/09/21.
//

import SwiftUI

struct VideoProgressBar: View {
    @ObservedObject var player: VlcPlayerView = Config.player!

    @Binding var isShowInfoPanel: Bool

    let maxProgressIndicatorWidth: CGFloat = 1750
    let skimmingSteps: CGFloat = 5.0
    let showVideoLengthUnyilProgressPercent: CGFloat = 0.96
    
    @State var slideTo: CGFloat = 0
    @State var uiUpdateCounter: Int = 0
    @State var animationDuration: CGFloat = 0.5

    func getMediaNewTime() -> VLCTime
    {
        let slideToPercentage: CGFloat = slideTo / maxProgressIndicatorWidth
        let slideToMilliseconds: CGFloat = CGFloat(player.videoLength) * slideToPercentage
        let slideToMediaMilliseconds: Int32 = player.videoCurrentTime + Int32(floor(slideToMilliseconds))
        return VLCTime(int: slideToMediaMilliseconds)
    }
    
    func playPauseVideo()
    {
        if(!(Config.player?.mediaPlayer.isPlaying)!)
        {
            // if play was pressed after skimming, then set player new time to the milliseconds the user skimmed to
            if(slideTo != 0)
            {
                Config.player?.mediaPlayer.time = Config.playerCopy?.mediaPlayer.time // set play position to new milliseconds
                player.currentTimeString = Config.playerCopy!.mediaPlayer.time.stringValue // set new time string
                player.videoCurrentTime = Config.playerCopy!.mediaPlayer.time.intValue // set new time int
                player.percentagePlayedSoFar = Float(player.videoCurrentTime) / Float(player.videoLength) // set percentage played so far
            }

            Config.player?.startPlayer()
            isShowInfoPanel = false
            slideTo = 0
        }
    }

    var body: some View
    {
        let currentPosition: CGFloat = (maxProgressIndicatorWidth * CGFloat(player.percentagePlayedSoFar))
        
        HStack(spacing: 0)
        {
            ZStack
            {
                /* full progress background */
                HStack(spacing: 0)
                {
                    Rectangle()
                        .frame(maxWidth: maxProgressIndicatorWidth, maxHeight: 15)
                        .cornerRadius(20)
                        .foregroundColor(Color.gray.opacity(0.3))
                }
                .frame(maxWidth: .infinity, alignment: Alignment.leading)

                /* video frame thumbnail */
                HStack(spacing: 0)
                {
                    VlcPlayerCopy()
                        .frame(width: Config.tvEpisodeImage.width, height: Config.tvEpisodeImage.height)
                        .offset(CGSize(width: ((Config.tvEpisodeImage.width / 2) * -1) + (maxProgressIndicatorWidth * CGFloat(player.percentagePlayedSoFar)) + slideTo, height: -225))
                        .animation(.easeInOut(duration: animationDuration), value: slideTo)
                        .onDisappear
                        {
                            Config.playerCopy!.stopPlayer()
                        }
                }
                .frame(maxWidth: .infinity, alignment: Alignment.leading)
                
                
                
                /* video play so far progress */
                HStack(spacing: 0)
                {
                    Rectangle()
                        .frame(maxWidth: (maxProgressIndicatorWidth * CGFloat(player.percentagePlayedSoFar)), maxHeight: 15, alignment: Alignment.leading)
                        .cornerRadius(20, corners: [.topLeft, .bottomLeft])
                        .foregroundColor(Color.white)
                }
                .frame(maxWidth: .infinity, alignment: Alignment.leading)
                
                
                
                /* Video played so far String */
                HStack(spacing: 0)
                {
                    Text(player.currentTimeString)
                        .foregroundColor(Color.white)
                        .font(Font.system(size: 28))
                        .offset(CGSize(width: -35 + (maxProgressIndicatorWidth * CGFloat(player.percentagePlayedSoFar)) + slideTo, height: -45))
                        .animation(.easeInOut(duration: animationDuration), value: slideTo)
                }
                .frame(maxWidth: .infinity, alignment: Alignment.leading)
                
                
                
                /* Video played so far progress indicator */
                HStack(spacing: 0)
                {
                    Rectangle()
                        .frame(maxWidth: 3, maxHeight: 45, alignment: Alignment.leading)
                        .cornerRadius(20, corners: [.topLeft, .bottomLeft])
                        .foregroundColor(Color.white)
                        .offset(CGSize(width: (maxProgressIndicatorWidth * CGFloat(player.percentagePlayedSoFar)) + slideTo, height: 0))
                        .animation(.easeInOut(duration: animationDuration), value: slideTo)
                }
                .frame(maxWidth: .infinity, alignment: Alignment.leading)
                
                
                
                /* video length string at the end of pregress timeline */
                if(CGFloat(player.percentagePlayedSoFar) + (slideTo / maxProgressIndicatorWidth) < showVideoLengthUnyilProgressPercent)
                {
                    HStack(spacing: 0)
                    {
                        Text(player.videoLengthString)
                            .foregroundColor(Color.white)
                            .font(Font.system(size: 28))
                            .offset(CGSize(width: -35 + maxProgressIndicatorWidth, height: 45))
                    }
                    .frame(maxWidth: .infinity, alignment: Alignment.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: Alignment.leading)
        }
        .frame(maxWidth: .infinity, alignment: Alignment.leading)
        .padding([.top], 500)
        .padding([.leading], 50)
        
        .dragGestures(
            onDragRight: {
                animationDuration = 0.5
                uiUpdateCounter = uiUpdateCounter + 1
                slideTo = slideTo + skimmingSteps
                if(currentPosition + slideTo  > maxProgressIndicatorWidth)
                {
                    slideTo = maxProgressIndicatorWidth - currentPosition
                }
                if(uiUpdateCounter % 4 == 0)
                {
                    let newTime: VLCTime = getMediaNewTime()
                    player.currentTimeString = newTime.stringValue
                    Config.playerCopy?.mediaPlayer.time = newTime
                    uiUpdateCounter = 0
                }
            },
            
            onDragLeft: {
                animationDuration = 0.5
                uiUpdateCounter = uiUpdateCounter + 1
                slideTo = slideTo - skimmingSteps
                if(currentPosition + slideTo  < 0)
                {
                    slideTo = -currentPosition
                }
                if(uiUpdateCounter % 4 == 0)
                {
                    let newTime: VLCTime = getMediaNewTime()
                    player.currentTimeString = newTime.stringValue
                    Config.playerCopy?.mediaPlayer.time = newTime
                    uiUpdateCounter = 0
                }
            },
            
            onDragEnded: {
                animationDuration = 0.5
                player.currentTimeString = getMediaNewTime().stringValue
            },
            
            onSwipeRight: {
                animationDuration = 0.8
                slideTo = slideTo + (skimmingSteps * 30)
                if(currentPosition + slideTo  > maxProgressIndicatorWidth)
                {
                    slideTo = maxProgressIndicatorWidth - currentPosition
                }
                player.currentTimeString = getMediaNewTime().stringValue
            },

            onSwipeLeft: {
                animationDuration = 0.8
                slideTo = slideTo - (skimmingSteps * 30)
                if(currentPosition + slideTo  < 0)
                {
                    slideTo = -currentPosition
                }
                player.currentTimeString = getMediaNewTime().stringValue
            }
        )
        
        .focusable()
        
        // on press action
        .onLongPressGesture(minimumDuration: 0.01, perform:
        {
            playPauseVideo()
        })
        
        .onPlayPauseCommand(perform: {
            playPauseVideo()
        })
        
        .onDisappear
        {
            slideTo = 0
            playPauseVideo()
        }
    }
}

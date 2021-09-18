//
//  Config.swift
//  VLCTester
//
//  Created by ShayBC on 18/09/21.
//

//import CoreGraphics
import SwiftUI

struct Config {
    struct tvEpisodeImage {
        static let width: CGFloat = 400.0
        static let height: CGFloat = 225.0
    }
    
    static var videoURLString: String = "https://upload.wikimedia.org/wikipedia/commons/transcoded/c/c0/Big_Buck_Bunny_4K.webm/Big_Buck_Bunny_4K.webm.480p.vp9.webm"
    static var player: VlcPlayerView?
    static var playerCopy: VlcPlayerCopyView?
}

//
//  VlcPlayer.swift
//  VLCTester
//
//  Created by ShayBC on 18/09/21.
//

import SwiftUI

struct VlcPlayer: UIViewRepresentable
{
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<VlcPlayer>)
    {
    }

    func makeUIView(context: Context) -> UIView
    {
        let player = VlcPlayerView()
        Config.player = player // save as a static or Environment so you could access from the view
        return player
    }
}

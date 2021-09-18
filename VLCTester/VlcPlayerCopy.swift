//
//  VlcPlayerCopy.swift
//  VLCTester
//
//  Created by ShayBC on 18/09/21.
//

import SwiftUI

struct VlcPlayerCopy: UIViewRepresentable
{
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<VlcPlayerCopy>)
    {
    }

    func makeUIView(context: Context) -> UIView
    {
        let player = VlcPlayerCopyView()
        Config.playerCopy = player
        return player
    }
}

//
//  DragGestureActions.swift
//  VLCTester
//
//  Created by ShayBC on 18/09/21.
//

import SwiftUI
import GameController

enum DragDirection: String
{
    case Up
    case Down
    case Left
    case Right
}

struct DragGestureActions: ViewModifier
{
    // how much pause in milliseconds should be between gestures in order for a gesture to be considered a new gesture and not a remenat x/y values from the previous gesture
    let secondsBetweenInteractions: Double = 0.2
    let secondsTouchToConsideredAsSwipe: Double = 0.3
    let resolution: Float = 0.03
    
    // save previous valueChangedHandler (to be restored when this view has disappeared
    @State var currentHandler: GCControllerDirectionPadValueChangedHandler? = nil

    // the closures to execute when up/down/left/right gesture are detected
    var onDragUp: (() -> Void)? = nil
    var onDragDown: (() -> Void)? = nil
    var onDragRight: (() -> Void)? = nil
    var onDragLeft: (() -> Void)? = nil
    
    var onDragEnded: (() -> Void)? = nil
    
    var onSwipeUp: (() -> Void)? = nil
    var onSwipeDown: (() -> Void)? = nil
    var onSwipeRight: (() -> Void)? = nil
    var onSwipeLeft: (() -> Void)? = nil

    @State var dragDirectionCounter: Dictionary<DragDirection, Int> =  [DragDirection.Up: 0, DragDirection.Down: 0, DragDirection.Right: 0, DragDirection.Left: 0]

    @State var lastY: Float = 0
    @State var lastX: Float = 0
    @State var lastInteractionTimeInterval: TimeInterval = Date().timeIntervalSince1970
    @State var firstInteractionTimeInterval: TimeInterval = Date().timeIntervalSince1970

    func resetCounters(x: Float, y: Float)
    {
//        print("resetCounters")
        firstInteractionTimeInterval = Date().timeIntervalSince1970
        lastY = y // start counting from the y point the finger is touching
        lastX = x // start counting from the x point the finger is touching
        dragDirectionCounter =  [DragDirection.Up: 0, DragDirection.Down: 0, DragDirection.Right: 0, DragDirection.Left: 0]
    }

    func body(content: Content) -> some View
    {
        content
            .onAppear(perform: {
                let gcController = GCController.controllers().first
                let microGamepad = gcController!.microGamepad
                microGamepad!.reportsAbsoluteDpadValues = true // assumes the location where the user first touches the pad is the origin value (0.0,0.0)
                currentHandler = microGamepad!.dpad.valueChangedHandler
                
                microGamepad!.dpad.valueChangedHandler = { pad, x, y in
                    
                    /* check how much time passed since the last interaction on the siri remote,
                     * if enough time has passed - reset counters and consider these comming values as a new gesture values
                     */
                    let nowTimestamp = Date().timeIntervalSince1970
                    let elapsedNanoSinceLastInteraction = nowTimestamp - lastInteractionTimeInterval
                    lastInteractionTimeInterval = nowTimestamp // update the last interaction interval
                    if elapsedNanoSinceLastInteraction > secondsBetweenInteractions
                    {
                        resetCounters(x: x, y: y)
                    }
                    
//                    print("y: \(y), x: \(x)")
                    
                    /* check if a drag gesture is ongoing and check for it's direction
                     * if it is up / down / left / right - execute it's closure
                     */
                    if (onDragUp != nil || onSwipeUp != nil) && y > lastY + resolution && abs(y) > abs(x)
                    {
                        dragDirectionCounter[DragDirection.Up] = dragDirectionCounter[DragDirection.Up]! + 1
                        onDragUp!()
                        // save the current y as the lastY
                        lastY = y
                    }
                    else if (onDragDown != nil || onSwipeDown != nil) && y < lastY - resolution && abs(y) > abs(x)
                    {
                        dragDirectionCounter[DragDirection.Down] = dragDirectionCounter[DragDirection.Down]! + 1
                        onDragDown!()
                        // save the current y as the lastY
                        lastY = y
                    }
                    else if (onDragLeft != nil || onSwipeLeft != nil) && x < lastX - resolution && abs(x) > abs(y)
                    {
                        dragDirectionCounter[DragDirection.Left] = dragDirectionCounter[DragDirection.Left]! + 1
                        onDragLeft!()
                        // save the current x as the lastX
                        lastX = x
                    }
                    else if (onDragRight != nil || onSwipeRight != nil) && x > lastX + resolution && abs(x) > abs(y)
                    {
                        dragDirectionCounter[DragDirection.Right] = dragDirectionCounter[DragDirection.Right]! + 1
                        onDragRight!()
                        // save the current x as the lastX
                        lastX = x
                    }
                    else if x == 0 && y == 0
                    {
                        let nowTimestamp = Date().timeIntervalSince1970
                        let elapsedNanoSinceLastInteraction = nowTimestamp - firstInteractionTimeInterval
//                        print(">>> finger up after: \(elapsedNanoSinceLastInteraction)")
                        if elapsedNanoSinceLastInteraction < secondsTouchToConsideredAsSwipe
                        {
                            // this was a very fast interaction, consider it a s wipe in the last detected dirction
                            let maxDirectionCounter = dragDirectionCounter.max { a, b in a.value < b.value }
                            
                            if(maxDirectionCounter?.value ?? 0 > 0)
                            {
                                switch maxDirectionCounter?.key {
                                case .Up:
                                    print(">>> onSwipeUp()")
                                    onSwipeUp?()
                                case .Down:
                                    print(">>> onSwipeDown()")
                                    onSwipeDown?()
                                case .Left:
                                    print(">>> onSwipeLeft()")
                                    onSwipeLeft?()
                                case .Right:
                                    print(">>> onSwipeRight()")
                                    onSwipeRight?()
                                case .none:
                                    print("Can't decide what direction is the swipe")
                                }
                            }
                        }
                        
                        // perform last action on drag ended
                        onDragEnded?()
                    }
                }
            })
                
            .onDisappear(perform: {
                // if there was a hendler already set before we started - restore it
                let gcController = GCController.controllers().first
                let microGamepad = gcController!.microGamepad
                microGamepad!.dpad.valueChangedHandler = currentHandler
            })
    }
}

extension View
{
    func dragGestures(onDragUp: (() -> Void)? = nil,
                      onDragDown: (() -> Void)? = nil,
                      onDragRight: (() -> Void)? = nil,
                      onDragLeft: (() -> Void)? = nil,
                      onDragEnded: (() -> Void)? = nil,
                      onSwipeUp: (() -> Void)? = nil,
                      onSwipeDown: (() -> Void)? = nil,
                      onSwipeRight: (() -> Void)? = nil,
                      onSwipeLeft: (() -> Void)? = nil) -> some View
    {
        self.modifier(DragGestureActions(onDragUp: onDragUp,
                                          onDragDown: onDragDown,
                                          onDragRight: onDragRight,
                                         onDragLeft: onDragLeft,
                                         onDragEnded: onDragEnded,
                                         onSwipeUp: onSwipeUp,
                                         onSwipeDown: onSwipeDown,
                                         onSwipeRight: onSwipeRight,
                                         onSwipeLeft: onSwipeLeft))
    }
}

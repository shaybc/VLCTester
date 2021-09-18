# VLCTester
a SwiftUI example for using a VLC player via TVVLCKit on tvOS and Apple TV and adding video progress bar and thumbnails


![Apple-TV-video-scrubbing](https://user-images.githubusercontent.com/8535905/133889196-53185b6e-b293-4b11-8668-552e744b5b27.jpg)


This is a small SwiftUI project to demonstrate how to implement Video skimmer track (video progress bar with current position thumbnail) for VLC player on Apple TV tvOS 14.7 and above should work (you can even set the project to 10.2)

this is a fully working project, download it, follow the instructions on how to install TVVLCKit as a Pod, and run it on a hardware Apple-Tv device (simulator still does not support a Siri Remote as a Game-Controller)

you can use it as an example,
though it does not suffer from performance issues or memory leak, i suggest to use it as a demo and not for production


**some words on several source files:**

**VideoPlayerView.swift**  
this is the view that displays the actual VLC player


**VideoProgressBar.swift**  
(this is the thumbnails view - i made it a player instead of just a frozen image, but muted the volume)
the swipe events i use are extension i wrote (since the Apple TV does not come with swipe and drag gestures), i have attached the extension as well


**VlcPlayer.swift**  
this is the representable view for bridging UIKit and SwiftUI views (VlcPlayerView.swift is a UIView) - it is the thumbnail view wrapper


**VlcPlayerView.swift**  
this is the vlc player primary player that loads the mediaplayer and plays the video


**VlcPlayerCopy.swift**  
this is the representable view for bridging UIKit and SwiftUI views (VlcPlayerCopyView.swift is a UIView) - it is the thumbnail view wrapper


**VlcPlayerCopyView.swift**  
this is the vlc player copy (second) player that relies on the mediaplayer of the first and primary player


**DragGestureActions.swift**  
it support a drag and a swipe, it rely on the GameController API, and it rely on the Apple-TV remote to be the first game controller (as of this time 18/SEP/2021 the simulator does not support Siri remote as a Game Controller, so in order to try the gestures you will need a real hardware apple tv device)


**Config.swift**  
this is a static class instead of using environment (for demo only)




**TVVLCKit install Instructions:**  
instructions found at: https://code.videolan.org/videolan/VLCKit#installation were not helpful,  
but this video helped allot: https://www.youtube.com/watch?v=TmdSnCw-Mjw

- open terminal, run cmd:  
`sudo gem install cocoapods`

- write and save a file with tha name: "Podfile" into your project home folder, with the content:  
`source 'https://github.com/CocoaPods/Specs.git'
project '~/VLCTester/VLCTester.xcodeproj'
target 'VLCTester' do
    platform :tvos, '10.2'
    pod 'TVVLCKit', '~>3.3.0'
end`


- make sure to replace project with your project file path  
- make sure to replace target with the name of the TVKit target name  


- cd to project folder (to folder where Podfile is located) and run the command:  
`pod install`


- close xcode and use created file: xcworkspace for this project from now on  


- make sure you project has the following dependencies (project file -> target -> general -> 'frameworks libraries and embeded content'):  

_AudioToolbox.framework  
AVFoundation.framework  
CFNetwork.framework  
CoreFoundation.framework  
CoreGraphics.framework  
CoreMedia.framework  
CoreText.framework  
CoreVideo.framework  
Foundation.framework  
libbz2.tbd  
libc++.tbd  
libiconv.tbd  
libxml2.tbd  
OpenGLES.framework  
QuartzCore.framework  
Security.framework  
VideoToolbox.framework  
UIKit.framework_  


- lastly create new file  
(file -> new -> file)
- choose 'Objective-C file'  
- name it 'header' and press create  
- choose 'create bridging header'
- at the created file (VLCTester-Bridging-Header.h) add the import line:  
`#import "TVVLCKit/TVVLCKit.h"`




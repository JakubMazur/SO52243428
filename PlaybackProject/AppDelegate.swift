//
//  AppDelegate.swift
//  PlaybackProject
//
//  Created by Jakub Mazur on 13/09/2018.
//  Copyright © 2018 Jakub Mazur. All rights reserved.
//

import UIKit
import MediaPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func playSth() {
        self.setupNowPlaying()
        self.setupRemoteTransportControls()
    }
    
    var audio: AVAudioPlayer?
    var session: AVAudioSession? = AVAudioSession.sharedInstance()
    
    func setupNowPlaying() {
        do {
            try session?.setCategory(AVAudioSessionCategoryPlayback)
            try session?.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print(error)
        }
        do {
            let url = Bundle.main.url(forResource: "example", withExtension: "mp3") // http://www.largesound.com/ashborytour/sound/
            audio = try AVAudioPlayer(contentsOf: url!)
        } catch {
            print(error)
        }
        audio?.play()
        
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "My Track"
        
        if let image = UIImage(named: "image") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audio!.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audio!.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = audio!.rate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.audio!.rate == 0.0 {
                self.audio!.play()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.audio!.rate == 1.0 {
                self.audio!.pause()
                return .success
            }
            return .commandFailed
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.playSth()
            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
                self.audio?.stop()
                try? self.session?.setActive(false, with: .notifyOthersOnDeactivation)
                MPNowPlayingInfoCenter.default().nowPlayingInfo = [:]
            })
        }
        return true
    }

}


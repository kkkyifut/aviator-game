//import Foundation
import AVFoundation

class MusicPlayer {
    static let shared = MusicPlayer()
    private var control: Timer?
    private var controlSecond: Timer?
    private var triggerTimer = false
    private var triggerTimerSecond = false
    private var audioPlayerBackground: AVAudioPlayer?
    private var audioPlayerFlight: AVAudioPlayer?
    private var audioPlayerEffect: AVAudioPlayer?
    private var audioPlayerEffectSecond: AVAudioPlayer?
    private let soundBackgroundGame = "backgroundGame"
    private let soundBackgroundMenu = "backgroundMenu"
    private let soundBackgroundFlight = "Flight"
//    var isMuted = true
    var isMuted = false
    
    func startGameMusic() {
        if isMuted { return }
        if let bundle = GameApp.bundleProvider().path(forResource: soundBackgroundGame, ofType: "mp3") {
            let backgroundMusic = NSURL(fileURLWithPath: bundle)
            do {
                audioPlayerBackground = try AVAudioPlayer(contentsOf: backgroundMusic as URL)
                guard let audioPlayerBackground = audioPlayerBackground else { return }
                audioPlayerBackground.numberOfLoops = -1
                audioPlayerBackground.prepareToPlay()
                audioPlayerBackground.play()
            } catch {
                print("Error: ", error)
            }
        }
    }
    
    func startMenuMusic() {
        if isMuted { return }
        if let bundle = GameApp.bundleProvider().path(forResource: soundBackgroundMenu, ofType: "mp3") {
            let backgroundMusic = NSURL(fileURLWithPath: bundle)
            do {
                audioPlayerBackground = try AVAudioPlayer(contentsOf: backgroundMusic as URL)
                guard let audioPlayerBackground = audioPlayerBackground else { return }
                audioPlayerBackground.numberOfLoops = -1
                audioPlayerBackground.prepareToPlay()
                audioPlayerBackground.play()
            } catch {
                print("Error: ", error)
            }
        }
    }
    
    func startFlightMusic() {
        if isMuted { return }
        if let bundle = GameApp.bundleProvider().path(forResource: soundBackgroundFlight, ofType: "mp3") {
            let flightMusic = NSURL(fileURLWithPath: bundle)
            do {
                audioPlayerFlight = try AVAudioPlayer(contentsOf: flightMusic as URL)
                guard let audioPlayerFlight = audioPlayerFlight else { return }
                audioPlayerFlight.numberOfLoops = -1
                audioPlayerFlight.prepareToPlay()
                audioPlayerFlight.play()
            } catch {
                print("Error: ", error)
            }
        }
    }
    
    func stopBGMusic() {
        guard let audioPlayerBackground = audioPlayerBackground else { return }
        audioPlayerBackground.stop()
    }
    
    func stopFlightMusic() {
        guard let audioPlayerFlight = audioPlayerFlight else { return }
        audioPlayerFlight.stop()
    }

    func playSound(withEffect soundEffect: String) {
        if isMuted { return }
        if triggerTimer { return }
        
        triggerTimer = true
        control = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(onTimeFires), userInfo: nil, repeats: false)
        
        if let bundle = GameApp.bundleProvider().path(forResource: soundEffect, ofType: "mp3") {
            let soundEffectUrl = NSURL(fileURLWithPath: bundle)
            do {
                audioPlayerEffect = try AVAudioPlayer(contentsOf: soundEffectUrl as URL)
                guard let audioPlayerEffect = audioPlayerEffect else { return }
                audioPlayerEffect.prepareToPlay()
                audioPlayerEffect.play()
            } catch {
                print("Error: ", error)
            }
        }
    }

    func playSoundSecond(withEffect soundEffect: String) {
        if isMuted { return }
        if triggerTimerSecond { return }
        
        triggerTimerSecond = true
        controlSecond = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(onTimeFiresSecond), userInfo: nil, repeats: false)
        
        if let bundle = GameApp.bundleProvider().path(forResource: soundEffect, ofType: "mp3") {
            let soundEffectUrl = NSURL(fileURLWithPath: bundle)
            do {
                audioPlayerEffectSecond = try AVAudioPlayer(contentsOf: soundEffectUrl as URL)
                guard let audioPlayerEffectSecond = audioPlayerEffectSecond else { return }
                audioPlayerEffectSecond.prepareToPlay()
                audioPlayerEffectSecond.play()
            } catch {
                print("Error: ", error)
            }
        }
    }
    
    @objc private func onTimeFires() {
        triggerTimer = false
    }
    
    @objc private func onTimeFiresSecond() {
        triggerTimerSecond = false
    }
}

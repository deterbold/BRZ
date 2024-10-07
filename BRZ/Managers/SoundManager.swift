//
//  SoundManager.swift
//  BRZ
//
//  Created by Miguel Sicart on 28/09/2024.
//

import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var audioPlayers: [String: AVAudioPlayer] = [:]

    private init() {}

    func playSound(named fileName: String, withExtension fileExtension: String = "mp3", loop: Bool = false) {
        let key = "\(fileName).\(fileExtension)"
        if let player = audioPlayers[key], player.isPlaying {
            // Sound is already playing
            return
        }

        if let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.numberOfLoops = loop ? -1 : 0
                audioPlayer.prepareToPlay()
                audioPlayers[key] = audioPlayer
                audioPlayer.play()
            } catch {
                print("Error playing sound \(fileName): \(error.localizedDescription)")
            }
        } else {
            print("Sound file not found: \(fileName).\(fileExtension)")
        }
    }

    func stopSound(named fileName: String, withExtension fileExtension: String = "mp3") {
        let key = "\(fileName).\(fileExtension)"
        if let player = audioPlayers[key] {
            player.stop()
            audioPlayers.removeValue(forKey: key)
        }
    }

    func stopAllSounds() {
        for player in audioPlayers.values {
            player.stop()
        }
        audioPlayers.removeAll()
    }
}


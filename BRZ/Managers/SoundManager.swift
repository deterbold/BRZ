//
//  SoundManager.swift
//  BRZ
//
//  Created by Miguel Sicart on 28/09/2024.
//

import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    var audioPlayer: AVAudioPlayer?

    private init() {}

    func playSound(named fileName: String, withExtension fileExtension: String = "mp3") {
        if let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Error playing sound: \(error.localizedDescription)")
            }
        }
    }

    func stopSound() {
        audioPlayer?.stop()
    }
}

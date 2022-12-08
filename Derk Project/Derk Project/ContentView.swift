//
//  ContentView.swift
//  Map Reader Project
//
//

import SwiftUI
import AVFoundation
import Speech


import SwiftUI

//
struct ContentView: View {
    @State private var navigating: Bool = false
    @State private var obstacleInFront: Bool = true
    
    let synthesizer = AVSpeechSynthesizer()
    private var videoOutput = AVCaptureVideoDataOutput()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    

    var body: some View {
        if navigating {
            HostedViewController()
                .ignoresSafeArea()
                .onReceive(timer) { _ in
                    let int = Int.random(in: 0..<3)
                    if int == 1 {
                        obstacleInFront = true
                    } else {
                        obstacleInFront = false
                    }
                    if obstacleInFront {
                        speak(words: "Watch out, obstacle in front", synth: synthesizer)
                    } else {
                        speak(words: "Onwards then", synth: synthesizer)
                    }
                }
                .onAppear {
                    speak(words: "Starting navigation", synth: synthesizer)
                }
        } else {
            NavigationStack {
                VStack {
                    Map()
                    Button("Ready to Navigate") {
                        navigating.toggle()
                    }
                }
                .padding()
                .navigationTitle("Map Reader App")
            }
        }
    }
}

func speak(words: String, synth: AVSpeechSynthesizer) {
    let utterance = AVSpeechUtterance(string: words)
    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    utterance.pitchMultiplier = 2.0
    utterance.rate = 0.3
    synth.speak(utterance)
}

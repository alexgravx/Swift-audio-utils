//
//  ContentView.swift
//  Sound-test
//
//  Created by Alexandre GRAVEREAUX on 01/03/2024.
//

import SwiftUI
import AVFoundation

enum SongFunctions: String, CaseIterable {
    case sine = "sine"
    case noise = "noise"
    case square = "square"
    case sawToothUp = "SUp"
    case triangle = "triangle"
}

struct ContentView: View {
    
    @State var selectedsong: SongFunctions = .sine
    @State var frequency: Float = 440.0
    @State var duration: Float = 3.0
    @State var amplitude: Float = 1.0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    VStack(alignment: .leading) {
                        Text("Song type")
                        Picker("Choose a song", selection: $selectedsong) {
                            ForEach(SongFunctions.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }.pickerStyle(.segmented)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Frequency: \(frequency)")
                        Slider(
                            value: $frequency,
                            in: 100...10000,
                            step: 1
                        )
                        {
                            Text("Frequency")
                        } minimumValueLabel: {
                            Text("100")
                        } maximumValueLabel: {
                            Text("10000")
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Aplitude: \(amplitude)")
                        Slider(
                            value: $amplitude,
                            in: 0...1,
                            step: 0.01
                        )
                        {
                            Text("Amplitude")
                        } minimumValueLabel: {
                            Text("0")
                        } maximumValueLabel: {
                            Text("1")
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Duration: \(duration)")
                        Slider(
                            value: $duration,
                            in: 0.5...50,
                            step: 0.5
                        )
                        {
                            Text("Duration")
                        } minimumValueLabel: {
                            Text("0.5")
                        } maximumValueLabel: {
                            Text("50")
                        }
                    }
                }
                
                Form {
                    Button("Jouer musique") {
                        playSound()
                    }
                    
                    Button("Générer son") {
                        SoundGenerator(frequency: frequency, amplitude: amplitude, duration: duration, signal_string: selectedsong.rawValue)
                    }
                    
                    Button("Stopper son") {
                        stopSound()
                    }
                }
            }
            .navigationTitle("SongGenerator")
        }
    }
}

#Preview {
    ContentView()
}

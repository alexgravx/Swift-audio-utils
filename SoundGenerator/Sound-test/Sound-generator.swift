//
// Copyright © 2021 Apple Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  Sound-generator.swift
//  Sound-test
//
//  Created by Alexandre GRAVEREAUX on 01/03/2024.
//

import Foundation
import AVFoundation

let twoPi = 2 * Float.pi

let sine = { (phase: Float) -> Float in
    return sin(phase)
}

let whiteNoise = { (phase: Float) -> Float in
    return ((Float(arc4random_uniform(UINT32_MAX)) / Float(UINT32_MAX)) * 2 - 1)
}

let sawtoothUp = { (phase: Float) -> Float in
    return 1.0 - 2.0 * (phase * (1.0 / twoPi))
}

let sawtoothDown = { (phase: Float) -> Float in
    return (2.0 * (phase * (1.0 / twoPi))) - 1.0
}

let square = { (phase: Float) -> Float in
    if phase <= Float.pi {
        return 1.0
    } else {
        return -1.0
    }
}

let triangle = { (phase: Float) -> Float in
    var value = (2.0 * (phase * (1.0 / twoPi))) - 1.0
    if value < 0.0 {
        value = -value
    }
    return 2.0 * (value - 0.5)
}

let engine = AVAudioEngine()
var run_duration: Float = 0

func SoundGenerator(frequency: Float, amplitude: Float, duration: Float, signal_string: String) {
    
    let amplitude = Float(min(max(amplitude, 0.0), 1.0))
    
    let dict = ["sine": sine,
            "noise": whiteNoise,
            "square": square,
            "SUp": sawtoothUp,
            "triangle": triangle]
    
    var signal: (Float) -> Float
    signal = dict[signal_string]!
    
    let mainMixer = engine.mainMixerNode
    let output = engine.outputNode
    let outputFormat = output.inputFormat(forBus: 0)
    let sampleRate = Float(outputFormat.sampleRate)
    // Use the output format for the input, but reduce the channel count to 1.
    let inputFormat = AVAudioFormat(commonFormat: outputFormat.commonFormat,
                                    sampleRate: outputFormat.sampleRate,
                                    channels: 1,
                                    interleaved: outputFormat.isInterleaved)
    
    var currentPhase: Float = 0
    // The interval to advance the phase each frame.
    let phaseIncrement = (twoPi / sampleRate) * frequency
    
    let srcNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
        let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
        
        for frame in 0..<Int(frameCount) {
            // Get the signal value for this frame at time.
            let value = signal(currentPhase) * amplitude
            // Advance the phase for the next frame.
            currentPhase += phaseIncrement
            if currentPhase >= twoPi {
                currentPhase -= twoPi
            }
            if currentPhase < 0.0 {
                currentPhase += twoPi
            }
            // Set the same value on all channels (due to the inputFormat, there's only one channel though).
            for buffer in ablPointer {
                
                let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                buf[frame] = value
            }
        }
        return noErr
    }
    
    engine.attach(srcNode)
    
    engine.connect(srcNode, to: mainMixer, format: inputFormat)
    engine.connect(mainMixer, to: output, format: outputFormat)
    mainMixer.outputVolume = 0.5
    
    DispatchQueue.main.async {
        do {
            try engine.start()
            print("loop launched")
            CFRunLoopRunInMode(.defaultMode, CFTimeInterval(duration), false)
            engine.stop()
        } catch {
            print("Could not start engine: \(error)")
        }
    }
    
}

func stopSound(duration: Float) {
    print("Son coupé")
    if player != nil {
        player.stop()
    }
    engine.stop()
}

var player: AVAudioPlayer!

func playSound() {
    let url = Bundle.main.url(forResource: "song", withExtension: "mp3")
    player = try! AVAudioPlayer(contentsOf: url!)
    player.play()
}

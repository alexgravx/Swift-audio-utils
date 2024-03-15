//
//  AudioPipeline.swift
//  sencial0
//
//  Created by Louis Vauterin on 28/02/2024.
//
import AVFoundation
import SwiftUI
import Charts

enum LineChartType: String, CaseIterable, Plottable {
    case input = "Input"
    case output = "Output"
    
    var color: Color {
        switch self {
        case .input: return .blue
        case .output: return .red
        }
    }
    
}

struct LineChartData {
    
    var id = UUID()
    var frequency: Int
    var value: Double
    var type: LineChartType

}

public class Audio {
    
    enum AudioState {
        case recording, stopped
    }
    
    private var state: AudioState = .stopped
    private var engine: AVAudioEngine!
    private var audioSession: AVAudioSession!
    private var mixerNode: AVAudioMixerNode!
    private var outputNode: AVAudioOutputNode!
    private var filterNode: AVAudioUnitEQ!
    
    let spectrumWidth: Int
    var data = [LineChartData]()

    init() {
        
        self.spectrumWidth = 512
        
        setupAudioSession()
        setupEngine()
    }
    
    fileprivate func setupEngine() {
        
        //setup engine Nodes
        engine = AVAudioEngine()
        mixerNode = AVAudioMixerNode()
        filterNode = AVAudioUnitEQ(numberOfBands: 10)
        
        let inputFormat = engine.inputNode.outputFormat(forBus: 0)

        // Set volume to 0 to avoid audio feedback while recording.
        mixerNode.volume = 0

        engine.attach(mixerNode)
        engine.attach(filterNode)

        // connect all engine parts : inputNode -> mixerNode -> outputNode
        engine.connect(engine.inputNode, to: mixerNode, format: inputFormat)
        engine.connect(mixerNode, to: filterNode, format: inputFormat)
        engine.connect(filterNode, to: engine.outputNode, format: inputFormat)
        

        let conn = engine.outputConnectionPoints(for: engine.inputNode, outputBus: 0)
        print("Nombre de connexions \(conn.count)")
        
        // Make a Tap to gather the data from a node
        let frameLength = UInt32(self.spectrumWidth)
        var array: [Float] = []
        var length: Int = 0
        
        mixerNode.installTap(onBus: 0, bufferSize: frameLength, format: engine.inputNode.outputFormat(forBus: 0), block: { (buffer, time) in
            //buffer.frameLength = frameLength
            (array, length) = self.makeSpectrumFromAudio(buffer)
            //print("Array IN \(array[0...10])")
            self.updateGraph(array, length)
        })
        
        // Prepare the engine in advance, in order for the system to allocate the necessary resources.
        engine.prepare()
    }
    
    //setup audiosession for iOS
    fileprivate func setupAudioSession() {
        
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.allowBluetoothA2DP, .allowBluetooth, .defaultToSpeaker, .mixWithOthers]) // for bluetooth and mixing with other apps
            try audioSession.setPreferredSampleRate(44100.0)
            try audioSession.setPreferredIOBufferDuration(0.005) // Buffer size to reduce latency
            try audioSession.setActive(true)
            
        } catch {
            print("Couldn't configure audio session : \(error)")
        }
    }
    
    func makeSpectrumFromAudio(_ buffer: AVAudioPCMBuffer) -> ([Float], Int) {

        /// minx and maxx for scale
        var minx : Float =  1.0e12
        var maxx : Float = -1.0e12
        var spectrumArray = [Float](repeating: 0, count: self.spectrumWidth)
        
        let fft = FFT()
        let magnitudeArray = fft.fft(buffer)
     
        for i in 0 ..< self.spectrumWidth/4 { // On affiche uniquement jusu'à 11kHz, la FFT va jusqu'à 44kHz
            if i < magnitudeArray.count {
                var x = (1024.0 + 64.0 * Float(i)) * magnitudeArray[i]
                if x > maxx { maxx = x }
                if x < minx { minx = x }
                var y : Float = 0.0
                if (x > minx) {
                    if (x < 1.0) { x = 1.0 }
                    let r = (logf(maxx - minx) - logf(1.0)) * 1.0
                    let u = (logf(x    - minx) - logf(1.0))
                    y = u / r
                }
                spectrumArray[i] = y
            }
        }
        
        return (spectrumArray, spectrumArray.count)
    }
    
    func updateGraph(_ spectrumArray: [Float], _ spectrum_length: Int) {
        data = [LineChartData]()
        for i in 0..<spectrum_length/4 {
            let freq = i*(Int(44100/spectrum_length)+8)
            let value1 = spectrumArray[i] > 0 ? spectrumArray[i] : 0

            data.append(
                LineChartData(
                    frequency: freq,
                    value: Double(value1),
                    type: .input
                )
            )
        }
    }

    
    func startRecording() throws {
      try engine.start()
      state = .recording
    }
    

    func stopRecording() {
      engine.stop()
      state = .stopped
    }
}

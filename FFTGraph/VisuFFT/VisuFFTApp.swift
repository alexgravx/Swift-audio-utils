//
//  VisuFFTApp.swift
//  VisuFFT
//
//  Created by gravlax on 28/02/2024.
//

import SwiftUI

@main
struct VisuFFTApp: App {
    var body: some Scene {
        WindowGroup {
            FrequencyGraph(audio_pipeline: Audio())
        }
    }
}

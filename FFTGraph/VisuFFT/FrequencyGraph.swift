//
//  FrequencyGraph.swift
//  sencial0
//
//  Created by Louis Vauterin on 29/02/2024.
//

import SwiftUI
import Charts

struct FrequencyGraph: View {
    
    enum Scales: String, CaseIterable {
        case scale1 = "2000"
        case scale2 = "5000"
        case scale3 = "12000"
    }
    
    var audio_pipeline: Audio
    let updateTimer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State var refresh: Bool = false
    @State var selectedscale: Scales = .scale1
    
    init(audio_pipeline: Audio) {
        self.audio_pipeline = audio_pipeline
        try! audio_pipeline.startRecording()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("FFT Graph").font(.headline)
                Text(String("\(refresh)")).foregroundStyle(Color.init(UIColor(red: 0, green:0, blue:0, alpha: 0)))
            }
            Chart {
                ForEach(audio_pipeline.data, id: \.id) { item in
                    // AreaMarkt ou BarMarkt, ou LineMarkt, ou PointMarkt
                    LineMark(
                        x: .value("Frequency", item.frequency),
                        y: .value("Value", item.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(item.type.color)
                    .foregroundStyle(by: .value("Plot", item.type))
                }
            }
            .chartXScale(domain: [0, Int(selectedscale.rawValue) ?? 12000])
            .chartYScale(domain: [0, 1])
            .chartYAxis{
                AxisMarks(values: [0, 0.2, 0.4, 0.6, 0.8, 1])
            }
            Picker("Choose a scale", selection: $selectedscale) {
                ForEach(Scales.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }.pickerStyle(.segmented)
        }
        .onReceive(updateTimer) { _ in refresh.toggle()}
        .padding(25)
        .background(Color(uiColor: .systemGray6))
        .frame(width: 350, height: 400)
        .cornerRadius(20)
    }
}

#Preview {
    FrequencyGraph(audio_pipeline: Audio())
}

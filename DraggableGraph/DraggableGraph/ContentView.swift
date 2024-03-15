//
//  Test.swift
//  Graphe-test
//
//  Created by Alexandre GRAVEREAUX on 08/03/2024.
//

import SwiftUI
import Charts

struct ChartData {
    var id = UUID()
    var frequency: Int
    var modulation: Double
}

struct DraggableChartView: View {
    
    @State var data: [ChartData]
    
    let min_x: Int = 1
    let max_x: Int = 9
    let min_y: Int = -20
    let max_y: Int = 20
    
    let freq_values: [Int: String] = [
        1: "60Hz",
        2: "150Hz",
        3: "400Hz",
        4: "700Hz",
        5: "1kHz",
        6: "2.4kHz",
        7: "5kHz",
        8: "10kHz",
        9: "15kHz"
    ]
    
     var body: some View {
         VStack() {
             Text("Audio Frequency Modulation")
                 .font(.system(size: 16, weight: .medium))
                 .padding()
             
             Chart(data, id: \.id) { item in
                 LineMark(
                    x: .value("date", item.frequency),
                    y: .value("price", item.modulation)
                 )
                 .interpolationMethod(.catmullRom)
                 .lineStyle(.init(lineWidth: 2))
                 .symbol {
                     Circle()
                         .frame(width: 12, height: 12)
                         .overlay {
                             Text("\(Int(item.modulation))")
                                 .frame(width: 20)
                                 .font(.system(size: 7, weight: .medium))
                                 .offset(y: -15)
                         }
                 }
             }
             .chartOverlay { proxy in
                 GeometryReader { geometry in
                     Rectangle().fill(.clear).contentShape(Rectangle())
                         .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // Convert the gesture location to the coordinate space of the plot area.
                                    let origin = geometry[proxy.plotFrame!].origin
                                    let location = CGPoint(
                                        x: value.location.x - origin.x,
                                        y: value.location.y - origin.y
                                    )
                                    // Get the x (date) and y (price) value from the location.
                                    let (frequency_value, modulation_value) = proxy.value(at: location, as: (Int, Double).self)!
                                    print("Location before: \(frequency_value), \(modulation_value)")
                                    if min_y...max_y ~= Int(modulation_value) && min_x...max_x ~= frequency_value {
                                        let id = data.firstIndex(where: {$0.frequency == frequency_value})!
                                        data[id].modulation = modulation_value
                                        print("Location after: \(frequency_value), \(modulation_value)")
                                    }
                                }
                         )
                 }
             }
             .chartXScale(domain: min_x...max_x)
             .chartYScale(domain: (min_y-2)...(max_y+2))
             .chartXAxis {
                 AxisMarks(preset: .aligned, position: .bottom, values: .stride(by: 1)) {
                     AxisGridLine()
                     AxisTick()
                     let value = $0.as(Int.self)!
                     AxisValueLabel {
                         Text(freq_values[value]!).font(.system(size: 8, weight: .medium))
                     }
                 }
             }
             .chartYAxis {
                 AxisMarks {}
             }
         }
         .frame(width: 300, height: 400)
     }
}

var datainput : [ChartData] = {
    var temp = [ChartData]()
    
    // Line 1
    for i in 1...9 {
        let value = Double.random(in: -20...20)
        temp.append(
            ChartData(
                frequency: i,
                modulation: value
            )
        )
    }
    
    return temp
}()


#Preview {
    VStack {
        Spacer()
        DraggableChartView(data: datainput)
            .padding()
        Spacer()
    }
}

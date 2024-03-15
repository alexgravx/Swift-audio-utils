//
//  DraggableGraphApp.swift
//  DraggableGraph
//
//  Created by Alexandre GRAVEREAUX on 08/03/2024.
//

import SwiftUI

@main
struct DraggableGraphApp: App {
    var body: some Scene {
        WindowGroup {
            DraggableChartView(data: datainput)
        }
    }
}

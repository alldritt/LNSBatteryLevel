//
//  ContentView.swift
//  Shared
//
//  Created by Mark Alldritt on 2021-02-16.
//

import SwiftUI
import LNSBatteryLevel


struct ContentView: View {
    @State var level = CGFloat(0.2)
    @State var charging = false

    var body: some View {
        VStack {
            HStack(alignment: .bottom, spacing: 10) {
                LNSBatteryLevel(level: $level, charging: $charging, borderColor: .blue)
                    .frame(width: 200, height: 200)
                LNSBatteryLevel(level: $level, charging: $charging)
                    .frame(width: 100, height: 180)
            }
            .padding()
            HStack(alignment: .bottom, spacing: 10) {
                LNSBatteryLevel(level: $level, charging: $charging, lowThreshold: 50)
                    .frame(width: 80, height: 80)
                    .padding(5)
                LNSBatteryLevel(level: $level, charging: $charging, borderColor: .white)
                    .frame(width: 80, height: 80)
                    .padding(5)
                    .background(Color.black)
                LNSBatteryLevel(level: $level, charging: $charging, lowThreshold: 20, highLevelColor: .blue, lowLevelColor: .orange)
                    .frame(width: 40, height: 40)
                    .rotationEffect(Angle(degrees: 90))
                LNSBatteryLevel(level: $level, charging: $charging)
                    .frame(width: 18, height: 18)
            }
            .padding()
            Slider(value: $level)
            Toggle("Charging", isOn: $charging)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

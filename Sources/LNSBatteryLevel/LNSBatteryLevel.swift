//
//  LNSBatteryLevel.swift
//  LNSBatteryLevel
//
//  Created by Mark Alldritt on 2021-02-14.
//

import SwiftUI


fileprivate extension Int {
    static let fullBattery = 100
}


fileprivate struct ChargingShape: Shape {

    let terminalLengthRatio: CGFloat
    let borderWidth: CGFloat

    func path(in bounds: CGRect) -> Path {
        // divide total length into body and terminal
        let bounds = bounds.insetBy(dx: borderWidth / 2, dy: borderWidth / 2)
        let terminalLength = terminalLengthRatio * bounds.height
        let (_, bodyFrame) = bounds.divided(atDistance: terminalLength, from: .minYEdge)
        let boltFrame = bodyFrame.insetBy(dx: bodyFrame.width / 4, dy: bodyFrame.height / 6)
        var path = Path()
        
        path.move(to: CGPoint(x: boltFrame.midX, y: boltFrame.minY))
        path.addLine(to: CGPoint(x: boltFrame.maxX, y: boltFrame.midY))
        path.addLine(to: CGPoint(x: boltFrame.midX, y: boltFrame.midY + borderWidth / 1.3))
        path.addLine(to: CGPoint(x: boltFrame.midX, y: boltFrame.maxY))
        path.addLine(to: CGPoint(x: boltFrame.minX, y: boltFrame.midY))
        path.addLine(to: CGPoint(x: boltFrame.midX, y: boltFrame.midY - borderWidth / 1.3))
        path.addLine(to: CGPoint(x: boltFrame.midX, y: boltFrame.minY))
        path.closeSubpath()

        return path
    }
}


fileprivate struct BatteryBodyShape: Shape {

    let terminalLengthRatio: CGFloat
    let terminalWidthRatio: CGFloat
    let borderWidth: CGFloat
    let cornerRadius: CGFloat

    func path(in bounds: CGRect) -> Path {
        // divide total length into body and terminal
        let bounds = bounds.insetBy(dx: borderWidth / 2, dy: borderWidth / 2)
        let terminalLength = terminalLengthRatio * bounds.height
        var (terminalFrame, bodyFrame) = bounds.divided(atDistance: terminalLength, from: .minYEdge)

        // layout terminal
        let parallelInsetRatio = (1 - terminalWidthRatio) / 2
        let perpendicularInset = borderWidth
        let (dx, dy) = (parallelInsetRatio * bounds.width, -perpendicularInset)
        (_, terminalFrame) = terminalFrame.insetBy(dx: dx, dy: dy).divided(atDistance: perpendicularInset, from: .minYEdge)
        
        //  Draw the battery frame
        var bodyOutline = Path()

        bodyOutline.move(to: CGPoint(x: terminalFrame.maxX, y: bodyFrame.minY))
        bodyOutline.addLine(to: CGPoint(x: bodyFrame.maxX - cornerRadius, y: bodyFrame.minY))
        bodyOutline.addArc(tangent1End: CGPoint(x: bodyFrame.maxX, y: bodyFrame.minY),
                           tangent2End: CGPoint(x: bodyFrame.maxX, y: bodyFrame.minY + cornerRadius),
                           radius: cornerRadius)
        bodyOutline.addLine(to: CGPoint(x: bodyFrame.maxX, y: bodyFrame.maxY - cornerRadius))
        bodyOutline.addArc(tangent1End: CGPoint(x: bodyFrame.maxX, y: bodyFrame.maxY),
                           tangent2End: CGPoint(x: bodyFrame.maxX - cornerRadius, y: bodyFrame.maxY),
                           radius: cornerRadius)
        bodyOutline.addLine(to: CGPoint(x: bodyFrame.minX + cornerRadius, y: bodyFrame.maxY))
        bodyOutline.addArc(tangent1End: CGPoint(x: bodyFrame.minX, y: bodyFrame.maxY),
                           tangent2End: CGPoint(x: bodyFrame.minX, y: bodyFrame.maxY - cornerRadius),
                           radius: cornerRadius)
        bodyOutline.addLine(to: CGPoint(x: bodyFrame.minX, y: bodyFrame.minY + cornerRadius))
        bodyOutline.addArc(tangent1End: CGPoint(x: bodyFrame.minX, y: bodyFrame.minY),
                           tangent2End: CGPoint(x: bodyFrame.minX + cornerRadius, y: bodyFrame.minY),
                           radius: cornerRadius)
        bodyOutline.addLine(to: CGPoint(x: terminalFrame.minX, y: bodyFrame.minY))

        //  Add the terminal cap
        bodyOutline.addLine(to: CGPoint(x: terminalFrame.minX, y: terminalFrame.minY + borderWidth / 3))
        bodyOutline.addArc(tangent1End: CGPoint(x: terminalFrame.minX, y: terminalFrame.minY),
                           tangent2End: CGPoint(x: terminalFrame.minX + borderWidth / 3, y: terminalFrame.minY),
                           radius: borderWidth / 3)
        bodyOutline.addLine(to: CGPoint(x: terminalFrame.maxX - borderWidth / 3, y: terminalFrame.minY))
        bodyOutline.addArc(tangent1End: CGPoint(x: terminalFrame.maxX, y: terminalFrame.minY),
                           tangent2End: CGPoint(x: terminalFrame.maxX, y: terminalFrame.minY + borderWidth / 3),
                           radius: borderWidth / 3)

        bodyOutline.addLine(to: CGPoint(x: terminalFrame.maxX, y: bodyFrame.minY))
        bodyOutline.closeSubpath()
        
        return bodyOutline
    }
}


fileprivate struct BatteryLevelShape: Shape {
    /// 0 to 100 percent full, unavailable = -1
    @Binding public var level: CGFloat
        
    // relative size of battery terminal
    let terminalLengthRatio: CGFloat
    
    func path(in bounds: CGRect) -> Path {
        // divide total length into body and terminal
        let terminalLength = terminalLengthRatio * bounds.height
        var (_, bodyFrame) = bounds.divided(atDistance: terminalLength, from: .minYEdge)

        bodyFrame.origin.y += bodyFrame.size.height - bodyFrame.size.height * CGFloat(min(1.0, max(level, 0)))
        bodyFrame.size.height = bodyFrame.size.height * CGFloat(min(1.0, max(level, 0)))

        return Path(bodyFrame)
    }
}


public struct LNSBatteryLevel: View {
    /// level 0...100, -1 = no level
    @Binding private var level: CGFloat
    @Binding private var charging: Bool

    let terminalLengthRatio: CGFloat = 0.1
    let terminalWidthRatio: CGFloat = 0.4

    let borderColor: Color
    
    let lowThreshold: Int

    let highLevelColor: Color
    let lowLevelColor: Color
    let noLevelColor: Color

    private var levelColor: Color {
        switch Int(max(0, min(level * CGFloat(Int.fullBattery), CGFloat(Int.fullBattery)))) {
        case 0 ... lowThreshold:
            return lowLevelColor
        case lowThreshold ... .fullBattery:
            return highLevelColor
        default:
            return noLevelColor
        }
    }
    
    public init(level: Binding<CGFloat>,
                charging: Binding<Bool> = .constant(false),
                borderColor: Color = .primary,
                lowThreshold: Int = 15,
                highLevelColor: Color = Color(red: 0.0, green: 0.9, blue: 0.0),
                lowLevelColor: Color = Color(red: 0.9, green: 0.0, blue: 0.0),
                noLevelColor: Color = Color(white: 0.8)) {
        _level = level
        _charging = charging
        self.borderColor = borderColor
        self.lowThreshold = lowThreshold
        self.highLevelColor = highLevelColor
        self.lowLevelColor = lowLevelColor
        self.noLevelColor = noLevelColor
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let aspectRatio = CGFloat(0.6)
            let cornerRadius = geometry.size.height / 10
            let borderWidth = geometry.size.height / 20
            
            if charging {
                BatteryLevelShape(level: $level, terminalLengthRatio: terminalLengthRatio)
                    .fill(levelColor)
                    .clipShape(BatteryBodyShape(terminalLengthRatio: terminalLengthRatio,
                                                terminalWidthRatio: terminalWidthRatio,
                                                borderWidth: borderWidth,
                                                cornerRadius: cornerRadius))
                    .overlay(BatteryBodyShape(terminalLengthRatio: terminalLengthRatio,
                                              terminalWidthRatio: terminalWidthRatio,
                                              borderWidth: borderWidth,
                                              cornerRadius: cornerRadius)
                                .stroke(borderColor, lineWidth: borderWidth)
                                .overlay(ChargingShape(terminalLengthRatio: terminalLengthRatio, borderWidth: borderWidth)
                                            .rotation(Angle(degrees: -12))
                                            .fill(borderColor))
                                .overlay(ChargingShape(terminalLengthRatio: terminalLengthRatio, borderWidth: borderWidth)
                                            .rotation(Angle(degrees: -12))
                                            .stroke(borderColor, style: StrokeStyle(lineWidth: borderWidth / 1.2, lineCap: .round, lineJoin: .round))))
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            }
            else {
                BatteryLevelShape(level: $level, terminalLengthRatio: terminalLengthRatio)
                    .fill(levelColor)
                    .clipShape(BatteryBodyShape(terminalLengthRatio: terminalLengthRatio,
                                                terminalWidthRatio: terminalWidthRatio,
                                                borderWidth: borderWidth,
                                                cornerRadius: cornerRadius))
                    .overlay(BatteryBodyShape(terminalLengthRatio: terminalLengthRatio,
                                              terminalWidthRatio: terminalWidthRatio,
                                              borderWidth: borderWidth,
                                              cornerRadius: cornerRadius)
                                .stroke(borderColor, lineWidth: borderWidth))
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            }
        }
    }
}

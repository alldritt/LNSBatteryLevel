//
//  BatterLevel.swift
//  BatteryLevel
//
//  Created by Mark Alldritt on 2021-02-14.
//

import SwiftUI


fileprivate extension Int {
    static let fullBattery = 100
}


struct ChargingShape: Shape {

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


struct BatteryBodyShape: Shape {

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


struct BatteryLevelShape: Shape {
    /// 0 to 100 percent full, unavailable = -1
    @Binding public var level: Float
        
    // relative size of battery terminal
    @Binding public var terminalLengthRatio: CGFloat
    
    func path(in bounds: CGRect) -> Path {
        // divide total length into body and terminal
        let terminalLength = terminalLengthRatio * bounds.height
        var (_, bodyFrame) = bounds.divided(atDistance: terminalLength, from: .minYEdge)

        bodyFrame.origin.y += bodyFrame.size.height - bodyFrame.size.height * CGFloat(min(1.0, max(level, 0)))
        bodyFrame.size.height = bodyFrame.size.height * CGFloat(min(1.0, max(level, 0)))

        return Path(bodyFrame)
    }
}


struct BatteryLevel: View {
    /// level 0...100, -1 = no level
    @Binding public var level: Float
    @Binding public var charging: Bool

    /// relative size of  battery terminal
    @State public var terminalLengthRatio: CGFloat = 0.1
    @State public var terminalWidthRatio: CGFloat = 0.4

    /// set as 0 for default borderWidth = length / 20
    @State public var borderWidth: CGFloat = 0
    @State public var borderColor = Color.blue

    /// set as 0 for default cornerRadius = length / 10
    @State public var cornerRadius: CGFloat = 0

    /// change color when level crosses below the threshold
    @State public var lowThreshold: Int = 17

    /// gradually change color when level crosses the threshold
    @State public var gradientThreshold: Int = 0

    @State public var highLevelColor = Color(red: 0.0, green: 0.9, blue: 0.0)
    @State public var lowLevelColor = Color(red: 0.9, green: 0.0, blue: 0.0)
    @State public var noLevelColor = Color(white: 0.8)

    private var levelColor: Color {
        switch Int(max(0, min(level * Float(Int.fullBattery), Float(Int.fullBattery)))) {
        case 0 ... lowThreshold:
            return lowLevelColor
        case gradientThreshold ... .fullBattery:
            return highLevelColor
        default:
            return noLevelColor
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let aspectRatio = CGFloat(0.6)
            let cornerRadius = self.cornerRadius <= 0 ? geometry.size.height / 10 : self.cornerRadius
            let borderWidth = self.borderWidth <= 0 ? geometry.size.height / 20 : self.borderWidth
            
            if charging {
                BatteryLevelShape(level: $level, terminalLengthRatio: $terminalLengthRatio)
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
            }
            else {
                BatteryLevelShape(level: $level, terminalLengthRatio: $terminalLengthRatio)
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
            }
        }
    }
}

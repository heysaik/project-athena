//
//  ProgressCircleView.swift
//  Athena
//
//  Created by Sai Kambampati on 5/3/22.
//

import SwiftUI

struct ProgressCircleView: View {
    @Binding var current: Int?
    var total: Int
    
    var body: some View {
        ZStack {
            Path { path in
                path.addArc(
                    center: CGPoint(x: 95, y: 95),
                    radius: 95,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 360),
                    clockwise: false
                )
            }
            .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
            .fill(Color.blue)
            .opacity(0.2)
            
            Path { path in
                path.addArc(
                    center: CGPoint(x: 95, y: 95),
                    radius: 95,
                    startAngle: Angle(degrees: -90),
                    endAngle: Angle(degrees: -90) + Angle(degrees: 360 * Double(current ?? 0) / Double(total)),
                    clockwise: false
                )
            }
            .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
            .fill(
                AngularGradient(
                    gradient: Gradient(colors: [.init(red: 102/255, green: 169/255, blue: 1)]),
                    center: .center
                )
            )
            
            VStack(alignment: .center, spacing: 4) {
                Text("\(Double(current ?? 0)/Double(total) * 100, specifier: "%.0f")%")
                    .font(.custom("FoundersGrotesk-Bold", size: 45))
                    .foregroundColor(.white)
                
                Text("\(current ?? 0)/\(total) pages read")
                    .caption()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: 180, alignment: .center)
        }
        .frame(width: 190, height: 190, alignment: .center)
        .padding()
    }
}

struct ProgressCircleView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressCircleView(current: .constant(70), total: 75)
    }
}

//
//  MoodChartView.swift
//  serevia
//
//  Created by ekatizzz on 15.04.2026.
//

import UIKit

class MoodChartView: UIView {
    
    private var moodData: [Int: Int] = [:]
    
    private let gridColor = UIColor.lightGray.withAlphaComponent(0.2)
    private let chartLineColor = AppColors.primary
    
    func configure(with data: [Int: Int]) {
        self.moodData = data
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        let padding: CGFloat = 35
        let bottomPadding: CGFloat = 25
        let chartWidth = rect.width - padding - 20
        let chartHeight = rect.height - bottomPadding - 20
        
        let moodEmojis = ["", "", "😔", "😐", "🙂", "😄"] // Индексы 2, 3, 4, 5
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30

        for i in 2...5 {
            let y = 20 + CGFloat(5 - i) * (chartHeight / 3)
            
            let line = UIBezierPath()
            line.move(to: CGPoint(x: padding, y: y))
            line.addLine(to: CGPoint(x: rect.width - 20, y: y))
            UIColor.lightGray.withAlphaComponent(0.2).setStroke()
            line.stroke()
            
            let emoji = moodEmojis[i] as NSString
            emoji.draw(at: CGPoint(x: 5, y: y - 10), withAttributes: [.font: UIFont.systemFont(ofSize: 16)])
        }

        guard !moodData.isEmpty else { return }

        let path = UIBezierPath()
        var isFirstPoint = true
        let sortedDays = moodData.keys.sorted()

        for day in sortedDays {
            guard let moodLevel = moodData[day] else { continue }

            let x = padding + CGFloat(day - 1) * (chartWidth / CGFloat(daysInMonth - 1))
            let y = 20 + CGFloat(5 - moodLevel) * (chartHeight / 3)
            let point = CGPoint(x: x, y: y)

            if isFirstPoint {
                path.move(to: point)
                isFirstPoint = false
            } else {
                path.addLine(to: point)
            }
            
            drawDot(at: point)
            
            let dayText = "\(day)" as NSString
            dayText.draw(at: CGPoint(x: x - 5, y: rect.height - 15), withAttributes: [
                .font: UIFont.systemFont(ofSize: 9),
                .foregroundColor: UIColor.gray
            ])
        }

        path.lineWidth = 3
        path.lineJoinStyle = .round
        AppColors.primary.setStroke()
        path.stroke()
    }
    
    private func drawDot(at point: CGPoint) {
        let dotRadius: CGFloat = 4
        let dot = UIBezierPath(arcCenter: point,
                               radius: dotRadius,
                               startAngle: 0,
                               endAngle: .pi * 2,
                               clockwise: true)
        chartLineColor.setFill()
        dot.fill()
        
        UIColor.white.setStroke()
        dot.lineWidth = 1.5
        dot.stroke()
    }
}

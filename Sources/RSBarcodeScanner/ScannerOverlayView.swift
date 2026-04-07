//
//  ScannerOverlayView.swift
//  BarcodeScannerSDK
//
//  Created by MACM62 on 02/04/26.
//

import Foundation
import UIKit

final class ScannerOverlayView: UIView {

    private let borderLayer = CAShapeLayer()
    private let scanLine = UIView()
    private let gradientLayer = CAGradientLayer()

    var scanRect: CGRect = .zero {
        didSet {
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.black.withAlphaComponent(0.5)

        borderLayer.strokeColor = UIColor.green.cgColor
        borderLayer.lineWidth = 2
        borderLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(borderLayer)

        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.red.cgColor, UIColor.clear.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        scanLine.layer.addSublayer(gradientLayer)
        
        scanLine.backgroundColor = .red
        addSubview(scanLine)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath(rect: bounds)
        let cutout = UIBezierPath(roundedRect: scanRect, cornerRadius: 12)
        path.append(cutout)
        path.usesEvenOddFillRule = true

        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.fillRule = .evenOdd
        layer.mask = mask

        borderLayer.path = cutout.cgPath

        scanLine.frame = CGRect(x: scanRect.minX, y: scanRect.minY, width: scanRect.width, height: 3)
        gradientLayer.frame = scanLine.bounds
        
        animateLine()
    }

    private func animateLine() {
        scanLine.layer.removeAllAnimations()

        // Reset position
        scanLine.frame = CGRect(x: scanRect.minX, y: scanRect.minY, width: scanRect.width, height: 2)

        // Animate transform instead of position (smoother)
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = 0
        animation.toValue = scanRect.height
        animation.duration = 1.5
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        scanLine.layer.add(animation, forKey: "scanLineAnimation")
    }
}

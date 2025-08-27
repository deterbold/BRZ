//
//  ShinyButton.swift
//  BRZ
//
//  Created by Miguel Sicart on 29/09/2024.
//

import UIKit

class ShinyButton: UIButton {
    
    private let shineLayer = CAGradientLayer()
    private let shineAnimation = CABasicAnimation(keyPath: "transform.translation.x")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
        setupShineLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
        setupShineLayer()
    }
    
    private func setupButton() {
        // Apply corner radius
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
        
        // Set background color - brighter white/cream for higher contrast
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.95, alpha: 1.0)
        
        // Set title color and font - pure black text for maximum legibility
        self.setTitleColor(UIColor.black, for: .normal)
        self.titleLabel?.font = UIFont(name: "Futura-Bold", size: 22)
    }
    
    private func setupShineLayer() {
        // Configure the gradient layer for subtle shine effect
        shineLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.15).cgColor,
            UIColor.clear.cgColor
        ]
        shineLayer.locations = [0.0, 0.5, 1.0]
        shineLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shineLayer.endPoint = CGPoint(x: 1, y: 0.5)
        shineLayer.frame = CGRect(x: -bounds.size.width, y: 0, width: bounds.size.width * 3, height: bounds.size.height)
        
        // Configure the animation - slower and less frequent
        shineAnimation.fromValue = -bounds.size.width
        shineAnimation.toValue = bounds.size.width
        shineAnimation.duration = 3.0 // Slower animation
        shineAnimation.repeatCount = Float.infinity
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update frames
        shineLayer.frame = CGRect(x: -bounds.size.width, y: 0, width: bounds.size.width * 3, height: bounds.size.height)
        
        // Remove existing shineLayer to prevent duplicates
        shineLayer.removeFromSuperlayer()
        
        // Add the shine layer
        layer.addSublayer(shineLayer)
        
        // Start the animation
        shineLayer.add(shineAnimation, forKey: "shineAnimation")
    }
}

//
//  CrossedButton.swift
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
        
        // Set background color
        self.backgroundColor = UIColor(red: 246/255, green: 200/255, blue: 131/255, alpha: 1)
        
        // Set title color and font
        self.setTitleColor(UIColor.black, for: .normal)
        self.titleLabel?.font = UIFont(name: "Futura-Bold", size: 22)
    }
    
    private func setupShineLayer() {
        // Configure the gradient layer for shine effect
        shineLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.7).cgColor,
            UIColor.clear.cgColor
        ]
        shineLayer.locations = [0.0, 0.5, 1.0]
        shineLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shineLayer.endPoint = CGPoint(x: 1, y: 0.5)
        shineLayer.frame = CGRect(x: -bounds.size.width, y: 0, width: bounds.size.width * 3, height: bounds.size.height)
        
        // Configure the animation
        shineAnimation.fromValue = -bounds.size.width
        shineAnimation.toValue = bounds.size.width
        shineAnimation.duration = 1.5 // Adjust as needed
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




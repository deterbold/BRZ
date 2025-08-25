//
//  MainInteractionViewController.swift
//  BRZ
//
//  Created by Miguel Sicart on 28/09/2024.
//

import UIKit
import AVFoundation

class MainInteractionViewController: UIViewController {

    // Rectangles
    let bottomRectangle = UIView()
    let middleRectangle = UIView()
    var topRectangle: UIView?

    // Constraints for dynamic updates
    var middleRectangleHeightConstraint: NSLayoutConstraint!
    var topRectangleHeightConstraint: NSLayoutConstraint?
    var topRectangleBottomConstraint: NSLayoutConstraint?

    // Labels
    let inhaleExhaleLabel = UILabel()
    var touchCounter = 0
    var hasShownExhaleInstruction = false
    var hasShownShakeInstruction = false

    // Timer and interaction properties
    var timer: Timer?
    var decreaseRate: CGFloat = 10 // Decrease by 10 px per second
    var increaseRate: CGFloat = 5  // Increase by 5 px per second

    // Haptic feedback
    var tapStartTime: Date?
    var hasTriggeredStrongHapticFeedback = false

    // Sound management
    var backgroundPlayer: AVAudioPlayer?
    var isSoundOn: Bool = true
    
    // Particle system
    var smokeEmitter: CAEmitterLayer?
    
    // City landscape
    var cityBackgroundView: UIView?
    
    // UI toggle
    var isMinimalistMode: Bool = true // Changed to true to hide city by default

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        setupNavigationBar()
        initializeBackgroundSound()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure the navigation bar is visible
        navigationController?.setNavigationBarHidden(false, animated: animated)
        updateSound()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backgroundPlayer?.stop()
    }

    func setupUI() {
        // Set background color
        view.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0) // Gray background
        
        // Add city landscape background
        setupCityLandscape()

        // Configure inhale/exhale label
        inhaleExhaleLabel.text = "INHALE"
        inhaleExhaleLabel.textColor = .gray
        inhaleExhaleLabel.font = UIFont.systemFont(ofSize: 24)
        inhaleExhaleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inhaleExhaleLabel)

        // Position inhale/exhale label
        NSLayoutConstraint.activate([
            inhaleExhaleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inhaleExhaleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50)
        ])

        // Configure bottom rectangle
        bottomRectangle.backgroundColor = UIColor(red: 199/255, green: 151/255, blue: 84/255, alpha: 1)
        bottomRectangle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomRectangle)

        // Configure middle rectangle
        middleRectangle.backgroundColor = .white
        middleRectangle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(middleRectangle)

        // Set up constraints

        // Bottom rectangle constraints
        NSLayoutConstraint.activate([
            bottomRectangle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomRectangle.widthAnchor.constraint(equalToConstant: 50),
            bottomRectangle.heightAnchor.constraint(equalToConstant: 100),
            bottomRectangle.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150)
        ])

        // Middle rectangle constraints
        NSLayoutConstraint.activate([
            middleRectangle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            middleRectangle.widthAnchor.constraint(equalToConstant: 50),
            middleRectangle.bottomAnchor.constraint(equalTo: bottomRectangle.topAnchor)
        ])
        // Middle rectangle height constraint (will be updated dynamically)
        middleRectangleHeightConstraint = middleRectangle.heightAnchor.constraint(equalToConstant: 300)
        middleRectangleHeightConstraint.isActive = true

        // Add initial top rectangle
        addTopRectangle()

        // Enable shake gesture detection
        becomeFirstResponder() // To receive shake events
    }

    func setupNavigationBar() {
        // Sound toggle button (right side)
        let soundButton = UIBarButtonItem(image: UIImage(systemName: "speaker.fill"), style: .plain, target: self, action: #selector(toggleSound))
        navigationItem.rightBarButtonItem = soundButton
        
        // Create minimalist toggle for center position
        let minimalistIcon = isMinimalistMode ? "eye.slash" : "eye"
        let minimalistButton = UIButton(type: .system)
        minimalistButton.setImage(UIImage(systemName: minimalistIcon), for: .normal)
        minimalistButton.tintColor = view.tintColor
        minimalistButton.addTarget(self, action: #selector(toggleMinimalistMode), for: .touchUpInside)
        
        // Set the button as the title view (center position)
        navigationItem.titleView = minimalistButton
        
        // Back button is automatically provided by navigation controller
        // No need to explicitly set it - it will appear automatically
    }
    
    func updateMinimalistButton() {
        let minimalistIcon = isMinimalistMode ? "eye.slash" : "eye"
        if let titleButton = navigationItem.titleView as? UIButton {
            titleButton.setImage(UIImage(systemName: minimalistIcon), for: .normal)
        }
    }

    @objc func toggleSound() {
        isSoundOn.toggle()
        updateSound()
    }
    
    @objc func toggleMinimalistMode() {
        isMinimalistMode.toggle()
        updateCityVisibility()
        updateMinimalistButton()
    }
    
    func updateCityVisibility() {
        cityBackgroundView?.isHidden = isMinimalistMode
    }
    
    func startBurningAnimation(on view: UIView) {
        // Create a color animation that cycles through fire colors
        let colorAnimation = CAKeyframeAnimation(keyPath: "backgroundColor")
        
        // Define fire colors: gray -> orange -> red -> yellow -> orange -> gray
        let grayColor = UIColor(red: 164/255, green: 162/255, blue: 152/255, alpha: 1).cgColor
        let orangeColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1).cgColor
        let redColor = UIColor(red: 1.0, green: 0.3, blue: 0.1, alpha: 1).cgColor
        let yellowColor = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1).cgColor
        let deepOrangeColor = UIColor(red: 0.9, green: 0.4, blue: 0.1, alpha: 1).cgColor
        
        colorAnimation.values = [
            grayColor,      // Start with gray
            orangeColor,    // Heat up to orange
            redColor,       // Intensify to red
            yellowColor,    // Flash yellow
            deepOrangeColor, // Deep orange
            orangeColor,    // Back to orange
            grayColor       // Cool down to gray
        ]
        
        // Set timing for each color transition
        colorAnimation.keyTimes = [0.0, 0.2, 0.4, 0.5, 0.6, 0.8, 1.0]
        
        // Animation properties
        colorAnimation.duration = 3.0 // 3 seconds for full cycle
        colorAnimation.repeatCount = .infinity
        colorAnimation.autoreverses = false
        colorAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // Add the animation to the view's layer
        view.layer.add(colorAnimation, forKey: "burningAnimation")
    }
    
    func stopBurningAnimation(on view: UIView) {
        view.layer.removeAnimation(forKey: "burningAnimation")
        // Reset to original gray color
        view.backgroundColor = UIColor(red: 164/255, green: 162/255, blue: 152/255, alpha: 1)
    }

    func updateSound() {
        if isSoundOn {
            // Play background sound
            backgroundPlayer?.play()
            // Update sound button icon
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "speaker.fill")
        } else {
            // Pause background sound
            backgroundPlayer?.pause()
            // Update sound button icon
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "speaker.slash.fill")
        }
    }

    func initializeBackgroundSound() {
        guard let soundURL = Bundle.main.url(forResource: "background", withExtension: "flac") else {
            print("Unable to find background.flac")
            return
        }

        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: soundURL)
            backgroundPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundPlayer?.prepareToPlay()
            if isSoundOn {
                backgroundPlayer?.play()
            }
        } catch {
            print("Unable to play background.flac: \(error)")
        }
    }

    func addTopRectangle() {
        // Remove existing top rectangle and constraints if any
        if let topRect = topRectangle {
            topRect.removeFromSuperview()
        }
        if let topRectHeightConstraint = topRectangleHeightConstraint {
            topRectHeightConstraint.isActive = false
        }
        if let topRectBottomConstraint = topRectangleBottomConstraint {
            topRectBottomConstraint.isActive = false
        }
        topRectangleHeightConstraint = nil
        topRectangleBottomConstraint = nil

        // Configure top rectangle
        let newTopRectangle = UIView()
        newTopRectangle.backgroundColor = UIColor(red: 164/255, green: 162/255, blue: 152/255, alpha: 1) // Keep base gray color
        newTopRectangle.translatesAutoresizingMaskIntoConstraints = false
        newTopRectangle.transform = .identity
        view.addSubview(newTopRectangle)
        topRectangle = newTopRectangle

        // Add burning animation
        startBurningAnimation(on: newTopRectangle)

        // Top rectangle constraints
        NSLayoutConstraint.activate([
            newTopRectangle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newTopRectangle.widthAnchor.constraint(equalToConstant: 50)
        ])
        // Top rectangle height constraint (will be updated dynamically)
        topRectangleHeightConstraint = newTopRectangle.heightAnchor.constraint(equalToConstant: 10)
        topRectangleHeightConstraint?.isActive = true

        // Top rectangle bottom constraint (to be updated as middle rectangle height changes)
        topRectangleBottomConstraint = newTopRectangle.bottomAnchor.constraint(equalTo: middleRectangle.topAnchor)
        topRectangleBottomConstraint?.isActive = true
    }

    func setupGestures() {
        // Add gesture recognizer to the main view
        let touchDownGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTouch(_:)))
        touchDownGesture.minimumPressDuration = 0
        touchDownGesture.delegate = self
        view.addGestureRecognizer(touchDownGesture)

        // Remove double-tap gesture recognizer if it exists
        // (Assuming previous code had a double-tap gesture; ensure it's removed)
        // Since in current implementation, double-tap is not added, no action needed here
    }

    // Enable shake detection
    override var canBecomeFirstResponder: Bool {
        return true
    }

    // Handle shake motion
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            handleShake()
        }
    }

    func handleShake() {
        guard let topRect = topRectangle else { return }
        
        // Hide SHAKE instruction when user shakes
        if hasShownShakeInstruction {
            inhaleExhaleLabel.isHidden = true
        }
        
        // Play "taps.wav" when removing the top rectangle
        SoundManager.shared.playSound(named: "taps", withExtension: "wav")

        // Remove top rectangle with animation
        UIView.animate(withDuration: 0.5, animations: {
            topRect.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }, completion: { _ in
            // Deactivate constraints
            self.topRectangleHeightConstraint?.isActive = false
            self.topRectangleHeightConstraint = nil

            self.topRectangleBottomConstraint?.isActive = false
            self.topRectangleBottomConstraint = nil

            topRect.removeFromSuperview()
            self.topRectangle = nil

            // Immediately add a new top rectangle without animation
            self.addTopRectangle()
            self.topRectangleHeightConstraint?.constant = 10
            self.view.layoutIfNeeded()
        })
    }

    @objc func handleTouch(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            // Increment touch counter
            touchCounter += 1
            
            // Start updating the heights
            startUpdatingHeights()
            
            // Start particle emission
            startSmokeParticles()

            // Record tap start time
            tapStartTime = Date()
            hasTriggeredStrongHapticFeedback = false

            // Trigger mild vibration
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()

            // Hide inhale/exhale label during interaction (unless EXHALE is already shown)
            if !hasShownExhaleInstruction {
                inhaleExhaleLabel.isHidden = true
            }
            
        } else if gesture.state == .ended || gesture.state == .cancelled {
            // Stop updating the heights
            stopUpdatingHeights()
            
            // Stop particle emission
            stopSmokeParticles()

            // Reset tap start time
            tapStartTime = nil
            hasTriggeredStrongHapticFeedback = false

            // Hide the label after touch ends
            inhaleExhaleLabel.isHidden = true

            // Show appropriate text after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !self.hasShownExhaleInstruction {
                    // Still showing INHALE
                    self.inhaleExhaleLabel.text = "INHALE"
                    self.inhaleExhaleLabel.isHidden = false
                } else {
                    // EXHALE was shown, check if we should show SHAKE
                    if self.touchCounter >= 3 && !self.hasShownShakeInstruction {
                        self.hasShownShakeInstruction = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.inhaleExhaleLabel.text = "SHAKE"
                            self.inhaleExhaleLabel.isHidden = false
                        }
                    }
                }
            }
        }
    }

    func startUpdatingHeights() {
        // Invalidate any existing timer
        timer?.invalidate()
        // Start a new timer
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateHeights), userInfo: nil, repeats: true)
    }

    func stopUpdatingHeights() {
        timer?.invalidate()
        timer = nil
    }

    @objc func updateHeights() {
        let timeInterval = CGFloat(timer?.timeInterval ?? 0.1)

        // Check for 2-second hold to show EXHALE instruction
        if let startTime = tapStartTime, !hasShownExhaleInstruction {
            let elapsedTime = Date().timeIntervalSince(startTime)
            if elapsedTime >= 2.0 {
                hasShownExhaleInstruction = true
                inhaleExhaleLabel.text = "EXHALE"
                inhaleExhaleLabel.isHidden = false
            }
        }

        // Decrease the height of the middle rectangle
        let decrement = decreaseRate * timeInterval
        let newMiddleHeight = middleRectangleHeightConstraint.constant - decrement

        var shouldStop = false

        if newMiddleHeight > 0 {
            middleRectangleHeightConstraint.constant = newMiddleHeight
        } else {
            // Stop decreasing when height reaches zero
            middleRectangleHeightConstraint.constant = 0
            shouldStop = true

            // Remove rectangles and show "NAMASTE"
            removeRectanglesAndShowNamaste()
        }

        // Increase the height of the top rectangle if it exists
        if let topRectHeightConstraint = topRectangleHeightConstraint, topRectangle != nil {
            let increment = increaseRate * timeInterval
            let newTopHeight = topRectHeightConstraint.constant + increment

            // Optionally, set a maximum height for the top rectangle
            let maxTopHeight: CGFloat = 500 // Adjust as needed
            if newTopHeight <= maxTopHeight {
                topRectHeightConstraint.constant = newTopHeight
            } else {
                topRectHeightConstraint.constant = maxTopHeight
            }
        }

        // Check for prolonged tap and trigger stronger haptic feedback
        if let startTime = tapStartTime, !hasTriggeredStrongHapticFeedback {
            let elapsedTime = Date().timeIntervalSince(startTime)
            if elapsedTime >= 2.0 {
                // Trigger stronger vibration
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.prepare()
                generator.impactOccurred()

                hasTriggeredStrongHapticFeedback = true
            }
        }

        // Update the layout
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
        
        // Update smoke emitter position as rectangles change
        updateSmokeEmitterPosition()

        if shouldStop {
            stopUpdatingHeights()
        }
    }

    func removeRectanglesAndShowNamaste() {
        // Remove rectangles from the view
        bottomRectangle.removeFromSuperview()
        middleRectangle.removeFromSuperview()
        topRectangle?.removeFromSuperview()

        // Show "NAMASTE" label
        let namasteLabel = UILabel()
        namasteLabel.text = "NAMASTE"
        namasteLabel.textColor = .white
        namasteLabel.font = UIFont.systemFont(ofSize: 32)
        namasteLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(namasteLabel)

        // Position "NAMASTE" label
        NSLayoutConstraint.activate([
            namasteLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            namasteLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Return to IntroductionViewController after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// Conform to UIGestureRecognizerDelegate to handle gesture recognition alongside other UI elements
extension MainInteractionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Avoid interfering with other interactive elements (e.g., navigation bar buttons)
        if let viewTouched = touch.view, viewTouched is UIControl {
            return false
        }
        return true
    }
}

// MARK: - Particle Effects
extension MainInteractionViewController {
    
    func startSmokeParticles() {
        guard let topRect = topRectangle,
              smokeEmitter == nil else { return }
        
        // Create the emitter layer
        smokeEmitter = CAEmitterLayer()
        guard let emitter = smokeEmitter else { return }
        
        // Position the emitter at the top center of the top rectangle
        let topRectFrame = topRect.frame
        emitter.emitterPosition = CGPoint(x: topRectFrame.midX, y: topRectFrame.minY)
        emitter.emitterSize = CGSize(width: topRectFrame.width, height: 1)
        emitter.emitterShape = CAEmitterLayerEmitterShape.line
        
        // Create the smoke particle cell
        let smokeCell = CAEmitterCell()
        smokeCell.name = "smoke"
        
        // Load the particle image
        if let smokeImage = UIImage(named: "smokeParticle") {
            smokeCell.contents = smokeImage.cgImage
        }
        
        // Particle properties
        smokeCell.birthRate = 15 // Particles per second
        smokeCell.lifetime = 2.5 // Particle life in seconds
        smokeCell.lifetimeRange = 1.0 // Variation in lifetime
        
        // Velocity and direction
        smokeCell.velocity = 50 // Initial velocity
        smokeCell.velocityRange = 20 // Velocity variation
        smokeCell.emissionRange = CGFloat.pi * 0.3 // Emission angle range (54 degrees)
        
        // Size and scale
        smokeCell.scale = 0.2 // Initial scale
        smokeCell.scaleRange = 0.07 // Scale variation
        smokeCell.scaleSpeed = 0.2 // Scale change over time
        
        // Alpha and fade
        smokeCell.alphaRange = 0.3 // Alpha variation
        smokeCell.alphaSpeed = -0.3 // Fade out over time
        
        // Spin
        smokeCell.spin = 0.5 // Rotation speed
        smokeCell.spinRange = 1.0 // Spin variation
        
        // Add the cell to the emitter
        emitter.emitterCells = [smokeCell]
        
        // Add the emitter to the view
        view.layer.addSublayer(emitter)
    }
    
    func stopSmokeParticles() {
        smokeEmitter?.removeFromSuperlayer()
        smokeEmitter = nil
    }
    
    func updateSmokeEmitterPosition() {
        guard let emitter = smokeEmitter,
              let topRect = topRectangle else { return }
        
        // Update emitter position as the top rectangle changes
        let topRectFrame = topRect.frame
        emitter.emitterPosition = CGPoint(x: topRectFrame.midX, y: topRectFrame.minY)
    }
}

// MARK: - City Landscape Background
extension MainInteractionViewController {
    
    func setupCityLandscape() {
        cityBackgroundView = UIView()
        guard let cityView = cityBackgroundView else { return }
        
        cityView.backgroundColor = .clear
        cityView.translatesAutoresizingMaskIntoConstraints = false
        cityView.isHidden = isMinimalistMode // Respect initial minimalist mode setting
        view.addSubview(cityView)
        view.sendSubviewToBack(cityView)
        
        // Fill the entire view
        NSLayoutConstraint.activate([
            cityView.topAnchor.constraint(equalTo: view.topAnchor),
            cityView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cityView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cityView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add city drawing after layout
        DispatchQueue.main.async {
            self.drawCityLandscape()
        }
    }
    
    func drawCityLandscape() {
        guard let cityView = cityBackgroundView else { return }
        
        // Remove existing city layers
        cityView.layer.sublayers?.removeAll()
        
        let bounds = cityView.bounds
        guard bounds.width > 0 && bounds.height > 0 else { return }
        
        // Create the city shape layer
        let cityLayer = CAShapeLayer()
        cityLayer.fillColor = UIColor.clear.cgColor
        cityLayer.strokeColor = UIColor.black.cgColor
        cityLayer.lineWidth = 1.5
        cityLayer.lineCap = .round
        cityLayer.lineJoin = .round
        
        let path = UIBezierPath()
        
        // Generate procedural city skyline
        generateCitySkyline(path: path, bounds: bounds)
        
        cityLayer.path = path.cgPath
        cityView.layer.addSublayer(cityLayer)
    }
    
    func generateCitySkyline(path: UIBezierPath, bounds: CGRect) {
        // Align ground level with bottom rectangle (top of bottom rectangle)
        let groundLevel = bounds.height - 150 // Same as bottomRectangle constraint
        
        let buildingCount = Int(bounds.width / 30) // One building every 30 points
        
        var currentX: CGFloat = 0
        
        for i in 0..<buildingCount {
            let buildingWidth = CGFloat.random(in: 20...60)
            let buildingHeight = CGFloat.random(in: 50...200)
            
            // Don't draw building if it goes beyond screen width
            if currentX + buildingWidth > bounds.width {
                break
            }
            
            let buildingTop = groundLevel - buildingHeight
            
            // Draw building outline
            drawBuilding(path: path,
                        x: currentX,
                        y: buildingTop,
                        width: buildingWidth,
                        height: buildingHeight)
            
            // Add some variation in spacing
            currentX += buildingWidth + CGFloat.random(in: 2...10)
        }
        
        // Draw ground line
        path.move(to: CGPoint(x: 0, y: groundLevel))
        path.addLine(to: CGPoint(x: bounds.width, y: groundLevel))
        
        // Add clouds
        generateClouds(path: path, bounds: bounds)
        
        // Add birds
        generateBirds(path: path, bounds: bounds)
    }
    
    func drawBuilding(path: UIBezierPath, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        // Basic building outline
        let buildingRect = CGRect(x: x, y: y, width: width, height: height)
        path.append(UIBezierPath(rect: buildingRect))
        
        // Add windows (simple grid pattern) - just outlines
        let windowRows = Int(height / 15)
        let windowCols = Int(width / 12)
        
        for row in 1..<windowRows {
            for col in 1..<windowCols {
                let windowX = x + CGFloat(col) * 12 + 2
                let windowY = y + CGFloat(row) * 15 + 2
                let windowSize: CGFloat = 6
                
                // Show window outlines (not filled)
                if Bool.random() && row < windowRows - 1 {
                    let windowRect = CGRect(x: windowX, y: windowY, width: windowSize, height: windowSize)
                    path.append(UIBezierPath(rect: windowRect))
                }
            }
        }
        
        // Add rooftop details occasionally
        if Bool.random() {
            let antennaHeight: CGFloat = CGFloat.random(in: 10...30)
            path.move(to: CGPoint(x: x + width/2, y: y))
            path.addLine(to: CGPoint(x: x + width/2, y: y - antennaHeight))
            
            // Small antenna top
            path.move(to: CGPoint(x: x + width/2 - 3, y: y - antennaHeight))
            path.addLine(to: CGPoint(x: x + width/2 + 3, y: y - antennaHeight))
        }
    }
    
    func generateClouds(path: UIBezierPath, bounds: CGRect) {
        let cloudCount = Int.random(in: 3...8)
        let skyHeight = bounds.height * 0.4 // Clouds in upper 40% of sky
        
        for _ in 0..<cloudCount {
            let cloudX = CGFloat.random(in: 0...bounds.width)
            let cloudY = CGFloat.random(in: 0...skyHeight)
            let cloudWidth = CGFloat.random(in: 40...80)
            let cloudHeight = CGFloat.random(in: 15...30)
            
            drawCloud(path: path, x: cloudX, y: cloudY, width: cloudWidth, height: cloudHeight)
        }
    }
    
    func drawCloud(path: UIBezierPath, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        // Simple cloud shape using connected arcs
        let cloudPath = UIBezierPath()
        
        // Start from left
        cloudPath.move(to: CGPoint(x: x + width * 0.2, y: y + height))
        
        // Bottom curve
        cloudPath.addQuadCurve(to: CGPoint(x: x + width * 0.8, y: y + height),
                              controlPoint: CGPoint(x: x + width * 0.5, y: y + height * 1.2))
        
        // Right side
        cloudPath.addQuadCurve(to: CGPoint(x: x + width * 0.9, y: y + height * 0.3),
                              controlPoint: CGPoint(x: x + width * 1.1, y: y + height * 0.7))
        
        // Top right bump
        cloudPath.addQuadCurve(to: CGPoint(x: x + width * 0.7, y: y),
                              controlPoint: CGPoint(x: x + width * 0.9, y: y - height * 0.2))
        
        // Top middle bump
        cloudPath.addQuadCurve(to: CGPoint(x: x + width * 0.4, y: y + height * 0.1),
                              controlPoint: CGPoint(x: x + width * 0.6, y: y - height * 0.3))
        
        // Top left bump
        cloudPath.addQuadCurve(to: CGPoint(x: x + width * 0.1, y: y + height * 0.4),
                              controlPoint: CGPoint(x: x + width * 0.2, y: y - height * 0.1))
        
        // Left side back to start
        cloudPath.addQuadCurve(to: CGPoint(x: x + width * 0.2, y: y + height),
                              controlPoint: CGPoint(x: x - width * 0.1, y: y + height * 0.8))
        
        path.append(cloudPath)
    }
    
    func generateBirds(path: UIBezierPath, bounds: CGRect) {
        let birdCount = Int.random(in: 2...6)
        let skyHeight = bounds.height * 0.6 // Birds in upper 60% of sky
        
        for _ in 0..<birdCount {
            let birdX = CGFloat.random(in: 0...bounds.width - 20)
            let birdY = CGFloat.random(in: 0...skyHeight)
            
            drawBird(path: path, x: birdX, y: birdY)
        }
    }
    
    func drawBird(path: UIBezierPath, x: CGFloat, y: CGFloat) {
        // Simple bird silhouette - two curved lines forming a "V" shape
        let wingSpan: CGFloat = 12
        let wingHeight: CGFloat = 6
        
        // Left wing
        path.move(to: CGPoint(x: x, y: y))
        path.addQuadCurve(to: CGPoint(x: x + wingSpan/2, y: y + wingHeight),
                         controlPoint: CGPoint(x: x + wingSpan/4, y: y - wingHeight/2))
        
        // Right wing
        path.move(to: CGPoint(x: x + wingSpan/2, y: y + wingHeight))
        path.addQuadCurve(to: CGPoint(x: x + wingSpan, y: y),
                         controlPoint: CGPoint(x: x + wingSpan * 0.75, y: y - wingHeight/2))
    }
}

// Override viewDidLayoutSubviews to redraw city when bounds change
extension MainInteractionViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Redraw city landscape when layout changes
        DispatchQueue.main.async {
            self.drawCityLandscape()
        }
    }
}

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
    var inhaleExhaleCounter = 0

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

    // Shake count to manage two shakes for adding top rectangle
    var shakeCountAfterTopRectangleRemoved: Int = 0

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
        view.backgroundColor = .black

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
        // Sound toggle button
        let soundButton = UIBarButtonItem(image: UIImage(systemName: "speaker.fill"), style: .plain, target: self, action: #selector(toggleSound))
        navigationItem.rightBarButtonItem = soundButton
    }

    @objc func toggleSound() {
        isSoundOn.toggle()
        updateSound()
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
        newTopRectangle.backgroundColor = UIColor(red: 164/255, green: 162/255, blue: 152/255, alpha: 1)
        newTopRectangle.translatesAutoresizingMaskIntoConstraints = false
        newTopRectangle.transform = .identity
        view.addSubview(newTopRectangle)
        topRectangle = newTopRectangle

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
        if let topRect = topRectangle {
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

                // Reset shake count
                self.shakeCountAfterTopRectangleRemoved = 0
            })
        } else {
            // Increment shake count
            shakeCountAfterTopRectangleRemoved += 1

            if shakeCountAfterTopRectangleRemoved >= 1 {
                // Add a new top rectangle with height 0
                addTopRectangle()
                topRectangleHeightConstraint?.constant = 0
                UIView.animate(withDuration: 0.1) {
                    self.view.layoutIfNeeded()
                }

                // Reset shake count
                shakeCountAfterTopRectangleRemoved = 0
            }
        }
    }

    @objc func handleTouch(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            // Start updating the heights
            startUpdatingHeights()

            // Record tap start time
            tapStartTime = Date()
            hasTriggeredStrongHapticFeedback = false

            // Trigger mild vibration
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()

            // Hide inhale/exhale label
            inhaleExhaleLabel.isHidden = true

            // Handle inhale/exhale text for first two taps
            if inhaleExhaleCounter < 2 {
                inhaleExhaleCounter += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.inhaleExhaleLabel.text = "EXHALE"
                    self.inhaleExhaleLabel.isHidden = false
                }
            }
        } else if gesture.state == .ended || gesture.state == .cancelled {
            // Stop updating the heights
            stopUpdatingHeights()

            // Reset tap start time
            tapStartTime = nil
            hasTriggeredStrongHapticFeedback = false

            // Hide inhale/exhale label after exhale
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.inhaleExhaleLabel.isHidden = true
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





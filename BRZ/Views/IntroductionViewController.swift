//
//  IntroductionViewController.swift
//  BRZ
//
//  Created by Miguel Sicart on 28/09/2024.
//

import UIKit
import WebKit

class IntroductionViewController: UIViewController {

    var webView: WKWebView!
    var startButton: ShinyButton!
    var backgroundImageView: UIImageView!
    var blurEffectView: UIVisualEffectView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupEssentialUI()
        observeAccessibilityChanges()
        // Defer non-critical UI setup
        DispatchQueue.main.async {
            self.setupDeferredUI()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startBackgroundImageRotation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopBackgroundImageRotation()
    }

    func setupEssentialUI() {
        // Initialize the background image view with a placeholder color
        backgroundImageView = UIImageView()
        backgroundImageView.backgroundColor = UIColor.black // Placeholder color
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.alpha = 0.8 // Adjust transparency as needed

        // Add the background image view
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)

        // Set up constraints for the background image view
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Add blur effect over the background image
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false

        // Add the blur effect view
        view.addSubview(blurEffectView)
        view.sendSubviewToBack(blurEffectView)

        // Set up constraints for the blur effect view
        NSLayoutConstraint.activate([
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Initialize the Start button using ShinyButton
        startButton = ShinyButton(type: .system)
        startButton.setTitle("Start", for: .normal)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        startButton.translatesAutoresizingMaskIntoConstraints = false

        // Accessibility settings
        startButton.accessibilityLabel = "Start"
        startButton.accessibilityHint = "Double-tap to begin your relaxation journey."

        // Add the start button to the view
        view.addSubview(startButton)

        // Set up constraints for the Start button
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120),
            startButton.widthAnchor.constraint(equalToConstant: 80),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func setupDeferredUI() {
        // Load the background image asynchronously
        DispatchQueue.global(qos: .background).async {
            if let image = UIImage(named: "backgroundImage") {
                DispatchQueue.main.async {
                    self.backgroundImageView.image = image
                }
            }
        }

        // Initialize WKWebView
        webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .clear
        webView.isOpaque = false

        // Load HTML content directly from the file URL
        if let htmlURL = Bundle.main.url(forResource: "instructions", withExtension: "html") {
            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
        } else {
            print("HTML file not found")
        }

        // Add the webView to the view hierarchy
        view.addSubview(webView)

        // Set up constraints for the webView
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -20)
        ])
    }

    @objc func startButtonTapped() {
        let mainVC = MainInteractionViewController()
        navigationController?.pushViewController(mainVC, animated: true)
    }

    func startBackgroundImageRotation() {
        guard !UIAccessibility.isReduceMotionEnabled else {
            // Do not start the animation if Reduce Motion is enabled
            return
        }

        // Check if the animation is already added
        if backgroundImageView.layer.animation(forKey: "rotationAnimation") == nil {
            // Create rotation animation
            let rotation = CABasicAnimation(keyPath: "transform.rotation")
            rotation.fromValue = 0
            rotation.toValue = CGFloat.pi * 2 // 360 degrees in radians
            rotation.duration = 30.0 // Adjust duration for rotation speed
            rotation.repeatCount = .infinity

            // Add animation to the background image view's layer
            backgroundImageView.layer.add(rotation, forKey: "rotationAnimation")
        }
    }

    func stopBackgroundImageRotation() {
        // Remove the rotation animation
        backgroundImageView.layer.removeAnimation(forKey: "rotationAnimation")
    }

    func observeAccessibilityChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessibilitySettingsChanged),
            name: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil
        )
    }

    @objc func accessibilitySettingsChanged() {
        if UIAccessibility.isReduceMotionEnabled {
            // Remove animation
            stopBackgroundImageRotation()
        } else {
            // Start animation
            startBackgroundImageRotation()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIAccessibility.reduceMotionStatusDidChangeNotification, object: nil)
    }
}


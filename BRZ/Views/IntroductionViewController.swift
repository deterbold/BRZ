//
//  IntroductionViewController.swift
//  BRZ
//
//  Created by Miguel Sicart on 28/09/2024.
//

//import UIKit
//import WebKit
//
//class IntroductionViewController: UIViewController {
//
//    var webView: WKWebView!
//    var startButton: UIButton!
//    var backgroundImageView: UIImageView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        observeAccessibilityChanges()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        startBackgroundImageRotation()
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        stopBackgroundImageRotation()
//    }
//
//    func setupUI() {
//        // Set up the background image view
//        backgroundImageView = UIImageView(image: UIImage(named: "backgroundImage"))
//        backgroundImageView.contentMode = .scaleAspectFill
//        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
//
//        // Add the background image view
//        view.addSubview(backgroundImageView)
//        view.sendSubviewToBack(backgroundImageView)
//
//        // Set up constraints for the background image view
//        NSLayoutConstraint.activate([
//            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
//            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//
//        // Initialize WKWebView
//        webView = WKWebView()
//        webView.translatesAutoresizingMaskIntoConstraints = false
//        webView.backgroundColor = .clear
//        webView.isOpaque = false
//
//        // Load HTML content directly from the file URL
//        if let htmlURL = Bundle.main.url(forResource: "instructions", withExtension: "html") {
//            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
//        } else {
//            print("HTML file not found")
//        }
//
//        // Initialize the Start button
//        startButton = UIButton(type: .system)
//        startButton.setTitle("START", for: .normal)
//        startButton.setTitleColor(.yellow, for: .normal)
//        startButton.backgroundColor = .black
//        startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20) // Bold text
//        startButton.layer.cornerRadius = 10 // Rounded corners
//        startButton.clipsToBounds = true // Clip to bounds to apply corner radius
//
//        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
//        startButton.translatesAutoresizingMaskIntoConstraints = false
//
//        // Accessibility settings
//        startButton.accessibilityLabel = "Start"
//        startButton.accessibilityHint = "Double-tap to begin your relaxation journey."
//
//        // Add subviews
//        view.addSubview(webView)
//        view.addSubview(startButton)
//
//        // Set up constraints
//
//        // WebView constraints
//        NSLayoutConstraint.activate([
//            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            webView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -20)
//        ])
//
//        // StartButton constraints
//        NSLayoutConstraint.activate([
//            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120),
//            startButton.widthAnchor.constraint(equalToConstant: 120),
//            startButton.heightAnchor.constraint(equalToConstant: 50)
//        ])
//    }
//
//    @objc func startButtonTapped() {
//        let mainVC = MainInteractionViewController()
//        navigationController?.pushViewController(mainVC, animated: true)
//    }
//
//    func startBackgroundImageRotation() {
//        guard !UIAccessibility.isReduceMotionEnabled else {
//            // Do not start the animation if Reduce Motion is enabled
//            return
//        }
//
//        // Check if the animation is already added
//        if backgroundImageView.layer.animation(forKey: "rotationAnimation") == nil {
//            // Create rotation animation
//            let rotation = CABasicAnimation(keyPath: "transform.rotation")
//            rotation.fromValue = 0
//            rotation.toValue = CGFloat.pi * 2 // 360 degrees in radians
//            rotation.duration = 30.0 // Adjust duration for rotation speed
//            rotation.repeatCount = .infinity
//
//            // Add animation to the background image view's layer
//            backgroundImageView.layer.add(rotation, forKey: "rotationAnimation")
//        }
//    }
//
//    func stopBackgroundImageRotation() {
//        // Remove the rotation animation
//        backgroundImageView.layer.removeAnimation(forKey: "rotationAnimation")
//    }
//
//    func observeAccessibilityChanges() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(accessibilitySettingsChanged),
//            name: UIAccessibility.reduceMotionStatusDidChangeNotification,
//            object: nil
//        )
//    }
//
//    @objc func accessibilitySettingsChanged() {
//        if UIAccessibility.isReduceMotionEnabled {
//            // Remove animation
//            stopBackgroundImageRotation()
//        } else {
//            // Start animation
//            startBackgroundImageRotation()
//        }
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: UIAccessibility.reduceMotionStatusDidChangeNotification, object: nil)
//    }
//}
import UIKit

class IntroductionViewController: UIViewController {

    var startButton: UIButton!
    var backgroundImageView: UIImageView!
    var scrollView: UIScrollView!
    var contentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observeAccessibilityChanges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startBackgroundImageRotation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopBackgroundImageRotation()
    }

    func setupUI() {
        // Set up the background image view
        backgroundImageView = UIImageView(image: UIImage(named: "backgroundImage"))
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false

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

        // Initialize the Start button
        startButton = UIButton(type: .system)
        startButton.setTitle("START", for: .normal)
        startButton.setTitleColor(.yellow, for: .normal)
        startButton.backgroundColor = .black
        startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20) // Bold text
        startButton.layer.cornerRadius = 10 // Rounded corners
        startButton.clipsToBounds = true // Apply corner radius

        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        startButton.translatesAutoresizingMaskIntoConstraints = false

        // Accessibility settings
        startButton.accessibilityLabel = "Start"
        startButton.accessibilityHint = "Double-tap to begin your relaxation journey."

        // Add the start button to the view
        view.addSubview(startButton)

        // Initialize the scroll view and content view for instructions
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Add scroll view and content view to the hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Set up constraints for the Start button
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120),
            startButton.widthAnchor.constraint(equalToConstant: 120),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Set up constraints for scroll view
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -20)
        ])

        // Set up constraints for content view
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Add labels to content view
        let titleLabel = UILabel()
        titleLabel.text = "Welcome to RelaxApp!"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 26)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let descriptionLabel = UILabel()
        descriptionLabel.text = "This app helps you relax through simple interactions."
        descriptionLabel.font = UIFont.systemFont(ofSize: 20)
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        let instructionsTitleLabel = UILabel()
        instructionsTitleLabel.text = "Instructions:"
        instructionsTitleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        instructionsTitleLabel.textColor = .white
        instructionsTitleLabel.textAlignment = .center
        instructionsTitleLabel.numberOfLines = 0
        instructionsTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Create labels for each instruction
        let instruction1Label = UILabel()
        instruction1Label.text = "1. Press and hold the button on the next screen."
        instruction1Label.font = UIFont.systemFont(ofSize: 18)
        instruction1Label.textColor = .white
        instruction1Label.numberOfLines = 0
        instruction1Label.translatesAutoresizingMaskIntoConstraints = false

        let instruction2Label = UILabel()
        instruction2Label.text = "2. Release when you're ready to relax."
        instruction2Label.font = UIFont.systemFont(ofSize: 18)
        instruction2Label.textColor = .white
        instruction2Label.numberOfLines = 0
        instruction2Label.translatesAutoresizingMaskIntoConstraints = false

        let instruction3Label = UILabel()
        instruction3Label.text = "3. Enjoy the soothing sounds and visuals."
        instruction3Label.font = UIFont.systemFont(ofSize: 18)
        instruction3Label.textColor = .white
        instruction3Label.numberOfLines = 0
        instruction3Label.translatesAutoresizingMaskIntoConstraints = false

        let startInstructionLabel = UILabel()
        startInstructionLabel.text = "Press \"Start\" to begin your relaxation journey."
        startInstructionLabel.font = UIFont.systemFont(ofSize: 20)
        startInstructionLabel.textColor = .white
        startInstructionLabel.textAlignment = .center
        startInstructionLabel.numberOfLines = 0
        startInstructionLabel.translatesAutoresizingMaskIntoConstraints = false

        // Add labels to content view
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(instructionsTitleLabel)
        contentView.addSubview(instruction1Label)
        contentView.addSubview(instruction2Label)
        contentView.addSubview(instruction3Label)
        contentView.addSubview(startInstructionLabel)

        // Set up constraints for labels
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            instructionsTitleLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            instructionsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            instructionsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            instruction1Label.topAnchor.constraint(equalTo: instructionsTitleLabel.bottomAnchor, constant: 10),
            instruction1Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            instruction1Label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            instruction2Label.topAnchor.constraint(equalTo: instruction1Label.bottomAnchor, constant: 5),
            instruction2Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            instruction2Label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            instruction3Label.topAnchor.constraint(equalTo: instruction2Label.bottomAnchor, constant: 5),
            instruction3Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            instruction3Label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            startInstructionLabel.topAnchor.constraint(equalTo: instruction3Label.bottomAnchor, constant: 20),
            startInstructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            startInstructionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            startInstructionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
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




//
//  IntroductionViewController.swift
//  BRZ
//
//  Created by Miguel Sicart on 28/09/2024.
//

import UIKit

class IntroductionViewController: UIViewController {
    
    // MARK: - UI Components
    private var textContainerView: UIView!
    private var textLabel: UILabel!
    private var startButton: ShinyButton!
    private var tutorialButton: ShinyButton!
    private var aboutButton: ShinyButton!
    private var backgroundImageView: UIImageView!
    private var blurEffectView: UIVisualEffectView!
    
    // MARK: - Constants
    private struct Constants {
        static let backgroundAlpha: CGFloat = 0.8
        static let rotationDuration: TimeInterval = 30.0
        
        // Responsive margins and spacing
        static let minButtonBottomMargin: CGFloat = 20
        static let buttonSpacingMultiplier: CGFloat = 0.02 // 2% of screen width
        static let minButtonSpacing: CGFloat = 8
        static let maxButtonSpacing: CGFloat = 30
        
        // Responsive button sizing
        static let buttonWidthMultiplier: CGFloat = 0.22 // 22% of screen width
        static let minButtonWidth: CGFloat = 80
        static let maxButtonWidth: CGFloat = 120
        static let buttonHeightMultiplier: CGFloat = 0.06 // 6% of screen height
        static let minButtonHeight: CGFloat = 44
        static let maxButtonHeight: CGFloat = 60
        
        // Responsive text container
        static let textContainerHorizontalMarginMultiplier: CGFloat = 0.05 // 5% of screen width
        static let minTextContainerMargin: CGFloat = 16
        static let maxTextContainerMargin: CGFloat = 40
        static let textContainerTopMarginMultiplier: CGFloat = 0.05 // 5% of screen height
        static let minTextContainerTopMargin: CGFloat = 20
        static let maxTextContainerTopMargin: CGFloat = 60
        static let textContainerBottomSpacingMultiplier: CGFloat = 0.05 // 5% of screen height
        static let minTextContainerBottomSpacing: CGFloat = 20
        
        // Container styling
        static let textContainerAlpha: CGFloat = 0.7
        static let textContainerCornerRadius: CGFloat = 12
        static let textContainerPaddingMultiplier: CGFloat = 0.04 // 4% of screen width
        static let minTextContainerPadding: CGFloat = 16
        static let maxTextContainerPadding: CGFloat = 24
        
        // Assets
        static let backgroundImageName = "backgroundImage"
        static let rotationAnimationKey = "rotationAnimation"
        
        static let instructionText = """
        Welcome to Chimney of Wisdom, your personal breathing and relaxation companion.
        
        • Tap and hold anywhere on the screen to begin your breathing exercise
        • Watch the rectangles respond to your touch
        • Shake your device to add or remove elements
        • Let the gentle sounds guide your practice
        
        Find a comfortable position and prepare to breathe mindfully.
        """
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observeAccessibilityChanges()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateConstraintsForCurrentSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startBackgroundImageRotation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopBackgroundImageRotation()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    @objc func startButtonTapped() {
        let mainViewController = MainInteractionViewController()
        navigationController?.pushViewController(mainViewController, animated: true)
    }
    
    @objc func tutorialButtonTapped() {
        let tutorialViewController = TutorialViewController()
        navigationController?.pushViewController(tutorialViewController, animated: true)
    }
    
    @objc func aboutButtonTapped() {
        let scienceViewController = ScienceViewController()
        navigationController?.pushViewController(scienceViewController, animated: true)
    }
}

// MARK: - UI Setup
private extension IntroductionViewController {
    
    func setupUI() {
        setupBackgroundImageView()
        setupBlurEffect()
        setupTextContainer()
        setupButtons()
        setupConstraints()
    }
    
    func setupBackgroundImageView() {
        backgroundImageView = UIImageView(image: UIImage(named: Constants.backgroundImageName))
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.alpha = Constants.backgroundAlpha
        
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
    }
    
    func setupBlurEffect() {
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(blurEffectView)
        view.sendSubviewToBack(blurEffectView)
    }
    
    func setupTextContainer() {
        // Container view with semi-translucent background
        textContainerView = UIView()
        textContainerView.backgroundColor = UIColor.black.withAlphaComponent(Constants.textContainerAlpha)
        textContainerView.layer.cornerRadius = Constants.textContainerCornerRadius
        textContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Text label
        textLabel = UILabel()
        textLabel.text = Constants.instructionText
        textLabel.textColor = .white
        textLabel.font = UIFont.preferredFont(forTextStyle: .body) // Use Dynamic Type
        textLabel.adjustsFontForContentSizeCategory = true // Support accessibility text sizing
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .left
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textContainerView.addSubview(textLabel)
        view.addSubview(textContainerView)
    }
    
    func setupButtons() {
        // Start Button
        startButton = ShinyButton(type: .system)
        startButton.setTitle("START", for: .normal)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Accessibility
        startButton.accessibilityLabel = "Start"
        startButton.accessibilityHint = "Double-tap to begin your relaxation journey."
        
        // Tutorial Button
        tutorialButton = ShinyButton(type: .system)
        tutorialButton.setTitle("TUTORIAL", for: .normal)
        tutorialButton.addTarget(self, action: #selector(tutorialButtonTapped), for: .touchUpInside)
        tutorialButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Accessibility
        tutorialButton.accessibilityLabel = "Tutorial"
        tutorialButton.accessibilityHint = "Double-tap to learn how to use the app."
        
        // About Button
        aboutButton = ShinyButton(type: .system)
        aboutButton.setTitle("ABOUT", for: .normal)
        aboutButton.addTarget(self, action: #selector(aboutButtonTapped), for: .touchUpInside)
        aboutButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Accessibility
        aboutButton.accessibilityLabel = "About"
        aboutButton.accessibilityHint = "Double-tap to learn more about the app."
        
        view.addSubview(startButton)
        view.addSubview(tutorialButton)
        view.addSubview(aboutButton)
    }
    
    func setupConstraints() {
        setupInitialConstraints()
    }
    
    func setupInitialConstraints() {
        NSLayoutConstraint.activate([
            // Background Image View
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Blur Effect View
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Text Label inside container (these don't change)
            textLabel.topAnchor.constraint(equalTo: textContainerView.topAnchor, constant: calculateTextContainerPadding()),
            textLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: calculateTextContainerPadding()),
            textLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -calculateTextContainerPadding()),
            textLabel.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor, constant: -calculateTextContainerPadding())
        ])
    }
}

// MARK: - Responsive Layout
private extension IntroductionViewController {
    
    func updateConstraintsForCurrentSize() {
        let screenSize = view.bounds.size
        let isCompact = traitCollection.verticalSizeClass == .compact
        
        // Remove existing responsive constraints
        view.constraints.forEach { constraint in
            if constraint.identifier?.hasPrefix("responsive_") == true {
                constraint.isActive = false
            }
        }
        
        // Calculate responsive values
        let buttonWidth = calculateButtonWidth(for: screenSize)
        let buttonHeight = calculateButtonHeight(for: screenSize)
        let buttonSpacing = calculateButtonSpacing(for: screenSize)
        let buttonBottomMargin = calculateButtonBottomMargin(for: screenSize, isCompact: isCompact)
        let textContainerMargin = calculateTextContainerMargin(for: screenSize)
        let textContainerTopMargin = calculateTextContainerTopMargin(for: screenSize, isCompact: isCompact)
        let textContainerBottomSpacing = calculateTextContainerBottomSpacing(for: screenSize)
        
        // Create new responsive constraints
        let newConstraints = [
            // Text Container
            textContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: textContainerTopMargin),
            textContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: textContainerMargin),
            textContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -textContainerMargin),
            textContainerView.bottomAnchor.constraint(lessThanOrEqualTo: startButton.topAnchor, constant: -textContainerBottomSpacing),
            
            // Start Button (left) - position based on left of center minus button width and spacing
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -(buttonWidth + buttonSpacing)),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: buttonBottomMargin),
            startButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            startButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            // Tutorial Button (center) - exactly centered
            tutorialButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tutorialButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: buttonBottomMargin),
            tutorialButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            tutorialButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            // About Button (right) - position based on right of center plus button width and spacing
            aboutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: (buttonWidth + buttonSpacing)),
            aboutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: buttonBottomMargin),
            aboutButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            aboutButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ]
        
        // Set identifiers and activate
        newConstraints.forEach { constraint in
            constraint.identifier = "responsive_\(UUID().uuidString.prefix(8))"
            constraint.isActive = true
        }
    }
    
    // MARK: - Calculation Methods
    
    func calculateButtonWidth(for screenSize: CGSize) -> CGFloat {
        let calculatedWidth = screenSize.width * Constants.buttonWidthMultiplier
        return max(Constants.minButtonWidth, min(Constants.maxButtonWidth, calculatedWidth))
    }
    
    func calculateButtonHeight(for screenSize: CGSize) -> CGFloat {
        let calculatedHeight = screenSize.height * Constants.buttonHeightMultiplier
        return max(Constants.minButtonHeight, min(Constants.maxButtonHeight, calculatedHeight))
    }
    
    func calculateButtonSpacing(for screenSize: CGSize) -> CGFloat {
        let calculatedSpacing = screenSize.width * Constants.buttonSpacingMultiplier
        return max(Constants.minButtonSpacing, min(Constants.maxButtonSpacing, calculatedSpacing)) / 2 // Divide by 2 since we use half-spacing in each direction
    }
    
    func calculateButtonBottomMargin(for screenSize: CGSize, isCompact: Bool) -> CGFloat {
        let baseMargin = isCompact ? Constants.minButtonBottomMargin : Constants.minButtonBottomMargin * 2
        return -max(baseMargin, Constants.minButtonBottomMargin)
    }
    
    func calculateTextContainerMargin(for screenSize: CGSize) -> CGFloat {
        let calculatedMargin = screenSize.width * Constants.textContainerHorizontalMarginMultiplier
        return max(Constants.minTextContainerMargin, min(Constants.maxTextContainerMargin, calculatedMargin))
    }
    
    func calculateTextContainerTopMargin(for screenSize: CGSize, isCompact: Bool) -> CGFloat {
        let baseMargin = screenSize.height * Constants.textContainerTopMarginMultiplier
        let calculatedMargin = isCompact ? baseMargin * 0.5 : baseMargin
        return max(Constants.minTextContainerTopMargin, min(Constants.maxTextContainerTopMargin, calculatedMargin))
    }
    
    func calculateTextContainerBottomSpacing(for screenSize: CGSize) -> CGFloat {
        let calculatedSpacing = screenSize.height * Constants.textContainerBottomSpacingMultiplier
        return max(Constants.minTextContainerBottomSpacing, calculatedSpacing)
    }
    
    func calculateTextContainerPadding() -> CGFloat {
        let screenWidth = view.bounds.width
        let calculatedPadding = screenWidth * Constants.textContainerPaddingMultiplier
        return max(Constants.minTextContainerPadding, min(Constants.maxTextContainerPadding, calculatedPadding))
    }
}

// MARK: - Background Animation
private extension IntroductionViewController {
    
    func startBackgroundImageRotation() {
        guard !UIAccessibility.isReduceMotionEnabled,
              backgroundImageView.layer.animation(forKey: Constants.rotationAnimationKey) == nil else {
            return
        }
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = Constants.rotationDuration
        rotation.repeatCount = .infinity
        
        backgroundImageView.layer.add(rotation, forKey: Constants.rotationAnimationKey)
    }
    
    func stopBackgroundImageRotation() {
        backgroundImageView.layer.removeAnimation(forKey: Constants.rotationAnimationKey)
    }
}

// MARK: - Accessibility
private extension IntroductionViewController {
    
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
            stopBackgroundImageRotation()
        } else {
            startBackgroundImageRotation()
        }
    }
}

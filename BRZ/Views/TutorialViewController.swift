//
//  TutorialViewController.swift
//  BRZ
//
//  Created by Miguel Sicart on 28/09/2024.
//

import UIKit

class TutorialViewController: UIViewController {
    
    // MARK: - UI Components
    private var backgroundImageView: UIImageView!
    private var blurEffectView: UIVisualEffectView!
    private var contentScrollView: UIScrollView!
    private var contentView: UIView!
    private var titleLabel: UILabel!
    private var step1Container: UIView!
    private var step2Container: UIView!
    private var step3Container: UIView!
    private var startButton: ShinyButton!
    
    // MARK: - Constants
    private struct Constants {
        static let backgroundAlpha: CGFloat = 0.8
        
        // Responsive container sizing
        static let containerHorizontalMarginMultiplier: CGFloat = 0.05 // 5% of screen width
        static let minContainerMargin: CGFloat = 16
        static let maxContainerMargin: CGFloat = 30
        
        static let containerAlpha: CGFloat = 0.85
        static let containerCornerRadius: CGFloat = 16
        
        static let containerPaddingMultiplier: CGFloat = 0.04 // 4% of screen width
        static let minContainerPadding: CGFloat = 16
        static let maxContainerPadding: CGFloat = 24
        
        // Responsive spacing
        static let stepSpacingMultiplier: CGFloat = 0.025 // 2.5% of screen height
        static let minStepSpacing: CGFloat = 16
        static let maxStepSpacing: CGFloat = 30
        
        static let titleTopMarginMultiplier: CGFloat = 0.04 // 4% of screen height
        static let minTitleTopMargin: CGFloat = 20
        static let maxTitleTopMargin: CGFloat = 40
        
        static let contentBottomMarginMultiplier: CGFloat = 0.04 // 4% of screen height
        static let minContentBottomMargin: CGFloat = 20
        static let maxContentBottomMargin: CGFloat = 40
        
        // Responsive button sizing
        static let buttonWidthMultiplier: CGFloat = 0.3 // 30% of screen width
        static let minButtonWidth: CGFloat = 100
        static let maxButtonWidth: CGFloat = 140
        static let buttonHeightMultiplier: CGFloat = 0.06 // 6% of screen height
        static let minButtonHeight: CGFloat = 44
        static let maxButtonHeight: CGFloat = 60
        
        static let buttonBottomMarginMultiplier: CGFloat = 0.03 // 3% of screen height
        static let minButtonBottomMargin: CGFloat = 20
        static let maxButtonBottomMargin: CGFloat = 50
        
        // Assets
        static let backgroundImageName = "backgroundImage"
        
        // Content
        static let titleText = "Tutorial"
        static let step1Title = "1. Tap & Hold to Inhale"
        static let step1Description = "Press and hold anywhere on the screen to activate the Chimney of Wisdom. Watch as your breath fills the space above, representing your focus and intention."
        
        static let step2Title = "2. Release to Exhale"
        static let step2Description = "Release your finger to exhale slowly. Feel the release as you let go of tension and stress, allowing calm to flow through you."
        
        static let step3Title = "3. Shake to Clear Ashes"
        static let step3Description = "Shake your device to clear the \"Ashes of Worry\" from the top of your chimney. This represents releasing negative thoughts and starting fresh."
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
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
    
    // MARK: - Actions
    @objc func startButtonTapped() {
        let mainViewController = MainInteractionViewController()
        navigationController?.pushViewController(mainViewController, animated: true)
    }
    
    // MARK: - Responsive Layout Calculations
    func updateConstraintsForCurrentSize() {
        let screenSize = view.bounds.size
        let isCompact = traitCollection.verticalSizeClass == .compact
        
        // Remove existing responsive constraints
        view.constraints.forEach { constraint in
            if constraint.identifier?.hasPrefix("responsive_") == true {
                constraint.isActive = false
            }
        }
        contentView.constraints.forEach { constraint in
            if constraint.identifier?.hasPrefix("responsive_") == true {
                constraint.isActive = false
            }
        }
        
        // Calculate responsive values
        let containerMargin = calculateContainerMargin(for: screenSize)
        let stepSpacing = calculateStepSpacing(for: screenSize, isCompact: isCompact)
        let titleTopMargin = calculateTitleTopMargin(for: screenSize, isCompact: isCompact)
        let contentBottomMargin = calculateContentBottomMargin(for: screenSize, isCompact: isCompact)
        let buttonWidth = calculateButtonWidth(for: screenSize)
        let buttonHeight = calculateButtonHeight(for: screenSize)
        let buttonBottomMargin = calculateButtonBottomMargin(for: screenSize, isCompact: isCompact)
        
        // Create new responsive constraints
        let newConstraints = [
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: titleTopMargin),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: containerMargin),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -containerMargin),
            
            // Step 1
            step1Container.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: stepSpacing),
            step1Container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: containerMargin),
            step1Container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -containerMargin),
            
            // Step 2
            step2Container.topAnchor.constraint(equalTo: step1Container.bottomAnchor, constant: stepSpacing),
            step2Container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: containerMargin),
            step2Container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -containerMargin),
            
            // Step 3
            step3Container.topAnchor.constraint(equalTo: step2Container.bottomAnchor, constant: stepSpacing),
            step3Container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: containerMargin),
            step3Container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -containerMargin),
            step3Container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentBottomMargin),
            
            // Start Button
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: buttonBottomMargin),
            startButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            startButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ]
        
        // Set identifiers and activate
        newConstraints.forEach { constraint in
            constraint.identifier = "responsive_\(UUID().uuidString.prefix(8))"
            constraint.isActive = true
        }
    }
    
    // MARK: - Calculation Methods
    func calculateContainerMargin(for screenSize: CGSize) -> CGFloat {
        let calculatedMargin = screenSize.width * Constants.containerHorizontalMarginMultiplier
        return max(Constants.minContainerMargin, min(Constants.maxContainerMargin, calculatedMargin))
    }
    
    func calculateContainerPadding() -> CGFloat {
        let screenWidth = view.bounds.width
        let calculatedPadding = screenWidth * Constants.containerPaddingMultiplier
        return max(Constants.minContainerPadding, min(Constants.maxContainerPadding, calculatedPadding))
    }
    
    func calculateStepSpacing(for screenSize: CGSize, isCompact: Bool) -> CGFloat {
        let baseSpacing = screenSize.height * Constants.stepSpacingMultiplier
        let calculatedSpacing = isCompact ? baseSpacing * 0.6 : baseSpacing
        return max(Constants.minStepSpacing, min(Constants.maxStepSpacing, calculatedSpacing))
    }
    
    func calculateTitleTopMargin(for screenSize: CGSize, isCompact: Bool) -> CGFloat {
        let baseMargin = screenSize.height * Constants.titleTopMarginMultiplier
        let calculatedMargin = isCompact ? baseMargin * 0.5 : baseMargin
        return max(Constants.minTitleTopMargin, min(Constants.maxTitleTopMargin, calculatedMargin))
    }
    
    func calculateContentBottomMargin(for screenSize: CGSize, isCompact: Bool) -> CGFloat {
        let baseMargin = screenSize.height * Constants.contentBottomMarginMultiplier
        let calculatedMargin = isCompact ? baseMargin * 0.5 : baseMargin
        return max(Constants.minContentBottomMargin, min(Constants.maxContentBottomMargin, calculatedMargin))
    }
    
    func calculateButtonWidth(for screenSize: CGSize) -> CGFloat {
        let calculatedWidth = screenSize.width * Constants.buttonWidthMultiplier
        return max(Constants.minButtonWidth, min(Constants.maxButtonWidth, calculatedWidth))
    }
    
    func calculateButtonHeight(for screenSize: CGSize) -> CGFloat {
        let calculatedHeight = screenSize.height * Constants.buttonHeightMultiplier
        return max(Constants.minButtonHeight, min(Constants.maxButtonHeight, calculatedHeight))
    }
    
    func calculateButtonBottomMargin(for screenSize: CGSize, isCompact: Bool) -> CGFloat {
        let baseMargin = screenSize.height * Constants.buttonBottomMarginMultiplier
        let calculatedMargin = isCompact ? baseMargin * 0.7 : baseMargin
        let finalMargin = max(Constants.minButtonBottomMargin, min(Constants.maxButtonBottomMargin, calculatedMargin))
        return -finalMargin // Negative for bottom constraint
    }
}

// MARK: - UI Setup
private extension TutorialViewController {
    
    func setupUI() {
        setupBackgroundImageView()
        setupBlurEffect()
        setupScrollView()
        setupContent()
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
    
    func setupScrollView() {
        contentScrollView = UIScrollView()
        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        contentScrollView.showsVerticalScrollIndicator = true
        contentScrollView.alwaysBounceVertical = true
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentScrollView.addSubview(contentView)
        view.addSubview(contentScrollView)
    }
    
    func setupContent() {
        setupTitle()
        setupStep1()
        setupStep2()
        setupStep3()
        setupStartButton()
    }
    
    func setupTitle() {
        titleLabel = UILabel()
        titleLabel.text = Constants.titleText
        titleLabel.textColor = .white
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle) // Use Dynamic Type
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
    }
    
    func setupStep1() {
        step1Container = createStepContainer(
            title: Constants.step1Title,
            description: Constants.step1Description,
            iconName: "hand.tap.fill"
        )
        contentView.addSubview(step1Container)
    }
    
    func setupStep2() {
        step2Container = createStepContainer(
            title: Constants.step2Title,
            description: Constants.step2Description,
            iconName: "lungs.fill"
        )
        contentView.addSubview(step2Container)
    }
    
    func setupStep3() {
        step3Container = createStepContainer(
            title: Constants.step3Title,
            description: Constants.step3Description,
            iconName: "iphone.radiowaves.left.and.right"
        )
        contentView.addSubview(step3Container)
    }
    
    func createStepContainer(title: String, description: String, iconName: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.black.withAlphaComponent(Constants.containerAlpha)
        container.layer.cornerRadius = Constants.containerCornerRadius
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline) // Use Dynamic Type
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Description
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body) // Use Dynamic Type
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconImageView)
        container.addSubview(titleLabel)
        container.addSubview(descriptionLabel)
        
        let containerPadding = calculateContainerPadding()
        
        NSLayoutConstraint.activate([
            // Icon
            iconImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: containerPadding),
            iconImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: containerPadding),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: containerPadding),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -containerPadding),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -containerPadding),
            descriptionLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -containerPadding)
        ])
        
        return container
    }
    
    func setupStartButton() {
        startButton = ShinyButton(type: .system)
        startButton.setTitle("START", for: .normal)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Accessibility
        startButton.accessibilityLabel = "Start"
        startButton.accessibilityHint = "Double-tap to begin your breathing journey."
        
        view.addSubview(startButton)
    }
    
    func setupNavigationBar() {
        title = "How to Use Chimney of Wisdom"
        
        // Customize navigation bar appearance
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
            ]
            navigationBar.tintColor = .white
        }
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
            
            // Scroll View
            contentScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -20),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: contentScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor)
        ])
    }
}

// MARK: - Background Animation
private extension TutorialViewController {
    
    func startBackgroundImageRotation() {
        guard !UIAccessibility.isReduceMotionEnabled,
              backgroundImageView.layer.animation(forKey: "rotationAnimation") == nil else {
            return
        }
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 30.0
        rotation.repeatCount = .infinity
        
        backgroundImageView.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func stopBackgroundImageRotation() {
        backgroundImageView.layer.removeAnimation(forKey: "rotationAnimation")
    }
}

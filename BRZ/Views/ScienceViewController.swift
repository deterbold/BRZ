//
//  ScienceViewController.swift
//  BRZ
//
//  Created by Miguel Sicart on 07/10/2024.
//

import UIKit

class ScienceViewController: UIViewController {
    
    // MARK: - UI Components
    private var contentContainerView: UIView!
    private var scienceLabel: UILabel!
    private var researchButton: UIButton!
    
    // MARK: - Properties
    private var fontSizeAdjusted = false
    
    // MARK: - Constants
    private struct Constants {
        static let backgroundColor = UIColor(red: 0.77, green: 0.85, blue: 0.80, alpha: 1.0)
        static let containerAlpha: CGFloat = 0.1
        static let containerCornerRadius: CGFloat = 16
        static let containerMargin: CGFloat = 25
        static let containerPadding: CGFloat = 20
        static let topBottomMargin: CGFloat = 30
        static let initialFontSize: CGFloat = 100
        static let minFontSize: CGFloat = 12
        static let fontSizeDecrement: CGFloat = 1
        static let buttonHeight: CGFloat = 44
        static let buttonSpacing: CGFloat = 16
        static let researchURL = "https://www.frontiersin.org/journals/human-neuroscience/articles/10.3389/fnhum.2018.00353/full?adb_sid=bd73ee3b-a36f-4585-8d3e-967cba74f006"
        
        static let aboutText = """
        When we worry, an immense tower of negativity and pain builds inside us.
        
        Chimney of Wisdom is inspired by the idea that controlling how to breath can have beneficial effects on people. If you want to read the research backing this idea, push the "Research" button.
        
        With Chimney of Wisdom we want to visualize how worries can be burnt away, vanish in ashes, and metaphorically disappear.
        """
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustFontSizeIfNeeded()
    }
}

// MARK: - UI Setup
private extension ScienceViewController {
    
    func setupUI() {
        setupBackgroundColor()
        setupContentContainer()
        setupScienceLabel()
        setupResearchButton()
        setupConstraints()
    }
    
    func setupBackgroundColor() {
        view.backgroundColor = Constants.backgroundColor
    }
    
    func setupContentContainer() {
        contentContainerView = UIView()
        contentContainerView.backgroundColor = UIColor.white.withAlphaComponent(Constants.containerAlpha)
        contentContainerView.layer.cornerRadius = Constants.containerCornerRadius
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentContainerView)
    }
    
    func setupScienceLabel() {
        scienceLabel = UILabel()
        scienceLabel.text = Constants.aboutText
        scienceLabel.textColor = .black
        scienceLabel.textAlignment = .left
        scienceLabel.numberOfLines = 0
        scienceLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        scienceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentContainerView.addSubview(scienceLabel)
    }
    
    func setupResearchButton() {
        researchButton = UIButton(type: .system)
        researchButton.setTitle("Research", for: .normal)
        researchButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        researchButton.setTitleColor(.black, for: .normal)
        researchButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        researchButton.layer.cornerRadius = 8
        researchButton.layer.borderWidth = 1
        researchButton.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        researchButton.addTarget(self, action: #selector(researchButtonTapped), for: .touchUpInside)
        researchButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentContainerView.addSubview(researchButton)
    }
    
    func setupNavigationBar() {
        title = "About"
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Customize navigation bar appearance for better contrast
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
            ]
            navigationBar.tintColor = .black
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // Content Container
            contentContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.topBottomMargin),
            contentContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.topBottomMargin),
            contentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.containerMargin),
            contentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.containerMargin),
            
            // Science Label inside container
            scienceLabel.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: Constants.containerPadding),
            scienceLabel.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: Constants.containerPadding),
            scienceLabel.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -Constants.containerPadding),
            scienceLabel.bottomAnchor.constraint(equalTo: researchButton.topAnchor, constant: -Constants.buttonSpacing),
            
            // Research Button
            researchButton.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: Constants.containerPadding),
            researchButton.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -Constants.containerPadding),
            researchButton.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor, constant: -Constants.containerPadding),
            researchButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
}

// MARK: - Font Adjustment
private extension ScienceViewController {
    
    func adjustFontSizeIfNeeded() {
        guard !fontSizeAdjusted else { return }
        adjustFontSizeToFit()
        fontSizeAdjusted = true
    }
    
    func adjustFontSizeToFit() {
        guard let text = scienceLabel.text,
              !text.isEmpty,
              scienceLabel.bounds.width > 0,
              scienceLabel.bounds.height > 0 else { return }
        
        let labelSize = scienceLabel.bounds.size
        var fontSize = Constants.initialFontSize
        
        // Binary search approach for better performance
        var minFont = Constants.minFontSize
        var maxFont = Constants.initialFontSize
        
        while maxFont - minFont > 1 {
            fontSize = (minFont + maxFont) / 2
            let testFont = UIFont.systemFont(ofSize: fontSize, weight: .regular)
            
            if textFits(text: text, font: testFont, size: labelSize) {
                minFont = fontSize
            } else {
                maxFont = fontSize
            }
        }
        
        // Use the largest font size that fits
        scienceLabel.font = UIFont.systemFont(ofSize: minFont, weight: .regular)
    }
    
    func textFits(text: String, font: UIFont, size: CGSize) -> Bool {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let textRect = NSString(string: text).boundingRect(
            with: CGSize(width: size.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        
        return textRect.height <= size.height
    }
}

// MARK: - Actions
private extension ScienceViewController {
    
    @objc func researchButtonTapped() {
        guard let url = URL(string: Constants.researchURL) else { return }
        UIApplication.shared.open(url)
    }
}

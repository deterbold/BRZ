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
        
        static let aboutText = """
        When we worry, an immense tower of negativity and pain builds inside us.
        
        Studies have shown that controlled breathing and relaxation can help change your inner and outer mood, and make you live happier with yourself.
        
        That's why we've developed the Chimney of Wisdom meditation aid. When you regulate your breathing with our app, you gain control over your fears and anxieties.
        
        The Chimney of Wisdom will help you burn away your worries, and you will see them vanish in ashes, while you get back to your best life, better.
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
            scienceLabel.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor, constant: -Constants.containerPadding),
            scienceLabel.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: Constants.containerPadding),
            scienceLabel.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -Constants.containerPadding)
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

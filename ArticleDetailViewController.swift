//
//  ArticleDetailViewController.swift
//  serevia
//
//  Created by ekatizzz on 12.04.2026.
//

import UIKit
import AVFoundation

class ArticleDetailViewController: UIViewController {
    
    var articleTitle: String?
    var contentText: String?
    
    // MARK: - Speech Properties
    private lazy var synthesizer: AVSpeechSynthesizer = {
        let synth = AVSpeechSynthesizer()
        synth.delegate = self
        return synth
    }()
    
    private var currentRate: Float = 0.46
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let textLabel = UILabel()
    private let speedSettingsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.96)
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.15
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.shadowRadius = 10
        view.isHidden = true
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let rateSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.3
        slider.maximumValue = 0.7
        slider.value = 0.46
        slider.minimumValueImage = UIImage(systemName: "tortoise")
        slider.maximumValueImage = UIImage(systemName: "hare")
        slider.tintColor = UIColor(red: 0.49, green: 0.38, blue: 0.27, alpha: 1)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupUI()
        updateNavigationBar(isPlaying: false, hasStarted: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    // MARK: - Navigation Bar Logic
    private func updateNavigationBar(isPlaying: Bool, hasStarted: Bool) {
        let speedButton = UIBarButtonItem(
            image: UIImage(systemName: "gauge.with.needle"),
            style: .plain,
            target: self,
            action: #selector(toggleSpeedPanel)
        )
        
        let playPauseImage = isPlaying ? "pause.circle.fill" : "play.circle.fill"
        let mainButton = UIBarButtonItem(
            image: UIImage(systemName: playPauseImage),
            style: .plain,
            target: self,
            action: #selector(toggleSpeech)
        )
        
        var buttons: [UIBarButtonItem] = [mainButton, speedButton]
        
        if hasStarted {
            let restartButton = UIBarButtonItem(
                image: UIImage(systemName: "backward.circle"),
                style: .plain,
                target: self,
                action: #selector(restartSpeech)
            )
            buttons.insert(restartButton, at: 0)
        }
        
        navigationItem.rightBarButtonItems = buttons
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Статья"
        navigationController?.navigationBar.tintColor = AppColors.primary
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(speedSettingsView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        rateSlider.addTarget(self, action: #selector(rateChanged(_:)), for: .valueChanged)
        
        let rateLabel = UILabel()
        rateLabel.text = "Скорость чтения"
        rateLabel.font = .systemFont(ofSize: 14, weight: .bold)
        rateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        speedSettingsView.addSubview(rateLabel)
        speedSettingsView.addSubview(rateSlider)
        
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            speedSettingsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            speedSettingsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            speedSettingsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            speedSettingsView.heightAnchor.constraint(equalToConstant: 100),
            
            rateLabel.topAnchor.constraint(equalTo: speedSettingsView.topAnchor, constant: 15),
            rateLabel.centerXAnchor.constraint(equalTo: speedSettingsView.centerXAnchor),
            rateSlider.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 12),
            rateSlider.leadingAnchor.constraint(equalTo: speedSettingsView.leadingAnchor, constant: 20),
            rateSlider.trailingAnchor.constraint(equalTo: speedSettingsView.trailingAnchor, constant: -20)
        ])
        
        formatAndSetText()
    }
    
    // MARK: - Actions
    @objc private func toggleSpeedPanel() {
        let isOpening = speedSettingsView.isHidden
        if isOpening { speedSettingsView.isHidden = false }
        
        UIView.animate(withDuration: 0.3) {
            self.speedSettingsView.alpha = isOpening ? 1 : 0
            self.speedSettingsView.transform = isOpening ? .identity : CGAffineTransform(translationX: 0, y: -10)
        } completion: { _ in
            if !isOpening { self.speedSettingsView.isHidden = true }
        }
    }
    
    @objc private func toggleSpeech() {
        if synthesizer.isSpeaking {
            if synthesizer.isPaused {
                synthesizer.continueSpeaking()
                updateNavigationBar(isPlaying: true, hasStarted: true)
            } else {
                synthesizer.pauseSpeaking(at: .immediate)
                updateNavigationBar(isPlaying: false, hasStarted: true)
            }
        } else {
            startSpeaking()
        }
    }
    
    @objc private func restartSpeech() {
        synthesizer.stopSpeaking(at: .immediate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.startSpeaking()
        }
    }
    
    private func startSpeaking() {
        guard let text = textLabel.attributedText?.string, !text.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: text)
        
        let voices = AVSpeechSynthesisVoice.speechVoices()
        if let premiumVoice = voices.first(where: { $0.name == "Milena" && $0.language == "ru-RU" }) {
            utterance.voice = premiumVoice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
        }
        
        utterance.rate = currentRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.postUtteranceDelay = 0.3
        
        synthesizer.speak(utterance)
        updateNavigationBar(isPlaying: true, hasStarted: true)
    }
    
    @objc private func rateChanged(_ sender: UISlider) {
        currentRate = sender.value
        if synthesizer.isSpeaking && !synthesizer.isPaused {
            restartSpeech()
        }
    }
    
    // MARK: - Formatting
    private func formatAndSetText() {
        guard let titleStr = articleTitle, let bodyStr = contentText else { return }
        let fullAttributedString = NSMutableAttributedString()
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 28, weight: .bold),
            .foregroundColor: UIColor(red: 0.20, green: 0.15, blue: 0.10, alpha: 1)
        ]
        fullAttributedString.append(NSAttributedString(string: titleStr + "\n\n", attributes: titleAttributes))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.paragraphSpacing = 12
        
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .foregroundColor: UIColor(red: 0.25, green: 0.20, blue: 0.15, alpha: 1),
            .paragraphStyle: paragraphStyle
        ]
        
        let lines = bodyStr.components(separatedBy: "\n")
        for line in lines {
            if line.uppercased() == line && line.count > 3 && !line.contains("ИСТОЧНИК") {
                let subTitleAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 19, weight: .bold),
                    .foregroundColor: UIColor(red: 0.20, green: 0.15, blue: 0.10, alpha: 1)
                ]
                fullAttributedString.append(NSAttributedString(string: line + "\n", attributes: subTitleAttr))
            } else if line.contains("Источник:") {
                let italicAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.italicSystemFont(ofSize: 14),
                    .foregroundColor: UIColor.gray,
                    .paragraphStyle: paragraphStyle
                ]
                fullAttributedString.append(NSAttributedString(string: "\n" + line, attributes: italicAttr))
            } else {
                fullAttributedString.append(NSAttributedString(string: line + "\n", attributes: bodyAttributes))
            }
        }
        textLabel.attributedText = fullAttributedString
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension ArticleDetailViewController: AVSpeechSynthesizerDelegate {
    func synthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.updateNavigationBar(isPlaying: false, hasStarted: false)
        }
    }
    
    func synthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.updateNavigationBar(isPlaying: false, hasStarted: false)
        }
    }
}

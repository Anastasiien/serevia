//
//  WishMapViewController.swift
//  serevia
//
//  Created by ekatizzz 11.03.2026.
//

import UIKit

 class WishMapEditorViewController: UIViewController,
                                        UIImagePickerControllerDelegate,
                                        UINavigationControllerDelegate,
                                        UIGestureRecognizerDelegate,
                                        UITextViewDelegate {

    // MARK: - Colors

    private let accent = UIColor(red: 0.58, green: 0.46, blue: 0.42, alpha: 1)
    private let pageBg = UIColor(red: 0.96, green: 0.94, blue: 0.91, alpha: 1)
    private let textDark = UIColor(red: 0.20, green: 0.15, blue: 0.10, alpha: 1)
    private let textMid = UIColor(red: 0.48, green: 0.40, blue: 0.32, alpha: 1)
    private let cardBg = UIColor(red: 0.99, green: 0.97, blue: 0.95, alpha: 1)
    private let divColor = UIColor(red: 0.76, green: 0.68, blue: 0.58, alpha: 0.3)

    // MARK: - UI

    private let canvasView = UIView()

    private let addImageButton = UIButton(type: .system)
    private let addTextButton = UIButton(type: .system)
    private let addStickerButton = UIButton(type: .system)

    private let clearButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)

    private let toolsPanel = UIView()
    private let toolsStack = UIStackView()

    private let sizeSlider = UISlider()
    private let sizeButton = UIButton(type: .system)

    private var placeholderStack: UIStackView?

    // MARK: - State

    private weak var currentTextView: UITextView?
    private weak var selectedImageView: UIImageView?

    private var editOverlay: UIView?

    private let wishMapStorageKey = "wishMapImage"

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = pageBg

        setupLayout()
        setupToolsPanel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if canvasView.bounds.width > 0,
           canvasView.viewWithTag(999) == nil {
            loadExistingMap()
        }
    }

    // MARK: - Layout

    private func setupLayout() {

        let titleLabel = UILabel()
        titleLabel.text = "Карта желаний"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = textDark
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Добавляй фото, текст и элементы"
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = textMid
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(subtitleLabel)

        configureTopButtons()

        canvasView.backgroundColor = cardBg
        canvasView.layer.cornerRadius = 24
        canvasView.layer.borderWidth = 1
        canvasView.layer.borderColor = divColor.cgColor
        canvasView.layer.shadowColor = UIColor.black.cgColor
        canvasView.layer.shadowOpacity = 0.08
        canvasView.layer.shadowRadius = 16
        canvasView.layer.shadowOffset = CGSize(width: 0, height: 6)
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.clipsToBounds = true

        view.addSubview(canvasView)

        setupPlaceholder()

        let bottomPanel = UIView()
        bottomPanel.backgroundColor = cardBg
        bottomPanel.layer.cornerRadius = 22
        bottomPanel.layer.shadowColor = UIColor.black.cgColor
        bottomPanel.layer.shadowOpacity = 0.05
        bottomPanel.layer.shadowRadius = 12
        bottomPanel.layer.shadowOffset = CGSize(width: 0, height: -2)
        bottomPanel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(bottomPanel)

        styleBottomButton(addImageButton, title: "Фото", icon: "photo")
        styleBottomButton(addTextButton, title: "Текст", icon: "textformat")
        styleBottomButton(addStickerButton, title: "Стикеры", icon: "sparkles")

        addImageButton.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        addTextButton.addTarget(self, action: #selector(addText), for: .touchUpInside)
        addStickerButton.addTarget(self, action: #selector(addSticker), for: .touchUpInside)

        let buttonsStack = UIStackView(arrangedSubviews: [
            addImageButton,
            addTextButton,
            addStickerButton
        ])

        buttonsStack.axis = .horizontal
        buttonsStack.distribution = .fillEqually
        buttonsStack.spacing = 10
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        bottomPanel.addSubview(buttonsStack)

        NSLayoutConstraint.activate([

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            clearButton.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),
            clearButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            saveButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            canvasView.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 16),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            canvasView.heightAnchor.constraint(equalTo: canvasView.widthAnchor, multiplier: 0.75),

            bottomPanel.topAnchor.constraint(equalTo: canvasView.bottomAnchor, constant: 180),
            bottomPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bottomPanel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),

            buttonsStack.topAnchor.constraint(equalTo: bottomPanel.topAnchor, constant: 14),
            buttonsStack.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor, constant: 14),
            buttonsStack.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor, constant: -14),
            buttonsStack.bottomAnchor.constraint(equalTo: bottomPanel.bottomAnchor, constant: -14)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tap.delegate = self
        canvasView.addGestureRecognizer(tap)
    }

    private func configureTopButtons() {
        clearButton.setTitle("Очистить", for: .normal)
        clearButton.setTitleColor(.systemRed, for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(clearCanvas), for: .touchUpInside)

        view.addSubview(clearButton)

        var config = UIButton.Configuration.filled()
        config.title = "Сохранить"
        config.baseBackgroundColor = accent
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 18, bottom: 10, trailing: 18)
        config.background.cornerRadius = 14
        
        saveButton.configuration = config
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveToHome), for: .touchUpInside)

        view.addSubview(saveButton)
    }
    
    private func setupPlaceholder() {

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        let icon = UILabel()
        icon.text = "✦"
        icon.font = .systemFont(ofSize: 34)
        icon.textColor = accent.withAlphaComponent(0.5)

        let text = UILabel()
        text.text = "Добавь первый элемент"
        text.font = .systemFont(ofSize: 14, weight: .medium)
        text.textColor = textMid.withAlphaComponent(0.7)

        stack.addArrangedSubview(icon)
        stack.addArrangedSubview(text)

        canvasView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: canvasView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: canvasView.centerYAnchor)
        ])

        placeholderStack = stack
    }

    private func styleBottomButton(_ button: UIButton,
                                  title: String,
                                  icon: String) {

        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)

        button.setImage(UIImage(systemName: icon, withConfiguration: config), for: .normal)
        button.setTitle("  \(title)", for: .normal)

        button.tintColor = accent
        button.setTitleColor(accent, for: .normal)

        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)

        button.backgroundColor = accent.withAlphaComponent(0.08)
        button.layer.cornerRadius = 14

        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    // MARK: - Tools Panel

    private func setupToolsPanel() {

        toolsPanel.backgroundColor = cardBg
        toolsPanel.layer.cornerRadius = 18
        toolsPanel.layer.borderWidth = 1
        toolsPanel.layer.borderColor = divColor.cgColor
        toolsPanel.layer.shadowColor = UIColor.black.cgColor
        toolsPanel.layer.shadowOpacity = 0.12
        toolsPanel.layer.shadowRadius = 12
        toolsPanel.layer.shadowOffset = CGSize(width: 0, height: 4)
        toolsPanel.translatesAutoresizingMaskIntoConstraints = false
        toolsPanel.isHidden = true

        view.addSubview(toolsPanel)

        toolsStack.axis = .vertical
        toolsStack.spacing = 12
        toolsStack.translatesAutoresizingMaskIntoConstraints = false

        toolsPanel.addSubview(toolsStack)

        let title = UILabel()
        title.text = "Редактирование"
        title.font = .systemFont(ofSize: 13, weight: .semibold)
        title.textAlignment = .center
        title.textColor = textMid

        let colors: [UIColor] = [
            textDark, .systemRed, .systemBlue, .systemGreen, .systemOrange,
            .systemPurple, .brown, .black, .darkGray, .systemPink
        ]

        let colorGrid = UIStackView()
        colorGrid.axis = .vertical
        colorGrid.spacing = 8

        for rowIndex in 0..<2 {

            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.spacing = 8

            for itemIndex in 0..<5 {

                let index = rowIndex * 5 + itemIndex

                let button = UIButton(type: .system)
                button.backgroundColor = colors[index]
                button.layer.cornerRadius = 14
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.white.cgColor
                button.heightAnchor.constraint(equalToConstant: 30).isActive = true

                button.addTarget(self,
                                 action: #selector(changeColor(_:)),
                                 for: .touchUpInside)

                row.addArrangedSubview(button)
            }

            colorGrid.addArrangedSubview(row)
        }

        let separator = UIView()
        separator.backgroundColor = divColor
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let styleButtons: [(String, Selector)] = [
            ("B", #selector(toggleBold)),
            ("I", #selector(toggleItalic)),
            ("U", #selector(toggleTextUnderline)),
            ("S", #selector(toggleStrike))
        ]

        let styleRow = UIStackView()
        styleRow.axis = .horizontal
        styleRow.distribution = .fillEqually
        styleRow.spacing = 8

        for item in styleButtons {

            let button = UIButton(type: .system)

            button.setTitle(item.0, for: .normal)
            button.setTitleColor(textDark, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)

            button.backgroundColor = accent.withAlphaComponent(0.08)
            button.layer.cornerRadius = 10
            button.heightAnchor.constraint(equalToConstant: 36).isActive = true

            button.addTarget(self,
                             action: item.1,
                             for: .touchUpInside)

            styleRow.addArrangedSubview(button)
        }

        sizeButton.setTitle("Размер: 20", for: .normal)
        sizeButton.setTitleColor(accent, for: .normal)
        sizeButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        sizeButton.addTarget(self,
                             action: #selector(toggleSlider),
                             for: .touchUpInside)

        sizeSlider.minimumValue = 12
        sizeSlider.maximumValue = 72
        sizeSlider.value = 20
        sizeSlider.tintColor = accent
        sizeSlider.isHidden = true

        sizeSlider.addTarget(self,
                             action: #selector(sliderChanged(_:)),
                             for: .touchUpInside)

        [
            title,
            colorGrid,
            separator,
            styleRow,
            sizeButton,
            sizeSlider
        ].forEach {
            toolsStack.addArrangedSubview($0)
        }

        NSLayoutConstraint.activate([
            toolsPanel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            toolsPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            toolsPanel.widthAnchor.constraint(equalToConstant: 200),

            toolsStack.topAnchor.constraint(equalTo: toolsPanel.topAnchor, constant: 14),
            toolsStack.bottomAnchor.constraint(equalTo: toolsPanel.bottomAnchor, constant: -14),
            toolsStack.leadingAnchor.constraint(equalTo: toolsPanel.leadingAnchor, constant: 14),
            toolsStack.trailingAnchor.constraint(equalTo: toolsPanel.trailingAnchor, constant: -14)
        ])
    }

    // MARK: - Gestures

    private func addGestures(to view: UIView) {

        let pan = UIPanGestureRecognizer(target: self, action: #selector(moveView(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(_:)))
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectView(_:)))

        [pan, pinch, rotate, tap].forEach {
            $0.delegate = self
            view.addGestureRecognizer($0)
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {

        if let touchView = touch.view, touchView.layer.cornerRadius == 14, touchView.backgroundColor == accent {
            if !(gestureRecognizer.view is UIButton) {
                return false
            }
        }

        if gestureRecognizer is UITapGestureRecognizer {
            return touch.view == canvasView
        }

        return true
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {

        guard let view = gesture.view else { return }

        view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1

        updateOverlay(for: view)
    }

    @objc private func handleRotate(_ gesture: UIRotationGestureRecognizer) {

        guard let view = gesture.view else { return }

        view.transform = view.transform.rotated(by: gesture.rotation)
        gesture.rotation = 0

        updateOverlay(for: view)
    }

    @objc private func moveView(_ gesture: UIPanGestureRecognizer) {

        guard let view = gesture.view else { return }

        let translation = gesture.translation(in: canvasView)

        view.center.x += translation.x
        view.center.y += translation.y

        gesture.setTranslation(.zero, in: canvasView)

        updateOverlay(for: view)
    }

    // MARK: - Actions

    @objc private func backgroundTapped() {
        hideTools()
    }

    @objc private func clearCanvas() {

        let alert = UIAlertController(
            title: "Очистить карту?",
            message: "Все элементы будут удалены",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in

            guard let self else { return }

            self.canvasView.subviews.forEach {
                if $0 != self.placeholderStack {
                    $0.removeFromSuperview()
                }
            }

            self.placeholderStack?.isHidden = false
            self.hideTools()

            UserDefaults.standard.removeObject(forKey: self.wishMapStorageKey)
        })

        present(alert, animated: true)
    }

    @objc private func addText() {

        placeholderStack?.isHidden = true

        let textView = UITextView(frame: CGRect(x: 70, y: 100, width: 180, height: 60))

        textView.text = "Новый текст"
        textView.font = .systemFont(ofSize: 20, weight: .medium)
        textView.textColor = textDark
        textView.backgroundColor = .clear
        textView.textAlignment = .center
        textView.delegate = self
        textView.isScrollEnabled = false

        addGestures(to: textView)
        canvasView.addSubview(textView)

        currentTextView = textView
        showTextOverlay(for: textView)

        toolsPanel.isHidden = false
        textView.becomeFirstResponder()
    }
    
    @objc func addImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false

        present(picker, animated: true)
    }

    @objc private func addSticker() {

        let alert = UIAlertController(title: "Стикеры", message: nil, preferredStyle: .actionSheet)

        let stickers = [
            "🌸", "✨", "💫", "🌙", "☀️",
            "🩷", "💜", "🌿", "🦋", "⭐️"
        ]

        for sticker in stickers {
            alert.addAction(UIAlertAction(title: sticker, style: .default) { [weak self] _ in
                self?.placeSticker(sticker)
            })
        }

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }

    private func placeSticker(_ value: String) {

        placeholderStack?.isHidden = true

        let label = UILabel(frame: CGRect(x: 120, y: 140, width: 80, height: 80))

        label.text = value
        label.font = .systemFont(ofSize: 42)
        label.textAlignment = .center
        label.isUserInteractionEnabled = true

        addGestures(to: label)
        canvasView.addSubview(label)
    }

    private func showTextOverlay(for textView: UITextView) {

        editOverlay?.removeFromSuperview()

        let overlay = UIView(frame: textView.frame.insetBy(dx: -6, dy: -6))

        overlay.layer.borderWidth = 1.5
        overlay.layer.borderColor = accent.cgColor
        overlay.layer.cornerRadius = 10
        overlay.isUserInteractionEnabled = false
        overlay.transform = textView.transform

        canvasView.addSubview(overlay)
        editOverlay = overlay
    }
    
    private func showGenericOverlay(for view: UIView) {
        editOverlay?.removeFromSuperview()

        let overlay = UIView(frame: view.frame.insetBy(dx: -6, dy: -6))
        overlay.layer.borderWidth = 1.5
        overlay.layer.borderColor = accent.cgColor
        overlay.layer.cornerRadius = 10
        overlay.isUserInteractionEnabled = false
        overlay.transform = view.transform

        canvasView.addSubview(overlay)
        editOverlay = overlay
    }

    @objc private func selectView(_ gesture: UITapGestureRecognizer) {

        hideTools()

        guard let targetView = gesture.view else { return }

        if let textView = targetView as? UITextView {
            currentTextView = textView
            toolsPanel.isHidden = false
            showTextOverlay(for: textView)
        } else if let imageView = targetView as? UIImageView {
            selectedImageView = imageView
            showImageOverlay(for: imageView)
        } else if let label = targetView as? UILabel {
            showGenericOverlay(for: label)
        }
    }
    
    private func showImageOverlay(for imageView: UIImageView) {

        editOverlay?.removeFromSuperview()

        let overlay = UIView(frame: imageView.frame.insetBy(dx: -6, dy: -6))

        overlay.layer.borderWidth = 1.5
        overlay.layer.borderColor = accent.cgColor
        overlay.layer.cornerRadius = 12
        overlay.isUserInteractionEnabled = false
        overlay.transform = imageView.transform

        canvasView.addSubview(overlay)
        editOverlay = overlay
    }

    private func updateOverlay(for view: UIView) {
        if let textView = view as? UITextView {
            editOverlay?.frame = textView.frame.insetBy(dx: -6, dy: -6)
            editOverlay?.transform = textView.transform
        } else if let imageView = view as? UIImageView {
            editOverlay?.frame = imageView.frame.insetBy(dx: -6, dy: -6)
            editOverlay?.transform = imageView.transform
        } else {
            editOverlay?.frame = view.frame.insetBy(dx: -6, dy: -6)
            editOverlay?.transform = view.transform
        }
    }
    
    private func hideTools() {

        view.endEditing(true)
        toolsPanel.isHidden = true

        editOverlay?.removeFromSuperview()
        editOverlay = nil

        currentTextView = nil
        selectedImageView = nil
    }

    // MARK: - Save / Load

    private func loadExistingMap() {

        guard let data = UserDefaults.standard.data(forKey: wishMapStorageKey),
              let image = UIImage(data: data) else {
            return
        }

        placeholderStack?.isHidden = true

        let imageView = UIImageView(image: image)
        imageView.frame = canvasView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tag = 999

        canvasView.insertSubview(imageView, at: 0)
    }

    @objc private func saveToHome() {

        hideTools()

        let renderer = UIGraphicsImageRenderer(bounds: canvasView.bounds)

        let image = renderer.image { _ in
            canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        }

        if let data = image.jpegData(compressionQuality: 0.9) {
            UserDefaults.standard.set(data, forKey: wishMapStorageKey)
        }

        let alert = UIAlertController(title: "Сохранено ✓", message: "Карта успешно сохранена", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))

        present(alert, animated: true)
    }

    // MARK: - Text Formatting

    @objc private func changeColor(_ sender: UIButton) {
        currentTextView?.textColor = sender.backgroundColor
    }

    @objc private func toggleSlider() {
        sizeSlider.isHidden.toggle()
    }

    @objc private func sliderChanged(_ sender: UISlider) {

        guard let textView = currentTextView else { return }

        let size = CGFloat(sender.value)
        textView.font = textView.font?.withSize(size)

        sizeButton.setTitle("Размер: \(Int(size))", for: .normal)

        let newSize = textView.sizeThatFits(CGSize(width: 220, height: CGFloat.greatestFiniteMagnitude))

        textView.bounds.size = CGSize(width: max(120, newSize.width), height: max(50, newSize.height))

        updateOverlay(for: textView)
    }

    @objc private func toggleBold() {
        applyFontTrait(.traitBold)
    }

    @objc private func toggleItalic() {
        applyFontTrait(.traitItalic)
    }

    @objc private func toggleTextUnderline() {
        applyAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue)
    }

    @objc private func toggleStrike() {
        applyAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue)
    }

    private func applyFontTrait(_ trait: UIFontDescriptor.SymbolicTraits) {

        guard let textView = currentTextView,
              let font = textView.font else {
            return
        }

        var traits = font.fontDescriptor.symbolicTraits

        if traits.contains(trait) {
            traits.remove(trait)
        } else {
            traits.insert(trait)
        }

        guard let descriptor = font.fontDescriptor.withSymbolicTraits(traits) else {
            return
        }

        textView.font = UIFont(descriptor: descriptor, size: font.pointSize)
    }

    private func applyAttribute(_ key: NSAttributedString.Key, value: Int) {

        guard let textView = currentTextView else { return }

        let attributed = NSMutableAttributedString(attributedString: textView.attributedText)
        let range = NSRange(location: 0, length: attributed.length)

        if attributed.attribute(key, at: 0, effectiveRange: nil) != nil {
            attributed.removeAttribute(key, range: range)
        } else {
            attributed.addAttribute(key, value: value, range: range)
        }

        textView.attributedText = attributed
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {

        let size = textView.sizeThatFits(CGSize(width: 240, height: CGFloat.greatestFiniteMagnitude))

        textView.bounds.size = CGSize(width: max(120, size.width), height: max(50, size.height))

        updateOverlay(for: textView)
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else {
            return
        }

        placeholderStack?.isHidden = true

        let side = min(canvasView.bounds.width, canvasView.bounds.height) * 0.45
        let imageView = UIImageView(image: image)

        imageView.frame = CGRect(
            x: canvasView.bounds.midX - side / 2,
            y: canvasView.bounds.midY - side / 2,
            width: side,
            height: side
        )

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 14
        imageView.isUserInteractionEnabled = true

        addGestures(to: imageView)
        canvasView.addSubview(imageView)

        selectedImageView = imageView
        showImageOverlay(for: imageView)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

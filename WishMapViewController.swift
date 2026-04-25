//
//  WishMapViewController.swift
//  serevia
//
//  Created by ekatizzz on 11.03.2026.
//

import UIKit
import Photos

class WishMapEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    // MARK: - UI Элементы
    private let canvasView = UIView()
    private let addImageButton = UIButton(type: .system)
    private let addTextButton = UIButton(type: .system)
    private let clearButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    
    private let toolsPanel = UIView()
    private let toolsStack = UIStackView()
    private let sizeSlider = UISlider()
    private let sizeButton = UIButton(type: .system)
    
    private var currentTextView: UITextView?
    private var editOverlay: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        
        setupCanvas()
        setupToolsPanel()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideTools))
        tap.delegate = self
        canvasView.addGestureRecognizer(tap)
    }

    // MARK: - Layout
    private func setupCanvas() {
        clearButton.setTitle("Очистить", for: .normal)
        clearButton.setTitleColor(.systemRed, for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        clearButton.addTarget(self, action: #selector(clearCanvas), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clearButton)
        
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.setTitleColor(AppColors.primary, for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        saveButton.addTarget(self, action: #selector(saveToGallery), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)

        canvasView.backgroundColor = AppColors.card
        canvasView.layer.cornerRadius = 16
        canvasView.layer.borderWidth = 1
        canvasView.layer.borderColor = AppColors.primary.cgColor
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.isUserInteractionEnabled = true
        canvasView.clipsToBounds = true
        view.addSubview(canvasView)
        
        [addImageButton, addTextButton].forEach {
            $0.backgroundColor = AppColors.primary
            $0.setTitleColor(.white, for: .normal)
            $0.layer.cornerRadius = 12
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        addImageButton.setTitle("Фото", for: .normal)
        addTextButton.setTitle("Текст", for: .normal)
        addImageButton.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        addTextButton.addTarget(self, action: #selector(addText), for: .touchUpInside)

        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            clearButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    
            canvasView.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 10),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            canvasView.bottomAnchor.constraint(equalTo: addImageButton.topAnchor, constant: -20),
            
            addImageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addImageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addImageButton.widthAnchor.constraint(equalToConstant: 120),
            addImageButton.heightAnchor.constraint(equalToConstant: 45),
            
            addTextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addTextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addTextButton.widthAnchor.constraint(equalToConstant: 120),
            addTextButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }

    private func setupToolsPanel() {
        toolsPanel.backgroundColor = AppColors.card
        toolsPanel.layer.cornerRadius = 20
        toolsPanel.layer.shadowColor = UIColor.black.cgColor
        toolsPanel.layer.shadowOffset = CGSize(width: 0, height: 4)
        toolsPanel.layer.shadowOpacity = 0.1
        toolsPanel.layer.shadowRadius = 10
        toolsPanel.translatesAutoresizingMaskIntoConstraints = false
        toolsPanel.isHidden = true
        view.addSubview(toolsPanel)

        toolsStack.axis = .vertical
        toolsStack.spacing = 8
        toolsStack.translatesAutoresizingMaskIntoConstraints = false
        toolsPanel.addSubview(toolsStack)

        let colorGrid = UIStackView()
        colorGrid.axis = .vertical
        colorGrid.spacing = 5
        let colors: [UIColor] = [.black, .red, .orange, .yellow, .green, .blue, .purple, .brown, .darkGray, .systemPink]
        for i in 0..<2 {
            let row = UIStackView(); row.axis = .horizontal; row.spacing = 5
            for j in 0..<5 {
                let btn = UIButton(); btn.backgroundColor = colors[i*5 + j]
                btn.layer.cornerRadius = 10; btn.widthAnchor.constraint(equalToConstant: 30).isActive = true
                btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
                btn.addTarget(self, action: #selector(changeColor), for: .touchUpInside)
                row.addArrangedSubview(btn)
            }
            colorGrid.addArrangedSubview(row)
        }

        let styleRow1 = UIStackView(); styleRow1.axis = .horizontal; styleRow1.distribution = .fillEqually; styleRow1.spacing = 5
        let styleRow2 = UIStackView(); styleRow2.axis = .horizontal; styleRow2.distribution = .fillEqually; styleRow2.spacing = 5
        
        let styleBtns = [
            ("B", #selector(toggleBold)), ("I", #selector(toggleItalic)), ("U", #selector(handleUnderline)),
            ("S", #selector(handleStrike)), ("•", #selector(toggleBullet)), ("☐", #selector(toggleTask))
        ]
        for (idx, item) in styleBtns.enumerated() {
            let btn = UIButton(type: .system); btn.setTitle(item.0, for: .normal)
            btn.setTitleColor(AppColors.primary, for: .normal)
            btn.addTarget(self, action: item.1, for: .touchUpInside)
            idx < 3 ? styleRow1.addArrangedSubview(btn) : styleRow2.addArrangedSubview(btn)
        }

        sizeButton.setTitle("Размер: 20", for: .normal)
        sizeButton.setTitleColor(AppColors.primary, for: .normal)
        sizeButton.addTarget(self, action: #selector(toggleSlider), for: .touchUpInside)
        sizeSlider.minimumValue = 10; sizeSlider.maximumValue = 80; sizeSlider.value = 20
        sizeSlider.isHidden = true
        sizeSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

        toolsStack.addArrangedSubview(colorGrid)
        toolsStack.addArrangedSubview(styleRow1)
        toolsStack.addArrangedSubview(styleRow2)
        toolsStack.addArrangedSubview(sizeButton)
        toolsStack.addArrangedSubview(sizeSlider)

        NSLayoutConstraint.activate([
            toolsPanel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            toolsPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            toolsStack.topAnchor.constraint(equalTo: toolsPanel.topAnchor, constant: 10),
            toolsStack.bottomAnchor.constraint(equalTo: toolsPanel.bottomAnchor, constant: -10),
            toolsStack.leadingAnchor.constraint(equalTo: toolsPanel.leadingAnchor, constant: 10),
            toolsPanel.widthAnchor.constraint(equalToConstant: 180)
        ])
    }

    // MARK: - Gestures
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let tap = gestureRecognizer as? UITapGestureRecognizer, canvasView.gestureRecognizers?.contains(tap) == true {
            return touch.view == canvasView
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    private func addGestures(to v: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(moveView))
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectView))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate))
        
        [pan, pinch, rotate, tap].forEach {
            $0.delegate = self
            v.addGestureRecognizer($0)
        }
    }

    @objc private func handlePinch(_ g: UIPinchGestureRecognizer) {
        guard let v = g.view else { return }
        v.transform = v.transform.scaledBy(x: g.scale, y: g.scale)
        g.scale = 1
        updateOverlay(for: v)
    }

    @objc private func handleRotate(_ g: UIRotationGestureRecognizer) {
        guard let v = g.view else { return }
        v.transform = v.transform.rotated(by: g.rotation)
        g.rotation = 0
        updateOverlay(for: v)
    }

    @objc private func moveView(_ g: UIPanGestureRecognizer) {
        guard let v = g.view else { return }
        let translation = g.translation(in: canvasView)
        v.center.x += translation.x
        v.center.y += translation.y
        g.setTranslation(.zero, in: canvasView)
        updateOverlay(for: v)
    }

    // MARK: - Actions
    @objc private func hideTools() {
        toolsPanel.isHidden = true
        editOverlay?.removeFromSuperview()
        currentTextView = nil
    }

    @objc private func clearCanvas() {
        let alert = UIAlertController(title: "Очистить всё?", message: "Это действие нельзя отменить", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { _ in
            self.canvasView.subviews.forEach { $0.removeFromSuperview() }
            self.hideTools()
        })
        present(alert, animated: true)
    }

    @objc private func addText() {
        let tv = UITextView(frame: CGRect(x: 50, y: 50, width: 150, height: 60))
        tv.text = "Текст"
        tv.font = .systemFont(ofSize: 20)
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        addGestures(to: tv)
        canvasView.addSubview(tv)
    }

    @objc private func addImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func selectView(_ g: UITapGestureRecognizer) {
        guard let v = g.view as? UITextView else { return }
        currentTextView = v
        toolsPanel.isHidden = false
        showOverlay(for: v)
    }

    private func showOverlay(for tv: UITextView) {
        editOverlay?.removeFromSuperview()
        let overlay = UIView(frame: tv.frame.insetBy(dx: -5, dy: -5))
        overlay.layer.borderWidth = 2
        overlay.layer.borderColor = AppColors.primary.cgColor
        canvasView.addSubview(overlay)
        editOverlay = overlay
    }
    
    private func updateOverlay(for v: UIView) {
        guard let tv = v as? UITextView, let overlay = editOverlay else { return }
        overlay.frame = tv.frame.insetBy(dx: -5, dy: -5)
        overlay.transform = tv.transform
    }

    // MARK: - Save Logic
    @objc private func saveToGallery() {
        hideTools()
        let renderer = UIGraphicsImageRenderer(bounds: canvasView.bounds)
        let image = renderer.image { context in
            canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Сохранено!", message: "Ваша карта желаний теперь в галерее.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Супер", style: .default))
            present(ac, animated: true)
        }
    }

    // MARK: - Style Actions
    @objc private func changeColor(_ s: UIButton) { currentTextView?.textColor = s.backgroundColor }
    @objc private func toggleSlider() { sizeSlider.isHidden.toggle() }
    
    @objc private func sliderChanged(_ s: UISlider) {
        let size = CGFloat(s.value)
        currentTextView?.font = currentTextView?.font?.withSize(size)
        sizeButton.setTitle("Размер: \(Int(size))", for: .normal)
        currentTextView?.frame.size = currentTextView?.sizeThatFits(CGSize(width: 500, height: 1000)) ?? .zero
        updateOverlay(for: currentTextView!)
    }

    @objc private func toggleBold() { applyFontTrait(trait: .traitBold) }
    @objc private func toggleItalic() { applyFontTrait(trait: .traitItalic) }
    
    private func applyFontTrait(trait: UIFontDescriptor.SymbolicTraits) {
        guard let tv = currentTextView, let font = tv.font else { return }
        let descriptor = font.fontDescriptor
        var traits = descriptor.symbolicTraits
        if traits.contains(trait) { traits.remove(trait) } else { traits.insert(trait) }
        if let newDescriptor = descriptor.withSymbolicTraits(traits) {
            tv.font = UIFont(descriptor: newDescriptor, size: font.pointSize)
        }
    }

    @objc private func handleUnderline() { applyAttr(.underlineStyle, value: NSUnderlineStyle.single.rawValue) }
    @objc private func handleStrike() { applyAttr(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue) }
    
    private func applyAttr(_ key: NSAttributedString.Key, value: Int) {
        guard let tv = currentTextView else { return }
        let attr = NSMutableAttributedString(attributedString: tv.attributedText)
        let range = NSRange(location: 0, length: attr.length)
        if attr.attribute(key, at: 0, effectiveRange: nil) != nil {
            attr.removeAttribute(key, range: range)
        } else {
            attr.addAttribute(key, value: value, range: range)
        }
        tv.attributedText = attr
    }

    @objc private func toggleBullet() { togglePrefix("• ") }
    @objc private func toggleTask() { togglePrefix("☐ ") }
    
    private func togglePrefix(_ prefix: String) {
        guard let tv = currentTextView else { return }
        tv.text = tv.text.hasPrefix(prefix) ? String(tv.text.dropFirst(2)) : prefix + tv.text
    }

    // MARK: - Image Picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            let iv = UIImageView(image: image)
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.frame = CGRect(x: 50, y: 50, width: 150, height: 150)
            iv.isUserInteractionEnabled = true
            addGestures(to: iv)
            canvasView.addSubview(iv)
        }
    }
}

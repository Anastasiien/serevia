import UIKit

class WishMapEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let canvasView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.99, green: 0.985, blue: 0.98, alpha: 1)
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        view.clipsToBounds = true
        return view
    }()

    private let addImageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Добавить картинку", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.53, green: 0.43, blue: 0.34, alpha: 1)
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return btn
    }()

    private let addTextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Добавить текст", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.99, green: 0.985, blue: 0.98, alpha: 1)
        setupUI()
    }

    private func setupUI() {
        view.addSubview(canvasView)
        view.addSubview(addImageButton)
        view.addSubview(addTextButton)

        canvasView.translatesAutoresizingMaskIntoConstraints = false
        addImageButton.translatesAutoresizingMaskIntoConstraints = false
        addTextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            canvasView.bottomAnchor.constraint(equalTo: addImageButton.topAnchor, constant: -20),

            addImageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addImageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addImageButton.heightAnchor.constraint(equalToConstant: 44),
            addImageButton.widthAnchor.constraint(equalToConstant: 150),

            addTextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addTextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addTextButton.heightAnchor.constraint(equalToConstant: 44),
            addTextButton.widthAnchor.constraint(equalToConstant: 150)
        ])

        addImageButton.addTarget(self, action: #selector(addImageTapped), for: .touchUpInside)
        addTextButton.addTarget(self, action: #selector(addTextTapped), for: .touchUpInside)
    }

    // MARK: - Add Image
    @objc private func addImageTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.isUserInteractionEnabled = true
            imageView.frame = CGRect(x: 20, y: 20, width: 120, height: 120)
            addGestures(to: imageView)
            canvasView.addSubview(imageView)
        }
    }

    // MARK: - Add Text
    @objc private func addTextTapped() {
        let label = UILabel()
        label.text = "Новая запись"
        label.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.sizeToFit()
        label.isUserInteractionEnabled = true

        // Place near center of canvas
        let cx = canvasView.bounds.width / 2
        let cy = canvasView.bounds.height / 2
        label.center = CGPoint(
            x: cx + CGFloat.random(in: -60...60),
            y: cy + CGFloat.random(in: -60...60)
        )

        addGestures(to: label)
        canvasView.addSubview(label)
    }

    // MARK: - Gestures
    private func addGestures(to view: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        pan.require(toFail: doubleTap)
        view.addGestureRecognizer(pan)
        view.addGestureRecognizer(pinch)
        view.addGestureRecognizer(doubleTap)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let target = gesture.view else { return }
        let translation = gesture.translation(in: canvasView)
        target.center = CGPoint(
            x: target.center.x + translation.x,
            y: target.center.y + translation.y
        )
        gesture.setTranslation(.zero, in: canvasView)

        if gesture.state == .began {
            UIView.animate(withDuration: 0.15) {
                target.transform = target.transform.scaledBy(x: 1.05, y: 1.05)
            }
        } else if gesture.state == .ended || gesture.state == .cancelled {
            UIView.animate(withDuration: 0.15) {
                // Reset scale component, keep rotation
                let angle = atan2(target.transform.b, target.transform.a)
                target.transform = CGAffineTransform(rotationAngle: angle)
            }
        }
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let target = gesture.view else { return }
        target.transform = target.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1
    }

    // MARK: - Double tap to rename label
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }

        let alert = UIAlertController(title: "Изменить текст", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.text = label.text
            tf.placeholder = "Введите текст"
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Сохранить", style: .default) { _ in
            guard let newText = alert.textFields?.first?.text, !newText.isEmpty else { return }
            label.text = newText
            label.sizeToFit()
        })
        present(alert, animated: true)
    }
}

import UIKit

// Расширение для UIColor из HEX
extension UIColor {
    static func fromHex(_ hex: String) -> UIColor? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let length = hexSanitized.count
        let r, g, b, a: UInt64
        if length == 6 {
            r = (rgb & 0xFF0000) >> 16
            g = (rgb & 0x00FF00) >> 8
            b = rgb & 0x0000FF
            a = 255
        } else if length == 8 {
            r = (rgb & 0xFF000000) >> 24
            g = (rgb & 0x00FF0000) >> 16
            b = (rgb & 0x0000FF00) >> 8
            a = rgb & 0x000000FF
        } else {
            return nil
        }

        return UIColor(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

class DiaryDetailViewController: UIViewController {

    private let entry: DiaryEntry

    init(entry: DiaryEntry) {
        self.entry = entry
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        title = "Запись дня"
        setupUI()
    }

    private func setupUI() {
        // Дата сверху
        let dateLabel = UILabel()
        dateLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        dateLabel.textColor = AppColors.text
        dateLabel.textAlignment = .center

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        dateLabel.text = formatter.string(from: entry.date)

        // Цвет кружком
        let colorView = UIView()
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.cornerRadius = 16
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = UIColor.gray.cgColor
        colorView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        colorView.heightAnchor.constraint(equalToConstant: 32).isActive = true

        if let hexColor = entry.color, let savedColor = UIColor.fromHex(hexColor) {
            colorView.backgroundColor = savedColor
        } else {
            colorView.backgroundColor = .clear
        }

        // Эмоция
        let moodLabel = UILabel()
        moodLabel.font = UIFont.systemFont(ofSize: 32)
        moodLabel.text = entry.mood

        // Метки "Цвет:" и "Эмоция:"
        let colorTextLabel = UILabel()
        colorTextLabel.text = "Цвет:"
        colorTextLabel.font = UIFont.systemFont(ofSize: 16)
        colorTextLabel.textColor = AppColors.text

        let emotionTextLabel = UILabel()
        emotionTextLabel.text = "Эмоция:"
        emotionTextLabel.font = UIFont.systemFont(ofSize: 16)
        emotionTextLabel.textColor = AppColors.text

        // Горизонтальный стек для цвета и эмоции
        let emotionStack = UIStackView(arrangedSubviews: [
            colorTextLabel, colorView,
            emotionTextLabel, moodLabel
        ])
        emotionStack.axis = .horizontal
        emotionStack.spacing = 12
        emotionStack.alignment = .center

        // Текст записи
        let textLabel = UILabel()
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.textColor = AppColors.text
        textLabel.numberOfLines = 0
        textLabel.text = entry.text

        // Фото, если есть
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        if let data = entry.imageData {
            imageView.image = UIImage(data: data)
        }

        // Основной вертикальный стек
        let stack = UIStackView(arrangedSubviews: [dateLabel, emotionStack, textLabel, imageView])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .leading

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        // Если фото отсутствует, скрываем UIImageView
        if entry.imageData == nil {
            imageView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        } else {
            imageView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        }
    }
}

import UIKit

// MARK: - UIColor из HEX
extension UIColor {
    static func fromHex(_ hex: String) -> UIColor? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r, g, b: CGFloat
        if hexSanitized.count == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255
            b = CGFloat(rgb & 0x0000FF) / 255
        } else {
            return nil
        }

        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}

class DiaryDetailViewController: UIViewController {

    private let entry: DiaryEntry

    init(entry: DiaryEntry) {
        self.entry = entry
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) не реализован")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.95, green: 0.93, blue: 0.88, alpha: 1.0)
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.94, blue: 0.91, alpha: 1.0)

        // MARK: - ScrollView
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // MARK: - Основной стек
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 24
        mainStack.alignment = .fill
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])

        // MARK: - Дата
        let dateLabel = UILabel()
        dateLabel.font = UIFont(name: "Georgia-Italic", size: 26)
        dateLabel.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1.0)
        dateLabel.textAlignment = .center

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        dateLabel.text = formatter.string(from: entry.date)

        // MARK: - Цвет и эмоция
        let colorView = UIView()
        colorView.layer.cornerRadius = 16
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = AppColors.border.cgColor
        colorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalToConstant: 32),
            colorView.heightAnchor.constraint(equalToConstant: 32)
        ])
        if let hex = entry.color, let uiColor = UIColor.fromHex(hex) {
            colorView.backgroundColor = uiColor
        }

        let moodLabel = UILabel()
        moodLabel.font = UIFont.systemFont(ofSize: 36)
        moodLabel.text = entry.mood

        let colorTextLabel = UILabel()
        colorTextLabel.text = "Цвет:"
        colorTextLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        colorTextLabel.textColor = AppColors.lightText

        let emotionTextLabel = UILabel()
        emotionTextLabel.text = "Эмоция:"
        emotionTextLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emotionTextLabel.textColor = AppColors.lightText

        let emotionStack = UIStackView(arrangedSubviews: [
            colorTextLabel, colorView,
            emotionTextLabel, moodLabel
        ])
        emotionStack.axis = .horizontal
        emotionStack.spacing = 20
        emotionStack.alignment = .center

        let infoCard = UIStackView(arrangedSubviews: [dateLabel, emotionStack])
        infoCard.axis = .vertical
        infoCard.spacing = 12
        infoCard.alignment = .center
        infoCard.backgroundColor = AppColors.card
        infoCard.layer.cornerRadius = 16
        infoCard.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        infoCard.isLayoutMarginsRelativeArrangement = true
        mainStack.addArrangedSubview(infoCard)

        // MARK: - Теги с горизонтальным скроллом
        if !entry.tags.isEmpty {
            let tagsScroll = UIScrollView()
            tagsScroll.showsHorizontalScrollIndicator = false
            tagsScroll.translatesAutoresizingMaskIntoConstraints = false
            let tagsStack = UIStackView()
            tagsStack.axis = .horizontal
            tagsStack.spacing = 8
            tagsStack.alignment = .center
            tagsStack.distribution = .fillProportionally
            tagsStack.translatesAutoresizingMaskIntoConstraints = false
            tagsScroll.addSubview(tagsStack)
            NSLayoutConstraint.activate([
                tagsStack.topAnchor.constraint(equalTo: tagsScroll.topAnchor),
                tagsStack.bottomAnchor.constraint(equalTo: tagsScroll.bottomAnchor),
                tagsStack.leadingAnchor.constraint(equalTo: tagsScroll.leadingAnchor),
                tagsStack.trailingAnchor.constraint(equalTo: tagsScroll.trailingAnchor),
                tagsStack.heightAnchor.constraint(equalTo: tagsScroll.heightAnchor)
            ])
            for tag in entry.tags {
                let label = UILabel()
                label.text = "#\(tag)"
                label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                label.textColor = AppColors.primary
                label.textAlignment = .center
                label.isUserInteractionEnabled = false

                let container = UIView()
                container.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.81, alpha: 1.0)
                container.layer.cornerRadius = 14
                container.clipsToBounds = true
                container.addSubview(label)

                label.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
                    label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
                    label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
                    label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
                ])
                tagsStack.addArrangedSubview(container)
            }
            mainStack.addArrangedSubview(tagsScroll)
        }

        // MARK: - Картинка (если есть)
        if let imageData = entry.imageData, let image = UIImage(data: imageData) {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.layer.cornerRadius = 12
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false

            mainStack.addArrangedSubview(imageView)

            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        }

        // MARK: - Текст
        if !entry.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let textLabel = UILabel()
            textLabel.font = UIFont.systemFont(ofSize: 16)
            textLabel.textColor = UIColor(red: 0.25, green: 0.20, blue: 0.15, alpha: 1.0)
            textLabel.numberOfLines = 0
            textLabel.text = entry.text

            let textContainer = UIView()
            textContainer.backgroundColor = UIColor(red: 0.92, green: 0.90, blue: 0.87, alpha: 1.0)
            textContainer.layer.cornerRadius = 12
            textContainer.addSubview(textLabel)

            textLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textLabel.topAnchor.constraint(equalTo: textContainer.topAnchor, constant: 16),
                textLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: 16),
                textLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: -16),
                textLabel.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor, constant: -16)
            ])

            mainStack.addArrangedSubview(textContainer)
        }
    }

}


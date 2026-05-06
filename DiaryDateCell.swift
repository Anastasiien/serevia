import UIKit

class DiaryDateCell: UICollectionViewCell {

    private let dateLabel   = UILabel()
    private let moodLabel   = UILabel()
    private let floralView  = UIImageView()
    private let overlayView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        layer.cornerRadius = 22
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6
        clipsToBounds = true

        // floral фон как на остальных карточках
        if let orig = UIImage(named: "floral_pattern") {
            let sz = CGSize(width: orig.size.width / 2.5, height: orig.size.height / 2.5)
            UIGraphicsBeginImageContextWithOptions(sz, false, 0)
            orig.draw(in: CGRect(origin: .zero, size: sz))
            let scaled = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            floralView.image = scaled ?? orig
        }
        floralView.contentMode = .scaleAspectFill
        floralView.alpha = 0.22
        floralView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(floralView)

        // цветной оверлей (цвет дня) или нейтральный
        overlayView.backgroundColor = UIColor(red: 0.99, green: 0.985, blue: 0.98, alpha: 1.0)
        overlayView.alpha = 0.78
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(overlayView)

        moodLabel.font = UIFont.systemFont(ofSize: 30)
        moodLabel.textAlignment = .center

        dateLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        dateLabel.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        dateLabel.textAlignment = .center
        dateLabel.numberOfLines = 2

        let stack = UIStackView(arrangedSubviews: [moodLabel, dateLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            floralView.topAnchor.constraint(equalTo: contentView.topAnchor),
            floralView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            floralView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            floralView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            overlayView.topAnchor.constraint(equalTo: contentView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8)
        ])
    }

    func configure(with entry: DiaryEntry) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM"
        dateLabel.text = formatter.string(from: entry.date)
        moodLabel.text = entry.mood

        if let hexColor = entry.color, let savedColor = UIColor(hex: hexColor) {
            overlayView.backgroundColor = savedColor
            overlayView.alpha = 0.72
        } else {
            overlayView.backgroundColor = UIColor(red: 0.99, green: 0.985, blue: 0.98, alpha: 1.0)
            overlayView.alpha = 0.78
        }
    }
}

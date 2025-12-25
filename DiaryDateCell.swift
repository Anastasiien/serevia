import UIKit

class DiaryDateCell: UICollectionViewCell {

    private let dateLabel = UILabel()
    private let moodLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor(red: 0.99, green: 0.985, blue: 0.98, alpha: 1.0)
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3

        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        dateLabel.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        dateLabel.textAlignment = .center
        dateLabel.numberOfLines = 2

        moodLabel.font = UIFont.systemFont(ofSize: 28)
        moodLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [dateLabel, moodLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
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
    }
}

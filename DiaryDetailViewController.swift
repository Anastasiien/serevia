import UIKit

extension UIColor {
    static func fromHex(_ hex: String) -> UIColor? {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: h).scanHexInt64(&rgb), h.count == 6 else { return nil }
        return UIColor(
            red:   CGFloat((rgb & 0xFF0000) >> 16) / 255,
            green: CGFloat((rgb & 0x00FF00) >> 8)  / 255,
            blue:  CGFloat(rgb & 0x0000FF)          / 255,
            alpha: 1
        )
    }
}

class DiaryDetailViewController: UIViewController {

    private let entry: DiaryEntry

    private let accent   = UIColor(red: 0.58, green: 0.46, blue: 0.42, alpha: 1)
    private let pageBg   = UIColor(red: 0.96, green: 0.94, blue: 0.91, alpha: 1)
    private let textDark = UIColor(red: 0.20, green: 0.15, blue: 0.10, alpha: 1)
    private let textMid  = UIColor(red: 0.48, green: 0.40, blue: 0.32, alpha: 1)
    private let cardBg   = UIColor.white

    init(entry: DiaryEntry) {
        self.entry = entry
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = pageBg
        setupUI()
    }

    // floral карточка — единый стиль
    private func makeFloralCard() -> UIView {
        let v = UIView()
        v.layer.cornerRadius = 22
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.04
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 6
        v.clipsToBounds = true

        if let orig = UIImage(named: "floral_pattern") {
            let sz = CGSize(width: orig.size.width / 2.5, height: orig.size.height / 2.5)
            UIGraphicsBeginImageContextWithOptions(sz, false, 0)
            orig.draw(in: CGRect(origin: .zero, size: sz))
            let scaled = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            v.backgroundColor = UIColor(patternImage: scaled ?? orig)
        } else {
            v.backgroundColor = cardBg
        }

        let overlay = UIView()
        overlay.backgroundColor = cardBg
        overlay.alpha = 0.82
        overlay.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: v.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: v.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: v.bottomAnchor)
        ])
        return v
    }

    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // ── заголовок в едином стиле ──
        let dateTopLabel = UILabel()
        let topFormatter = DateFormatter()
        topFormatter.locale = Locale(identifier: "ru_RU")
        topFormatter.dateFormat = "EEEE, d MMMM yyyy"
        let raw = topFormatter.string(from: entry.date)
        dateTopLabel.text = raw.prefix(1).uppercased() + raw.dropFirst()
        dateTopLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateTopLabel.textColor = textMid.withAlphaComponent(0.7)
        dateTopLabel.textAlignment = .center

        let titleLabel = UILabel()
        titleLabel.text = "Запись дня"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = textDark
        titleLabel.textAlignment = .center

        let divider = UIView()
        divider.backgroundColor = UIColor(red: 0.76, green: 0.68, blue: 0.58, alpha: 0.2)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let headerStack = UIStackView(arrangedSubviews: [dateTopLabel, titleLabel, divider])
        headerStack.axis = .vertical
        headerStack.spacing = 4
        headerStack.setCustomSpacing(14, after: titleLabel)

        // ── карточка: настроение + цвет дня ──
        let moodCard = makeFloralCard()

        let moodBigLabel = UILabel()
        moodBigLabel.text = entry.mood
        moodBigLabel.font = .systemFont(ofSize: 44)
        moodBigLabel.textAlignment = .center

        let moodTextLabel = UILabel()
        moodTextLabel.font = .systemFont(ofSize: 13, weight: .medium)
        moodTextLabel.textColor = textMid
        moodTextLabel.textAlignment = .center
        let moodMap = ["😄": "Отлично", "🙂": "Хорошо", "😐": "Нормально", "😔": "Грустно"]
        moodTextLabel.text = moodMap[entry.mood] ?? "Настроение"

        var moodCardArranged: [UIView] = [moodBigLabel, moodTextLabel]

        if let hex = entry.color, let uiColor = UIColor.fromHex(hex) {
            let colorRow = UIStackView()
            colorRow.axis = .horizontal
            colorRow.spacing = 10
            colorRow.alignment = .center

            let colorDot = UIView()
            colorDot.backgroundColor = uiColor
            colorDot.layer.cornerRadius = 10
            colorDot.translatesAutoresizingMaskIntoConstraints = false
            colorDot.widthAnchor.constraint(equalToConstant: 20).isActive = true
            colorDot.heightAnchor.constraint(equalToConstant: 20).isActive = true

            let colorLbl = UILabel()
            colorLbl.text = "Цвет дня"
            colorLbl.font = .systemFont(ofSize: 13, weight: .medium)
            colorLbl.textColor = textMid

            colorRow.addArrangedSubview(colorDot)
            colorRow.addArrangedSubview(colorLbl)
            moodCardArranged.append(colorRow)
        }

        let moodInner = UIStackView(arrangedSubviews: moodCardArranged)
        moodInner.axis = .vertical
        moodInner.alignment = .center
        moodInner.spacing = 6
        moodInner.translatesAutoresizingMaskIntoConstraints = false
        moodCard.addSubview(moodInner)
        NSLayoutConstraint.activate([
            moodInner.topAnchor.constraint(equalTo: moodCard.topAnchor, constant: 20),
            moodInner.leadingAnchor.constraint(equalTo: moodCard.leadingAnchor, constant: 20),
            moodInner.trailingAnchor.constraint(equalTo: moodCard.trailingAnchor, constant: -20),
            moodInner.bottomAnchor.constraint(equalTo: moodCard.bottomAnchor, constant: -20)
        ])

        // ── карточка: теги ──
        var tagsCard: UIView? = nil
        if !entry.tags.isEmpty {
            let card = makeFloralCard()

            let tagsTitle = UILabel()
            tagsTitle.text = "Теги"
            tagsTitle.font = .systemFont(ofSize: 13, weight: .semibold)
            tagsTitle.textColor = textMid

            let tagsScroll = UIScrollView()
            tagsScroll.showsHorizontalScrollIndicator = false
            tagsScroll.translatesAutoresizingMaskIntoConstraints = false

            let tagsStack = UIStackView()
            tagsStack.axis = .horizontal
            tagsStack.spacing = 8
            tagsStack.alignment = .center
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
                let lbl = UILabel()
                lbl.text = "#\(tag)"
                lbl.font = .systemFont(ofSize: 13, weight: .medium)
                lbl.textColor = accent
                lbl.textAlignment = .center

                let pill = UIView()
                pill.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.81, alpha: 1)
                pill.layer.cornerRadius = 13
                pill.clipsToBounds = true
                lbl.translatesAutoresizingMaskIntoConstraints = false
                pill.addSubview(lbl)
                NSLayoutConstraint.activate([
                    lbl.topAnchor.constraint(equalTo: pill.topAnchor, constant: 5),
                    lbl.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -5),
                    lbl.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 12),
                    lbl.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -12)
                ])
                tagsStack.addArrangedSubview(pill)
            }

            let inner = UIStackView(arrangedSubviews: [tagsTitle, tagsScroll])
            inner.axis = .vertical
            inner.spacing = 10
            inner.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(inner)
            NSLayoutConstraint.activate([
                inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
                inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
                inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
                inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
                tagsScroll.heightAnchor.constraint(equalToConstant: 32)
            ])
            tagsCard = card
        }

        // ── карточка: текст ──
        var textCard: UIView? = nil
        if !entry.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let card = makeFloralCard()

            let textTitle = UILabel()
            textTitle.text = "Запись"
            textTitle.font = .systemFont(ofSize: 13, weight: .semibold)
            textTitle.textColor = textMid

            let textLabel = UILabel()
            textLabel.font = .systemFont(ofSize: 15)
            textLabel.textColor = textDark
            textLabel.numberOfLines = 0
            textLabel.text = entry.text

            let inner = UIStackView(arrangedSubviews: [textTitle, textLabel])
            inner.axis = .vertical
            inner.spacing = 10
            inner.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(inner)
            NSLayoutConstraint.activate([
                inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
                inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
                inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
                inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
            ])
            textCard = card
        }

        // ── карточка: фото ──
        var photoCard: UIView? = nil
        if let imageData = entry.imageData, let image = UIImage(data: imageData) {
            let card = makeFloralCard()

            let photoTitle = UILabel()
            photoTitle.text = "Фото дня"
            photoTitle.font = .systemFont(ofSize: 13, weight: .semibold)
            photoTitle.textColor = textMid

            let iv = UIImageView(image: image)
            iv.contentMode = .scaleAspectFit
            iv.layer.cornerRadius = 14
            iv.clipsToBounds = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.heightAnchor.constraint(lessThanOrEqualToConstant: 280).isActive = true

            let inner = UIStackView(arrangedSubviews: [photoTitle, iv])
            inner.axis = .vertical
            inner.spacing = 10
            inner.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(inner)
            NSLayoutConstraint.activate([
                inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
                inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
                inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
                inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
            ])
            photoCard = card
        }

        // ── собираем главный стек ──
        var arranged: [UIView] = [headerStack, moodCard]
        if let t = tagsCard  { arranged.append(t) }
        if let t = textCard  { arranged.append(t) }
        if let p = photoCard { arranged.append(p) }

        let mainStack = UIStackView(arrangedSubviews: arranged)
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 32, right: 20)
        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

import UIKit

class ExploreViewController: UIViewController {

    // MARK: - Constants
    private let accent   = UIColor(red: 0.49, green: 0.38, blue: 0.27, alpha: 1)
    private let textDark = UIColor(red: 0.20, green: 0.15, blue: 0.10, alpha: 1)
    private let textMid  = UIColor(red: 0.48, green: 0.40, blue: 0.32, alpha: 1)
    private let cardBg   = UIColor.white

    private let scrollView  = UIScrollView()
    private let contentView = UIView()

    // MARK: - Data
    private let articles: [(title: String, category: String, time: String, emoji: String)] = [
        ("Управление стрессом",   "Психология",    "5 мин", "🧠"),
        ("Сила благодарности",    "Саморазвитие",  "7 мин", "🌿"),
        ("Осознанное дыхание",    "Практики",      "4 мин", "🌬️"),
        ("Сон и восстановление",  "Здоровье",      "6 мин", "🌙"),
        ("Медитация для начинающих", "Практики",   "8 мин", "🪷")
    ]

    private let tests: [(title: String, desc: String, emoji: String)] = [
        ("Тест на стресс",     "Оцени уровень тревожности",  "📊"),
        ("Тест на внимание",   "Проверь концентрацию",       "🎯"),
        ("Тест на эмоции",     "Узнай своё состояние",       "💭")
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupScrollView()
        buildUI()
    }

    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func buildUI() {
        // ── Header ──
        let titleLabel = UILabel()
        titleLabel.text = "Интересное"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = textDark
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Статьи, тесты и практики для тебя"
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = textMid
        subtitleLabel.textAlignment = .center

        // ── Articles section ──
        let articlesHeader = makeSectionHeader("Статьи")
        let articlesScroll = makeArticlesScroll()

        // ── Wish map card ──
        let wishHeader = makeSectionHeader("Карта желаний")
        let wishCard = makeWishMapCard()

        // ── Tests section ──
        let testsHeader = makeSectionHeader("Тесты")
        let testsStack = makeTestsStack()

        // ── Main stack ──
        let mainStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            articlesHeader,
            articlesScroll,
            wishHeader,
            wishCard,
            testsHeader,
            testsStack
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 0
        mainStack.setCustomSpacing(4,  after: titleLabel)
        mainStack.setCustomSpacing(28, after: subtitleLabel)
        mainStack.setCustomSpacing(14, after: articlesHeader)
        mainStack.setCustomSpacing(28, after: articlesScroll)
        mainStack.setCustomSpacing(14, after: wishHeader)
        mainStack.setCustomSpacing(28, after: wishCard)
        mainStack.setCustomSpacing(14, after: testsHeader)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.layoutMargins = UIEdgeInsets(top: 16, left: 20, bottom: 32, right: 20)
        contentView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Section Header
    private func makeSectionHeader(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = textDark
        return l
    }

    // MARK: - Articles Horizontal Scroll
    private func makeArticlesScroll() -> UIScrollView {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.clipsToBounds = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.heightAnchor.constraint(equalToConstant: 148).isActive = true

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.heightAnchor.constraint(equalTo: scroll.heightAnchor)
        ])

        for (i, article) in articles.enumerated() {
            let card = makeArticleCard(article, index: i)
            stack.addArrangedSubview(card)
        }

        return scroll
    }

    private func makeArticleCard(_ article: (title: String, category: String, time: String, emoji: String), index: Int) -> UIView {
        let pastelBgs: [UIColor] = [
            UIColor(red: 0.98, green: 0.93, blue: 0.88, alpha: 1),
            UIColor(red: 0.92, green: 0.95, blue: 0.88, alpha: 1),
            UIColor(red: 0.88, green: 0.93, blue: 0.98, alpha: 1),
            UIColor(red: 0.95, green: 0.90, blue: 0.97, alpha: 1),
            UIColor(red: 0.97, green: 0.95, blue: 0.88, alpha: 1)
        ]

        let card = UIButton(type: .system)
        card.backgroundColor = pastelBgs[index % pastelBgs.count]
        card.layer.cornerRadius = 20
        card.translatesAutoresizingMaskIntoConstraints = false
        card.widthAnchor.constraint(equalToConstant: 160).isActive = true
        card.tag = index
        card.addTarget(self, action: #selector(articleTapped(_:)), for: .touchUpInside)

        let emojiLabel = UILabel()
        emojiLabel.text = article.emoji
        emojiLabel.font = .systemFont(ofSize: 28)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = article.title
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = textDark
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let metaLabel = UILabel()
        metaLabel.text = "\(article.category)  ·  \(article.time)"
        metaLabel.font = .systemFont(ofSize: 11, weight: .regular)
        metaLabel.textColor = textMid
        metaLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(emojiLabel)
        card.addSubview(titleLabel)
        card.addSubview(metaLabel)
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            emojiLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            metaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            metaLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            metaLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            metaLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -14)
        ])

        return card
    }

    // MARK: - Wish Map Card
    private func makeWishMapCard() -> UIView {
        let card = UIView()
        card.backgroundColor = accent
        card.layer.cornerRadius = 22
        card.translatesAutoresizingMaskIntoConstraints = false

        let emojiLabel = UILabel()
        emojiLabel.text = "✨"
        emojiLabel.font = .systemFont(ofSize: 32)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Карта желаний"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let descLabel = UILabel()
        descLabel.text = "Визуализируй мечты и цели"
        descLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        let button = UIButton(type: .system)
        button.setTitle("Открыть →", for: .normal)
        button.setTitleColor(accent, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .white
        button.layer.cornerRadius = 14
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openWishMap), for: .touchUpInside)

        card.addSubview(emojiLabel)
        card.addSubview(titleLabel)
        card.addSubview(descLabel)
        card.addSubview(button)
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            emojiLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            button.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 16),
            button.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            button.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])

        return card
    }

    // MARK: - Tests Stack
    private func makeTestsStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10

        for (i, test) in tests.enumerated() {
            let card = makeTestRow(test, index: i)
            stack.addArrangedSubview(card)
        }
        return stack
    }

    private func makeTestRow(_ test: (title: String, desc: String, emoji: String), index: Int) -> UIView {
        let card = UIButton(type: .system)
        card.backgroundColor = cardBg
        card.layer.cornerRadius = 18
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.04
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 6
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 70).isActive = true
        card.tag = index
        card.addTarget(self, action: #selector(testTapped(_:)), for: .touchUpInside)

        let emojiLabel = UILabel()
        emojiLabel.text = test.emoji
        emojiLabel.font = .systemFont(ofSize: 24)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = test.title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = textDark
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let descLabel = UILabel()
        descLabel.text = test.desc
        descLabel.font = .systemFont(ofSize: 12, weight: .regular)
        descLabel.textColor = textMid
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UILabel()
        chevron.text = "›"
        chevron.font = .systemFont(ofSize: 22, weight: .light)
        chevron.textColor = textMid
        chevron.translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [titleLabel, descLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(emojiLabel)
        card.addSubview(textStack)
        card.addSubview(chevron)
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            emojiLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            textStack.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 14),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            textStack.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -12),
            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

        return card
    }

    // MARK: - Actions
    @objc private func articleTapped(_ sender: UIButton) {
        let vc = UIViewController()
        vc.view.backgroundColor = AppColors.background
        let l = UILabel()
        l.text = articles[sender.tag].title
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = textDark
        l.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(l)
        NSLayoutConstraint.activate([
            l.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            l.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 30)
        ])
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func testTapped(_ sender: UIButton) {
        let vc = UIViewController()
        vc.view.backgroundColor = AppColors.background
        let l = UILabel()
        l.text = tests[sender.tag].title
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = textDark
        l.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(l)
        NSLayoutConstraint.activate([
            l.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            l.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 30)
        ])
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openWishMap() {
        let wishMapVC = WishMapEditorViewController()
        navigationController?.pushViewController(wishMapVC, animated: true)
    }
}

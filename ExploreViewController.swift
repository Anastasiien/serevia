//
//  ExploreViewController.swift
//  serevia
//
//  Created by ekatizzz 10.03.2026.
//

import UIKit

class ExploreViewController: UIViewController {

    // MARK: - Constants
    private let accent = UIColor(red: 0.58, green: 0.46, blue: 0.42, alpha: 1)
    private let textDark = UIColor(red: 0.20, green: 0.15, blue: 0.10, alpha: 1)
    private let textMid  = UIColor(red: 0.48, green: 0.40, blue: 0.32, alpha: 1)
    private let cardBg   = UIColor.white
    private let bgMain = UIColor(red: 0.96, green: 0.94, blue: 0.91, alpha: 1)
    
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
    
    private let podcasts: [(title: String, author: String, url: String, emoji: String)] = [
        ("Чай с психологом", "Егор Егоров - психолог, специалист краткосрочной терапии", "https://music.yandex.ru/album/9223243", "☕️"),
        ("Ты - это важно", "Елена Мицкевич - практикующий психолог и автор блога", "https://music.yandex.ru/album/15666261", "🤎"),
        ("Развитие осознанности", "Юлия Шешенева - преподаватель студии йоги Retunsky", "https://music.yandex.ru/album/10935950", "🍀"),
        ("Медитируй со мной", "Авторские практики для расслабления", "https://music.yandex.ru/album/15774913", "🧘‍♂️"),
        ("Психология", "Александра Яковлева - автор подкаста, психолог, журналист", "https://music.yandex.ru/album/9091989?activeTab=about", "📚")
    ]

    private let tests: [(title: String, desc: String, emoji: String)] = [
        ("Уровень депрессии", "По шкале Бека (BDI)", "🧠"),
        ("Уровень тревожности", "По шкале Бека (BAI)",  "👀"),
        ("Внимательность и осознанность", "По шкале MAAS", "🪷"),
        ("Психологическое благополучие", "По шкале Риффа (PWB)", "🌱")
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgMain
        
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

        let articlesHeader = makeSectionHeader("Статьи")
        let articlesScroll = makeArticlesScroll()
        
        let podcastsHeader = makeSectionHeader("Рекомендуем послушать")
        let podcastsScroll = makePodcastsScroll()

        let wishHeader = makeSectionHeader("Карта желаний")
        let wishCard = makeWishMapCard()

        // Изменённая секция тестов с кнопкой "История"
        let testsSection = makeTestsSection()

        let mainStack = UIStackView(arrangedSubviews: [
            titleLabel, subtitleLabel,
            articlesHeader, articlesScroll,
            podcastsHeader, podcastsScroll,
            wishHeader, wishCard,
            testsSection
        ])
        
        mainStack.axis = .vertical
        mainStack.spacing = 0
        mainStack.setCustomSpacing(4,  after: titleLabel)
        mainStack.setCustomSpacing(28, after: subtitleLabel)
        mainStack.setCustomSpacing(14, after: articlesHeader)
        mainStack.setCustomSpacing(28, after: articlesScroll)
        mainStack.setCustomSpacing(14, after: podcastsHeader)
        mainStack.setCustomSpacing(28, after: podcastsScroll)
        mainStack.setCustomSpacing(14, after: wishHeader)
        mainStack.setCustomSpacing(28, after: wishCard)
        mainStack.setCustomSpacing(14, after: testsSection)
        
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

    private func makeSectionHeader(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = textDark
        return l
    }

    // MARK: - New tests section with a "History" button
    private func makeTestsSection() -> UIStackView {й
        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.distribution = .equalSpacing
        headerStack.spacing = 8
        
        let titleLabel = makeSectionHeader("Тесты")
        
        let historyButton = UIButton(type: .system)
        historyButton.setTitle("История", for: .normal)
        historyButton.setTitleColor(accent, for: .normal)
        historyButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        historyButton.addTarget(self, action: #selector(showTestHistory), for: .touchUpInside)
        
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(historyButton)
        
        let testsStack = makeTestsStack()
        
        let mainTestsStack = UIStackView(arrangedSubviews: [headerStack, testsStack])
        mainTestsStack.axis = .vertical
        mainTestsStack.spacing = 14
        
        return mainTestsStack
    }

    // MARK: - Podcasts Logic
    private func makePodcastsScroll() -> UIScrollView {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.clipsToBounds = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.heightAnchor.constraint(equalToConstant: 110).isActive = true

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.heightAnchor.constraint(equalTo: scroll.heightAnchor)
        ])

        for (i, podcast) in podcasts.enumerated() {
            stack.addArrangedSubview(makePodcastCard(podcast, index: i))
        }
        return scroll
    }
    
    private func makePodcastCard(_ podcast: (title: String, author: String, url: String, emoji: String), index: Int) -> UIView {
        let card = UIButton(type: .system)
        card.backgroundColor = cardBg
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = accent.withAlphaComponent(0.1).cgColor
        card.clipsToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false
        card.widthAnchor.constraint(equalToConstant: 210).isActive = true
        card.tag = index
        card.addTarget(self, action: #selector(podcastTapped(_:)), for: .touchUpInside)

        let backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "floral_pattern")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.alpha = 0.2
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.isUserInteractionEnabled = false
        backgroundImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        card.addSubview(backgroundImageView)

        let emojiCircle = UIView()
        emojiCircle.backgroundColor = accent.withAlphaComponent(0.08)
        emojiCircle.layer.cornerRadius = 10
        emojiCircle.translatesAutoresizingMaskIntoConstraints = false
        
        let emojiLabel = UILabel()
        emojiLabel.text = podcast.emoji
        emojiLabel.font = .systemFont(ofSize: 16)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = podcast.title
        titleLabel.font = .systemFont(ofSize: 13, weight: .bold)
        titleLabel.textColor = textDark
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let authorLabel = UILabel()
        authorLabel.text = podcast.author
        authorLabel.font = .systemFont(ofSize: 11, weight: .regular)
        authorLabel.textColor = textMid
        authorLabel.numberOfLines = 0
        authorLabel.lineBreakMode = .byWordWrapping
        authorLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(emojiCircle)
        emojiCircle.addSubview(emojiLabel)
        card.addSubview(titleLabel)
        card.addSubview(authorLabel)

        NSLayoutConstraint.activate([
            backgroundImageView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            backgroundImageView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            backgroundImageView.widthAnchor.constraint(equalTo: card.widthAnchor),
            backgroundImageView.heightAnchor.constraint(equalTo: card.heightAnchor),

            emojiCircle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            emojiCircle.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            emojiCircle.widthAnchor.constraint(equalToConstant: 34),
            emojiCircle.heightAnchor.constraint(equalToConstant: 34),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiCircle.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiCircle.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: emojiCircle.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),

            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            authorLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -8)
        ])

        return card
    }

    // MARK: - Articles Logic
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
            stack.addArrangedSubview(makeArticleCard(article, index: i))
        }
        return scroll
    }

    private func makeArticleCard(_ article: (title: String, category: String, time: String, emoji: String), index: Int) -> UIView {
        let pastelBgs: [UIColor] = [
            UIColor(red: 0.98, green: 0.88, blue: 0.78, alpha: 1),
            UIColor(red: 0.88, green: 0.94, blue: 0.82, alpha: 1),
            UIColor(red: 0.82, green: 0.90, blue: 0.98, alpha: 1),
            UIColor(red: 0.92, green: 0.84, blue: 0.96, alpha: 1),
            UIColor(red: 0.96, green: 0.92, blue: 0.78, alpha: 1)
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
        metaLabel.text = "\(article.category) · \(article.time)"
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
    
    // MARK: - Tests Logic
    private func makeTestsStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        for (i, test) in tests.enumerated() {
            stack.addArrangedSubview(makeTestRow(test, index: i))
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
        
        card.clipsToBounds = true
        
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 70).isActive = true
        card.tag = index
        card.addTarget(self, action: #selector(testTapped(_:)), for: .touchUpInside)

        let backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "floral_pattern")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.alpha = 0.2
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.isUserInteractionEnabled = false
        backgroundImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        card.addSubview(backgroundImageView)

        let emojiLabel = UILabel()
        emojiLabel.text = test.emoji
        emojiLabel.font = .systemFont(ofSize: 24)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = test.title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = textDark
        
        let descLabel = UILabel()
        descLabel.text = test.desc
        descLabel.font = .systemFont(ofSize: 12, weight: .regular)
        descLabel.textColor = textMid

        let textStack = UIStackView(arrangedSubviews: [titleLabel, descLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading
        textStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(emojiLabel)
        card.addSubview(textStack)
        
        NSLayoutConstraint.activate([
            backgroundImageView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            backgroundImageView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            backgroundImageView.widthAnchor.constraint(equalTo: card.widthAnchor),
            backgroundImageView.heightAnchor.constraint(equalTo: card.heightAnchor),

            emojiLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            emojiLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            textStack.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 14),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            textStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12)
        ])
        return card
    }

    // MARK: - Actions
    @objc private func articleTapped(_ sender: UIButton) {
        let title = articles[sender.tag].title
        let detailVC = ArticleDetailViewController()
        detailVC.articleTitle = title
        detailVC.contentText = ArticleProvider.getContent(for: title)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @objc private func podcastTapped(_ sender: UIButton) {
        let podcastUrl = podcasts[sender.tag].url
        if let url = URL(string: podcastUrl) {
            UIApplication.shared.open(url)
        }
    }

    @objc private func testTapped(_ sender: UIButton) {
        let title = tests[sender.tag].title
        
        switch title {
        case "Уровень депрессии":
            let vc = BeckTestViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
            
        case "Уровень тревожности":
            let vc = BeckAnxietyTestViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        
        case "Внимательность и осознанность":
            let vc = MindfulnessTestViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
            
        case "Психологическое благополучие":
            let vc = WellBeingTestViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
            
        default:
            let vc = UIViewController()
            vc.view.backgroundColor = AppColors.background
            let l = UILabel()
            l.text = title
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
    }

    @objc private func openWishMap() {
        let wishMapVC = WishMapEditorViewController()
        navigationController?.pushViewController(wishMapVC, animated: true)
    }

    // MARK: - Opening test history
    @objc private func showTestHistory() {
        let historyVC = TestHistoryViewController()
        historyVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(historyVC, animated: true)
    }
}

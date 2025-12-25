import UIKit

class HomeViewController: UIViewController {

    private let typingLabel = UILabel()
    private var currentPhraseIndex = 0
    private let phrases = [
        "Спокойствие — это суперсила",
        "Ты сильнее, чем думаешь",
        "Каждый день — новый шанс",
        "Сосредоточься на хорошем",
        "Сила в маленьких победах",
        "Мир внутри важнее всего",
        "Дыши глубоко и расслабься",
        "Слушай своё тело",
        "Найди радость в простом",
        "Будь добр к себе",
        "Позволь себе отдыхать",
        "Настройся на позитив"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        // Светлый фон, ближе к белому
        view.backgroundColor = AppColors.background

        // Логотип SEREVIA
        let logoLabel = UILabel()
        let attributed = NSMutableAttributedString(string: "SEREVIA")
        attributed.addAttribute(.kern, value: 8, range: NSRange(location: 0, length: attributed.length))
        logoLabel.attributedText = attributed
        logoLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        logoLabel.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        logoLabel.textAlignment = .center
        logoLabel.translatesAutoresizingMaskIntoConstraints = false

        // Приветствие
        let greetingLabel = UILabel()
        greetingLabel.text = "Привет, Анастасия"
        greetingLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        greetingLabel.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        greetingLabel.textAlignment = .center
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false

        // Карточка с цитатой
        let quoteCard = createCardView()
        typingLabel.text = (phrases.first!)
        typingLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        typingLabel.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        typingLabel.textAlignment = .center
        typingLabel.numberOfLines = 0

        let morePhraseButton = UIButton(type: .system)
        morePhraseButton.setTitle("⟳ Еще фраза", for: .normal)
        morePhraseButton.setTitleColor(UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1), for: .normal)
        morePhraseButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 100, bottom: 10, right: 100)
        morePhraseButton.backgroundColor = UIColor(red: 0.94, green: 0.91, blue: 0.87, alpha: 1.0)
        morePhraseButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        morePhraseButton.layer.cornerRadius = 20
        morePhraseButton.addTarget(self, action: #selector(nextPhrase), for: .touchUpInside)

        let quoteStack = UIStackView(arrangedSubviews: [typingLabel, morePhraseButton])
        quoteStack.axis = .vertical
        quoteStack.alignment = .center
        quoteStack.spacing = 15
        quoteCard.addSubview(quoteStack)
        quoteStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            quoteStack.topAnchor.constraint(equalTo: quoteCard.topAnchor, constant: 20),
            quoteStack.leadingAnchor.constraint(equalTo: quoteCard.leadingAnchor, constant: 20),
            quoteStack.trailingAnchor.constraint(equalTo: quoteCard.trailingAnchor, constant: -20),
            quoteStack.bottomAnchor.constraint(equalTo: quoteCard.bottomAnchor, constant: -20)
        ])

        // Привычки
        let habitsCard = createCardView()
        let habitsTitle = createSmallLabel("Привычки")
        let habitsProgress = UILabel()
        habitsProgress.text = "3 / 5"
        habitsProgress.font = UIFont.systemFont(ofSize: 22, weight: .bold) // побольше
        habitsProgress.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        let habitsSubtitle = createSmallLabel("Сегодня")

        let habitsStack = UIStackView(arrangedSubviews: [habitsTitle, habitsProgress])
        habitsStack.axis = .vertical
        habitsStack.distribution = .equalSpacing
        habitsCard.addSubview(habitsStack)
        habitsCard.addSubview(habitsSubtitle)
        habitsStack.translatesAutoresizingMaskIntoConstraints = false
        habitsSubtitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            habitsStack.topAnchor.constraint(equalTo: habitsCard.topAnchor, constant: 16),
            habitsStack.leadingAnchor.constraint(equalTo: habitsCard.leadingAnchor, constant: 16),
            habitsStack.trailingAnchor.constraint(equalTo: habitsCard.trailingAnchor, constant: -16),

            habitsSubtitle.topAnchor.constraint(equalTo: habitsStack.bottomAnchor, constant: 8),
            habitsSubtitle.leadingAnchor.constraint(equalTo: habitsCard.leadingAnchor, constant: 16),
            habitsSubtitle.bottomAnchor.constraint(equalTo: habitsCard.bottomAnchor, constant: -12)
        ])

        // Дней подряд
        let streakCard = createCardView()
        let streakTitle = createSmallLabel("Дней подряд")
        let streakNumber = UILabel()
        streakNumber.text = "7 🔥"
        streakNumber.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        streakNumber.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)

        let topLabel = UILabel()
        topLabel.text = "Топ: 10"
        topLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        topLabel.textColor = UIColor(red: 0.56, green: 0.47, blue: 0.38, alpha: 1)

        let streakStack = UIStackView(arrangedSubviews: [streakTitle, streakNumber, topLabel])
        streakStack.axis = .vertical
        streakStack.alignment = .center
        streakStack.spacing = 6
        streakCard.addSubview(streakStack)
        streakStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            streakStack.topAnchor.constraint(equalTo: streakCard.topAnchor, constant: 16),
            streakStack.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor, constant: 16),
            streakStack.trailingAnchor.constraint(equalTo: streakCard.trailingAnchor, constant: -16),
            streakStack.bottomAnchor.constraint(equalTo: streakCard.bottomAnchor, constant: -12)
        ])

        let habitsAndStreakStack = UIStackView(arrangedSubviews: [habitsCard, streakCard])
        habitsAndStreakStack.axis = .horizontal
        habitsAndStreakStack.distribution = .fillEqually
        habitsAndStreakStack.spacing = 15
        habitsAndStreakStack.translatesAutoresizingMaskIntoConstraints = false

        // Быстрые действия
        let actionsCard = createCardView()
        let actionsTitle = createTitleLabel("Быстрые действия")

        let dayButton = createActionButton(title: "Оценить день", color: UIColor(red: 0.53, green: 0.43, blue: 0.34, alpha: 1))
        let photoButton = createActionButton(title: "📸 Фото дня", color: UIColor(red: 0.78, green: 0.70, blue: 0.60, alpha: 1))

        let actionsStack = UIStackView(arrangedSubviews: [actionsTitle, dayButton, photoButton])
        actionsStack.axis = .vertical
        actionsStack.spacing = 10
        actionsCard.addSubview(actionsStack)
        actionsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionsStack.topAnchor.constraint(equalTo: actionsCard.topAnchor, constant: 16),
            actionsStack.leadingAnchor.constraint(equalTo: actionsCard.leadingAnchor, constant: 16),
            actionsStack.trailingAnchor.constraint(equalTo: actionsCard.trailingAnchor, constant: -16),
            actionsStack.bottomAnchor.constraint(equalTo: actionsCard.bottomAnchor, constant: -16)
        ])

        // Сегодня
        let todayCard = createCardView()
        let todayTitle = createTitleLabel("Сегодня")
        let todaySubtitle = createSmallLabel("Скоро здесь появится ваш день ✨")

        let todayStack = UIStackView(arrangedSubviews: [todayTitle, todaySubtitle])
        todayStack.axis = .vertical
        todayStack.spacing = 8
        todayCard.addSubview(todayStack)
        todayStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            todayStack.topAnchor.constraint(equalTo: todayCard.topAnchor, constant: 16),
            todayStack.leadingAnchor.constraint(equalTo: todayCard.leadingAnchor, constant: 16),
            todayStack.trailingAnchor.constraint(equalTo: todayCard.trailingAnchor, constant: -16),
            todayStack.bottomAnchor.constraint(equalTo: todayCard.bottomAnchor, constant: -16)
        ])

        // Общий стек
        let mainStack = UIStackView(arrangedSubviews: [logoLabel, greetingLabel, quoteCard, habitsAndStreakStack, actionsCard, todayCard])
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.spacing = 18
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: Components

    private func createCardView() -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor(red: 0.99, green: 0.985, blue: 0.98, alpha: 1.0)
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        card.layer.shadowOpacity = 0.3
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 3
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }

    private func createTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        return label
    }

    private func createSubtitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        return label
    }

    private func createSmallLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(red: 0.56, green: 0.47, blue: 0.38, alpha: 1)
        return label
    }

    private func createActionButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 14
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        return button
    }

    // MARK: Actions

    @objc private func nextPhrase() {
        currentPhraseIndex = (currentPhraseIndex + 1) % phrases.count
        typingLabel.text = "\"\(phrases[currentPhraseIndex])\""
    }
}

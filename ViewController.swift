import UIKit

extension Notification.Name {
    static let userDataDidChange = Notification.Name("userDataDidChange")
}

// MARK: - Habit Model
struct Habit: Codable {
    let title: String
    var isCompleted: Bool
}

class HomeViewController: UIViewController {

    // MARK: - Constants
    private let accent    = AppColors.primary
    private let textDark  = AppColors.text
    private let textMid   = AppColors.lightText
    private let cardBg    = AppColors.card
    private let pageBg    = AppColors.background
    private let greetingLabel = UILabel()
    
    // MARK: - Phrase
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

    // MARK: - Streak / Progress
    private let habitsProgress = UILabel()
    private let streakNumber   = UILabel()
    private let topLabel       = UILabel()

    private let streakKey        = "currentStreak"
    private let topStreakKey      = "topStreak"
    private let lastStreakDateKey = "lastStreakDate"
    private let lastResetKey      = "lastHabitResetDate"

    private var currentStreak: Int {
        get { UserDefaults.standard.integer(forKey: streakKey) }
        set { UserDefaults.standard.set(newValue, forKey: streakKey) }
    }
    private var topStreak: Int {
        get { UserDefaults.standard.integer(forKey: topStreakKey) }
        set { UserDefaults.standard.set(newValue, forKey: topStreakKey) }
    }
    private var lastStreakDate: Date? {
        get { UserDefaults.standard.object(forKey: lastStreakDateKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: lastStreakDateKey) }
    }

    // MARK: - Habits
    private var habits: [Habit] = [] {
        didSet { saveHabits(); reloadHabitStack() }
    }
    private let habitsContainerCard = UIView()
    private let habitStack = UIStackView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupUI()
        loadHabits()
        resetHabitsIfNeeded()
        updateStreak()
        updateHabitsProgress()
        setupProfileButton()
        loadHabits()
        updateHabitsProgress()
        
        NotificationCenter.default.addObserver(self,
                                                   selector: #selector(refreshGreeting),
                                                   name: .userDataDidChange,
                                                   object: nil)
    }
    
    // MARK: - Navigation
    @objc private func profileButtonTapped() {
        let profileVC = ProfileViewController()
        profileVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc private func refreshGreeting() {
        let savedName = UserDefaults.standard.string(forKey: "userName") ?? "Анастасия"
        greetingLabel.text = "Привет, \(savedName)"
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Profile Button
    private func setupProfileButton() {
        navigationItem.title = ""
        title = ""
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let profileImage = UIImage(systemName: "person.circle", withConfiguration: config)
        let profileButton = UIBarButtonItem(
            image: profileImage,
            style: .plain,
            target: self,
            action: #selector(profileButtonTapped)
        )
        
        profileButton.tintColor = accent
        navigationItem.rightBarButtonItem = profileButton
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    // MARK: - Streak
    private func updateStreak() {
        let calendar = Calendar.current
        if let last = lastStreakDate {
            if calendar.isDateInYesterday(last)     { currentStreak += 1 }
            else if !calendar.isDateInToday(last)   { currentStreak = 1 }
        } else { currentStreak = 1 }
        if currentStreak > topStreak { topStreak = currentStreak }
        lastStreakDate = Date()
        streakNumber.text = "\(currentStreak)"
        topLabel.text = "Топ: \(topStreak)"
    }

    private func resetHabitsIfNeeded() {
        let calendar = Calendar.current
        let today = Date()
        if let last = UserDefaults.standard.object(forKey: lastResetKey) as? Date {
            if !calendar.isDate(last, inSameDayAs: today) {
                habits = habits.map { Habit(title: $0.title, isCompleted: false) }
                UserDefaults.standard.set(today, forKey: lastResetKey)
                saveHabits()
            }
        } else {
            UserDefaults.standard.set(today, forKey: lastResetKey)
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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

        // ── Logo ──
        let logoLabel = UILabel()
        let attributed = NSMutableAttributedString(string: "SEREVIA")
        attributed.addAttribute(.kern, value: 8, range: NSRange(location: 0, length: attributed.length))
        logoLabel.attributedText = attributed
        logoLabel.font = .systemFont(ofSize: 32, weight: .bold)
        logoLabel.textColor = textDark
        logoLabel.textAlignment = .center

        // ── Greeting ──
        let savedName = UserDefaults.standard.string(forKey: "userName") ?? "Гость"
        greetingLabel.text = "Привет, \(savedName)"
        greetingLabel.font = .systemFont(ofSize: 20, weight: .regular)
        greetingLabel.textColor = textMid
        greetingLabel.textAlignment = .center

        // ── Quote card ──
        let quoteCard = makeCard()
        quoteCard.clipsToBounds = true

        let flowerBackground = UIImageView()
        flowerBackground.image = UIImage(named: "floral_pattern")
        flowerBackground.contentMode = .scaleAspectFill
        flowerBackground.alpha = 0.2
        flowerBackground.translatesAutoresizingMaskIntoConstraints = false
        quoteCard.addSubview(flowerBackground)

        typingLabel.text = phrases.first
        typingLabel.font = .systemFont(ofSize: 18, weight: .medium).italic()
        typingLabel.textColor = textDark
        typingLabel.numberOfLines = 0
        typingLabel.textAlignment = .left

        let morePhraseButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let refreshImage = UIImage(systemName: "arrow.clockwise", withConfiguration: config)
        morePhraseButton.setImage(refreshImage, for: .normal)
                
        morePhraseButton.tintColor = textMid
        morePhraseButton.backgroundColor = accent.withAlphaComponent(0.12)
                
        morePhraseButton.layer.cornerRadius = 14
        morePhraseButton.translatesAutoresizingMaskIntoConstraints = false
        morePhraseButton.addTarget(self, action: #selector(nextPhrase), for: .touchUpInside)

        let horizontalStack = UIStackView(arrangedSubviews: [typingLabel, morePhraseButton])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 12
        horizontalStack.alignment = .center
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        quoteCard.addSubview(horizontalStack)

        NSLayoutConstraint.activate([
            flowerBackground.topAnchor.constraint(equalTo: quoteCard.topAnchor),
            flowerBackground.leadingAnchor.constraint(equalTo: quoteCard.leadingAnchor),
            flowerBackground.trailingAnchor.constraint(equalTo: quoteCard.trailingAnchor),
            flowerBackground.bottomAnchor.constraint(equalTo: quoteCard.bottomAnchor),

            quoteCard.heightAnchor.constraint(equalToConstant: 80),

            morePhraseButton.widthAnchor.constraint(equalToConstant: 42),
            morePhraseButton.heightAnchor.constraint(equalToConstant: 42),

            horizontalStack.leadingAnchor.constraint(equalTo: quoteCard.leadingAnchor, constant: 20),
            horizontalStack.trailingAnchor.constraint(equalTo: quoteCard.trailingAnchor, constant: -16),
            horizontalStack.centerYAnchor.constraint(equalTo: quoteCard.centerYAnchor)
        ])
        
        // ── Habits mini card ──
        let habitsCard = makeCard()
        habitsCard.clipsToBounds = true
        habitsCard.heightAnchor.constraint(equalToConstant: 110).isActive = true

        let habitsPattern = UIImageView()
        habitsPattern.image = UIImage(named: "floral_pattern")
        habitsPattern.contentMode = .scaleAspectFill
        habitsPattern.alpha = 0.2
        habitsPattern.translatesAutoresizingMaskIntoConstraints = false
        habitsPattern.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        habitsCard.addSubview(habitsPattern)

        let habitsTitle = makeSmallLabel("Привычки")
        habitsTitle.textAlignment = .center
                
        habitsProgress.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        habitsProgress.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        habitsProgress.textAlignment = .center

        let habitsSubtitle = makeSmallLabel("Сегодня")
        habitsSubtitle.textAlignment = .center
        habitsSubtitle.translatesAutoresizingMaskIntoConstraints = false

        let habitsInnerStack = UIStackView(arrangedSubviews: [habitsTitle, habitsProgress])
        habitsInnerStack.axis = .vertical
        habitsInnerStack.spacing = 2
        habitsInnerStack.alignment = .center
        habitsInnerStack.translatesAutoresizingMaskIntoConstraints = false

        habitsCard.addSubview(habitsInnerStack)
        habitsCard.addSubview(habitsSubtitle)

        NSLayoutConstraint.activate([
            habitsPattern.topAnchor.constraint(equalTo: habitsCard.topAnchor),
            habitsPattern.leadingAnchor.constraint(equalTo: habitsCard.leadingAnchor),
            habitsPattern.trailingAnchor.constraint(equalTo: habitsCard.trailingAnchor),
            habitsPattern.bottomAnchor.constraint(equalTo: habitsCard.bottomAnchor),

            habitsInnerStack.topAnchor.constraint(equalTo: habitsCard.topAnchor, constant: 14),
            habitsInnerStack.leadingAnchor.constraint(equalTo: habitsCard.leadingAnchor, constant: 16),
            habitsInnerStack.trailingAnchor.constraint(equalTo: habitsCard.trailingAnchor, constant: -16),
            
            habitsSubtitle.centerXAnchor.constraint(equalTo: habitsCard.centerXAnchor),
            habitsSubtitle.bottomAnchor.constraint(equalTo: habitsCard.bottomAnchor, constant: -14)
        ])

        // ── Streak card ──
        let streakCard = makeCard()
        streakCard.clipsToBounds = true

        let streakPattern = UIImageView()
        streakPattern.image = UIImage(named: "floral_pattern")
        streakPattern.contentMode = .scaleAspectFill
        streakPattern.alpha = 0.2
        streakPattern.translatesAutoresizingMaskIntoConstraints = false
        streakPattern.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        streakCard.addSubview(streakPattern)

        let streakTitle = makeSmallLabel("Дней подряд")
        streakTitle.textAlignment = .center

        streakNumber.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        streakNumber.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        streakNumber.textAlignment = .center

        topLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        topLabel.textColor = UIColor(red: 0.56, green: 0.47, blue: 0.38, alpha: 1)
        topLabel.textAlignment = .center
        topLabel.translatesAutoresizingMaskIntoConstraints = false

        let streakInnerStack = UIStackView(arrangedSubviews: [streakTitle, streakNumber])
        streakInnerStack.axis = .vertical
        streakInnerStack.spacing = 2
        streakInnerStack.alignment = .center
        streakInnerStack.translatesAutoresizingMaskIntoConstraints = false

        streakCard.addSubview(streakInnerStack)
        streakCard.addSubview(topLabel)

        NSLayoutConstraint.activate([
            streakPattern.topAnchor.constraint(equalTo: streakCard.topAnchor),
            streakPattern.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor),
            streakPattern.trailingAnchor.constraint(equalTo: streakCard.trailingAnchor),
            streakPattern.bottomAnchor.constraint(equalTo: streakCard.bottomAnchor),

            streakInnerStack.topAnchor.constraint(equalTo: streakCard.topAnchor, constant: 14),
            streakInnerStack.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor, constant: 16),
            streakInnerStack.trailingAnchor.constraint(equalTo: streakCard.trailingAnchor, constant: -16),
                    
            topLabel.centerXAnchor.constraint(equalTo: streakCard.centerXAnchor),
            topLabel.bottomAnchor.constraint(equalTo: streakCard.bottomAnchor, constant: -14)
        ])

        let statsRow = UIStackView(arrangedSubviews: [habitsCard, streakCard])
        statsRow.axis = .horizontal
        statsRow.distribution = .fillEqually
        statsRow.spacing = 14

        // ── Habits container card ──
        setupHabitBlock()

        // ── Diary button (no card wrapper) ──
        let diaryButton = UIButton(type: .system)
        diaryButton.setTitle("Мой дневник", for: .normal)
        diaryButton.setTitleColor(.white, for: .normal)
        diaryButton.backgroundColor = accent
        diaryButton.layer.cornerRadius = 16
        diaryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        diaryButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        diaryButton.addTarget(self, action: #selector(openDiary), for: .touchUpInside)
        diaryButton.translatesAutoresizingMaskIntoConstraints = false

        // ── Main stack ──
        let mainStack = UIStackView(arrangedSubviews: [
            logoLabel,
            greetingLabel,
            quoteCard,
            statsRow,
            habitsContainerCard,
            diaryButton
        ])
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 24, right: 20)
        contentView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Helpers
    private func makeCard() -> UIView {
        let v = UIView()
        v.backgroundColor = cardBg
        v.layer.cornerRadius = 22
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.04
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 6
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    private func makeSmallLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = textMid
        return l
    }

    // MARK: - Habit Block
    private func setupHabitBlock() {
        habitsContainerCard.backgroundColor = cardBg
        habitsContainerCard.layer.cornerRadius = 22
        habitsContainerCard.layer.shadowColor = UIColor.black.cgColor
        habitsContainerCard.layer.shadowOpacity = 0.04
        habitsContainerCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        habitsContainerCard.layer.shadowRadius = 6
        habitsContainerCard.clipsToBounds = true
        habitsContainerCard.translatesAutoresizingMaskIntoConstraints = false

        if let originalImage = UIImage(named: "floral_pattern") {
            let newSize = CGSize(width: originalImage.size.width / 2.5,
                                height: originalImage.size.height / 2.5)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            originalImage.draw(in: CGRect(origin: .zero, size: newSize))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let smallerImage = scaledImage {
                habitsContainerCard.backgroundColor = UIColor(patternImage: smallerImage)
            } else {
                habitsContainerCard.backgroundColor = UIColor(patternImage: originalImage)
            }
        }
        
        let overlayView = UIView()
        overlayView.backgroundColor = cardBg
        overlayView.alpha = 0.8
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        habitsContainerCard.addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: habitsContainerCard.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: habitsContainerCard.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: habitsContainerCard.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: habitsContainerCard.bottomAnchor)
        ])

        let titleLabel = UILabel()
        titleLabel.text = "Мои привычки"
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = textDark

        let addButton = UIButton(type: .system)
        addButton.setTitle("+ Добавить привычку", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = accent
        addButton.layer.cornerRadius = 14
        addButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        addButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
        addButton.addTarget(self, action: #selector(addHabit), for: .touchUpInside)

        habitStack.axis = .vertical
        habitStack.spacing = 2
        habitStack.translatesAutoresizingMaskIntoConstraints = false

        let containerStack = UIStackView(arrangedSubviews: [titleLabel, habitStack, addButton])
        containerStack.axis = .vertical
        containerStack.spacing = 12
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        habitsContainerCard.addSubview(containerStack)
        
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: habitsContainerCard.topAnchor, constant: 20),
            containerStack.leadingAnchor.constraint(equalTo: habitsContainerCard.leadingAnchor, constant: 20),
            containerStack.trailingAnchor.constraint(equalTo: habitsContainerCard.trailingAnchor, constant: -20),
            containerStack.bottomAnchor.constraint(equalTo: habitsContainerCard.bottomAnchor, constant: -20)
        ])
    }

    private func reloadHabitStack() {
        habitStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, habit) in habits.enumerated() {
            let row = UIView()
            row.translatesAutoresizingMaskIntoConstraints = false

            let indicator = UIView()
            indicator.layer.cornerRadius = 11
            indicator.layer.borderWidth = 1.5
            indicator.translatesAutoresizingMaskIntoConstraints = false

            if habit.isCompleted {
                indicator.backgroundColor = accent
                indicator.layer.borderColor = accent.cgColor
                let check = UILabel()
                check.text = "✓"
                check.font = .systemFont(ofSize: 11, weight: .bold)
                check.textColor = .white
                check.textAlignment = .center
                check.translatesAutoresizingMaskIntoConstraints = false
                indicator.addSubview(check)
                NSLayoutConstraint.activate([
                    check.centerXAnchor.constraint(equalTo: indicator.centerXAnchor),
                    check.centerYAnchor.constraint(equalTo: indicator.centerYAnchor)
                ])
            } else {
                indicator.backgroundColor = .clear
                indicator.layer.borderColor = UIColor(red: 0.76, green: 0.68, blue: 0.58, alpha: 1).cgColor
            }

            let titleLabel = UILabel()
            titleLabel.text = habit.title
            titleLabel.font = .systemFont(ofSize: 15, weight: habit.isCompleted ? .regular : .medium)
            titleLabel.textColor = habit.isCompleted ? textMid : textDark
            if habit.isCompleted {
                let attr = NSAttributedString(string: habit.title, attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: textMid
                ])
                titleLabel.attributedText = attr
            }
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            row.addSubview(indicator)
            row.addSubview(titleLabel)
            NSLayoutConstraint.activate([
                indicator.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                indicator.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                indicator.widthAnchor.constraint(equalToConstant: 22),
                indicator.heightAnchor.constraint(equalToConstant: 22),
                titleLabel.leadingAnchor.constraint(equalTo: indicator.trailingAnchor, constant: 12),
                titleLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                row.heightAnchor.constraint(equalToConstant: 44)
            ])

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleHabitRow(_:)))
            tapGesture.view?.tag = index
            row.tag = index
            row.addGestureRecognizer(tapGesture)
            row.isUserInteractionEnabled = true

            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            row.addGestureRecognizer(longPress)

            habitStack.addArrangedSubview(row)

            if index < habits.count - 1 {
                let divider = UIView()
                divider.backgroundColor = UIColor(red: 0.90, green: 0.87, blue: 0.82, alpha: 1)
                divider.translatesAutoresizingMaskIntoConstraints = false
                divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
                habitStack.addArrangedSubview(divider)
            }
        }
        updateHabitsProgress()
    }

    @objc private func toggleHabitRow(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        let index = view.tag
        habits[index].isCompleted.toggle()
        reloadHabitStack()
    }

    @objc private func toggleHabit(_ sender: UIButton) {
        habits[sender.tag].isCompleted.toggle()
        reloadHabitStack()
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let view = gesture.view else { return }
        let index = view.tag
        guard index < habits.count else { return }
        let alert = UIAlertController(title: "Удалить привычку?", message: "«\(habits[index].title)»", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.habits.remove(at: index)
            self?.updateHabitsProgress()
        })
        present(alert, animated: true)
    }

    private func updateHabitsProgress() {
        let completed = habits.filter { $0.isCompleted }.count
        habitsProgress.text = "\(completed) / \(habits.count)"
    }

    // MARK: - Actions
    @objc private func nextPhrase() {
        currentPhraseIndex = (currentPhraseIndex + 1) % phrases.count
        UIView.transition(with: typingLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.typingLabel.text = self.phrases[self.currentPhraseIndex]
        }
    }

    @objc private func addHabit() {
        let alert = UIAlertController(title: "Новая привычка", message: "Введите название", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Название привычки" }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text, !text.isEmpty else { return }
            self?.habits.append(Habit(title: text, isCompleted: false))
            self?.updateHabitsProgress()
        })
        present(alert, animated: true)
    }

    @objc private func openDiary() {
        let vc = DiaryListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Persistence
    private func saveHabits() {
        if let data = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(data, forKey: "habits")
        }
    }

    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: "habits"),
           let saved = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = saved
        }
    }
}

extension UIFont {
    func italic() -> UIFont {
        return self.withTraits(traits: .traitItalic)
    }

    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0)
    }
}

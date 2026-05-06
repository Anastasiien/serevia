import UIKit

extension Notification.Name {
    static let userDataDidChange = Notification.Name("userDataDidChange")
    static let wishMapDidUpdate  = Notification.Name("wishMapDidUpdate")
}

struct Habit: Codable {
    let title: String
    var isCompleted: Bool
}

class HomeViewController: UIViewController {

    private let accent    = AppColors.primary
    private let textDark  = AppColors.text
    private let textMid   = AppColors.lightText
    private let cardBg    = AppColors.card
    private let pageBg    = AppColors.background
    private let greetingLabel = UILabel()

    private let typingLabel = UILabel()
    private var currentPhraseIndex = 0
    private var phraseTimer: Timer?
    private let phraseIndexKey = "savedPhraseIndex"
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

    private var habits: [Habit] = [] {
        didSet { saveHabits(); reloadHabitStack() }
    }
    private let habitsContainerCard = UIView()
    private let habitStack = UIStackView()

    // wish map — скрыта если нет картинки
    private let wishMapCard = UIView()
    private let wishMapImageView = UIImageView()

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

        NotificationCenter.default.addObserver(self, selector: #selector(refreshGreeting), name: .userDataDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshWishMap), name: .wishMapDidUpdate, object: nil)

        rotatePhraseOnAppear()
        startPhraseTimer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshWishMap()
        rotatePhraseOnAppear()
    }

    // меняем фразу при каждом заходе, индекс сохраняется между сессиями
    private func rotatePhraseOnAppear() {
        let saved = UserDefaults.standard.integer(forKey: phraseIndexKey)
        let next = (saved + 1) % phrases.count
        currentPhraseIndex = next
        UserDefaults.standard.set(next, forKey: phraseIndexKey)
        UIView.transition(with: typingLabel, duration: 0.4, options: .transitionCrossDissolve) {
            self.typingLabel.text = self.phrases[self.currentPhraseIndex]
        }
    }

    // дополнительно меняем каждые 2 часа пока приложение открыто
    private func startPhraseTimer() {
        phraseTimer?.invalidate()
        phraseTimer = Timer.scheduledTimer(withTimeInterval: 2 * 60 * 60, repeats: true) { [weak self] _ in
            self?.rotatePhraseOnAppear()
        }
    }

    @objc private func profileButtonTapped() {
        let profileVC = ProfileViewController()
        profileVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profileVC, animated: true)
    }

    @objc private func refreshGreeting() {
        let savedName = UserDefaults.standard.string(forKey: "userName") ?? "Анастасия"
        greetingLabel.text = "Привет, \(savedName)"
    }

    // FIX 1: показываем карту только если есть сохранённое изображение
    @objc private func refreshWishMap() {
        if let data = UserDefaults.standard.data(forKey: "wishMapImage"),
           let image = UIImage(data: data) {
            wishMapImageView.image = image
            wishMapCard.isHidden = false
        } else {
            wishMapCard.isHidden = true
        }
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func setupProfileButton() {
        title = "Home"
        navigationItem.title = ""
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let profileImage = UIImage(systemName: "person.circle", withConfiguration: config)
        let profileButton = UIBarButtonItem(image: profileImage, style: .plain, target: self, action: #selector(profileButtonTapped))
        profileButton.tintColor = accent
        navigationItem.rightBarButtonItem = profileButton
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    private func updateStreak() {
        let calendar = Calendar.current
        if let last = lastStreakDate {
            if calendar.isDateInYesterday(last)   { currentStreak += 1 }
            else if !calendar.isDateInToday(last) { currentStreak = 1 }
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

        // FIX 4: дата сверху + логотип + приветствие + разделитель
        let dateLabel = UILabel()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE, d MMMM"
        let raw = formatter.string(from: Date())
        dateLabel.text = raw.prefix(1).uppercased() + raw.dropFirst()
        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = textMid.withAlphaComponent(0.7)
        dateLabel.textAlignment = .center

        let logoLabel = UILabel()
        let attributed = NSMutableAttributedString(string: "SEREVIA")
        attributed.addAttribute(.kern, value: 8, range: NSRange(location: 0, length: attributed.length))
        logoLabel.attributedText = attributed
        logoLabel.font = .systemFont(ofSize: 32, weight: .bold)
        logoLabel.textColor = textDark
        logoLabel.textAlignment = .center

        let savedName = UserDefaults.standard.string(forKey: "userName") ?? "Гость"
        greetingLabel.text = "Привет, \(savedName)"
        greetingLabel.font = .systemFont(ofSize: 20, weight: .regular)
        greetingLabel.textColor = textMid
        greetingLabel.textAlignment = .center

        let headerDivider = UIView()
        headerDivider.backgroundColor = UIColor(red: 0.76, green: 0.68, blue: 0.58, alpha: 0.2)
        headerDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        headerDivider.translatesAutoresizingMaskIntoConstraints = false

        let headerStack = UIStackView(arrangedSubviews: [dateLabel, logoLabel, greetingLabel, headerDivider])
        headerStack.axis = .vertical
        headerStack.spacing = 4
        headerStack.setCustomSpacing(14, after: greetingLabel)

        // ── Quote card ──
        let quoteCard = makeCard()
        quoteCard.clipsToBounds = true
        let flowerBg = UIImageView()
        flowerBg.image = UIImage(named: "floral_pattern")
        flowerBg.contentMode = .scaleAspectFill
        flowerBg.alpha = 0.2
        flowerBg.translatesAutoresizingMaskIntoConstraints = false
        quoteCard.addSubview(flowerBg)

        typingLabel.text = phrases.first
        typingLabel.font = .systemFont(ofSize: 18, weight: .medium).italic()
        typingLabel.textColor = textDark
        typingLabel.numberOfLines = 0

        let refreshBtn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        refreshBtn.setImage(UIImage(systemName: "arrow.clockwise", withConfiguration: cfg), for: .normal)
        refreshBtn.tintColor = textMid
        refreshBtn.backgroundColor = accent.withAlphaComponent(0.12)
        refreshBtn.layer.cornerRadius = 14
        refreshBtn.translatesAutoresizingMaskIntoConstraints = false
        refreshBtn.addTarget(self, action: #selector(nextPhrase), for: .touchUpInside)

        let quoteRow = UIStackView(arrangedSubviews: [typingLabel, refreshBtn])
        quoteRow.axis = .horizontal
        quoteRow.spacing = 12
        quoteRow.alignment = .center
        quoteRow.translatesAutoresizingMaskIntoConstraints = false
        quoteCard.addSubview(quoteRow)

        NSLayoutConstraint.activate([
            flowerBg.topAnchor.constraint(equalTo: quoteCard.topAnchor),
            flowerBg.leadingAnchor.constraint(equalTo: quoteCard.leadingAnchor),
            flowerBg.trailingAnchor.constraint(equalTo: quoteCard.trailingAnchor),
            flowerBg.bottomAnchor.constraint(equalTo: quoteCard.bottomAnchor),
            quoteCard.heightAnchor.constraint(equalToConstant: 80),
            refreshBtn.widthAnchor.constraint(equalToConstant: 42),
            refreshBtn.heightAnchor.constraint(equalToConstant: 42),
            quoteRow.leadingAnchor.constraint(equalTo: quoteCard.leadingAnchor, constant: 20),
            quoteRow.trailingAnchor.constraint(equalTo: quoteCard.trailingAnchor, constant: -16),
            quoteRow.centerYAnchor.constraint(equalTo: quoteCard.centerYAnchor)
        ])

        // ── Stats row ──
        let habitsCard  = makeFloralMiniCard(top: "Привычки", bottom: "Сегодня", big: habitsProgress)
        let streakCardView = makeFloralMiniCard(top: "Дней подряд", bottom: "", big: streakNumber)
        streakCardView.addSubview(topLabel)
        topLabel.font = .systemFont(ofSize: 14, weight: .regular)
        topLabel.textColor = UIColor(red: 0.56, green: 0.47, blue: 0.38, alpha: 1)
        topLabel.textAlignment = .center
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topLabel.centerXAnchor.constraint(equalTo: streakCardView.centerXAnchor),
            topLabel.bottomAnchor.constraint(equalTo: streakCardView.bottomAnchor, constant: -14)
        ])

        let statsRow = UIStackView(arrangedSubviews: [habitsCard, streakCardView])
        statsRow.axis = .horizontal
        statsRow.distribution = .fillEqually
        statsRow.spacing = 14

        // ── Habits container ──
        setupHabitBlock()

        // ── Wish map card ──
        wishMapCard.backgroundColor = pageBg
        wishMapCard.layer.cornerRadius = 22
        wishMapCard.layer.shadowColor  = UIColor.black.cgColor
        wishMapCard.layer.shadowOpacity = 0.06
        wishMapCard.layer.shadowOffset  = CGSize(width: 0, height: 2)
        wishMapCard.layer.shadowRadius  = 8
        wishMapCard.layer.masksToBounds = false
        wishMapCard.translatesAutoresizingMaskIntoConstraints = false
        wishMapCard.isHidden = true


        // ── Wish map card ──
                // Настраиваем основной контейнер карточки (с рамкой как в редакторе)
                wishMapCard.backgroundColor = AppColors.card
                wishMapCard.layer.cornerRadius = 16
                wishMapCard.layer.borderWidth = 1
                wishMapCard.layer.borderColor = AppColors.primary.cgColor
                wishMapCard.layer.shadowOpacity = 0 // Убираем тень для соответствия WishMapEditorViewController
                wishMapCard.translatesAutoresizingMaskIntoConstraints = false
                wishMapCard.isHidden = true // По умолчанию скрыта, пока refreshWishMap() не найдет фото

                // Создаем внутренний слой для обрезки фото по углам
                let wishMapClipView = UIView()
                wishMapClipView.layer.cornerRadius = 16
                wishMapClipView.clipsToBounds = true
                wishMapClipView.translatesAutoresizingMaskIntoConstraints = false
                wishMapCard.addSubview(wishMapClipView)

                // Настраиваем саму картинку
                wishMapImageView.contentMode = .scaleAspectFill
                wishMapImageView.clipsToBounds = true
                wishMapImageView.translatesAutoresizingMaskIntoConstraints = false // Нужно для работы констрейнтов
                wishMapClipView.addSubview(wishMapImageView)

                // Активируем констрейнты для корректного отображения размеров
                NSLayoutConstraint.activate([
                    // Соотношение сторон 4:3 как в редакторе[cite: 2]
                    wishMapCard.heightAnchor.constraint(equalTo: wishMapCard.widthAnchor, multiplier: 3.0/4.0),
                    
                    // Растягиваем контейнер обрезки на всю карточку
                    wishMapClipView.topAnchor.constraint(equalTo: wishMapCard.topAnchor),
                    wishMapClipView.leadingAnchor.constraint(equalTo: wishMapCard.leadingAnchor),
                    wishMapClipView.trailingAnchor.constraint(equalTo: wishMapCard.trailingAnchor),
                    wishMapClipView.bottomAnchor.constraint(equalTo: wishMapCard.bottomAnchor),
                    
                    // Растягиваем картинку на весь контейнер
                    wishMapImageView.topAnchor.constraint(equalTo: wishMapClipView.topAnchor),
                    wishMapImageView.leadingAnchor.constraint(equalTo: wishMapClipView.leadingAnchor),
                    wishMapImageView.trailingAnchor.constraint(equalTo: wishMapClipView.trailingAnchor),
                    wishMapImageView.bottomAnchor.constraint(equalTo: wishMapClipView.bottomAnchor)
                ])

        // ── Diary button ──
        let diaryButton = UIButton(type: .system)
        diaryButton.setTitle("Мой дневник", for: .normal)
        diaryButton.setTitleColor(.white, for: .normal)
        diaryButton.backgroundColor = accent
        diaryButton.layer.cornerRadius = 16
        diaryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        diaryButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        diaryButton.addTarget(self, action: #selector(openDiary), for: .touchUpInside)

        let mainStack = UIStackView(arrangedSubviews: [
            headerStack, quoteCard, statsRow,
            habitsContainerCard, wishMapCard, diaryButton
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

        refreshWishMap()
    }

    // мини-карточка для статистики (привычки / стрик) с floral фоном
    private func makeFloralMiniCard(top: String, bottom: String, big: UILabel) -> UIView {
        let card = makeCard()
        card.clipsToBounds = true
        card.heightAnchor.constraint(equalToConstant: 110).isActive = true

        let pattern = UIImageView()
        pattern.image = UIImage(named: "floral_pattern")
        pattern.contentMode = .scaleAspectFill
        pattern.alpha = 0.2
        pattern.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        pattern.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(pattern)

        let topLbl = makeSmallLabel(top)
        topLbl.textAlignment = .center
        big.font = .systemFont(ofSize: 30, weight: .bold)
        big.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        big.textAlignment = .center

        let inner = UIStackView(arrangedSubviews: [topLbl, big])
        inner.axis = .vertical
        inner.spacing = 2
        inner.alignment = .center
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)

        if !bottom.isEmpty {
            let botLbl = makeSmallLabel(bottom)
            botLbl.textAlignment = .center
            botLbl.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(botLbl)
            NSLayoutConstraint.activate([
                botLbl.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                botLbl.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
            ])
        }

        NSLayoutConstraint.activate([
            pattern.topAnchor.constraint(equalTo: card.topAnchor),
            pattern.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            pattern.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            pattern.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16)
        ])
        return card
    }

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

    private func setupHabitBlock() {
        habitsContainerCard.backgroundColor = cardBg
        habitsContainerCard.layer.cornerRadius = 22
        habitsContainerCard.layer.shadowColor = UIColor.black.cgColor
        habitsContainerCard.layer.shadowOpacity = 0.04
        habitsContainerCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        habitsContainerCard.layer.shadowRadius = 6
        habitsContainerCard.clipsToBounds = true
        habitsContainerCard.translatesAutoresizingMaskIntoConstraints = false

        if let orig = UIImage(named: "floral_pattern") {
            let sz = CGSize(width: orig.size.width / 2.5, height: orig.size.height / 2.5)
            UIGraphicsBeginImageContextWithOptions(sz, false, 0)
            orig.draw(in: CGRect(origin: .zero, size: sz))
            let scaled = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            habitsContainerCard.backgroundColor = UIColor(patternImage: scaled ?? orig)
        }

        let overlay = UIView()
        overlay.backgroundColor = cardBg
        overlay.alpha = 0.8
        overlay.translatesAutoresizingMaskIntoConstraints = false
        habitsContainerCard.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: habitsContainerCard.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: habitsContainerCard.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: habitsContainerCard.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: habitsContainerCard.bottomAnchor)
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

        let cs = UIStackView(arrangedSubviews: [titleLabel, habitStack, addButton])
        cs.axis = .vertical
        cs.spacing = 12
        cs.translatesAutoresizingMaskIntoConstraints = false
        habitsContainerCard.addSubview(cs)
        NSLayoutConstraint.activate([
            cs.topAnchor.constraint(equalTo: habitsContainerCard.topAnchor, constant: 20),
            cs.leadingAnchor.constraint(equalTo: habitsContainerCard.leadingAnchor, constant: 20),
            cs.trailingAnchor.constraint(equalTo: habitsContainerCard.trailingAnchor, constant: -20),
            cs.bottomAnchor.constraint(equalTo: habitsContainerCard.bottomAnchor, constant: -20)
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
            titleLabel.font = .systemFont(ofSize: 15, weight: habit.isCompleted ? .regular : .medium)
            titleLabel.textColor = habit.isCompleted ? textMid : textDark
            if habit.isCompleted {
                titleLabel.attributedText = NSAttributedString(string: habit.title, attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: textMid
                ])
            } else {
                titleLabel.text = habit.title
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

            row.tag = index
            row.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(toggleHabitRow(_:)))
            row.addGestureRecognizer(tap)
            let lp = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            row.addGestureRecognizer(lp)
            habitStack.addArrangedSubview(row)

            if index < habits.count - 1 {
                let div = UIView()
                div.backgroundColor = UIColor(red: 0.90, green: 0.87, blue: 0.82, alpha: 1)
                div.translatesAutoresizingMaskIntoConstraints = false
                div.heightAnchor.constraint(equalToConstant: 1).isActive = true
                habitStack.addArrangedSubview(div)
            }
        }
        updateHabitsProgress()
    }

    @objc private func toggleHabitRow(_ gesture: UITapGestureRecognizer) {
        guard let v = gesture.view else { return }
        habits[v.tag].isCompleted.toggle()
        reloadHabitStack()
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let v = gesture.view, v.tag < habits.count else { return }
        let alert = UIAlertController(title: "Удалить привычку?", message: "«\(habits[v.tag].title)»", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.habits.remove(at: v.tag)
            self?.updateHabitsProgress()
        })
        present(alert, animated: true)
    }

    private func updateHabitsProgress() {
        let completed = habits.filter { $0.isCompleted }.count
        habitsProgress.text = "\(completed) / \(habits.count)"
    }

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
    func italic() -> UIFont { withTraits(traits: .traitItalic) }
    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        UIFont(descriptor: fontDescriptor.withSymbolicTraits(traits)!, size: 0)
    }
}

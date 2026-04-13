import UIKit
import AVFoundation

class MeditateViewController: UIViewController {

    // MARK: - Properties
    private var selectedTime: Int = 10
    private var timer: Timer?
    private var remainingSeconds = 0
    private var favorites: Set<String> = []
    private var audioPlayer: AVAudioPlayer?

    private enum Sound: String, CaseIterable {
        case whiteNoise       = "Белый шум"
        case rain             = "Дождь"
        case sea              = "Шум моря"
        case birds            = "Пение птиц"
        case train            = "Шум поезда"
        case airplane         = "Шум полета"
        case cat              = "Мурчание"
        case zenBells         = "Звон"
        case fireplace        = "Камин"
        case stream           = "Ручей"
        case tibetanBowls     = "Чаши"
        case japan            = "Япония"
        case africa           = "Африка"
        case loFi             = "Lo-Fi"
        case djaz             = "Джаз"

        var icon: String {
            switch self {
            case .whiteNoise:       return "📻"
            case .rain:             return "🌧"
            case .sea:              return "🌊"
            case .birds:            return "🐦"
            case .train:            return "🚆"
            case .airplane:         return "✈️"
            case .cat:              return "🐈"
            case .zenBells:         return "🔔"
            case .fireplace:        return "🔥"
            case .stream:           return "🌿"
            case .tibetanBowls:     return "🧘‍♂️"
            case .japan:            return "🎴"
            case .africa:           return "🪘"
            case .loFi:             return "🎧"
            case .djaz:             return "🎶"
            }
        }
    }

    private var timerCard: UIView!
    private var selectedSound: Sound = .rain
    private var timerLabel = UILabel()
    private var durationSlider = UISlider()
    private var soundScrollView = UIScrollView()
    private var categoriesScrollView: UIScrollView!
    private var categoriesStack: UIStackView!
    private let categories = ["Все", "Избранное", "Сон", "Расслабление", "Фокус"]
    private var selectedCategory = "Все"
    private var startButton = UIButton(type: .system)
    private var stopButton  = UIButton(type: .system)
    private var meditationsStack = UIStackView()

    private let meditations: [String: [(name: String, duration: Int)]] = [
        "Сон":          [("Мягкое засыпание", 10), ("Покой и тишина", 15), ("Сон природы", 20)],
        "Расслабление": [("Дыхание покоя", 5),    ("Отпустить тревогу", 10), ("Тепло и свет", 12)],
        "Фокус":        [("Сила внимания", 8),     ("Чистота мыслей", 10),   ("Энергия момента", 15)]
    ]

    // MARK: - Active Meditation
    private var activeMeditationTimer: Timer?
    private var activeMeditationSeconds = 0
    private var activePlayButton:    UIButton?
    private var activeCancelButton:  UIButton?
    private var activeDurationLabel: UILabel?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateMeditations()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = AppColors.background

        // MARK: - Заголовок
        let titleLabel = UILabel()
        titleLabel.text = "Медитация"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = AppColors.text

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Найдите внутренний покой"
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = AppColors.lightText

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 6

        // MARK: - Timer Card
        timerCard = createCardView()

        let timerContentStack = UIStackView()
        timerContentStack.axis = .vertical
        timerContentStack.spacing = 14
        timerContentStack.translatesAutoresizingMaskIntoConstraints = false
        timerCard.addSubview(timerContentStack)

        NSLayoutConstraint.activate([
            timerContentStack.topAnchor.constraint(equalTo: timerCard.topAnchor, constant: 22),
            timerContentStack.leadingAnchor.constraint(equalTo: timerCard.leadingAnchor, constant: 20),
            timerContentStack.trailingAnchor.constraint(equalTo: timerCard.trailingAnchor, constant: -20),
            timerContentStack.bottomAnchor.constraint(equalTo: timerCard.bottomAnchor, constant: -22)
        ])

        let timerHeaderStack = UIStackView()
        timerHeaderStack.axis = .horizontal
        timerHeaderStack.distribution = .equalSpacing
        timerHeaderStack.alignment = .center

        let timerTitle = UILabel()
        timerTitle.text = "Время сеанса"
        timerTitle.font = .systemFont(ofSize: 13, weight: .medium)
        timerTitle.textColor = AppColors.lightText
        timerTitle.textAlignment = .left

        timerLabel.text = "\(selectedTime) мин"
        timerLabel.font = .systemFont(ofSize: 20, weight: .bold)
        timerLabel.adjustsFontSizeToFitWidth = true
        timerLabel.minimumScaleFactor = 0.7
        timerLabel.textAlignment = .right
        timerLabel.textColor = AppColors.text

        timerHeaderStack.addArrangedSubview(timerTitle)
        timerHeaderStack.addArrangedSubview(timerLabel)
        timerContentStack.addArrangedSubview(timerHeaderStack)

        durationSlider.minimumValue = 1
        durationSlider.maximumValue = 120
        durationSlider.value = Float(selectedTime)
        durationSlider.tintColor = AppColors.primary
        durationSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        timerContentStack.addArrangedSubview(durationSlider)

        let divider = UIView()
        divider.backgroundColor = AppColors.border
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        timerContentStack.addArrangedSubview(divider)

        let soundTitle = UILabel()
        soundTitle.text = "Мелодия"
        soundTitle.font = .systemFont(ofSize: 13, weight: .medium)
        soundTitle.textColor = AppColors.lightText
        timerContentStack.addArrangedSubview(soundTitle)

        soundScrollView.showsVerticalScrollIndicator = false
        soundScrollView.translatesAutoresizingMaskIntoConstraints = false
        timerContentStack.addArrangedSubview(soundScrollView)

        let buttonHeight: CGFloat = 72
        let rowSpacing:   CGFloat = 8
        let visibleRows:  CGFloat = 3
        soundScrollView.heightAnchor.constraint(
            equalToConstant: visibleRows * buttonHeight + (visibleRows - 1) * rowSpacing
        ).isActive = true
        soundScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)

        let soundGridStack = UIStackView()
        soundGridStack.axis = .vertical
        soundGridStack.spacing = rowSpacing
        soundGridStack.translatesAutoresizingMaskIntoConstraints = false
        soundScrollView.addSubview(soundGridStack)

        NSLayoutConstraint.activate([
            soundGridStack.topAnchor.constraint(equalTo: soundScrollView.topAnchor),
            soundGridStack.bottomAnchor.constraint(equalTo: soundScrollView.bottomAnchor),
            soundGridStack.leadingAnchor.constraint(equalTo: soundScrollView.leadingAnchor),
            soundGridStack.trailingAnchor.constraint(equalTo: soundScrollView.trailingAnchor),
            soundGridStack.widthAnchor.constraint(equalTo: soundScrollView.widthAnchor)
        ])

        var currentRowStack: UIStackView?
        for (index, sound) in Sound.allCases.enumerated() {
            if index % 3 == 0 {
                currentRowStack = UIStackView()
                currentRowStack?.axis = .horizontal
                currentRowStack?.spacing = 8
                currentRowStack?.distribution = .fillEqually
                soundGridStack.addArrangedSubview(currentRowStack!)
            }
            let isSelected = sound == selectedSound
            let button = UIButton(type: .system)
            button.tag = index
            button.setTitle("\(sound.icon)\n\(sound.rawValue)", for: .normal)
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
            button.layer.cornerRadius = 18
            button.layer.borderWidth = isSelected ? 0 : 1
            button.layer.borderColor = AppColors.border.cgColor
            button.backgroundColor = isSelected
                ? AppColors.primary
                : AppColors.background
            button.setTitleColor(isSelected ? .white : AppColors.text, for: .normal)
            button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
            button.addTarget(self, action: #selector(soundSelected(_:)), for: .touchUpInside)
            currentRowStack?.addArrangedSubview(button)
        }

        startButton.setTitle("Начать", for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        startButton.backgroundColor = AppColors.primary
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 16
        startButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        timerContentStack.addArrangedSubview(startButton)

        stopButton.setTitle("⏸  Остановить", for: .normal)
        stopButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        stopButton.setTitleColor(AppColors.primary, for: .normal)
        stopButton.isHidden = true
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        timerContentStack.addArrangedSubview(stopButton)

        // MARK: - Categories
        categoriesScrollView = UIScrollView()
        categoriesScrollView.showsHorizontalScrollIndicator = false
        categoriesScrollView.translatesAutoresizingMaskIntoConstraints = false

        categoriesStack = UIStackView()
        categoriesStack.axis = .horizontal
        categoriesStack.spacing = 8
        categoriesStack.translatesAutoresizingMaskIntoConstraints = false
        categoriesScrollView.addSubview(categoriesStack)

        NSLayoutConstraint.activate([
            categoriesStack.topAnchor.constraint(equalTo: categoriesScrollView.topAnchor),
            categoriesStack.bottomAnchor.constraint(equalTo: categoriesScrollView.bottomAnchor),
            categoriesStack.leadingAnchor.constraint(equalTo: categoriesScrollView.leadingAnchor, constant: 10),
            categoriesStack.trailingAnchor.constraint(equalTo: categoriesScrollView.trailingAnchor, constant: -10),
            categoriesStack.heightAnchor.constraint(equalTo: categoriesScrollView.heightAnchor)
        ])
        setupCategoryButtons()

        let meditationsTitle = UILabel()
        meditationsTitle.text = "Практики"
        meditationsTitle.font = .systemFont(ofSize: 18, weight: .bold)
        meditationsTitle.textColor = AppColors.text

        meditationsStack.axis = .vertical
        meditationsStack.spacing = 10
        meditationsStack.translatesAutoresizingMaskIntoConstraints = false

        let mainStack = UIStackView(arrangedSubviews: [
            headerStack,
            timerCard,
            categoriesScrollView,
            meditationsTitle,
            meditationsStack
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 32, right: 20)

        let pageScrollView = UIScrollView()
        pageScrollView.showsVerticalScrollIndicator = false
        pageScrollView.translatesAutoresizingMaskIntoConstraints = false
        pageScrollView.addSubview(mainStack)
        view.addSubview(pageScrollView)

        NSLayoutConstraint.activate([
            pageScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pageScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            mainStack.topAnchor.constraint(equalTo: pageScrollView.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: pageScrollView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: pageScrollView.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: pageScrollView.bottomAnchor),
            mainStack.widthAnchor.constraint(equalTo: pageScrollView.widthAnchor),

            categoriesScrollView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func lockControls() {
        durationSlider.isUserInteractionEnabled = false
        durationSlider.alpha = 0.4
        soundScrollView.isUserInteractionEnabled = false
        soundScrollView.alpha = 0.4
    }

    private func unlockControls() {
        durationSlider.isUserInteractionEnabled = true
        durationSlider.alpha = 1.0
        soundScrollView.isUserInteractionEnabled = true
        soundScrollView.alpha = 1.0
    }

    // MARK: - Timer Actions
    @objc private func sliderChanged(_ sender: UISlider) {
        selectedTime = Int(sender.value)
        timerLabel.text = "\(selectedTime) мин"
    }

    @objc private func startButtonTapped() {
        if startButton.title(for: .normal) == "Начать" {
            if remainingSeconds > 0 {
                startTimerResume()
                playSound(for: selectedSound)
            } else {
                startMeditation()
            }
            startButton.setTitle("Отменить", for: .normal)
            stopButton.isHidden = false
            stopButton.setTitle("Остановить", for: .normal)
            lockControls()
        } else {
            timer?.invalidate()
            stopSound()
            remainingSeconds = 0
            selectedTime = 1
            durationSlider.value = 1
            timerLabel.text = "1 мин"
            startButton.setTitle("Начать", for: .normal)
            stopButton.isHidden = true
            unlockControls()
        }
    }

    @objc private func soundSelected(_ sender: UIButton) {
        let sound = Sound.allCases[sender.tag]
        selectedSound = sound
        guard let gridStack = sender.superview?.superview as? UIStackView else { return }
        for row in gridStack.arrangedSubviews {
            guard let rowStack = row as? UIStackView else { continue }
            for view in rowStack.arrangedSubviews {
                guard let button = view as? UIButton else { continue }
                let isSelected = button.tag == sender.tag
                button.backgroundColor = isSelected ? AppColors.primary : AppColors.background
                button.setTitleColor(isSelected ? .white : AppColors.text, for: .normal)
                button.layer.borderWidth = isSelected ? 0 : 1
            }
        }
    }

    @objc private func stopButtonTapped() {
        if stopButton.title(for: .normal) == "Остановить" {
            timer?.invalidate()
            audioPlayer?.pause()
            stopButton.setTitle("Продолжить", for: .normal)
        } else {
            startTimerResume()
            audioPlayer?.play()
            stopButton.setTitle("Остановить", for: .normal)
        }
    }

    // MARK: - Timer Logic
    private func startTimerResume() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
                self.updateTimerLabel()
            } else {
                self.timer?.invalidate()
                self.timerLabel.text = "✅ Сеанс завершен"
                self.startButton.setTitle("Начать", for: .normal)
                self.stopButton.isHidden = true
                self.stopSound()
                self.unlockControls()
            }
        }
    }

    private func updateTimerLabel() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        timerLabel.text = String(format: "⏳ %02d:%02d", minutes, seconds)
    }

    private func startMeditation() {
        timer?.invalidate()
        remainingSeconds = selectedTime * 60
        updateTimerLabel()
        playSound(for: selectedSound)
        startTimerResume()
    }

    private func stopSound() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    private func playSound(for sound: Sound) {
        let fileName: String
        switch sound {
        case .whiteNoise:       fileName = "white_noise"
        case .rain:             fileName = "rain"
        case .sea:              fileName = "sea"
        case .birds:            fileName = "birds"
        case .japan:            fileName = "japan"
        case .train:            fileName = "train"
        case .airplane:         fileName = "airplane"
        case .cat:              fileName = "cat"
        case .loFi:             fileName = "lofi"
        case .tibetanBowls:     fileName = "tibetan_bowls"
        case .fireplace:        fileName = "fireplace"
        case .stream:           fileName = "stream"
        case .africa:           fileName = "africa"
        case .zenBells:         fileName = "zen_bells"
        case .djaz:             fileName = "djaz"
        }

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("❌ Ошибка: \(error)")
        }
    }

    private func createCardView() -> UIView {
        let card = UIView()
        card.backgroundColor = AppColors.card
        card.layer.cornerRadius = 22
        card.layer.shadowColor = AppColors.text.cgColor
        card.layer.shadowOpacity = 0.04
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 8
        return card
    }

    // MARK: - Categories
    private func setupCategoryButtons() {
        categoriesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for cat in categories {
            let isActive = cat == selectedCategory
            let button = UIButton(type: .system)
            button.setTitle(cat, for: .normal)
            button.setTitleColor(isActive ? .white : AppColors.text, for: .normal)
            button.backgroundColor = isActive ? AppColors.primary : AppColors.sectionBackground
            button.layer.cornerRadius = 14
            button.layer.borderWidth = isActive ? 0 : 1
            button.layer.borderColor = AppColors.border.cgColor
            button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            button.heightAnchor.constraint(equalToConstant: 36).isActive = true
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 82).isActive = true
            button.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
            categoriesStack.addArrangedSubview(button)
        }
    }

    @objc private func categoryTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        selectedCategory = title
        setupCategoryButtons()
        updateMeditations()
    }

    // MARK: - Meditations Logic (Timers & Handlers)
    private func handleMeditationPlay(
        meditation: (name: String, duration: Int),
        playButton: UIButton,
        cancelButton: UIButton,
        durationLabel: UILabel
    ) {
        stopSound()
        if activeMeditationTimer != nil && activePlayButton != playButton {
            activeMeditationTimer?.invalidate()
            activePlayButton?.setTitle("▶️", for: .normal)
            activeCancelButton?.isHidden = true
            activeDurationLabel?.text = "\(activeMeditationSeconds / 60) мин"
        }
        if activeMeditationTimer == nil {
            activeMeditationSeconds = meditation.duration * 60
            playButton.setTitle("⏸", for: .normal)
            cancelButton.isHidden = false
            durationLabel.text = String(format: "%02d:%02d", activeMeditationSeconds / 60, activeMeditationSeconds % 60)
            startMeditationTimer(playButton: playButton, cancelButton: cancelButton, durationLabel: durationLabel)
        } else {
            activeMeditationTimer?.invalidate()
            activeMeditationTimer = nil
            playButton.setTitle("▶️", for: .normal)
        }
        activePlayButton    = playButton
        activeCancelButton  = cancelButton
        activeDurationLabel = durationLabel
    }

    private func startMeditationTimer(
        playButton: UIButton,
        cancelButton: UIButton,
        durationLabel: UILabel
    ) {
        activeMeditationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.activeMeditationSeconds > 0 {
                self.activeMeditationSeconds -= 1
                durationLabel.text = String(format: "%02d:%02d", self.activeMeditationSeconds / 60, self.activeMeditationSeconds % 60)
            } else {
                self.activeMeditationTimer?.invalidate()
                self.activeMeditationTimer = nil
                playButton.setTitle("▶️", for: .normal)
                cancelButton.isHidden = true
                durationLabel.text = "✅ Завершено"
            }
        }
    }

    private func cancelMeditation(
        playButton: UIButton,
        cancelButton: UIButton,
        durationLabel: UILabel,
        duration: Int
    ) {
        activeMeditationTimer?.invalidate()
        activeMeditationTimer = nil
        playButton.setTitle("▶️", for: .normal)
        cancelButton.isHidden = true
        durationLabel.text = "\(duration) мин"
    }

    // MARK: - Update Meditations
    private func updateMeditations() {
        meditationsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let items: [(name: String, duration: Int)]
        if selectedCategory == "Все" {
            items = meditations.values.flatMap { $0 }
        } else if selectedCategory == "Избранное" {
            items = Array(favorites).compactMap { name in
                for category in meditations.values {
                    if let item = category.first(where: { $0.name == name }) { return item }
                }
                return nil
            }
        } else {
            items = meditations[selectedCategory] ?? []
        }

        for meditation in items {
            let card = createCardView()
            let isFav = favorites.contains(meditation.name)

            let favButton = UIButton(type: .system)
            favButton.setTitle(isFav ? "❤️" : "🤍", for: .normal)
            favButton.widthAnchor.constraint(equalToConstant: 30).isActive = true

            let playButton = UIButton(type: .system)
            playButton.setTitle("▶️", for: .normal)
            playButton.widthAnchor.constraint(equalToConstant: 30).isActive = true

            let cancelButton = UIButton(type: .system)
            cancelButton.setTitle("❌", for: .normal)
            cancelButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
            cancelButton.isHidden = true

            let title = UILabel()
            title.text = meditation.name
            title.font = .systemFont(ofSize: 15, weight: .semibold)
            title.textColor = AppColors.text
            title.setContentHuggingPriority(.defaultLow, for: .horizontal)

            let durationLabel = UILabel()
            durationLabel.text = "\(meditation.duration) мин"
            durationLabel.font = .systemFont(ofSize: 13, weight: .medium)
            durationLabel.textColor = AppColors.lightText
            durationLabel.setContentHuggingPriority(.required, for: .horizontal)

            favButton.addAction(UIAction(handler: { [weak self] _ in
                guard let self = self else { return }
                if isFav { self.favorites.remove(meditation.name) }
                else      { self.favorites.insert(meditation.name) }
                self.updateMeditations()
            }), for: .touchUpInside)

            playButton.addAction(UIAction(handler: { [weak self] _ in
                self?.handleMeditationPlay(
                    meditation: meditation,
                    playButton: playButton,
                    cancelButton: cancelButton,
                    durationLabel: durationLabel
                )
            }), for: .touchUpInside)

            cancelButton.addAction(UIAction(handler: { [weak self] _ in
                self?.cancelMeditation(
                    playButton: playButton,
                    cancelButton: cancelButton,
                    durationLabel: durationLabel,
                    duration: meditation.duration
                )
            }), for: .touchUpInside)

            let stack = UIStackView(arrangedSubviews: [favButton, playButton, cancelButton, title, durationLabel])
            stack.axis = .horizontal
            stack.alignment = .center
            stack.spacing = 10
            stack.translatesAutoresizingMaskIntoConstraints = false

            card.addSubview(stack)
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
                stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
                stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
                stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
            ])

            meditationsStack.addArrangedSubview(card)
        }
    }
}

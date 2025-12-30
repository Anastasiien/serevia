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

        case whiteNoise = "Белый шум"
        case rain = "Дождь"
        case sea = "Шум моря"
        
        case summerEvening = "Вечер лета"
        case morningMountains = "Горы"
        case train = "Шум поезда"
        
        case airplane = "Шум полета"
        case wheatField = "Шум поля"
        case loFi = "Lo-Fi"
        
        case tibetanBowls = "Чаши"
        case fireplace = "Камин"
        case stream = "Ручей"
        
        case caveDrops = "Пещера"
        case zenBells = "Звон"
        case gong = "???"

        var icon: String {
            switch self {
            case .whiteNoise: return "📻"
            case .rain: return "🌧"
            case .sea: return "🌊"
                
            case .summerEvening: return "🌆"
            case .morningMountains: return "🏔"
            case .train: return "🚆"
                
            case .airplane: return "✈️"
            case .wheatField: return "🌾"
            case .loFi: return "🎧"
                
            case .fireplace: return "🔥"
            case .stream: return "🌿"
            case .caveDrops: return "🪨"
                
            case .tibetanBowls: return "🧘‍♂️"
            case .zenBells: return "🔔"
            case .gong: return "🥁"
            }
        }
    }


    
    private var timerCard: UIView!
    private var selectedSound: Sound = .rain

    private var timerLabel = UILabel()
    private var categoriesScrollView: UIScrollView!
    private var categoriesStack: UIStackView!
    
    private let categories = ["Все", "Избранное", "Сон", "Расслабление", "Фокус"]
    private var selectedCategory = "Все"
    
    private var startButton = UIButton(type: .system)
    private var stopButton = UIButton(type: .system)
    private var timerStack = UIStackView()
    
    private let meditations: [String: [(name: String, duration: Int)]] = [
        "Сон": [("Мягкое засыпание", 10), ("Покой и тишина", 15), ("Сон природы", 20)],
        "Расслабление": [("Дыхание покоя", 5), ("Отпустить тревогу", 10), ("Тепло и свет", 12)],
        "Фокус": [("Сила внимания", 8), ("Чистота мыслей", 10), ("Энергия момента", 15)]
    ]
    
    // MARK: - Active Meditation
    private var activeMeditationTimer: Timer?
    private var activeMeditationSeconds = 0
    private var activePlayButton: UIButton?
    private var activeCancelButton: UIButton?
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

        // MARK: - Title
        let titleLabel = UILabel()
        titleLabel.text = "Медитация"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Найдите внутренний покой"
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = UIColor(red: 0.52, green: 0.44, blue: 0.35, alpha: 1)

        // MARK: - Timer Card
        timerCard = createCardView()

        let timerTitle = UILabel()
        timerTitle.text = "Выберите время"
        timerTitle.font = .systemFont(ofSize: 16, weight: .medium)
        timerTitle.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)

        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 120
        slider.value = Float(selectedTime)
        slider.tintColor = UIColor(red: 0.53, green: 0.43, blue: 0.34, alpha: 1)
        slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)

        timerLabel.text = "⏱ \(selectedTime) мин"
        timerLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        timerLabel.textAlignment = .center
        timerLabel.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)

        // MARK: - Sound Grid с вертикальным скроллом
        // Создаём таймерный вертикальный стек
        let timerContentStack = UIStackView()
        timerContentStack.axis = .vertical
        timerContentStack.spacing = 12
        timerContentStack.translatesAutoresizingMaskIntoConstraints = false
        timerCard.addSubview(timerContentStack)

        // Добавляем таймер и слайдер
        timerContentStack.addArrangedSubview(timerTitle)
        timerContentStack.addArrangedSubview(slider)
        timerContentStack.addArrangedSubview(timerLabel)

        // Создаём заголовок для звуков
        let soundTitle = UILabel()
        soundTitle.text = "Мелодия"
        soundTitle.font = .systemFont(ofSize: 16, weight: .medium)
        soundTitle.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        timerContentStack.addArrangedSubview(soundTitle)

        // ScrollView для сетки звуков
        let soundScrollView = UIScrollView()
        soundScrollView.showsVerticalScrollIndicator = true
        soundScrollView.translatesAutoresizingMaskIntoConstraints = false
        timerContentStack.addArrangedSubview(soundScrollView)

        // Grid внутри ScrollView
        let soundGridStack = UIStackView()
        soundGridStack.axis = .vertical
        soundGridStack.spacing = 12
        soundGridStack.translatesAutoresizingMaskIntoConstraints = false
        soundScrollView.addSubview(soundGridStack)

        NSLayoutConstraint.activate([
            soundGridStack.topAnchor.constraint(equalTo: soundScrollView.topAnchor),
            soundGridStack.bottomAnchor.constraint(equalTo: soundScrollView.bottomAnchor),
            soundGridStack.leadingAnchor.constraint(equalTo: soundScrollView.leadingAnchor),
            soundGridStack.trailingAnchor.constraint(equalTo: soundScrollView.trailingAnchor),
            soundGridStack.widthAnchor.constraint(equalTo: soundScrollView.widthAnchor)
        ])
        let buttonHeight: CGFloat = 64
        let rowSpacing: CGFloat = 10
        let visibleRows: CGFloat = 3

        soundScrollView.heightAnchor.constraint(
            equalToConstant: visibleRows * buttonHeight + (visibleRows - 1) * rowSpacing
        ).isActive = true

        soundScrollView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 20,
            right: 0
        )

        // Кнопки 3 в ряд
        let soundsPerRow = 3
        var currentRowStack: UIStackView?

        for (index, sound) in Sound.allCases.enumerated() {
            if index % soundsPerRow == 0 {
                currentRowStack = UIStackView()
                currentRowStack?.axis = .horizontal
                currentRowStack?.spacing = 12
                currentRowStack?.distribution = .fillEqually
                soundGridStack.addArrangedSubview(currentRowStack!)
            }

            let button = UIButton(type: .system)
            button.tag = index
            button.setTitle("\(sound.icon)\n\(sound.rawValue)", for: .normal)
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            button.layer.cornerRadius = 16
            button.backgroundColor = sound == selectedSound
                ? UIColor(red: 0.53, green: 0.43, blue: 0.34, alpha: 1)
                : UIColor(white: 0.95, alpha: 1)
            button.setTitleColor(sound == selectedSound ? .white : .darkText, for: .normal)
            // 1. Уменьшаем кнопки
            button.heightAnchor.constraint(equalToConstant: 64).isActive = true
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 4, bottom: 6, right: 4)
            
            button.addTarget(self, action: #selector(soundSelected(_:)), for: .touchUpInside)



            currentRowStack?.addArrangedSubview(button)
        }

        // Ограничиваем высоту ScrollView так, чтобы видно было только 3 ряда
        
        

        // Ограничения для timerContentStack внутри карточки
        NSLayoutConstraint.activate([
            timerContentStack.topAnchor.constraint(equalTo: timerCard.topAnchor, constant: 16),
            timerContentStack.leadingAnchor.constraint(equalTo: timerCard.leadingAnchor, constant: 16),
            timerContentStack.trailingAnchor.constraint(equalTo: timerCard.trailingAnchor, constant: -16)
        ])



        // Добавляем в таймерный стек
       
        timerContentStack.axis = .vertical
        timerContentStack.spacing = 12
        timerContentStack.translatesAutoresizingMaskIntoConstraints = false
        timerCard.addSubview(timerContentStack)

        


        setupTimerUI(timerCard: timerCard)

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

        // MARK: - Meditations Scroll
        let meditationsScrollView = UIScrollView()
        meditationsScrollView.tag = 100
        meditationsScrollView.translatesAutoresizingMaskIntoConstraints = false

        // MARK: - Main Stack
        let mainStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            timerCard,
            categoriesScrollView,
            meditationsScrollView
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 18
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            categoriesScrollView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }


    // MARK: - Timer Controls UI
    private func setupTimerUI(timerCard: UIView) {

        startButton.setTitle("Начать", for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        startButton.backgroundColor = UIColor(red: 0.53, green: 0.43, blue: 0.34, alpha: 1)
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 14
        startButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)

        stopButton.setTitle("Остановить", for: .normal)
        stopButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        stopButton.setTitleColor(
            UIColor(red: 0.53, green: 0.43, blue: 0.34, alpha: 1),
            for: .normal
        )
        stopButton.isHidden = true
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)

        timerStack.axis = .vertical
        timerStack.spacing = 10
        timerStack.translatesAutoresizingMaskIntoConstraints = false
        timerStack.addArrangedSubview(startButton)
        timerStack.addArrangedSubview(stopButton)

        timerCard.addSubview(timerStack)

        NSLayoutConstraint.activate([
            timerStack.bottomAnchor.constraint(equalTo: timerCard.bottomAnchor, constant: -16),
            timerStack.leadingAnchor.constraint(equalTo: timerCard.leadingAnchor, constant: 16),
            timerStack.trailingAnchor.constraint(equalTo: timerCard.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Timer Actions
    @objc private func sliderChanged(_ sender: UISlider) {
        selectedTime = Int(sender.value)
        timerLabel.text = "⏱ \(selectedTime) мин"
        
        if timer != nil {
            timer?.invalidate()
            timer = nil
            remainingSeconds = 0
            updateTimerLabel()
            startButton.setTitle("Начать", for: .normal)
            stopButton.isHidden = true
        }
    }
    
    @objc private func startButtonTapped() {
        if startButton.title(for: .normal) == "Начать" {
            startMeditation()
            startButton.setTitle("Отменить", for: .normal)
            stopButton.isHidden = false
            stopButton.setTitle("Остановить", for: .normal)
        } else {
            timer?.invalidate()
            stopSound()
            remainingSeconds = 0
            updateTimerLabel()
            startButton.setTitle("Начать", for: .normal)
            stopButton.isHidden = true
        }
    }
    
    @objc private func soundSelected(_ sender: UIButton) {
        let sound = Sound.allCases[sender.tag]
        selectedSound = sound

        // Проходим по ВСЕМ кнопкам в сетке
        guard let gridStack = sender.superview?.superview as? UIStackView else { return }

        for row in gridStack.arrangedSubviews {
            guard let rowStack = row as? UIStackView else { continue }

            for view in rowStack.arrangedSubviews {
                guard let button = view as? UIButton else { continue }

                let isSelected = button.tag == sender.tag
                button.backgroundColor = isSelected
                    ? UIColor(red: 0.53, green: 0.43, blue: 0.34, alpha: 1)
                    : UIColor(white: 0.95, alpha: 1)

                button.setTitleColor(isSelected ? .white : .darkText, for: .normal)
            }
        }
    }


    
    @objc private func stopButtonTapped() {
        if stopButton.title(for: .normal) == "Остановить" {
            timer?.invalidate()
            stopSound()
            stopButton.setTitle("Продолжить", for: .normal)

        } else {
            startTimerResume()
            playSound(for: selectedSound)
            stopButton.setTitle("Остановить", for: .normal)
        }
    }
    
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
        
        // В будущем здесь будет запуск аудио
        playSound(for: selectedSound)

        startTimerResume()
    }
    private func stopSound() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    private func playSound(for sound: Sound) {
        // ВРЕМЕННОЕ имя файла — ты потом поменяешь
        let fileName = "test_sound"
        let fileExtension = "mp3"

        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("❌ Звук не найден")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // зацикливаем
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("❌ Ошибка воспроизведения звука:", error)
        }
    }

    
    private func createCardView() -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor(red: 0.99, green: 0.985, blue: 0.98, alpha: 1.0)
        card.layer.cornerRadius = 18
        card.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        card.layer.shadowOpacity = 0.2
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 3
        return card
    }
    
    // MARK: - Categories
    private func setupCategoryButtons() {
        categoriesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for cat in categories {
            let button = UIButton(type: .system)
            button.setTitle(cat, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = cat == selectedCategory
                ? UIColor(red: 0.53, green: 0.43, blue: 0.34, alpha: 1)
                : UIColor(red: 0.78, green: 0.70, blue: 0.60, alpha: 1)
            button.layer.cornerRadius = 12
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            button.heightAnchor.constraint(equalToConstant: 35).isActive = true
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
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
    
    // MARK: - Meditations
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

        activePlayButton = playButton
        activeCancelButton = cancelButton
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
                durationLabel.text = "✅ Сеанс завершен"
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
        guard let scrollView = view.viewWithTag(100) as? UIScrollView else { return }
        scrollView.subviews.forEach { $0.removeFromSuperview() }

        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

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

            let favButton = UIButton(type: .system)
            let isFav = favorites.contains(meditation.name)
            favButton.setTitle(isFav ? "❤️" : "🤍", for: .normal)
            favButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            favButton.widthAnchor.constraint(equalToConstant: 30).isActive = true

            let playButton = UIButton(type: .system)
            playButton.setTitle("▶️", for: .normal)
            playButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            playButton.widthAnchor.constraint(equalToConstant: 30).isActive = true

            let cancelButton = UIButton(type: .system)
            cancelButton.setTitle("❌", for: .normal)
            cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            cancelButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
            cancelButton.isHidden = true

            let title = UILabel()
            title.text = meditation.name
            title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            title.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
            title.setContentHuggingPriority(.defaultLow, for: .horizontal)

            let durationLabel = UILabel()
            durationLabel.text = "\(meditation.duration) мин"
            durationLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            durationLabel.textColor = UIColor(red: 0.52, green: 0.44, blue: 0.35, alpha: 1)
            durationLabel.setContentHuggingPriority(.required, for: .horizontal)

            // Actions
            favButton.addAction(UIAction(handler: { [weak self] _ in
                guard let self = self else { return }
                if isFav {
                    self.favorites.remove(meditation.name)
                } else {
                    self.favorites.insert(meditation.name)
                }
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

            // Главный стек карточки с сердечком слева
            let stack = UIStackView(arrangedSubviews: [favButton, playButton, cancelButton, title, durationLabel])
            stack.axis = .horizontal
            stack.alignment = .center
            stack.spacing = 8
            stack.distribution = .fill

            card.addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
                stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
            ])

            contentStack.addArrangedSubview(card)
        }

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
}

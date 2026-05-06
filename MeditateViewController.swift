import UIKit
import AVFoundation

class MeditateViewController: UIViewController {

    // MARK: - Properties
    private var currentMeditation: MeditationAudio?
    private var isMeditationRunning = false
    private var initialMeditationSeconds = 0
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
    
    enum MeditationAudio: String, CaseIterable {
        case focusPower      = "Сила внимания"
        case clearMind       = "Чистота мыслей"
        case energyNow       = "Энергия момента" //
        
        case sleepSoft       = "Мягкое засыпание" //
        case calmSilence     = "Покой и тишина" // !!!
        case natureSleep     = "Сон природы" //
        
        case breathingCalm   = "Дыхание покоя"
        case letGoAnxiety    = "Отпустить тревогу" //
        case warmLight       = "Тепло и свет" //

        /// 🎵 имя файла (как у Sound)
        var fileName: String {
            switch self {
            case .focusPower:    return "focus_power" //
            case .clearMind:     return "clear_mind" //
            case .energyNow:     return "energy" //
            
            case .sleepSoft:     return "sleep_soft" //
            case .calmSilence:   return "calm_silence" //
            case .natureSleep:   return "nature_sleep" //
            
            case .breathingCalm: return "breathing_calm" //
            case .letGoAnxiety:  return "let_go_anxiety" //
            case .warmLight:     return "teplo_svet" //
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

    private let meditations: [String: [(audio: MeditationAudio, duration: Int)]] = [
        "Сон": [
            (.sleepSoft, 10),
            (.calmSilence, 15),
            (.natureSleep, 20)
        ],
        "Расслабление": [
            (.breathingCalm, 5),
            (.letGoAnxiety, 10),
            (.warmLight, 12)
        ],
        "Фокус": [
            (.focusPower, 8),
            (.clearMind, 10),
            (.energyNow, 15)
        ]
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
        // FIX 4: дата + заголовок + подзаголовок + разделитель
        let dateLabel = UILabel()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE, d MMMM"
        let raw = formatter.string(from: Date())
        dateLabel.text = raw.prefix(1).uppercased() + raw.dropFirst()
        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = AppColors.lightText.withAlphaComponent(0.7)
        dateLabel.textAlignment = .center

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

        let headerDivider = UIView()
        headerDivider.backgroundColor = UIColor(red: 0.76, green: 0.68, blue: 0.58, alpha: 0.2)
        headerDivider.translatesAutoresizingMaskIntoConstraints = false
        headerDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let headerStack = UIStackView(arrangedSubviews: [dateLabel, titleLabel, subtitleLabel, headerDivider])
        headerStack.axis = .vertical
        headerStack.spacing = 4
        headerStack.setCustomSpacing(14, after: subtitleLabel)

        // MARK: - Timer Card
        // FIX 3: floral pattern фон в timerCard как в привычках
        timerCard = createCardView()
        timerCard.clipsToBounds = true

        if let originalImage = UIImage(named: "floral_pattern") {
            let newSize = CGSize(width: originalImage.size.width / 2.5,
                                height: originalImage.size.height / 2.5)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            originalImage.draw(in: CGRect(origin: .zero, size: newSize))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let smallerImage = scaledImage {
                timerCard.backgroundColor = UIColor(patternImage: smallerImage)
            } else {
                timerCard.backgroundColor = UIColor(patternImage: originalImage)
            }
        }

        let timerCardOverlay = UIView()
        timerCardOverlay.backgroundColor = AppColors.card
        timerCardOverlay.alpha = 0.85
        timerCardOverlay.translatesAutoresizingMaskIntoConstraints = false
        timerCard.addSubview(timerCardOverlay)
        NSLayoutConstraint.activate([
            timerCardOverlay.topAnchor.constraint(equalTo: timerCard.topAnchor),
            timerCardOverlay.leadingAnchor.constraint(equalTo: timerCard.leadingAnchor),
            timerCardOverlay.trailingAnchor.constraint(equalTo: timerCard.trailingAnchor),
            timerCardOverlay.bottomAnchor.constraint(equalTo: timerCard.bottomAnchor)
        ])

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
    private func playMeditationAudio(_ meditation: MeditationAudio) {
        stopSound()

        guard let url = Bundle.main.url(
            forResource: meditation.fileName,
            withExtension: "mp3"
        ) else {
            print("❌ Не найден файл:", meditation.fileName)
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = 0
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("❌ Ошибка:", error)
        }
    }
    // MARK: - Meditations Logic (Timers & Handlers)
    private func handleMeditationPlay(
        meditation: (audio: MeditationAudio, duration: Int),
        playButton: UIButton,
        cancelButton: UIButton,
        durationLabel: UILabel
    ) {
        // блокируем запуск другой медитации пока идёт воспроизведение ИЛИ пауза
        let isActiveSession = (activeMeditationTimer != nil) || (currentMeditation != nil && !isMeditationRunning && activeMeditationSeconds > 0)
        if isActiveSession && currentMeditation != meditation.audio { return }

        // если эта медитация уже завершилась — сброс для перезапуска
        if currentMeditation == meditation.audio && activeMeditationSeconds == 0 && !isMeditationRunning {
            currentMeditation = nil
        }

        // если нажали на другую (и сессии нет) — сбрасываем старую
        if currentMeditation != nil && currentMeditation != meditation.audio {
            activeMeditationTimer?.invalidate()
            activeMeditationTimer = nil
            activeMeditationSeconds = 0
            isMeditationRunning = false
            stopSound()
        }

        activePlayButton    = playButton
        activeCancelButton  = cancelButton
        activeDurationLabel = durationLabel

        if !isMeditationRunning {
            if currentMeditation != meditation.audio {
                currentMeditation = meditation.audio
                activeMeditationSeconds = meditation.duration * 60
                initialMeditationSeconds = activeMeditationSeconds
                playMeditationAudio(meditation.audio)
            } else {
                audioPlayer?.play()
            }
            isMeditationRunning = true
            playButton.setTitle("⏸", for: .normal)
            cancelButton.isHidden = false
            startMeditationTimer(playButton: playButton, cancelButton: cancelButton, durationLabel: durationLabel, duration: meditation.duration)
        } else {
            isMeditationRunning = false
            activeMeditationTimer?.invalidate()
            activeMeditationTimer = nil
            audioPlayer?.pause()
            playButton.setTitle("▶️", for: .normal)
        }
    }

    private func startMeditationTimer(
        playButton: UIButton,
        cancelButton: UIButton,
        durationLabel: UILabel,
        duration: Int
    ) {
        // Не вызываем play здесь, если уже вызвали в handleMeditationPlay
        activeMeditationTimer?.invalidate()

        activeMeditationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isMeditationRunning else { return }

            if self.activeMeditationSeconds > 0 {
                self.activeMeditationSeconds -= 1
                durationLabel.text = String(
                    format: "%02d:%02d",
                    self.activeMeditationSeconds / 60,
                    self.activeMeditationSeconds % 60
                )
            } else {
                // Завершение
                self.activeMeditationTimer?.invalidate()
                self.activeMeditationTimer = nil
                self.isMeditationRunning = false
                self.activeMeditationSeconds = 0
                self.currentMeditation = nil  // сброс — позволяет запустить снова

                playButton.setTitle("▶️", for: .normal)
                cancelButton.isHidden = true
                durationLabel.text = "✅ Завершено"
                self.stopSound()

                // через 60 секунд сбрасываем надпись обратно
                DispatchQueue.main.asyncAfter(deadline: .now() + 60) { [weak durationLabel] in
                    durationLabel?.text = "\(duration) мин"
                }
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

        stopSound()

        isMeditationRunning = false
        activeMeditationSeconds = 0
        initialMeditationSeconds = 0

        playButton.setTitle("▶️", for: .normal)
        cancelButton.isHidden = true

        durationLabel.text = "\(duration) мин"
    }

    private func updateMeditations() {
        meditationsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let items: [(audio: MeditationAudio, duration: Int)]

        if selectedCategory == "Все" {
            items = meditations.values.flatMap { $0 }
        } else if selectedCategory == "Избранное" {
            items = Array(favorites).compactMap { name in
                MeditationAudio.allCases.first { $0.rawValue == name }
            }.map { ($0, 10) } // можно потом хранить duration отдельно
        } else {
            items = meditations[selectedCategory] ?? []
        }

        for meditation in items {

            let card = createMeditationCard()
            let name = meditation.audio.rawValue
            let isFav = favorites.contains(name)

            // ── строка 1: название + сердечко ──
            let titleLabel = UILabel()
            titleLabel.text = name
            titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
            titleLabel.textColor = AppColors.text
            titleLabel.numberOfLines = 1
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.minimumScaleFactor = 0.8
            titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            let favButton = UIButton(type: .system)
            favButton.setTitle(isFav ? "❤️" : "🤍", for: .normal)
            favButton.titleLabel?.font = .systemFont(ofSize: 16)
            favButton.translatesAutoresizingMaskIntoConstraints = false
            favButton.widthAnchor.constraint(equalToConstant: 28).isActive = true

            let topRow = UIStackView(arrangedSubviews: [titleLabel, favButton])
            topRow.axis = .horizontal
            topRow.spacing = 6
            topRow.alignment = .center

            // ── строка 2: ▶️ | ❌ | время ──
            let playButton = UIButton(type: .system)
            playButton.setTitle("▶️", for: .normal)
            playButton.titleLabel?.font = .systemFont(ofSize: 15)

            let cancelButton = UIButton(type: .system)
            cancelButton.setTitle("❌", for: .normal)
            cancelButton.titleLabel?.font = .systemFont(ofSize: 13)
            cancelButton.isHidden = true

            let durationLabel = UILabel()
            durationLabel.text = "\(meditation.duration) мин"
            durationLabel.font = .systemFont(ofSize: 12, weight: .medium)
            durationLabel.textColor = AppColors.lightText
            durationLabel.textAlignment = .right
            durationLabel.numberOfLines = 1
            durationLabel.setContentHuggingPriority(.required, for: .horizontal)
            durationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

            let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

            let bottomRow = UIStackView(arrangedSubviews: [playButton, cancelButton, spacer, durationLabel])
            bottomRow.axis = .horizontal
            bottomRow.spacing = 8
            bottomRow.alignment = .center

            // ── общий вертикальный стек ──
            let mainCardStack = UIStackView(arrangedSubviews: [topRow, bottomRow])
            mainCardStack.axis = .vertical
            mainCardStack.spacing = 6
            mainCardStack.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(mainCardStack)
            NSLayoutConstraint.activate([
                mainCardStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
                mainCardStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                mainCardStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                mainCardStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
            ])

            // ❤️ избранное — только меняем иконку, не пересоздаём карточки
            favButton.addAction(UIAction(handler: { [weak self] _ in
                guard let self = self else { return }
                if self.favorites.contains(name) {
                    self.favorites.remove(name)
                    favButton.setTitle("🤍", for: .normal)
                } else {
                    self.favorites.insert(name)
                    favButton.setTitle("❤️", for: .normal)
                }
            }), for: .touchUpInside)

            // ▶️ запуск
            playButton.addAction(UIAction(handler: { [weak self] _ in
                self?.handleMeditationPlay(
                    meditation: meditation,
                    playButton: playButton,
                    cancelButton: cancelButton,
                    durationLabel: durationLabel
                )
            }), for: .touchUpInside)

            // ❌ отмена
            cancelButton.addAction(UIAction(handler: { [weak self] _ in
                self?.cancelMeditation(
                    playButton: playButton,
                    cancelButton: cancelButton,
                    durationLabel: durationLabel,
                    duration: meditation.duration
                )
            }), for: .touchUpInside)

            // Fix 3: восстанавливаем визуальное состояние если эта медитация активна
            if currentMeditation == meditation.audio {
                if isMeditationRunning {
                    playButton.setTitle("⏸", for: .normal)
                    cancelButton.isHidden = false
                    let mins = activeMeditationSeconds / 60
                    let secs = activeMeditationSeconds % 60
                    durationLabel.text = String(format: "%02d:%02d", mins, secs)
                } else if activeMeditationSeconds > 0 {
                    // на паузе
                    playButton.setTitle("▶️", for: .normal)
                    cancelButton.isHidden = false
                    let mins = activeMeditationSeconds / 60
                    let secs = activeMeditationSeconds % 60
                    durationLabel.text = String(format: "%02d:%02d", mins, secs)
                } else {
                    // завершено
                    durationLabel.text = "✅ Завершено"
                }
                // обновляем ссылки на UI-элементы активной медитации
                activePlayButton = playButton
                activeCancelButton = cancelButton
                activeDurationLabel = durationLabel
                // перезапускаем таймер если был запущен
                if isMeditationRunning {
                    activeMeditationTimer?.invalidate()
                    startMeditationTimer(
                        playButton: playButton,
                        cancelButton: cancelButton,
                        durationLabel: durationLabel,
                        duration: meditation.duration
                    )
                }
            }

            meditationsStack.addArrangedSubview(card)
        }
    }

    // FIX 3: отдельный метод для карточек практик с floral pattern
    private func createMeditationCard() -> UIView {
        let card = UIView()
        card.layer.cornerRadius = 22
        card.layer.shadowColor = AppColors.text.cgColor
        card.layer.shadowOpacity = 0.04
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 8
        card.clipsToBounds = true

        if let originalImage = UIImage(named: "floral_pattern") {
            let newSize = CGSize(width: originalImage.size.width / 2.5,
                                height: originalImage.size.height / 2.5)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            originalImage.draw(in: CGRect(origin: .zero, size: newSize))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let smallerImage = scaledImage {
                card.backgroundColor = UIColor(patternImage: smallerImage)
            } else {
                card.backgroundColor = UIColor(patternImage: originalImage)
            }
        } else {
            card.backgroundColor = AppColors.card
        }

        let overlay = UIView()
        overlay.backgroundColor = AppColors.card
        overlay.alpha = 0.82
        overlay.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: card.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])

        return card
    }
}

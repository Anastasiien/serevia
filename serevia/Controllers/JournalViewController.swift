import UIKit

class JournalViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIColorPickerViewControllerDelegate {

    // MARK: - Constants
    private let accent     = UIColor(red: 0.58, green: 0.46, blue: 0.42, alpha: 1)
    private let pageBg     = UIColor(red: 0.96, green: 0.94, blue: 0.91, alpha: 1)
    private let textDark   = UIColor(red: 0.20, green: 0.15, blue: 0.10, alpha: 1)
    private let textMid    = UIColor(red: 0.48, green: 0.40, blue: 0.32, alpha: 1)
    private let tagInactive = UIColor(red: 0.88, green: 0.85, blue: 0.81, alpha: 1.0)
    private let tagBorder   = UIColor(red: 0.84, green: 0.79, blue: 0.73, alpha: 1)

    // MARK: - Data
    private var selectedMood: String?
    private var selectedColor: UIColor?
    private let customColorsKey = "customColors"
    private let tagsKey = "saved_tags"
    private var customColorButtons: [UIButton] = []
    private let defaultColors: [UIColor] = [
        UIColor(red: 1.0,  green: 0.6,  blue: 0.6,  alpha: 1),
        UIColor(red: 1.0,  green: 0.7,  blue: 0.85, alpha: 1),
        UIColor(red: 1.0,  green: 0.9,  blue: 0.5,  alpha: 1),
        UIColor(red: 0.75, green: 0.65, blue: 0.95, alpha: 1),
        UIColor(red: 0.55, green: 0.8,  blue: 0.95, alpha: 1),
        UIColor(red: 0.4,  green: 0.6,  blue: 0.95, alpha: 1)
    ]
    private var currentColors: [UIColor] = []
    private let colorsKey = "saved_colors_list"
    private var tags: [String] = ["Работа", "Учёба", "Отдых", "Семья", "Здоровье"]
    private var selectedTags: [String] = []

    private func saveTags() { UserDefaults.standard.set(tags, forKey: tagsKey) }
    private func loadTags() {
        if let saved = UserDefaults.standard.array(forKey: tagsKey) as? [String] { tags = saved }
    }

    // MARK: - UI Elements
    private let moodStack = UIStackView()
    private var moodButtons: [UIButton] = []
    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15)
        tv.textColor = textDark
        tv.backgroundColor = UIColor(red: 0.92, green: 0.90, blue: 0.87, alpha: 1.0)
        tv.layer.cornerRadius = 14
        tv.layer.borderWidth = 1.5
        tv.layer.borderColor = UIColor(red: 0.76, green: 0.68, blue: 0.58, alpha: 1).cgColor
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        tv.isScrollEnabled = false
        return tv
    }()
    private let colorScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        return sv
    }()
    private let colorStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 12
        s.alignment = .center
        return s
    }()
    private var colorButtons: [UIButton] = []
    private let tagsScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        return sv
    }()
    private let tagsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 8
        s.alignment = .center
        return s
    }()
    private var tagButtons: [UIButton] = []
    private lazy var photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.backgroundColor = .clear
        return iv
    }()
    private lazy var addPhotoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Добавить фото дня", for: .normal)
        btn.setTitleColor(textMid, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.backgroundColor = .clear
        return btn
    }()
    private lazy var saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Сохранить", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = accent
        btn.layer.cornerRadius = 16
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = pageBg
        loadTags()
        currentColors = loadSavedColors()
        if currentColors.isEmpty { currentColors = defaultColors; saveColors(currentColors) }
        setupUI()
        setupMoodButtons()
        setupColorButtons()
        setupTagButtons()
    }

    // MARK: - Floral card helper (FIX 3: все белые карточки с floral)
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
            v.backgroundColor = .white
        }

        let overlay = UIView()
        overlay.backgroundColor = .white
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

    private func makeSectionLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = textMid
        return l
    }

    // MARK: - UI Setup
    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)

        // FIX 4: дата + заголовок + подзаголовок + разделитель
        let dateLabel = UILabel()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE, d MMMM"
        let raw = formatter.string(from: Date())
        dateLabel.text = raw.prefix(1).uppercased() + raw.dropFirst()
        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = textMid.withAlphaComponent(0.7)
        dateLabel.textAlignment = .center

        let titleLabel = UILabel()
        titleLabel.text = "Мой дневник"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = textDark

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Расскажи о своём дне"
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = textMid

        let headerDivider = UIView()
        headerDivider.backgroundColor = UIColor(red: 0.76, green: 0.68, blue: 0.58, alpha: 0.2)
        headerDivider.translatesAutoresizingMaskIntoConstraints = false
        headerDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let headerStack = UIStackView(arrangedSubviews: [dateLabel, titleLabel, subtitleLabel, headerDivider])
        headerStack.axis = .vertical
        headerStack.spacing = 4
        headerStack.setCustomSpacing(14, after: subtitleLabel)

        // ── Mood card (floral) ──
        let moodCard = makeFloralCard()
        let moodQuestion = UILabel()
        moodQuestion.text = "Как оцените свой день?"
        moodQuestion.font = .systemFont(ofSize: 15, weight: .semibold)
        moodQuestion.textColor = textDark
        moodQuestion.textAlignment = .center
        moodQuestion.translatesAutoresizingMaskIntoConstraints = false
        moodStack.translatesAutoresizingMaskIntoConstraints = false
        moodCard.addSubview(moodQuestion)
        moodCard.addSubview(moodStack)
        NSLayoutConstraint.activate([
            moodQuestion.topAnchor.constraint(equalTo: moodCard.topAnchor, constant: 18),
            moodQuestion.centerXAnchor.constraint(equalTo: moodCard.centerXAnchor),
            moodStack.topAnchor.constraint(equalTo: moodQuestion.bottomAnchor, constant: 14),
            moodStack.leadingAnchor.constraint(equalTo: moodCard.leadingAnchor, constant: 20),
            moodStack.trailingAnchor.constraint(equalTo: moodCard.trailingAnchor, constant: -20),
            moodStack.bottomAnchor.constraint(equalTo: moodCard.bottomAnchor, constant: -18),
            moodStack.heightAnchor.constraint(equalToConstant: 56)
        ])

        // ── Entry card (floral) ──
        let entryCard = makeFloralCard()
        let entryLbl = makeSectionLabel("Запись дня")
        entryLbl.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        entryCard.addSubview(entryLbl)
        entryCard.addSubview(textView)
        NSLayoutConstraint.activate([
            entryLbl.topAnchor.constraint(equalTo: entryCard.topAnchor, constant: 18),
            entryLbl.leadingAnchor.constraint(equalTo: entryCard.leadingAnchor, constant: 20),
            textView.topAnchor.constraint(equalTo: entryLbl.bottomAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: entryCard.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: entryCard.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: entryCard.bottomAnchor, constant: -16),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])

        // ── Color card (floral) ──
        let colorCard = makeFloralCard()
        let colorLbl = makeSectionLabel("Цвет дня")
        colorLbl.translatesAutoresizingMaskIntoConstraints = false
        colorScrollView.translatesAutoresizingMaskIntoConstraints = false
        colorStack.translatesAutoresizingMaskIntoConstraints = false
        colorScrollView.addSubview(colorStack)
        colorCard.addSubview(colorLbl)
        colorCard.addSubview(colorScrollView)
        NSLayoutConstraint.activate([
            colorLbl.topAnchor.constraint(equalTo: colorCard.topAnchor, constant: 18),
            colorLbl.leadingAnchor.constraint(equalTo: colorCard.leadingAnchor, constant: 20),
            colorScrollView.topAnchor.constraint(equalTo: colorLbl.bottomAnchor, constant: 12),
            colorScrollView.leadingAnchor.constraint(equalTo: colorCard.leadingAnchor, constant: 20),
            colorScrollView.trailingAnchor.constraint(equalTo: colorCard.trailingAnchor, constant: -20),
            colorScrollView.bottomAnchor.constraint(equalTo: colorCard.bottomAnchor, constant: -18),
            colorScrollView.heightAnchor.constraint(equalToConstant: 44),
            colorStack.topAnchor.constraint(equalTo: colorScrollView.contentLayoutGuide.topAnchor),
            colorStack.bottomAnchor.constraint(equalTo: colorScrollView.contentLayoutGuide.bottomAnchor),
            colorStack.leadingAnchor.constraint(equalTo: colorScrollView.contentLayoutGuide.leadingAnchor),
            colorStack.trailingAnchor.constraint(equalTo: colorScrollView.contentLayoutGuide.trailingAnchor),
            colorStack.heightAnchor.constraint(equalTo: colorScrollView.frameLayoutGuide.heightAnchor)
        ])

        // ── Tags card (floral) ──
        let tagsCard = makeFloralCard()
        let tagsLbl = makeSectionLabel("Теги")
        tagsLbl.translatesAutoresizingMaskIntoConstraints = false
        tagsScrollView.translatesAutoresizingMaskIntoConstraints = false
        tagsStack.translatesAutoresizingMaskIntoConstraints = false
        tagsScrollView.addSubview(tagsStack)
        tagsCard.addSubview(tagsLbl)
        tagsCard.addSubview(tagsScrollView)
        NSLayoutConstraint.activate([
            tagsLbl.topAnchor.constraint(equalTo: tagsCard.topAnchor, constant: 18),
            tagsLbl.leadingAnchor.constraint(equalTo: tagsCard.leadingAnchor, constant: 20),
            tagsScrollView.topAnchor.constraint(equalTo: tagsLbl.bottomAnchor, constant: 12),
            tagsScrollView.leadingAnchor.constraint(equalTo: tagsCard.leadingAnchor, constant: 20),
            tagsScrollView.trailingAnchor.constraint(equalTo: tagsCard.trailingAnchor, constant: -20),
            tagsScrollView.bottomAnchor.constraint(equalTo: tagsCard.bottomAnchor, constant: -18),
            tagsScrollView.heightAnchor.constraint(equalToConstant: 36),
            tagsStack.topAnchor.constraint(equalTo: tagsScrollView.contentLayoutGuide.topAnchor),
            tagsStack.bottomAnchor.constraint(equalTo: tagsScrollView.contentLayoutGuide.bottomAnchor),
            tagsStack.leadingAnchor.constraint(equalTo: tagsScrollView.contentLayoutGuide.leadingAnchor),
            tagsStack.trailingAnchor.constraint(equalTo: tagsScrollView.contentLayoutGuide.trailingAnchor),
            tagsStack.heightAnchor.constraint(equalTo: tagsScrollView.frameLayoutGuide.heightAnchor)
        ])

        // ── Photo card (floral) ──
        let photoCard = makeFloralCard()
        let dropZone = UIView()
        dropZone.backgroundColor = UIColor(red: 0.92, green: 0.90, blue: 0.87, alpha: 1.0)
        dropZone.layer.cornerRadius = 16
        dropZone.translatesAutoresizingMaskIntoConstraints = false
        photoCard.addSubview(dropZone)

        let dash = CAShapeLayer()
        dash.strokeColor = UIColor(red: 0.65, green: 0.55, blue: 0.44, alpha: 1).cgColor
        dash.fillColor = UIColor.clear.cgColor
        dash.lineWidth = 1.5
        dash.lineDashPattern = [6, 4]
        dropZone.layer.addSublayer(dash)
        DispatchQueue.main.async {
            dash.frame = dropZone.bounds
            dash.path = UIBezierPath(roundedRect: dropZone.bounds, cornerRadius: 16).cgPath
        }

        let cameraIcon = UILabel()
        cameraIcon.text = "📷"
        cameraIcon.font = .systemFont(ofSize: 30)
        cameraIcon.textAlignment = .center
        cameraIcon.translatesAutoresizingMaskIntoConstraints = false
        dropZone.addSubview(cameraIcon)

        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        dropZone.addSubview(photoImageView)
        dropZone.addSubview(addPhotoButton)

        NSLayoutConstraint.activate([
            dropZone.topAnchor.constraint(equalTo: photoCard.topAnchor, constant: 16),
            dropZone.leadingAnchor.constraint(equalTo: photoCard.leadingAnchor, constant: 16),
            dropZone.trailingAnchor.constraint(equalTo: photoCard.trailingAnchor, constant: -16),
            dropZone.bottomAnchor.constraint(equalTo: photoCard.bottomAnchor, constant: -16),
            photoCard.heightAnchor.constraint(equalToConstant: 180),
            cameraIcon.centerXAnchor.constraint(equalTo: dropZone.centerXAnchor),
            cameraIcon.centerYAnchor.constraint(equalTo: dropZone.centerYAnchor, constant: -16),
            photoImageView.topAnchor.constraint(equalTo: dropZone.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: dropZone.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: dropZone.trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: dropZone.bottomAnchor),
            addPhotoButton.centerXAnchor.constraint(equalTo: dropZone.centerXAnchor),
            addPhotoButton.bottomAnchor.constraint(equalTo: dropZone.bottomAnchor, constant: -14),
            addPhotoButton.heightAnchor.constraint(equalToConstant: 36),
            addPhotoButton.widthAnchor.constraint(equalToConstant: 200)
        ])

        // ── Main stack ──
        let mainStack = UIStackView(arrangedSubviews: [
            headerStack,
            moodCard, entryCard, colorCard, tagsCard, photoCard,
            saveButton
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 32, right: 20)

        scrollView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            mainStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    // MARK: - Mood Buttons
    private func setupMoodButtons() {
        moodStack.axis = .horizontal
        moodStack.spacing = 12
        moodStack.distribution = .equalSpacing

        let moods: [(String, String)] = [
            ("😄", "Отлично"), ("🙂", "Хорошо"), ("😐", "Нормально"), ("😔", "Грустно")
        ]
        for mood in moods {
            let col = UIStackView()
            col.axis = .vertical
            col.alignment = .center
            col.spacing = 6

            let btn = UIButton(type: .system)
            btn.setTitle(mood.0, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 28)
            btn.backgroundColor = UIColor(red: 0.96, green: 0.93, blue: 0.89, alpha: 1)
            btn.layer.cornerRadius = 18
            btn.layer.borderWidth = 1.5
            btn.layer.borderColor = UIColor.clear.cgColor
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalToConstant: 56).isActive = true
            btn.widthAnchor.constraint(equalToConstant: 56).isActive = true
            btn.addTarget(self, action: #selector(moodButtonTapped(_:)), for: .touchUpInside)
            moodButtons.append(btn)

            let lbl = UILabel()
            lbl.text = mood.1
            lbl.font = .systemFont(ofSize: 11, weight: .medium)
            lbl.textColor = textMid
            lbl.textAlignment = .center

            col.addArrangedSubview(btn)
            col.addArrangedSubview(lbl)
            moodStack.addArrangedSubview(col)
        }
    }

    @objc private func moodButtonTapped(_ sender: UIButton) {
        moodButtons.forEach {
            $0.backgroundColor = UIColor(red: 0.96, green: 0.93, blue: 0.89, alpha: 1)
            $0.layer.borderColor = UIColor.clear.cgColor
        }
        sender.backgroundColor = accent.withAlphaComponent(0.15)
        sender.layer.borderColor = accent.cgColor
        selectedMood = sender.title(for: .normal)
    }

    // MARK: - Color Buttons
    private func setupColorButtons() {
        colorStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        colorButtons.removeAll()
        let size: CGFloat = 40
        for color in currentColors {
            let btn = createColorButton(color: color, size: size)
            colorButtons.append(btn)
            colorStack.addArrangedSubview(btn)
        }
        let addBtn = makeAddButton(size: size)
        addBtn.addTarget(self, action: #selector(addNewColorTapped), for: .touchUpInside)
        colorStack.addArrangedSubview(addBtn)
    }

    private func createColorButton(color: UIColor, size: CGFloat) -> UIButton {
        let btn = UIButton(type: .system)
        btn.backgroundColor = color
        btn.layer.cornerRadius = size / 2
        btn.layer.borderWidth = 2.5
        btn.layer.borderColor = UIColor.clear.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: size).isActive = true
        btn.widthAnchor.constraint(equalToConstant: size).isActive = true
        btn.addTarget(self, action: #selector(colorTapped(_:)), for: .touchUpInside)
        let lp = UILongPressGestureRecognizer(target: self, action: #selector(colorButtonLongPressed(_:)))
        btn.addGestureRecognizer(lp)
        return btn
    }

    private func makeAddButton(size: CGFloat) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle("+", for: .normal)
        btn.setTitleColor(textMid, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        btn.backgroundColor = UIColor(red: 0.95, green: 0.92, blue: 0.88, alpha: 1)
        btn.layer.cornerRadius = size / 2
        btn.layer.borderWidth = 1
        btn.layer.borderColor = tagBorder.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: size).isActive = true
        btn.widthAnchor.constraint(equalToConstant: size).isActive = true
        return btn
    }

    @objc private func colorTapped(_ sender: UIButton) {
        colorButtons.forEach { $0.layer.borderColor = UIColor.clear.cgColor }
        sender.layer.borderColor = accent.cgColor
        selectedColor = sender.backgroundColor
    }

    @objc private func colorButtonLongPressed(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began, let btn = sender.view as? UIButton,
              let idx = colorButtons.firstIndex(of: btn) else { return }
        let alert = UIAlertController(title: "Удалить цвет?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.currentColors.remove(at: idx)
            self.saveColors(self.currentColors)
            self.setupColorButtons()
            self.selectedColor = nil
        })
        present(alert, animated: true)
    }

    @available(iOS 14.0, *)
    @objc private func addNewColorTapped() {
        let picker = UIColorPickerViewController()
        picker.delegate = self
        present(picker, animated: true)
    }

    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let pastel = pastelColor(from: viewController.selectedColor)
        currentColors.append(pastel)
        saveColors(currentColors)
        setupColorButtons()
    }

    private func saveColors(_ colors: [UIColor]) {
        let data = colors.compactMap { try? NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: false) }
        UserDefaults.standard.set(data, forKey: customColorsKey)
    }

    private func loadSavedColors() -> [UIColor] {
        guard let arr = UserDefaults.standard.array(forKey: customColorsKey) as? [Data] else { return [] }
        return arr.compactMap { try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData($0) as? UIColor }
    }

    private func pastelColor(from color: UIColor) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: min(s, 0.4), brightness: max(b, 0.85), alpha: a)
    }

    // MARK: - Tags
    private func setupTagButtons() {
        tagsStack.arrangedSubviews.forEach { tagsStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        tagButtons.removeAll()

        for tag in tags {
            let isSelected = selectedTags.contains(tag)
            let btn = UIButton(type: .system)
            btn.setTitle(tag, for: .normal)
            btn.setTitleColor(isSelected ? .white : textDark, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
            btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
            btn.backgroundColor = isSelected ? accent : tagInactive
            btn.layer.cornerRadius = 14
            btn.layer.borderWidth = 1
            btn.layer.borderColor = isSelected ? UIColor.clear.cgColor : tagBorder.cgColor
            btn.setContentHuggingPriority(.required, for: .horizontal)
            btn.addTarget(self, action: #selector(tagTapped(_:)), for: .touchUpInside)
            let lp = UILongPressGestureRecognizer(target: self, action: #selector(tagLongPressed(_:)))
            btn.addGestureRecognizer(lp)
            tagButtons.append(btn)
            tagsStack.addArrangedSubview(btn)
        }

        let addBtn = UIButton(type: .system)
        addBtn.setTitle("+", for: .normal)
        addBtn.setTitleColor(textMid, for: .normal)
        addBtn.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        addBtn.backgroundColor = UIColor(red: 0.95, green: 0.92, blue: 0.88, alpha: 1)
        addBtn.layer.cornerRadius = 14
        addBtn.layer.borderWidth = 1
        addBtn.layer.borderColor = tagBorder.cgColor
        addBtn.translatesAutoresizingMaskIntoConstraints = false
        addBtn.heightAnchor.constraint(equalToConstant: 32).isActive = true
        addBtn.widthAnchor.constraint(equalToConstant: 32).isActive = true
        addBtn.addTarget(self, action: #selector(addNewTagTapped), for: .touchUpInside)
        tagsStack.addArrangedSubview(addBtn)
    }

    @objc private func tagTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        if selectedTags.contains(title) {
            selectedTags.removeAll { $0 == title }
            sender.backgroundColor = tagInactive
            sender.setTitleColor(textDark, for: .normal)
            sender.layer.borderColor = tagBorder.cgColor
        } else {
            selectedTags.append(title)
            sender.backgroundColor = accent
            sender.setTitleColor(.white, for: .normal)
            sender.layer.borderColor = UIColor.clear.cgColor
        }
    }

    @objc private func tagLongPressed(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let btn = gesture.view as? UIButton,
              let title = btn.title(for: .normal) else { return }
        let alert = UIAlertController(title: "Удалить тег «\(title)»?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self, let idx = self.tagButtons.firstIndex(of: btn) else { return }
            self.tagButtons.remove(at: idx)
            btn.removeFromSuperview()
            self.tags.removeAll { $0 == title }
            self.selectedTags.removeAll { $0 == title }
            self.saveTags()
        })
        present(alert, animated: true)
    }

    @objc private func addNewTagTapped() {
        let alert = UIAlertController(title: "Новый тег", message: "Введите название", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Например: Друзья" }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
            guard let self = self, let text = alert.textFields?.first?.text, !text.isEmpty else { return }
            self.tags.append(text)
            self.saveTags()
            self.setupTagButtons()
        })
        present(alert, animated: true)
    }

    // MARK: - Photo
    @objc private func addPhotoTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - Save
    @objc private func saveButtonTapped() {
        guard let mood = selectedMood else {
            let a = UIAlertController(title: "Выберите эмоцию", message: "Выберите настроение перед сохранением", preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "Ок", style: .default))
            present(a, animated: true); return
        }
        let text = textView.text ?? ""
        var imageData: Data? = nil
        if let img = photoImageView.image { imageData = img.jpegData(compressionQuality: 0.8) }
        let entry = DiaryEntry(date: Date(), text: text, mood: mood, imageData: imageData, tags: selectedTags, color: selectedColor?.hexString)
        DiaryStorage.shared.save(entry: entry)

        textView.text = ""
        photoImageView.image = nil
        addPhotoButton.isHidden = false
        moodButtons.forEach {
            $0.backgroundColor = UIColor(red: 0.96, green: 0.93, blue: 0.89, alpha: 1)
            $0.layer.borderColor = UIColor.clear.cgColor
        }
        selectedMood = nil
        colorButtons.forEach { $0.layer.borderColor = UIColor.clear.cgColor }
        selectedColor = nil
        selectedTags = []
        setupTagButtons()

        let a = UIAlertController(title: "Сохранено ✓", message: "Запись добавлена в дневник", preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Ок", style: .default))
        present(a, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension JournalViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            photoImageView.image = image
            addPhotoButton.isHidden = true
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

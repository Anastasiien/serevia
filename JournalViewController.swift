import UIKit

class JournalViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var selectedMood: String?
    private var selectedColor: UIColor?
    
    let dayColors: [UIColor] = [
        UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1),
        UIColor(red: 1.0, green: 0.7, blue: 0.85, alpha: 1),
        UIColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 1),
        UIColor(red: 0.75, green: 0.65, blue: 0.95, alpha: 1),
        UIColor(red: 0.55, green: 0.8, blue: 0.95, alpha: 1),
        UIColor(red: 0.4, green: 0.6, blue: 0.95, alpha: 1)
    ]
    
    // MARK: - Tags
    private var tags: [String] = ["Работа", "Учёба", "Отдых", "Семья", "Здоровье"]
    private var selectedTags: [String] = []

    private let tagsLabel: UILabel = {
        let label = UILabel()
        label.text = "Теги"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        return label
    }()

    private let tagsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()

    private var tagButtons: [UIButton] = []
    
    private let tagsScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        return sv
    }()

    private let addTagButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("+", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor.systemGray4
        btn.layer.cornerRadius = 14
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 28).isActive = true
        return btn
    }()

    @objc private func tagLongPressed(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let button = gesture.view as? UIButton,
              let tagTitle = button.title(for: .normal)
        else { return }

        let alert = UIAlertController(
            title: "Удалить тег?",
            message: "Вы уверены, что хотите удалить тег «\(tagTitle)»",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }

            // Удаляем из списка тегов
            self.tags.removeAll { $0 == tagTitle }

            // Удаляем из выбранных (если был выбран)
            self.selectedTags.removeAll { $0 == tagTitle }

            // Перерисовываем кнопки
            self.setupTagButtons()
        })

        present(alert, animated: true)
    }

    
    // MARK: - Tags logic
    private func setupTagButtons() {
        // Очищаем старые кнопки
        tagsStack.arrangedSubviews.forEach {
            tagsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        tagButtons.removeAll()

        // Создаём кнопки тегов
        for tag in tags {
            let btn = UIButton(type: .system)
            btn.setTitle(tag, for: .normal)
            btn.setTitleColor(.white, for: .normal)

            btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            btn.titleLabel?.lineBreakMode = .byClipping
            btn.titleLabel?.numberOfLines = 1

            btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)

            btn.backgroundColor = selectedTags.contains(tag)
                ? UIColor(red: 0.55, green: 0.4, blue: 0.95, alpha: 1)
                : UIColor.systemGray3

            btn.layer.cornerRadius = 12

            // КЛЮЧЕВОЕ — запрещаем сжатие текста
            btn.setContentHuggingPriority(.required, for: .horizontal)
            btn.setContentCompressionResistancePriority(.required, for: .horizontal)

            btn.addTarget(self, action: #selector(tagTapped(_:)), for: .touchUpInside)

            let longPress = UILongPressGestureRecognizer(
                target: self,
                action: #selector(tagLongPressed(_:))
            )
            btn.addGestureRecognizer(longPress)

            tagButtons.append(btn)
            tagsStack.addArrangedSubview(btn)
        }

        // Кнопка "+"
        tagsStack.addArrangedSubview(addTagButton)
        addTagButton.removeTarget(nil, action: nil, for: .allEvents)
        addTagButton.addTarget(self, action: #selector(addNewTagTapped), for: .touchUpInside)
    }


    @objc private func tagTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }

        if selectedTags.contains(title) {
            selectedTags.removeAll { $0 == title }
            sender.backgroundColor = .systemGray3
        } else {
            selectedTags.append(title)
            sender.backgroundColor = UIColor(red: 0.55, green: 0.4, blue: 0.95, alpha: 1)
        }
    }

    @objc private func addNewTagTapped() {
        let alert = UIAlertController(title: "Новый тег",
                                      message: "Введите название",
                                      preferredStyle: .alert)

        alert.addTextField { $0.placeholder = "Например: Друзья" }

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
            guard
                let self = self,
                let text = alert.textFields?.first?.text,
                !text.isEmpty
            else { return }

            self.tags.append(text)
            self.setupTagButtons()
        })

        present(alert, animated: true)
    }



    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Мой дневник"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расскажи о своем дне"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.52, green: 0.44, blue: 0.35, alpha: 1)
        return label
    }()
    
    private let moodCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 1)
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let moodQuestionLabel: UILabel = {
        let label = UILabel()
        label.text = "Как оцените свой день?"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        return label
    }()
    
    private let moodStack = UIStackView()
    private var moodButtons: [UIButton] = []
    
    private let entryLabel: UILabel = {
        let label = UILabel()
        label.text = "Запись дня"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        return label
    }()
    
    private let colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет дня"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        return label
    }()
    
    private let colorStack = UIStackView()
    private var colorButtons: [UIButton] = []
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = UIColor(red: 0.99, green: 0.985, blue: 0.98, alpha: 1.0)
        tv.layer.cornerRadius = 12
        tv.layer.borderWidth = 0.5
        tv.layer.borderColor = UIColor(red: 0.78, green: 0.70, blue: 0.60, alpha: 1).cgColor
        tv.isScrollEnabled = false
        return tv
    }()
    
    private let photoCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.99, green: 0.985, blue: 0.98, alpha: 1.0)
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 3
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.78, green: 0.70, blue: 0.60, alpha: 1).cgColor
        return view
    }()
    
    private let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = UIColor(red: 0.94, green: 0.93, blue: 0.92, alpha: 1)
        return iv
    }()
    
    private let addPhotoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Добавить фото дня", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.53, green: 0.43, blue: 0.34, alpha: 1)
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return btn
    }()
    
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Сохранить", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.53, green: 0.43, blue: 0.34, alpha: 1)
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return btn
    }()

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupUI()
        setupMoodButtons()
        setupColorButtons()
        addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Color Buttons
    private func setupColorButtons() {
        colorStack.axis = .horizontal
        colorStack.spacing = 12
        colorStack.distribution = .fillEqually
        let buttonSize: CGFloat = 40
        
        // Существующие цвета
        for color in dayColors {
            let btn = createColorButton(color: color, size: buttonSize)
            colorButtons.append(btn)
            colorStack.addArrangedSubview(btn)
        }
        
        
        
        // Кнопка "+"
        let addButton = UIButton(type: .system)
        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(.black, for: .normal)
        addButton.backgroundColor = UIColor(white: 0.95, alpha: 1)
        addButton.layer.cornerRadius = buttonSize / 2
        addButton.layer.borderWidth = 1
        addButton.layer.borderColor = UIColor.gray.cgColor
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        addButton.addTarget(self, action: #selector(addNewColorTapped), for: .touchUpInside)
        colorStack.addArrangedSubview(addButton)
    }
    
    @objc private func addNewColorTapped() {
        if #available(iOS 14.0, *) {
            let picker = UIColorPickerViewController()
            picker.delegate = self
            picker.supportsAlpha = false
            present(picker, animated: true)
        }
    }

    
    private func createColorButton(color: UIColor, size: CGFloat) -> UIButton {
        let btn = UIButton(type: .system)
        btn.backgroundColor = color
        btn.layer.cornerRadius = size / 2
        btn.layer.borderWidth = 2
        btn.layer.borderColor = UIColor.clear.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: size).isActive = true
        btn.widthAnchor.constraint(equalToConstant: size).isActive = true
        
        btn.addTarget(self, action: #selector(colorTapped(_:)), for: .touchUpInside)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(colorButtonLongPressed(_:)))
        btn.addGestureRecognizer(longPress)
        return btn
    }
    
    @objc private func colorButtonLongPressed(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began, let button = sender.view as? UIButton else { return }
        
        let alert = UIAlertController(
            title: "Удалить цвет?",
            message: "Вы уверены, что хотите удалить этот цвет?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            if let index = self.colorButtons.firstIndex(of: button) {
                self.colorButtons.remove(at: index)
                button.removeFromSuperview()
            }
        }))
        
        present(alert, animated: true)
    }

    

    
    private func pastelColor(from color: UIColor) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: min(saturation, 0.4), brightness: max(brightness, 0.85), alpha: alpha)
    }
    
    @available(iOS 14.0, *)
    private func addColorButton(_ color: UIColor) {
        let buttonSize: CGFloat = 40
        let pastelBtn = createColorButton(color: pastelColor(from: color), size: buttonSize)
        colorButtons.append(pastelBtn)
        colorStack.insertArrangedSubview(pastelBtn, at: colorStack.arrangedSubviews.count - 1)
        selectedColor = pastelBtn.backgroundColor
        colorButtons.forEach { $0.layer.borderColor = UIColor.clear.cgColor }
        pastelBtn.layer.borderColor = UIColor.black.cgColor
    }
    
    @objc private func colorTapped(_ sender: UIButton) {
        colorButtons.forEach { $0.layer.borderColor = UIColor.clear.cgColor }
        sender.layer.borderColor = UIColor.black.cgColor
        selectedColor = sender.backgroundColor
        photoCard.layer.borderColor = selectedColor?.cgColor
    }
    
    // MARK: - UI Setup
       private func setupUI() {
           let scrollView = UIScrollView()
           scrollView.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(scrollView)
           
           NSLayoutConstraint.activate([
               scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
               scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
               scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
           ])
           
           // MARK: - Content Stack (Title + Subtitle)
           let contentStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
           contentStack.axis = .vertical
           contentStack.spacing = 12
           contentStack.translatesAutoresizingMaskIntoConstraints = false
           scrollView.addSubview(contentStack)
           
           NSLayoutConstraint.activate([
               contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
               contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
               contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
               contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
           ])
           
           // MARK: - Mood Card
           scrollView.addSubview(moodCard)
           moodCard.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               moodCard.topAnchor.constraint(equalTo: contentStack.bottomAnchor, constant: 20),
               moodCard.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
               moodCard.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
               moodCard.heightAnchor.constraint(equalToConstant: 120)
           ])
           
           moodCard.addSubview(moodQuestionLabel)
           moodCard.addSubview(moodStack)
           moodQuestionLabel.translatesAutoresizingMaskIntoConstraints = false
           moodStack.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([
               moodQuestionLabel.topAnchor.constraint(equalTo: moodCard.topAnchor, constant: 16),
               moodQuestionLabel.centerXAnchor.constraint(equalTo: moodCard.centerXAnchor),
               
               moodStack.topAnchor.constraint(equalTo: moodQuestionLabel.bottomAnchor, constant: 12),
               moodStack.leadingAnchor.constraint(equalTo: moodCard.leadingAnchor, constant: 16),
               moodStack.trailingAnchor.constraint(equalTo: moodCard.trailingAnchor, constant: -16),
               moodStack.bottomAnchor.constraint(equalTo: moodCard.bottomAnchor, constant: -16),
               moodStack.heightAnchor.constraint(equalToConstant: 50)
           ])
           
           // MARK: - Entry Label + TextView
           scrollView.addSubview(entryLabel)
           scrollView.addSubview(textView)
           entryLabel.translatesAutoresizingMaskIntoConstraints = false
           textView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([
               entryLabel.topAnchor.constraint(equalTo: moodCard.bottomAnchor, constant: 20),
               entryLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
               
               textView.topAnchor.constraint(equalTo: entryLabel.bottomAnchor, constant: 8),
               textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
               textView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
               textView.heightAnchor.constraint(equalToConstant: 120)
           ])
           
           // MARK: - Color Label + Color Stack
           scrollView.addSubview(colorLabel)
           scrollView.addSubview(colorStack)
           colorLabel.translatesAutoresizingMaskIntoConstraints = false
           colorStack.translatesAutoresizingMaskIntoConstraints = false
           
           
           NSLayoutConstraint.activate([
               colorLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
               colorLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
               
               colorStack.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 12),
               colorStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
               colorStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
               colorStack.heightAnchor.constraint(equalToConstant: 44)
           ])
           
           scrollView.addSubview(tagsLabel)
           scrollView.addSubview(tagsScrollView)

           tagsScrollView.addSubview(tagsStack)

           tagsLabel.translatesAutoresizingMaskIntoConstraints = false
           tagsScrollView.translatesAutoresizingMaskIntoConstraints = false
           tagsStack.translatesAutoresizingMaskIntoConstraints = false

           NSLayoutConstraint.activate([
               tagsLabel.topAnchor.constraint(equalTo: colorStack.bottomAnchor, constant: 20),
               tagsLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),

               tagsScrollView.topAnchor.constraint(equalTo: tagsLabel.bottomAnchor, constant: 8),
               tagsScrollView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
               tagsScrollView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
               tagsScrollView.heightAnchor.constraint(equalToConstant: 40),

               tagsStack.topAnchor.constraint(equalTo: tagsScrollView.topAnchor),
               tagsStack.bottomAnchor.constraint(equalTo: tagsScrollView.bottomAnchor),
               tagsStack.leadingAnchor.constraint(equalTo: tagsScrollView.leadingAnchor),
               tagsStack.trailingAnchor.constraint(equalTo: tagsScrollView.trailingAnchor),
               tagsStack.heightAnchor.constraint(equalTo: tagsScrollView.heightAnchor)
           ])

           tagsLabel.translatesAutoresizingMaskIntoConstraints = false
           tagsStack.translatesAutoresizingMaskIntoConstraints = false

           NSLayoutConstraint.activate([
               tagsLabel.topAnchor.constraint(equalTo: colorStack.bottomAnchor, constant: 20),
               tagsLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),

               tagsStack.topAnchor.constraint(equalTo: tagsLabel.bottomAnchor, constant: 8),
               tagsStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
               tagsStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
               tagsStack.heightAnchor.constraint(equalToConstant: 40)
           ])

           setupTagButtons()


           
           // MARK: - Photo Card
           scrollView.addSubview(photoCard)
           photoCard.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               photoCard.topAnchor.constraint(equalTo: tagsStack.bottomAnchor, constant: 20),
               photoCard.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
               photoCard.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
               photoCard.heightAnchor.constraint(equalToConstant: 200)
           ])
           
           photoCard.addSubview(photoImageView)
           photoCard.addSubview(addPhotoButton)
           photoImageView.translatesAutoresizingMaskIntoConstraints = false
           addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([
               photoImageView.topAnchor.constraint(equalTo: photoCard.topAnchor),
               photoImageView.leadingAnchor.constraint(equalTo: photoCard.leadingAnchor),
               photoImageView.trailingAnchor.constraint(equalTo: photoCard.trailingAnchor),
               photoImageView.bottomAnchor.constraint(equalTo: photoCard.bottomAnchor),
               
               addPhotoButton.centerXAnchor.constraint(equalTo: photoCard.centerXAnchor),
               addPhotoButton.centerYAnchor.constraint(equalTo: photoCard.centerYAnchor),
               addPhotoButton.heightAnchor.constraint(equalToConstant: 44),
               addPhotoButton.widthAnchor.constraint(equalToConstant: 180)
           ])
           
           // MARK: - Save Button
           scrollView.addSubview(saveButton)
           saveButton.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               saveButton.topAnchor.constraint(equalTo: photoCard.bottomAnchor, constant: 20),
               saveButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
               saveButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
               saveButton.heightAnchor.constraint(equalToConstant: 50),
               saveButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
           ])
           
           saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
       }

       
       
       

    // MARK: - Mood Buttons
    private func setupMoodButtons() {
        moodStack.axis = .horizontal
        moodStack.spacing = 16
        moodStack.distribution = .fillEqually
        
        let moods: [(emoji: String, label: String)] = [
            ("😄", "Отлично"),
            ("🙂", "Хорошо"),
            ("😐", "Нормально"),
            ("😔", "Грустно")
        ]
        
        for mood in moods {
            let verticalStack = UIStackView()
            verticalStack.axis = .vertical
            verticalStack.alignment = .center
            verticalStack.spacing = 4
            
            let button = UIButton(type: .system)
            button.setTitle(mood.emoji, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 32)
            button.backgroundColor = UIColor(red: 0.94, green: 0.93, blue: 0.92, alpha: 1)
            button.layer.cornerRadius = 12
            button.addTarget(self, action: #selector(moodButtonTapped(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 60).isActive = true
            button.widthAnchor.constraint(equalToConstant: 60).isActive = true
            moodButtons.append(button)
            
            let label = UILabel()
            label.text = mood.label
            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            label.textColor = UIColor.gray
            label.textAlignment = .center
            verticalStack.addArrangedSubview(button)
            verticalStack.addArrangedSubview(label)
            moodStack.addArrangedSubview(verticalStack)
        }
    }
    
    @objc private func moodButtonTapped(_ sender: UIButton) {
        for button in moodButtons {
            button.backgroundColor = UIColor(red: 0.94, green: 0.93, blue: 0.92, alpha: 1)
        }
        sender.backgroundColor = UIColor(red: 0.53, green: 0.43, blue: 0.34, alpha: 1)
        selectedMood = sender.title(for: .normal)
    }
    
    // MARK: - Photo Selection
    @objc private func addPhotoTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let mood = selectedMood else {
            let alert = UIAlertController(
                title: "Выберите эмоцию",
                message: "Пожалуйста, выберите настроение перед сохранением записи",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Ок", style: .default))
            present(alert, animated: true)
            return
        }

        let text = textView.text ?? ""
        let date = Date()
        var imageData: Data? = nil
        if let image = photoImageView.image {
            imageData = image.jpegData(compressionQuality: 0.8)
        }

        let entry = DiaryEntry(date: date, text: text, mood: mood, imageData: imageData, tags: selectedTags)
        DiaryStorage.shared.save(entry: entry)

        // Очистка UI после сохранения
        textView.text = ""
        photoImageView.image = nil
        addPhotoButton.isHidden = false
        selectedMood = nil

        // Сброс выбранных тегов
        selectedTags = []
        setupTagButtons() // <- обновляем кнопки тегов, чтобы снять выделение

        let alert = UIAlertController(title: "Сохранено", message: "Запись добавлена в дневник", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
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

// MARK: - UIColorPickerViewControllerDelegate
@available(iOS 14.0, *)
extension JournalViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
            addColorButton(viewController.selectedColor)
        }
}

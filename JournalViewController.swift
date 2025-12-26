import UIKit

class JournalViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var selectedMood: String?
    private var selectedColor: UIColor?

    let dayColors: [UIColor] = [
        UIColor(red: 0.55, green: 0.12, blue: 0.12, alpha: 1), // тёмно-красный
        UIColor.systemPink,
        UIColor.systemPurple,
        UIColor.systemBlue,
        UIColor.systemYellow
    ]
    
    private var tags: [String] = []



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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupUI()
        setupMoodButtons()
        addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
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
        
        // Mood Card
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
        
        // Entry Label & TextView
        scrollView.addSubview(entryLabel)
        entryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            entryLabel.topAnchor.constraint(equalTo: moodCard.bottomAnchor, constant: 20),
            entryLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16)
        ])
        
        
        scrollView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: entryLabel.bottomAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        // Photo Card
        // После добавления photoCard в scrollView
        // Фото дня
        scrollView.addSubview(photoCard)
        photoCard.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoCard.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
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

        // Кнопка Сохранить
        scrollView.addSubview(saveButton)
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: photoCard.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)

        
        
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
    }
    
    
    
    // MARK: - Mood Buttons
    // MARK: - UI Elements
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Сохранить", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.53, green: 0.43, blue: 0.34, alpha: 1)
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

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

        // Проверка выбора эмоции
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

        let entry = DiaryEntry(
            date: date,
            text: text,
            mood: mood,
            imageData: imageData
        )

        DiaryStorage.shared.save(entry: entry)

        // Очистка формы
        textView.text = ""
        photoImageView.image = nil
        addPhotoButton.isHidden = false
        selectedMood = nil

        let alert = UIAlertController(
            title: "Сохранено",
            message: "Запись добавлена в дневник",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }



}

// MARK: - UIImagePickerControllerDelegate
extension JournalViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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

import UIKit

class DiaryDetailViewController: UIViewController {

    private let entry: DiaryEntry

    init(entry: DiaryEntry) {
        self.entry = entry
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        title = "Запись дня"

        setupUI()
    }

    private func setupUI() {
        let moodLabel = UILabel()
        moodLabel.font = UIFont.systemFont(ofSize: 40)
        moodLabel.textAlignment = .center
        moodLabel.text = entry.mood

        let textLabel = UILabel()
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.textColor = .darkText
        textLabel.numberOfLines = 0
        textLabel.text = entry.text

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16

        if let data = entry.imageData {
            imageView.image = UIImage(data: data)
        }

        let stack = UIStackView(arrangedSubviews: [moodLabel, textLabel, imageView])
        stack.axis = .vertical
        stack.spacing = 16

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        if entry.imageData == nil {
            imageView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        } else {
            imageView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        }
    }
}

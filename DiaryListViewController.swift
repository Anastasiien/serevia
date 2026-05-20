import UIKit

class DiaryListViewController: UIViewController {

    private let accent   = UIColor(red: 0.58, green: 0.46, blue: 0.42, alpha: 1)
    private let textDark = UIColor(red: 0.20, green: 0.15, blue: 0.10, alpha: 1)
    private let textMid  = UIColor(red: 0.48, green: 0.40, blue: 0.32, alpha: 1)

    private var entries: [DiaryEntry] = []

    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        title = ""
        entries = DiaryStorage.shared.loadEntries()
        setupUI()
        setupLongPress()
    }

    private func setupUI() {
        // заголовок в едином стиле
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
        titleLabel.textColor = textDark
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Твои мысли и воспоминания"
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = textMid
        subtitleLabel.textAlignment = .center

        let divider = UIView()
        divider.backgroundColor = UIColor(red: 0.76, green: 0.68, blue: 0.58, alpha: 0.2)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let headerStack = UIStackView(arrangedSubviews: [dateLabel, titleLabel, subtitleLabel, divider])
        headerStack.axis = .vertical
        headerStack.spacing = 4
        headerStack.setCustomSpacing(14, after: subtitleLabel)
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        let spacing: CGFloat = 16

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        let width = (UIScreen.main.bounds.width - spacing * 3) / 2
        layout.itemSize = CGSize(width: width, height: width)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DiaryDateCell.self, forCellWithReuseIdentifier: "DiaryDateCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(headerStack)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            collectionView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: spacing),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: spacing),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -spacing),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupLongPress() {
        let lp = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(lp)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let point = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        let entry = entries[indexPath.item]

        let alert = UIAlertController(title: "Удалить запись?", message: "Вы уверены?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            DiaryStorage.shared.delete(entry: entry)
            self.entries.remove(at: indexPath.item)
            self.collectionView.deleteItems(at: [indexPath])
        })
        present(alert, animated: true)
    }
}

extension DiaryListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        entries.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryDateCell", for: indexPath) as! DiaryDateCell
        cell.configure(with: entries[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = DiaryDetailViewController(entry: entries[indexPath.item])
        navigationController?.pushViewController(vc, animated: true)
    }
}

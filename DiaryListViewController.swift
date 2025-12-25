import UIKit

class DiaryListViewController: UIViewController {

    private var entries: [DiaryEntry] = []

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.width - 16 * 3) / 2
        layout.itemSize = CGSize(width: width, height: width)


        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()
    
    private func setupLongPress() {
        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
        collectionView.addGestureRecognizer(longPress)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        title = "Мой дневник"

        entries = DiaryStorage.shared.loadEntries()
        setupCollectionView()
        setupLongPress()
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        let point = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }

        let entry = entries[indexPath.item]

        let alert = UIAlertController(
            title: "Удалить запись?",
            message: "Вы уверены, что хотите удалить эту запись?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }

            DiaryStorage.shared.delete(entry: entry)
            self.entries.remove(at: indexPath.item)
            self.collectionView.deleteItems(at: [indexPath])
        }))

        present(alert, animated: true)
    }


    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DiaryDateCell.self, forCellWithReuseIdentifier: "DiaryDateCell")
    }
}
extension DiaryListViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        entries.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "DiaryDateCell",
            for: indexPath
        ) as! DiaryDateCell

        cell.configure(with: entries[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let entry = entries[indexPath.item]
        let vc = DiaryDetailViewController(entry: entry)
        navigationController?.pushViewController(vc, animated: true)
    }
}

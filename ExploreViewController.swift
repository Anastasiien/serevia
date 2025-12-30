import UIKit

class ExploreViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupExploreScreen()
    }
    
    private func setupExploreScreen() {
        view.backgroundColor = AppColors.background
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Заголовок
        let titleLabel = UILabel()
        titleLabel.text = "Интересное" // оставляем текст для Explore
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(red: 0.36, green: 0.29, blue: 0.22, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])

        
        // Статьи
        let articlesLabel = UILabel()
        articlesLabel.text = "Статьи"
        articlesLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        articlesLabel.textColor = AppColors.text
        articlesLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(articlesLabel)
        NSLayoutConstraint.activate([
            articlesLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            articlesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
        
        let articlesScroll = createHorizontalScrollStack(items: [
            ("Управление стрессом", "Психология", "5 мин"),
            ("Сила благодарности", "Саморазвитие", "7 мин"),
            ("Осознанное дыхание", "Практики", "4 мин")
        ], isArticle: true)
        contentView.addSubview(articlesScroll)
        NSLayoutConstraint.activate([
            articlesScroll.topAnchor.constraint(equalTo: articlesLabel.bottomAnchor, constant: 15),
            articlesScroll.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            articlesScroll.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            articlesScroll.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Карта желаний
        let creativityLabel = UILabel()
        creativityLabel.text = "Карта желаний"
        creativityLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        creativityLabel.textColor = AppColors.text
        creativityLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(creativityLabel)
        
        let creativityView = UIButton()
        creativityView.backgroundColor = AppColors.card
        creativityView.layer.cornerRadius = 12
        creativityView.layer.borderWidth = 1
        creativityView.layer.borderColor = AppColors.border.cgColor
        creativityView.setTitle("Создать карту желаний", for: .normal)
        creativityView.setTitleColor(AppColors.text, for: .normal)
        creativityView.addTarget(self, action: #selector(openWishMap), for: .touchUpInside)
        creativityView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(creativityView)
        
        NSLayoutConstraint.activate([
            creativityLabel.topAnchor.constraint(equalTo: articlesScroll.bottomAnchor, constant: 30),
            creativityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            creativityView.topAnchor.constraint(equalTo: creativityLabel.bottomAnchor, constant: 15),
            creativityView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            creativityView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            creativityView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        // Тесты
        let testsLabel = UILabel()
        testsLabel.text = "Тесты"
        testsLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        testsLabel.textColor = AppColors.text
        testsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(testsLabel)
        NSLayoutConstraint.activate([
            testsLabel.topAnchor.constraint(equalTo: creativityView.bottomAnchor, constant: 30),
            testsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
        
        let testsScroll = createHorizontalScrollStack(items: [
            ("Тест на стресс", "", ""),
            ("Тест на внимание", "", ""),
            ("Тест на эмоции", "", "")
        ], isArticle: false)
        contentView.addSubview(testsScroll)
        NSLayoutConstraint.activate([
            testsScroll.topAnchor.constraint(equalTo: testsLabel.bottomAnchor, constant: 15),
            testsScroll.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            testsScroll.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            testsScroll.heightAnchor.constraint(equalToConstant: 100),
            testsScroll.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func createHorizontalScrollStack(items: [(String, String, String)], isArticle: Bool) -> UIScrollView {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.heightAnchor.constraint(equalTo: scroll.heightAnchor)
        ])
        
        for item in items {
            let card = UIButton()
            card.backgroundColor = AppColors.card
            card.layer.cornerRadius = 12
            card.layer.borderWidth = 1
            card.layer.borderColor = AppColors.border.cgColor
            card.translatesAutoresizingMaskIntoConstraints = false
            card.widthAnchor.constraint(equalToConstant: 180).isActive = true
            
            let titleLabel = UILabel()
            titleLabel.text = item.0
            titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            titleLabel.textColor = AppColors.text
            titleLabel.numberOfLines = 0
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            card.addSubview(titleLabel)
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
                titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
                titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
                titleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
            ])
            
            card.addTarget(self, action: #selector(cardTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(card)
        }
        
        return scroll
    }
    
    @objc private func cardTapped(_ sender: UIButton) {
        guard let title = sender.subviews.compactMap({ $0 as? UILabel }).first?.text else { return }
        
        let detailVC = UIViewController()
        detailVC.view.backgroundColor = AppColors.background
        
        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = UIFont.systemFont(ofSize: 16)
        
        textLabel.text = title.contains("Тест") ? "// Здесь будет тест" : "// Здесь будет статья"
        
        detailVC.view.addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: detailVC.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textLabel.leadingAnchor.constraint(equalTo: detailVC.view.leadingAnchor, constant: 20),
            textLabel.trailingAnchor.constraint(equalTo: detailVC.view.trailingAnchor, constant: -20)
        ])
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @objc private func openWishMap() {
        let wishMapVC = WishMapEditorViewController()
        navigationController?.pushViewController(wishMapVC, animated: true)
    }
}

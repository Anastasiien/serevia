//
//  TestHistoryViewController.swift
//  serevia
//
//  Created by ekatizzz on 14.04.2026.
//

import UIKit

class TestHistoryViewController: UIViewController {
    
    private var history: [TestResult] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "История пройденных тестов"
        view.backgroundColor = AppColors.background
        
        setupTableView()
        loadHistory()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TestHistoryCell.self, forCellReuseIdentifier: "TestHistoryCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "testHistory"),
           let savedHistory = try? JSONDecoder().decode([TestResult].self, from: data) {
            history = savedHistory.sorted { $0.date > $1.date }
        }
        tableView.reloadData()
    }
    
    static func saveResult(testName: String, score: Double, status: String) {
        var history: [TestResult] = []
        
        if let data = UserDefaults.standard.data(forKey: "testHistory"),
           let saved = try? JSONDecoder().decode([TestResult].self, from: data) {
            history = saved
        }
        
        let newResult = TestResult(testName: testName, score: score, date: Date(), status: status)
        history.append(newResult)
        
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "testHistory")
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension TestHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.isEmpty ? 1 : history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if history.isEmpty {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "Пока нет пройденных тестов"
            cell.textLabel?.textColor = .systemGray
            cell.textLabel?.textAlignment = .center
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestHistoryCell", for: indexPath) as! TestHistoryCell
        let result = history[indexPath.row]
        cell.configure(with: result)
        return cell
    }
}

// MARK: - Castom
class TestHistoryCell: UITableViewCell {
    
    private let cardView = UIView()
    
    private let testNameLabel = UILabel()
    private let scoreLabel = UILabel()
    private let statusLabel = UILabel()
    private let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .clear
        
        cardView.backgroundColor = AppColors.card
        cardView.layer.cornerRadius = 18
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cardView.layer.shadowRadius = 8
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        testNameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        testNameLabel.textColor = AppColors.text
        testNameLabel.numberOfLines = 0
        
        scoreLabel.font = .systemFont(ofSize: 16, weight: .bold)
        scoreLabel.textColor = AppColors.primary
        
        statusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        statusLabel.textColor = AppColors.lightText
        statusLabel.numberOfLines = 0
        
        dateLabel.font = .systemFont(ofSize: 13, weight: .regular)
        dateLabel.textColor = .systemGray2
        
        let infoStack = UIStackView(arrangedSubviews: [testNameLabel, scoreLabel, statusLabel, dateLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 6
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(infoStack)
        contentView.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            infoStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            infoStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            infoStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            infoStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with result: TestResult) {
        testNameLabel.text = result.testName
        
        if result.score.truncatingRemainder(dividingBy: 1) == 0 {
            scoreLabel.text = "Балл: \(Int(result.score))"
        } else {
            scoreLabel.text = String(format: "Балл: %.1f", result.score)
        }
        
        statusLabel.text = result.status
        dateLabel.text = result.formattedDate
    }
}

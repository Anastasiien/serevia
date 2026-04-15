//
//  ProfileViewController.swift
//  serevia
//
//  Created by ekatizzz on 15.04.2026.
//

import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - Constants
    private let accent    = AppColors.primary
    private let pageBg    = AppColors.background
    private let textDark  = AppColors.text
    private let cardBg    = AppColors.card
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let avatarView = UIView()
    private let initialsLabel = UILabel()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    
    private let aboutTitleLabel = UILabel()
    private let detailsStack = UIStackView()
    private let ageLabel = UILabel()
    private let genderLabel = UILabel()
    
    private let chartTitleLabel = UILabel()
    private let chartCard = UIView()
    private let chartView = MoodChartView()
    
    private let testsTitleLabel = UILabel()
    private let testsStack = UIStackView()

    private let shareButton = UIButton(type: .system)
    private let logoutButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadUserData()
        loadMoodData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMoodData()
    }
    
    // MARK: - UI Setup
    private func setupNavigationBar() {
        let editButton = UIBarButtonItem(title: "Изм.", style: .plain, target: self, action: #selector(editProfileTapped))
        navigationItem.rightBarButtonItem = editButton
    }
    
    private func setupUI() {
        view.backgroundColor = pageBg
        title = "Личный кабинет"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        avatarView.backgroundColor = accent
        avatarView.layer.cornerRadius = 50
        initialsLabel.textColor = .white
        initialsLabel.font = .systemFont(ofSize: 40, weight: .medium)
        initialsLabel.textAlignment = .center
        
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = textDark
        
        emailLabel.font = .systemFont(ofSize: 16)
        emailLabel.textColor = textDark.withAlphaComponent(0.6)
        
        setupAboutSection()
        setupMoodChartSection()
        setupTestsSection()
        
        shareButton.setTitle("Поделиться отчетом со специалистом", for: .normal)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        shareButton.backgroundColor = accent
        shareButton.layer.cornerRadius = 16
        shareButton.addTarget(self, action: #selector(handleShareReport), for: .touchUpInside)
        
        logoutButton.setTitle("Выйти из аккаунта", for: .normal)
        logoutButton.setTitleColor(.systemRed, for: .normal)
        logoutButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        logoutButton.backgroundColor = .white
        logoutButton.layer.cornerRadius = 16
        logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        
        layoutUI()
    }

    private func setupAboutSection() {
        aboutTitleLabel.text = "О себе"
        aboutTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        aboutTitleLabel.textColor = textDark
        detailsStack.axis = .vertical
        detailsStack.spacing = 12
        detailsStack.backgroundColor = cardBg
        detailsStack.layer.cornerRadius = 20
        detailsStack.isLayoutMarginsRelativeArrangement = true
        detailsStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        [ageLabel, genderLabel].forEach {
            $0.font = .systemFont(ofSize: 16)
            $0.textColor = textDark
            detailsStack.addArrangedSubview($0)
        }
    }
    
    private func setupMoodChartSection() {
        chartTitleLabel.text = "Трекер настроения за месяц"
        chartTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        chartTitleLabel.textColor = textDark
        chartCard.backgroundColor = cardBg
        chartCard.layer.cornerRadius = 20
        chartView.backgroundColor = .clear
    }
    
    private func setupTestsSection() {
        testsTitleLabel.text = "Результаты последних тестов"
        testsTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        testsTitleLabel.textColor = textDark
        testsStack.axis = .vertical
        testsStack.spacing = 12
    }

    private func layoutUI() {
        let elements = [avatarView, nameLabel, emailLabel, aboutTitleLabel, detailsStack,
                        chartTitleLabel, chartCard, testsTitleLabel, testsStack,
                        shareButton, logoutButton]
        
        elements.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        avatarView.addSubview(initialsLabel)
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        chartCard.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            avatarView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 100),
            avatarView.heightAnchor.constraint(equalToConstant: 100),
            
            initialsLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            aboutTitleLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 25),
            aboutTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            detailsStack.topAnchor.constraint(equalTo: aboutTitleLabel.bottomAnchor, constant: 12),
            detailsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            chartTitleLabel.topAnchor.constraint(equalTo: detailsStack.bottomAnchor, constant: 25),
            chartTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            chartCard.topAnchor.constraint(equalTo: chartTitleLabel.bottomAnchor, constant: 12),
            chartCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            chartCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            chartCard.heightAnchor.constraint(equalToConstant: 200),
            
            chartView.topAnchor.constraint(equalTo: chartCard.topAnchor),
            chartView.leadingAnchor.constraint(equalTo: chartCard.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: chartCard.trailingAnchor),
            chartView.bottomAnchor.constraint(equalTo: chartCard.bottomAnchor),
            
            testsTitleLabel.topAnchor.constraint(equalTo: chartCard.bottomAnchor, constant: 30),
            testsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            testsStack.topAnchor.constraint(equalTo: testsTitleLabel.bottomAnchor, constant: 12),
            testsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            testsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            shareButton.topAnchor.constraint(equalTo: testsStack.bottomAnchor, constant: 40),
            shareButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            shareButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            shareButton.heightAnchor.constraint(equalToConstant: 55),
            
            logoutButton.topAnchor.constraint(equalTo: shareButton.bottomAnchor, constant: 16),
            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            logoutButton.heightAnchor.constraint(equalToConstant: 55),
            logoutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }

    // MARK: - Report Management
    @objc private func handleShareReport() {
        let reportText = generateFullReport()
        let name = UserDefaults.standard.string(forKey: "userName") ?? "User"
        let fileName = "Medical_Report_\(name).txt"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try reportText.write(to: path, atomically: true, encoding: .utf8)
            let vc = UIActivityViewController(activityItems: [path], applicationActivities: nil)
            
            if let popover = vc.popoverPresentationController {
                popover.sourceView = shareButton
                popover.sourceRect = shareButton.bounds
            }
            
            present(vc, animated: true)
        } catch {
            print("Ошибка создания файла отчета: \(error)")
        }
    }
    
    private func generateFullReport() -> String {
        let name = UserDefaults.standard.string(forKey: "userName") ?? "Не указано"
        let email = UserDefaults.standard.string(forKey: "userEmail") ?? "Не указано"
        let bday = UserDefaults.standard.string(forKey: "userBirthDate") ?? "Не указано"
        let gender = UserDefaults.standard.string(forKey: "userGender") ?? "Не указано"
        let moodDescriptions: [String: String] = [
            "😄": "Отлично",
            "🙂": "Хорошо",
            "😐": "Нормально",
            "😔": "Грустно"
        ]
        
        var report = """
        ОТЧЁТ О ПОЛЬЗОВАТЕЛЕ ИЗ ПРИЛОЖЕНИЯ SEREVIA
        Дата создания: \(Date().formatted(date: .numeric, time: .shortened))
        
        ЛИЧНЫЕ ДАННЫЕ:
        Имя: \(name)
        Email: \(email)
        Дата рождения: \(bday)
        Пол: \(gender)
        
        -------------------------------
        ДИНАМИКА НАСТРОЕНИЯ (За текущий месяц):
        """
        
        let entries = DiaryStorage.shared.loadEntries()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        
        let filteredEntries = entries.filter { calendar.component(.month, from: $0.date) == currentMonth }
            .sorted(by: { $0.date < $1.date })
        
        if filteredEntries.isEmpty {
            report += "\nДанные о настроении за этот месяц отсутствуют."
        } else {
            for entry in filteredEntries {
                let dateStr = entry.date.formatted(date: .numeric, time: .omitted)
                let moodKey = entry.mood.trimmingCharacters(in: .whitespacesAndNewlines)
                let description = moodDescriptions[moodKey] ?? "Нет описания"
                
                report += "\n\(dateStr): \(moodKey) — \(description)"
            }
        }
        
        report += "\n\n-------------------------------\nРЕЗУЛЬТАТЫ ПОСЛЕДНИХ ТЕСТОВ:"
        let testResults = getLastTestResults()
        
        if testResults.isEmpty {
            report += "\nТесты еще не пройдены."
        } else {
            testResults.forEach { result in
                report += "\n- \(result.testName): \(result.status)"
            }
        }
        
        report += "\n\n-------------------------------\nС уважением, команда SEREVIA."
        
        return report
    }

    // MARK: - Data Management
    private func loadUserData() {
        let name = UserDefaults.standard.string(forKey: "userName") ?? "Гость"
        let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        let bday = UserDefaults.standard.string(forKey: "userBirthDate") ?? "Не указана"
        let gender = UserDefaults.standard.string(forKey: "userGender") ?? "Не указан"
        let age = calculateAge(from: bday)
        
        nameLabel.text = name
        emailLabel.text = email
        initialsLabel.text = String(name.prefix(1)).uppercased()
        ageLabel.text = "🗓 Дата рождения: \(bday) (\(age) лет)"
        genderLabel.text = "👤 Пол: \(gender)"
        
        updateTestResults()
    }

    private func loadMoodData() {
        let entries = DiaryStorage.shared.loadEntries()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let moodMap: [String: Int] = ["😄": 5, "🙂": 4, "😐": 3, "😔": 2]
        
        var chartData: [Int: Int] = [:]
        for entry in entries {
            if calendar.component(.month, from: entry.date) == currentMonth {
                let day = calendar.component(.day, from: entry.date)
                let moodKey = entry.mood.trimmingCharacters(in: .whitespacesAndNewlines)
                if let score = moodMap[moodKey] { chartData[day] = score }
            }
        }
        chartView.configure(with: chartData)
    }

    private func updateTestResults() {
        testsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let results = getLastTestResults()
        if results.isEmpty {
            let l = UILabel(); l.text = "Нет пройденных тестов"; l.font = .systemFont(ofSize: 14); l.textColor = .gray
            testsStack.addArrangedSubview(l)
        } else {
            results.forEach { testsStack.addArrangedSubview(createTestRow(for: $0)) }
        }
    }

    private func getLastTestResults() -> [TestResult] {
        guard let data = UserDefaults.standard.data(forKey: "testHistory"),
              let history = try? JSONDecoder().decode([TestResult].self, from: data) else { return [] }
        var dict: [String: TestResult] = [:]
        history.sorted(by: { $0.date > $1.date }).forEach { if dict[$0.testName] == nil { dict[$0.testName] = $0 } }
        return Array(dict.values).sorted(by: { $0.testName < $1.testName })
    }

    private func calculateAge(from dateString: String) -> Int {
        let formatter = DateFormatter(); formatter.dateFormat = "dd.MM.yyyy"
        guard let bday = formatter.date(from: dateString) else { return 0 }
        return Calendar.current.dateComponents([.year], from: bday, to: Date()).year ?? 0
    }

    private func createTestRow(for result: TestResult) -> UIView {
        let container = UIView()
        container.backgroundColor = cardBg
        container.layer.cornerRadius = 15
        container.layer.borderWidth = 1
        container.layer.borderColor = AppColors.border.cgColor
        
        let nLabel = UILabel(); nLabel.text = result.testName; nLabel.font = .systemFont(ofSize: 17, weight: .bold)
        let sLabel = UILabel(); sLabel.text = result.status; sLabel.font = .systemFont(ofSize: 14); sLabel.textColor = accent
        
        let stack = UIStackView(arrangedSubviews: [nLabel, sLabel])
        stack.axis = .vertical; stack.spacing = 6; stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
        return container
    }

    @objc private func editProfileTapped() {
        let alert = UIAlertController(title: "Редактирование", message: "\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Имя"; $0.text = self.nameLabel.text }
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date; datePicker.preferredDatePickerStyle = .wheels; datePicker.maximumDate = Date()
        datePicker.frame = CGRect(x: 10, y: 50, width: 250, height: 140)
        alert.view.addSubview(datePicker)
        alert.addAction(UIAlertAction(title: "Далее (Пол)", style: .default) { _ in
            let name = alert.textFields?.first?.text ?? ""
            let formatter = DateFormatter(); formatter.dateFormat = "dd.MM.yyyy"
            self.showGenderSelection(name: name, bday: formatter.string(from: datePicker.date))
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showGenderSelection(name: String, bday: String) {
        let sheet = UIAlertController(title: "Выберите пол", message: nil, preferredStyle: .actionSheet)
        ["Мужской", "Женский"].forEach { gender in
            sheet.addAction(UIAlertAction(title: gender, style: .default) { _ in
                UserDefaults.standard.set(name, forKey: "userName")
                UserDefaults.standard.set(bday, forKey: "userBirthDate")
                UserDefaults.standard.set(gender, forKey: "userGender")
                
                NotificationCenter.default.post(name: .userDataDidChange, object: nil)
                
                self.loadUserData()
            })
        }
        sheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func handleLogout() {
        let alert = UIAlertController(title: "Выход", message: "Вы уверены?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { _ in
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = AuthViewController()
                UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: nil)
            }
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
}

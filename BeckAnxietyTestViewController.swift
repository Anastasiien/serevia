//
//  BeckAnxietyTestViewController.swift
//  serevia
//
//  Created by ekatizzz on 02.04.2026.
//

import UIKit

class BeckAnxietyTestViewController: UIViewController {
    
    // MARK: - Model
    struct Question {
        let text: String
    }
    
    private let options = [
        "Совсем не беспокоил",
        "Слегка (не слишком неприятно)",
        "Умеренно (было неприятно, но можно перенести)",
        "Очень сильно (с трудом мог выносить)"
    ]
    
    private let questions: [Question] = [
        Question(text: "Ощущение онемения или покалывания"),
        Question(text: "Ощущение жара"),
        Question(text: "Дрожь в ногах"),
        Question(text: "Неспособность расслабиться"),
        Question(text: "Страх того, что случится самое худшее"),
        Question(text: "Головокружение или легкость в голове"),
        Question(text: "Учащенное сердцебиение"),
        Question(text: "Неустойчивость (ощущение шаткости)"),
        Question(text: "Чувство ужаса или паники"),
        Question(text: "Нервозность"),
        Question(text: "Ощущение удушья (нехватка воздуха)"),
        Question(text: "Дрожь в руках"),
        Question(text: "Шаткость походки"),
        Question(text: "Страх потери контроля"),
        Question(text: "Затруднения при дыхании"),
        Question(text: "Страх смерти"),
        Question(text: "Испуг"),
        Question(text: "Дискомфорт в животе (пищеварение)"),
        Question(text: "Обморочное состояние"),
        Question(text: "Покраснение лица"),
        Question(text: "Потливость (не связанная с жарой)")
    ]

    // MARK: - State
    private var currentQuestionIndex = 0
    private var totalScore = 0

    // MARK: - UI Elements
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let counterLabel = UILabel()
    
    private let mainContainerStack = UIStackView()
    private let descriptionLabel = UILabel()
    private let questionTitleLabel = UILabel()
    private let optionsStackView = UIStackView()
    
    private let startButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showInstructions()
    }

    private func setupUI() {
        view.backgroundColor = AppColors.background
        title = "Уровень тревожности"
        
        progressView.progressTintColor = AppColors.primary
        progressView.trackTintColor = AppColors.accent.withAlphaComponent(0.3)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        counterLabel.font = .systemFont(ofSize: 14, weight: .medium)
        counterLabel.textColor = AppColors.lightText
        counterLabel.textAlignment = .center
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(counterLabel)
        
        mainContainerStack.axis = .vertical
        mainContainerStack.spacing = 24
        mainContainerStack.alignment = .fill
        mainContainerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainContainerStack)
        
        descriptionLabel.textColor = AppColors.text
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .left
        
        questionTitleLabel.textColor = AppColors.text
        questionTitleLabel.numberOfLines = 0
        questionTitleLabel.textAlignment = .center
        
        optionsStackView.axis = .vertical
        optionsStackView.spacing = 12
        optionsStackView.distribution = .fill
        
        mainContainerStack.addArrangedSubview(descriptionLabel)
        mainContainerStack.addArrangedSubview(questionTitleLabel)
        mainContainerStack.addArrangedSubview(optionsStackView)
        
        startButton.setTitle("Начать тест", for: .normal)
        startButton.backgroundColor = AppColors.primary
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        startButton.layer.cornerRadius = 16
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(startTest), for: .touchUpInside)
        view.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            counterLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
            counterLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            mainContainerStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainContainerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            mainContainerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 280),
            startButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func showInstructions() {
        descriptionLabel.isHidden = false
        descriptionLabel.text = """
        Шкала тревоги Бека (BAI) — надежный метод оценки физических и когнитивных симптомов тревожности.

        Инструкция:
        • Оцените свое состояние за последние 7 дней.
        • Насколько сильно каждый из перечисленных симптомов беспокоил вас?

        Результаты теста носят ознакомительный характер и не являются диагнозом. При необходимости проконсультируйтесь со специалистом.
        """
        
        questionTitleLabel.text = "Готовы начать?"
        questionTitleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        optionsStackView.isHidden = true
        progressView.isHidden = true
        counterLabel.isHidden = true
        startButton.isHidden = false
    }

    @objc private func startTest() {
        UIView.animate(withDuration: 0.3) {
            self.descriptionLabel.isHidden = true
            self.startButton.isHidden = true
            self.optionsStackView.isHidden = false
            self.progressView.isHidden = false
            self.counterLabel.isHidden = false
        }
        updateQuestion()
    }

    private func updateQuestion() {
        let currentQuestion = questions[currentQuestionIndex]
        counterLabel.text = "Вопрос \(currentQuestionIndex + 1) из \(questions.count)"
        
        let mainText = "Насколько сильно вас беспокоил симптом:\n\n"
        let symptomText = currentQuestion.text
        
        let attributedString = NSMutableAttributedString(string: mainText, attributes: [
            .font: UIFont.systemFont(ofSize: 15, weight: .regular),
            .foregroundColor: AppColors.lightText
        ])
        
        attributedString.append(NSAttributedString(string: symptomText, attributes: [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: AppColors.text
        ]))
        
        questionTitleLabel.attributedText = attributedString
        
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, option) in options.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            button.setTitleColor(AppColors.text, for: .normal)
            button.backgroundColor = AppColors.card
            button.layer.cornerRadius = 14
            button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
            button.tag = index
            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.05
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 4
            
            optionsStackView.addArrangedSubview(button)
        }
        
        let progress = Float(currentQuestionIndex + 1) / Float(questions.count)
        progressView.setProgress(progress, animated: true)
    }

    @objc private func optionSelected(_ sender: UIButton) {
        totalScore += sender.tag
        
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            UIView.transition(with: optionsStackView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.updateQuestion()
            })
        } else {
            showResults()
        }
    }

    private func showResults() {
        let (status, description) = interpretScore(totalScore)
        
        let alert = UIAlertController(
            title: "Результат: \(totalScore) баллов",
            message: "\(status)\n\n\(description)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Завершить", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    private func interpretScore(_ score: Int) -> (String, String) {
        switch score {
        case 0...21:
            return ("Низкий уровень тревожности", "Ваше состояние в пределах нормы. Незначительные симптомы не требуют лечения.")
        case 22...35:
            return ("Средний уровень тревожности", "У вас наблюдается умеренная тревожность. Стоит проанализировать причины стресса.")
        case 36...63:
            return ("Высокий уровень тревожности", "Постарайтесь быть менее требовательным и категоричным к себе, тревога существенно влияет на вашу жизнь. Рекомендуется консультация специалиста.")
        default:
            return ("Результат", "Тест завершен.")
        }
    }
}

//
//  MindfulnessTestViewController.swift
//  serevia
//
//  Created by ekatizzz on 03.04.2026.
//

import UIKit

class MindfulnessTestViewController: UIViewController {
    
    // MARK: - Model
    private let questions = [
        "1. Я могу испытывать какую-то эмоцию и не осознавать этого до тех пор, пока не пройдет некоторое время.",
        "2. Я ломаю или проливаю что-то из-за небрежности, невнимательности или потому, что думаю о чем-то другом.",
        "3. Мне трудно оставаться сосредоточенным на том, что происходит в настоящий момент.",
        "4. Я имею привычку ходить очень быстро, чтобы добраться до места, не обращая внимания на то, что встречается мне по пути.",
        "5. Я склонен не замечать физических ощущений напряжения или дискомфорта, пока они действительно не привлекут мое внимание.",
        "6. Я забываю имя человека почти сразу после того, как мне его назвали в первый раз.",
        "7. Кажется, что я действую «на автомате», не слишком осознавая то, что я делаю.",
        "8. Я выполняю свои дела, не слишком вникая в них.",
        "9. Я так сильно сосредоточен на цели, которую хочу достичь, что теряю связь с тем, что я делаю прямо сейчас для этого.",
        "10. Я выполняю работу или задания механически, не осознавая, что именно я делаю.",
        "11. Я ловлю себя на том, что слушаю кого-то вполуха, одновременно делая что-то другое.",
        "12. Я прихожу в какое-то место «на автопилоте» и потом удивляюсь, как я там оказался.",
        "13. Я ловлю себя на том, что поглощен мыслями о будущем или прошлом.",
        "14. Я ловлю себя на том, что делаю что-то, не уделяя этому внимания.",
        "15. Я перекусываю, не осознавая, что я ем."
    ]
    
    private let options = [
        "Почти всегда",
        "Очень часто",
        "Довольно часто",
        "Иногда",
        "Редко",
        "Почти никогда"
    ]

    // MARK: - State
    private var currentQuestionIndex = 0
    private var totalPoints = 0

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
        title = "Внимательность и осознанность"

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
        optionsStackView.spacing = 10
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
        Тест внимательности и осознанности (MAAS) измеряет вашу способность находиться в настоящем моменте.

        Инструкция:
        • Оцените, как часто вы сталкиваетесь с описанными ситуациями.
        • Отвечайте искренне, основываясь на реальном опыте «автопилота» в жизни.

        Результаты теста носят ознакомительный характер и не являются диагнозом. При необходимости проконсультируйтесь со специалистом.
        """
        questionTitleLabel.attributedText = nil
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
        let questionText = questions[currentQuestionIndex]
        counterLabel.text = "Вопрос \(currentQuestionIndex + 1) из \(questions.count)"
        
        let mainText = "Как часто это происходит с вами?\n\n"
        let attributedString = NSMutableAttributedString(string: mainText, attributes: [
            .font: UIFont.systemFont(ofSize: 15, weight: .regular),
            .foregroundColor: AppColors.lightText
        ])
        
        attributedString.append(NSAttributedString(string: questionText, attributes: [
            .font: UIFont.systemFont(ofSize: 19, weight: .bold),
            .foregroundColor: AppColors.text
        ]))
        
        questionTitleLabel.attributedText = attributedString
        
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, option) in options.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            button.setTitleColor(AppColors.text, for: .normal)
            button.backgroundColor = AppColors.card
            button.layer.cornerRadius = 14
            button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            button.tag = index + 1
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
        totalPoints += sender.tag
        
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
        let averageScore = Double(totalPoints) / 15.0
        let (status, description) = interpretScore(averageScore)
        
        TestHistoryViewController.saveResult(
            testName: "Внимательность и осознанность",
            score: Double(averageScore),
            status: status
        )
        
        let alert = UIAlertController(
            title: String(format: "Ваш балл: %.1f", averageScore),
            message: "\(status)\n\n\(description)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Завершить", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    private func interpretScore(_ score: Double) -> (String, String) {
        switch score {
        case 1.0...3.0:
            return ("Низкий уровень осознанности", "Вы часто действуете на «автопилоте». Практики медитации помогут вам чаще возвращаться в настоящий момент.")
        case 3.1...4.5:
            return ("Средний уровень осознанности", "Вы умеете присутствовать в моменте, но внешние факторы часто отвлекают вас.")
        case 4.6...6.0:
            return ("Высокий уровень осознанности", "Вы глубоко проживаете текущий момент. Это ваша суперсила.")
        default:
            return ("Результат", "Тест завершен.")
        }
    }
}

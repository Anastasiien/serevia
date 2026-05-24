//
//  BeckTestViewController.swift
//  serevia
//
//  Created by ekatizzz on 01.04.2026.
//

import UIKit

class BeckTestViewController: UIViewController {
    
    // MARK: - Model
    struct Question {
        let options: [String]
    }
    
    private let questions: [Question] = [
        Question(options: ["Я не чувствую себя расстроенным, печальным.", "Я расстроен.", "Я все время расстроен и не могу от этого отключиться.", "Я настолько расстроен и несчастлив, что не могу это выдержать."]),
        Question(options: ["Я не тревожусь о своем будущем.", "Я чувствую, что озадачен будущим.", "Я чувствую, что меня ничего не ждет в будущем.", "Мое будущее безнадежно, и ничто не может измениться к лучшему."]),
        Question(options: ["Я не чувствую себя неудачником.", "Я чувствую, что терпел больше неудач, чем другие люди.", "Когда я оглядываюсь на свою жизнь, я вижу в ней много неудач.", "Я чувствую, что как личность я — полный неудачник."]),
        Question(options: ["Я получаю столько же удовлетворения от жизни, как раньше.", "Я не получаю столько же удовлетворения от жизни, как раньше.", "Я больше не получаю удовлетворения ни от чего.", "Я полностью не удовлетворен жизнью и мне все надоело."]),
        Question(options: ["Я не чувствую себя в чем-нибудь виноватым.", "Достаточно часто я чувствую себя виноватым.", "Большую часть времени я чувствую себя виноватым.", "Я постоянно испытываю чувство вины."]),
        Question(options: ["Я не чувствую, что могу быть наказанным за что-либо.", "Я чувствую, что могу быть наказан.", "Я ожидаю, что могу быть наказан.", "Я чувствую себя уже наказанным."]),
        Question(options: ["Я не разочаровался в себе.", "Я разочаровался в себе.", "Я себе противен.", "Я себя ненавижу."]),
        Question(options: ["Я знаю, что я не хуже других.", "Я критикую себя за ошибки и слабости.", "Я все время обвиняю себя за свои поступки.", "Я виню себя во всем плохом, что происходит."]),
        Question(options: ["Я никогда не думал покончить с собой.", "Ко мне приходят мысли покончить с собой, но я не буду их осуществлять.", "Я хотел бы покончить с собой.", "Я бы убил себя, если бы представился случай."]),
        Question(options: ["Я плачу не больше, чем обычно.", "Сейчас я плачу чаще, чем раньше.", "Теперь я все время плачу.", "Раньше я мог плакать, а сейчас не могу, даже если мне хочется."]),
        Question(options: ["Сейчас я раздражителен не более, чем обычно.", "Я более легко раздражаюсь, чем раньше.", "Теперь я постоянно чувствую, что раздражен.", "Я стал равнодушен к вещам, которые меня раньше раздражали."]),
        Question(options: ["Я не утратил интереса к другим людям.", "Я меньше интересуюсь другими людьми, чем раньше.", "Я почти потерял интерес к другим людям.", "Я полностью утратил интерес к другим людям."]),
        Question(options: ["Я откладываю принятие решения иногда, как и раньше.", "Я чаще, чем раньше, откладываю принятие решения.", "Мне труднее принимать решения, чем раньше.", "Я больше не могу принимать решения."]),
        Question(options: ["Я не чувствую, что выгляжу хуже, чем обычно.", "Меня тревожит, что я выгляжу старым и непривлекательным.", "Я знаю, что в моей внешности произошли существенные изменения.", "Я знаю, что выгляжу безобразно."]),
        Question(options: ["Я могу работать так же хорошо, как и раньше.", "Мне необходимо сделать усилие, чтобы начать делать что-нибудь.", "Я с трудом заставляю себя делать что-либо.", "Я совсем не могу выполнять никакую работу."]),
        Question(options: ["Я сплю так же хорошо, как и раньше.", "Сейчас я сплю хуже, чем раньше.", "Я просыпаюсь на 1-2 часа раньше обычного.", "Я просыпаюсь на несколько часов раньше и не могу заснуть."]),
        Question(options: ["Я устаю не больше, чем обычно.", "Теперь я устаю быстрее, чем раньше.", "Я устаю почти от всего, что я делаю.", "Я не могу ничего делать из-за усталости."]),
        Question(options: ["Мой аппетит не хуже, чем обычно.", "Мой аппетит стал хуже, чем раньше.", "Мой аппетит теперь значительно хуже.", "У меня вообще нет аппетита."]),
        Question(options: ["Я не худел в последнее время.", "Я потерял более 2 кг.", "Я потерял более 5 кг.", "Я потерял более 7 кг."]),
        Question(options: ["Я беспокоюсь о здоровье не больше обычного.", "Меня тревожат физические проблемы (боли, желудок).", "Я очень обеспокоен своим состоянием.", "Я настолько обеспокоен, что не могу думать ни о чем другом."]),
        Question(options: ["Интерес к близости не изменился.", "Меня меньше занимает эта тема, чем раньше.", "Сейчас я значительно меньше интересуюсь этим.", "Я полностью утратил интерес."] )
    ]

    // MARK: - State
    private var currentQuestionIndex = 0
    private var totalScore = 0

    // MARK: - UI Elements
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let counterLabel = UILabel()
    
    private let mainContainerStack = UIStackView()
    private let questionTitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let optionsStackView = UIStackView()
    
    private let startButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showInstructions()
    }

    private func setupUI() {
        view.backgroundColor = AppColors.background
        title = "Уровень депрессии"

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
        questionTitleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        
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
        descriptionLabel.text = """
        Шкала депрессии Бека (BDI) — это научный инструмент для оценки тяжести депрессивных состояний.

        Инструкция:
        • Внимательно прочитайте варианты ответов в каждом вопросе.
        • Выберите одно утверждение, которое лучше всего описывает ваше состояние за последнюю неделю, включая сегодняшний день.

        Результаты теста носят ознакомительный характер и не являются диагнозом. При необходимости проконсультируйтесь со специалистом.
        """
        questionTitleLabel.text = "Готовы начать?"
        
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
        let question = questions[currentQuestionIndex]
        counterLabel.text = "Вопрос \(currentQuestionIndex + 1) из \(questions.count)"
        questionTitleLabel.text = "Выберите подходящее утверждение:"
        
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, option) in question.options.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            button.titleLabel?.textAlignment = .center
            button.setTitleColor(AppColors.text, for: .normal)
            button.backgroundColor = AppColors.card
            button.layer.cornerRadius = 14
            button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
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

    @objc func optionSelected(_ sender: UIButton) {
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
        
        TestHistoryViewController.saveResult(
            testName: "Уровень депрессии",
            score: Double(totalScore),
            status: status
        )
        
        let alert = UIAlertController(
            title: "Результат: \(totalScore) баллов",
            message: """
            \(status)

            \(description)
            
            Помните: результаты носят ознакомительный характер. Если вы чувствуете потребность, обратитесь к специалисту.
            """,
            preferredStyle: .alert
        )

        let finishAction = UIAlertAction(
            title: "Завершить",
            style: .default
        ) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }

        alert.addAction(finishAction)

        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: false)
        }
    }

    private func interpretScore(_ score: Int) -> (String, String) {
        switch score {
        case 0...9:   return ("Норма", "Отсутствие депрессивных симптомов.")
        case 10...15: return ("Субдепрессия", "Легкая депрессия. Рекомендуется отдых и внимание к себе.")
        case 16...19: return ("Умеренная депрессия", "Стоит обратить внимание на ментальное здоровье.")
        case 20...29: return ("Выраженная депрессия", "Средняя тяжесть. Рекомендуется консультация специалиста.")
        case 30...63: return ("Тяжелая депрессия", "Необходимо обратиться к специалисту в ближайшее время.")
        default:      return ("Результат", "Тест завершен.")
        }
    }
}

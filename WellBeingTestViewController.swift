//
//  WellBeingTestViewController.swift
//  serevia
//
//  Created by ekatizzz on 05.04.2026.
//

import UIKit

class WellBeingTestViewController: UIViewController {
    
    // MARK: - Model
    struct Question {
        let text: String
        let scale: Int // 0: Отношения, 1: Автономия, 2: Мастерство, 3: Рост, 4: Цели, 5: Самопринятие
        let isReverse: Bool
    }
    
    private let questions: [Question] = [
        Question(text: "1. Большинство моих знакомых считают меня любящим и преданным человеком.", scale: 0, isReverse: false),
        Question(text: "2. Иногда я меняю свое поведение или образ мышления, чтобы не выделяться.", scale: 1, isReverse: true),
        Question(text: "3. Как правило, я считаю себя в ответе за то, как я живу.", scale: 2, isReverse: false),
        Question(text: "4. Меня не интересуют занятия, которые принесут результат в отдаленном будущем.", scale: 3, isReverse: true),
        Question(text: "5. Мне приятно думать о том, что я совершил в прошлом и надеюсь совершить в будущем.", scale: 4, isReverse: false),
        Question(text: "6. Когда я оглядываюсь назад, мне нравится, как сложилась моя жизнь.", scale: 5, isReverse: false),
        Question(text: "7. Поддержание близких отношений было связано для меня с трудностями и разочарованиями.", scale: 0, isReverse: true),
        Question(text: "8. Я не боюсь высказывать свое мнение, даже если оно противоречит мнению большинства.", scale: 1, isReverse: false),
        Question(text: "9. Требования повседневной жизни часто угнетают меня.", scale: 2, isReverse: true),
        Question(text: "10. В принципе, я считаю, что со временем узнаю о себе всё больше и больше.", scale: 3, isReverse: false),
        Question(text: "11. Я живу сегодняшним днем и не особо задумываюсь о будущем.", scale: 4, isReverse: true),
        Question(text: "12. В целом я уверен в себе.", scale: 5, isReverse: false),
        Question(text: "13. Мне часто бывает одиноко из-за того, что у меня мало друзей, с кем я могу поделиться своими проблемами.", scale: 0, isReverse: true),
        Question(text: "14. На мои решения обычно не влияет то, что делают другие.", scale: 1, isReverse: false),
        Question(text: "15. Я не очень вписываюсь в сообщество окружающих меня людей.", scale: 2, isReverse: true),
        Question(text: "16. Я отношусь к тем людям, которым нравится пробовать всё новое.", scale: 3, isReverse: false),
        Question(text: "17. Я стараюсь сосредоточиться на настоящем, потому что будущее почти всегда приносит какие-то проблемы.", scale: 4, isReverse: true),
        Question(text: "18. Мне кажется, что многие из моих знакомых преуспели в жизни больше, чем я.", scale: 5, isReverse: true),
        Question(text: "19. Я люблю задушевные беседы с родными или друзьями.", scale: 0, isReverse: false),
        Question(text: "20. Меня беспокоит то, что думают обо мне другие.", scale: 1, isReverse: true),
        Question(text: "21. Я вполне справляюсь со своими повседневными заботами.", scale: 2, isReverse: false),
        Question(text: "22. Я не хочу пробовать новые виды деятельности – моя жизнь и так меня устраивает.", scale: 3, isReverse: true),
        Question(text: "23. Моя жизнь имеет смысл.", scale: 4, isReverse: false),
        Question(text: "24. Если бы у меня была такая возможность, я бы многое в себе изменил.", scale: 5, isReverse: true),
        Question(text: "25. Мне кажется важным быть хорошим слушателем, когда близкие друзья делятся со мной своими проблемами.", scale: 0, isReverse: false),
        Question(text: "26. Для меня важнее быть в согласии с самим собой, чем получать одобрение окружающих.", scale: 1, isReverse: false),
        Question(text: "27. Я часто чувствую, что мои обязанности угнетают меня.", scale: 2, isReverse: true),
        Question(text: "28. Мне кажется, что новый опыт, способный изменить мои представления о себе и об окружающем мире, очень важен.", scale: 3, isReverse: false),
        Question(text: "29. Мои повседневные дела часто кажутся мне банальными и незначительными.", scale: 4, isReverse: true),
        Question(text: "30. В целом я себе нравлюсь.", scale: 5, isReverse: false),
        Question(text: "31. У меня не так много знакомых, готовых выслушать меня, когда мне нужно выговориться.", scale: 0, isReverse: true),
        Question(text: "32. На меня оказывают влияние сильные люди.", scale: 1, isReverse: true),
        Question(text: "33. Если бы я был несчастен в жизни, я предпринял бы эффективные меры, чтобы изменить ситуацию.", scale: 2, isReverse: false),
        Question(text: "34. Если задуматься, то с годами я не стал намного лучше.", scale: 3, isReverse: true),
        Question(text: "35. Я не очень хорошо осознаю, чего хочу достичь в жизни.", scale: 4, isReverse: true),
        Question(text: "36. Я совершал ошибки, но всё, что ни делается, – всё к лучшему.", scale: 5, isReverse: false),
        Question(text: "37. Я считаю, что многое получаю от друзей.", scale: 0, isReverse: false),
        Question(text: "38. Людям редко удается уговорить меня сделать то, чего я сам не хочу.", scale: 1, isReverse: false),
        Question(text: "39. Я неплохо справляюсь со своими финансовыми делами.", scale: 2, isReverse: false),
        Question(text: "40. На мой взгляд, человек способен расти и развиваться в любом возрасте.", scale: 3, isReverse: false),
        Question(text: "41. Когда-то я ставил перед собой цели, но теперь это кажется мне пустой тратой времени.", scale: 4, isReverse: true),
        Question(text: "42. Во многом я разочарован своими достижениями в жизни.", scale: 5, isReverse: true),
        Question(text: "43. Мне кажется, что у большинства людей больше друзей, чем у меня.", scale: 0, isReverse: true),
        Question(text: "44. Для меня важнее приспособиться к окружающим людям, чем в одиночку отстаивать свои принципы.", scale: 1, isReverse: true),
        Question(text: "45. Я расстраиваюсь, когда не успеваю сделать всё, что намечено на день.", scale: 2, isReverse: true),
        Question(text: "46. Со временем я стал лучше разбираться в жизни, и это сделало меня более сильным и компетентным.", scale: 3, isReverse: false),
        Question(text: "47. Мне доставляет удовольствие составлять планы на будущее и воплощать их в жизнь.", scale: 4, isReverse: false),
        Question(text: "48. Как правило, я горжусь тем, какой я, и какой образ жизни я веду.", scale: 5, isReverse: false),
        Question(text: "49. Окружающие считают меня отзывчивым человеком, у которого всегда найдется время для других.", scale: 0, isReverse: false),
        Question(text: "50. Я уверен в своих суждениях, даже если они идут вразрез с общепринятым мнением.", scale: 1, isReverse: false),
        Question(text: "51. Я умею рассчитывать свое время так, чтобы всё делать в срок.", scale: 2, isReverse: false),
        Question(text: "52. У меня есть ощущение, что с годами я стал лучше.", scale: 3, isReverse: false),
        Question(text: "53. Я активно стараюсь осуществлять планы, которые составляю для себя.", scale: 4, isReverse: false),
        Question(text: "54. Я завидую образу жизни многих людей.", scale: 5, isReverse: true),
        Question(text: "55. У меня было мало теплых доверительных отношений с другими людьми.", scale: 0, isReverse: true),
        Question(text: "56. Мне трудно высказывать свое мнение по спорным вопросам.", scale: 1, isReverse: true),
        Question(text: "57. Я занятой человек, но я получаю удовольствие от того, что справляюсь с делами.", scale: 2, isReverse: false),
        Question(text: "58. Я не люблю оказываться в новых ситуациях, когда нужно менять привычный для меня способ поведения.", scale: 3, isReverse: true),
        Question(text: "59. Я не отношусь к людям, которые скитаются по жизни безо всякой цели.", scale: 4, isReverse: false),
        Question(text: "60. Возможно, я отношусь к себе хуже, чем большинство людей.", scale: 5, isReverse: true),
        Question(text: "61. Когда дело доходит до дружбы, я часто чувствую себя сторонним наблюдателем.", scale: 0, isReverse: true),
        Question(text: "62. Я часто меняю свою точку зрения, если друзья или родные не согласны с ней.", scale: 1, isReverse: true),
        Question(text: "63. Я не люблю строить планы на день, потому что никогда не успеваю сделать всё запланированное.", scale: 2, isReverse: true),
        Question(text: "64. Для меня жизнь – это непрерывный процесс познания и развития.", scale: 3, isReverse: false),
        Question(text: "65. Мне иногда кажется, что я уже совершил в жизни всё, что было можно.", scale: 4, isReverse: true),
        Question(text: "66. Я часто просыпаюсь с мыслью о том, что жил неправильно.", scale: 5, isReverse: true),
        Question(text: "67. Я знаю, что могу доверять моим друзьям, а они знают, что могут доверять мне.", scale: 0, isReverse: false),
        Question(text: "68. Я не из тех, кто поддается давлению общества в том, как себя вести и как мыслить.", scale: 1, isReverse: false),
        Question(text: "69. Мне удалось найти себе подходящее занятие и нужные мне отношения.", scale: 2, isReverse: false),
        Question(text: "70. Мне нравится наблюдать, как с годами мои взгляды изменились и стали более зрелыми.", scale: 3, isReverse: false),
        Question(text: "71. Цели, которые я ставил перед собой, чаще приносили мне радость, нежели разочарование.", scale: 4, isReverse: false),
        Question(text: "72. В моем прошлом были взлеты и падения, но я не хотел бы ничего менять.", scale: 5, isReverse: false),
        Question(text: "73. Мне трудно полностью раскрыться в общении с людьми.", scale: 0, isReverse: true),
        Question(text: "74. Меня беспокоит, как окружающие оценивают то, что я выбираю в жизни.", scale: 1, isReverse: true),
        Question(text: "75. Мне трудно обустроить свою жизнь так, как хотелось бы.", scale: 2, isReverse: true),
        Question(text: "76. Я уже давно не пытаюсь изменить или улучшить свою жизнь.", scale: 3, isReverse: true),
        Question(text: "77. Мне приятно думать о том, чего я достиг в жизни.", scale: 4, isReverse: false),
        Question(text: "78. Когда я сравниваю себя со своими друзьями и знакомыми, то понимаю, что я во многом лучше их.", scale: 5, isReverse: false),
        Question(text: "79. Мы с моими друзьями относимся с сочувствием к проблемам друг друга.", scale: 0, isReverse: false),
        Question(text: "80. Я сужу о себе исходя из того, что я считаю важным, а не из того, что считают важным другие.", scale: 1, isReverse: false),
        Question(text: "81. Мне удалось создать себе такое жилище и такой образ жизни, которые мне очень нравятся.", scale: 2, isReverse: false),
        Question(text: "82. Старого пса не научить новым трюкам.", scale: 3, isReverse: true),
        Question(text: "83. Я не уверен, что мне стоит чего-то ждать от жизни.", scale: 4, isReverse: true),
        Question(text: "84. Каждый имеет недостатки, но у меня их больше, чем у других.", scale: 5, isReverse: true)
    ]

    private let options = ["Абсолютно не согласен", "Не согласен", "Скорее не согласен", "Скорее согласен", "Согласен", "Абсолютно согласен"]

    // MARK: - State
    private var currentQuestionIndex = 0
    private var scaleScores = Array(repeating: 0, count: 6)

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
        title = "Психологическое благополучие"
        
        progressView.progressTintColor = AppColors.primary
        progressView.trackTintColor = AppColors.accent.withAlphaComponent(0.3)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        counterLabel.font = .systemFont(ofSize: 14, weight: .medium)
        counterLabel.textColor = AppColors.lightText
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(counterLabel)
        
        mainContainerStack.axis = .vertical
        mainContainerStack.spacing = 24
        mainContainerStack.alignment = .fill
        mainContainerStack.distribution = .fill
        mainContainerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainContainerStack)
        
        descriptionLabel.textColor = AppColors.text
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .left
        
        questionTitleLabel.textColor = AppColors.text
        questionTitleLabel.numberOfLines = 0
        questionTitleLabel.textAlignment = .center
        questionTitleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        
        optionsStackView.axis = .vertical
        optionsStackView.spacing = 10
        optionsStackView.distribution = .fillEqually
        
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
        Методика Кэрол Рифф (PWB) — один из самых точных научных инструментов для оценки вашего психологического здоровья по 6 ключевым направлениям:
        
        Самопринятие: Позитивная оценка себя и своего прошлого, принятие своих хороших и плохих сторон.
        Позитивные отношения с окружающими: Способность к близким, доверительным отношениям, эмпатия и забота.
        Автономия: Независимость, способность противостоять социальному давлению, самостоятельность в решениях.
        Мастерство: Умение создавать подходящие условия жизни, эффективно использовать возможности.
        Цели в жизни: Наличие смысла жизни, целей и ощущение, что прошлое и настоящее осмысленны.
        Личностный рост: Стремление к самосовершенствованию, ощущение развития и реализации своего потенциала. 
        
        Инструкция:
        • Вам предстоит оценить 84 утверждения.
        • Будьте искренни: здесь нет верных или неверных ответов, выбирайте вариант, который первым откликается внутри.

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
        let q = questions[currentQuestionIndex]
        counterLabel.text = "Вопрос \(currentQuestionIndex + 1) из 84"
        questionTitleLabel.text = q.text
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, option) in options.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(option, for: .normal)
            btn.backgroundColor = AppColors.card
            btn.setTitleColor(AppColors.text, for: .normal)
            btn.layer.cornerRadius = 12
            btn.titleLabel?.numberOfLines = 0
            btn.titleLabel?.textAlignment = .center
            btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
            btn.tag = index + 1
            btn.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
            optionsStackView.addArrangedSubview(btn)
        }
        progressView.setProgress(Float(currentQuestionIndex + 1) / 84.0, animated: true)
    }

    @objc private func answerTapped(_ sender: UIButton) {
        let q = questions[currentQuestionIndex]
        scaleScores[q.scale] += q.isReverse ? (7 - sender.tag) : sender.tag
        
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            updateQuestion()
        } else {
            showFinalResults()
        }
    }

    private func showFinalResults() {
        let names = ["Отношения", "Автономия", "Мастерство", "Рост", "Цели", "Самопринятие"]
        var report = ""

        for i in 0..<6 {
            let score = scaleScores[i]
            let name = names[i]
            let level: String
            let interpretation: String
            
            if score > 42 {
                level = "Высокий"
                switch i {
                case 0: interpretation = "У вас есть теплые, доверительные отношения."
                case 1: interpretation = "Вы независимы и не боитесь общественного давления."
                case 2: interpretation = "Вы отлично управляете своей жизнью и окружением."
                case 3: interpretation = "Вы постоянно развиваетесь и открыты новому опыту."
                case 4: interpretation = "Ваша жизнь наполнена смыслом и четкими целями."
                case 5: interpretation = "Вы принимаете себя и позитивно относитесь к прошлому."
                default: interpretation = ""
                }
            } else if score > 28 {
                level = "Средний"
                switch i {
                case 0: interpretation = "У вас есть круг общения, но порой не хватает глубины близости."
                case 1: interpretation = "Вы вполне самостоятельны, но иногда зависите от чужих оценок."
                case 2: interpretation = "Вы справляетесь с делами, но порой чувствуете нехватку контроля."
                case 3: interpretation = "Вы растете как личность, но иногда ощущаете застой."
                case 4: interpretation = "Цели есть, но вы порой сомневаетесь в своем направлении."
                case 5: interpretation = "Вы принимаете себя, но бываете излишне самокритичны."
                default: interpretation = ""
                }
            } else {
                level = "Низкий"
                switch i {
                case 0: interpretation = "Вам сложно поддерживать доверительные связи с другими."
                case 1: interpretation = "Вы сильно зависите от мнения других при принятии решений."
                case 2: interpretation = "Вам трудно организовывать быт и контролировать события."
                case 3: interpretation = "Вы чувствуете скуку и отсутствие интереса к развитию."
                case 4: interpretation = "Вы не видите ясной цели и смысла в своей деятельности."
                case 5: interpretation = "Вы недовольны собой и часто сожалеете о прошлом."
                default: interpretation = ""
                }
            }
            
            report += "\(name): \(score) б. (\(level))\n\(interpretation)\n\n"
        }

        let alert = UIAlertController(title: "Результаты теста", message: nil, preferredStyle: .alert)
        let textView = UITextView()
        textView.text = report
        textView.font = .systemFont(ofSize: 14)
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            textView.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 15),
            textView.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -15),
            textView.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -50),
            alert.view.heightAnchor.constraint(equalToConstant: 450)
        ])

        alert.addAction(UIAlertAction(title: "Завершить", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

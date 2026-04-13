import UIKit
import CoreML
import NaturalLanguage

class AIViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    // MARK: - Message Model
    struct Message {
        let text: String
        let isUser: Bool
    }

    // MARK: - State
    private var messages: [Message] = []
    private var messageCount = 0

    // MARK: - ML Model
    private let model: serevia1 = {
        do { return try serevia1(configuration: MLModelConfiguration()) }
        catch { fatalError("Не удалось загрузить модель: \(error)") }
    }()

    // MARK: - Keyword Dictionary (гибридный подход)
    // Используется когда ML уверенность < порога
    private let keywords: [String: [String]] = [
        "anxiety": [
            "тревог", "паник", "беспоко", "страх", "боюсь", "нервнич", "волну",
            "переживаю", "напряж", "боязн", "тревожн", "пугает", "пугаюсь",
            "ужас", "испуг", "мандраж", "трясёт", "дрожь", "не могу успокоиться"
        ],
        "sadness": [
            "грустн", "грущу", "плачу", "слёзы", "слезы", "тоск", "уныл",
            "подавлен", "печаль", "горе", "скорбь", "меланхол", "депресс",
            "безнадёжн", "пустот", "бессмысл", "не вижу смысла", "темно на душе",
            "душа болит", "тяжело на душе", "боль внутри"
        ],
        "sleep": [
            "не сплю", "бессонниц", "не могу уснуть", "не засыпаю", "кошмар",
            "просыпаюсь", "сон плох", "плохо сплю", "не высыпаюсь", "засыпаю с трудом",
            "ночью не могу", "режим сна", "поверхностный сон", "сон прерыв"
        ],
        "fatigue": [
            "устал", "устала", "усталость", "нет сил", "выгорел", "выгорела",
            "выгорание", "апатия", "апатичн", "нет энергии", "нет мотивации",
            "нет желания", "лениво", "разбит", "опустошен", "опустошена",
            "нет сил", "всё в тягость", "не хочется", "сил нет"
        ],
        "anger": [
            "злюсь", "злость", "раздража", "бесит", "бесят", "ярость", "злой",
            "злая", "агрессия", "агрессивн", "вспыш", "обида", "обидно",
            "несправедлив", "ненавижу", "раздражен", "раздражена", "кипит",
            "взорвусь", "срываюсь"
        ],
        "stress": [
            "стресс", "стрессовый", "дедлайн", "нагрузк", "перегруз", "давлен",
            "не успеваю", "много задач", "не справляюсь", "слишком много",
            "на пределе", "хаос", "не могу расставить", "времени нет", "горит"
        ],
        "loneliness": [
            "одинок", "одиночество", "никого", "не с кем", "никто не понимает",
            "чужой", "чужая", "изоляц", "брошен", "брошена", "невидим",
            "не замечают", "нет друзей", "нет близких", "все далеко", "не нужен", "не нужна"
        ],
        "positive": [
            "хорошо", "отлично", "счастлив", "счастлива", "радуюсь", "радость",
            "прекрасно", "замечательно", "доволен", "довольна", "вдохновл",
            "энергия есть", "всё получается", "лёгко", "светло", "благодарн",
            "позитив", "гармония"
        ]
    ]

    // MARK: - Responses
    private let responses: [String: [String]] = [
        "anxiety": [
            "Я слышу тебя. Тревога — это очень тяжело. Попробуй прямо сейчас сделать глубокий вдох на 4 счёта, задержать на 4, и выдохнуть на 4. Это помогает успокоить нервную систему 🌿",
            "Твои чувства абсолютно нормальны. Когда тревога накрывает, попробуй заземлиться: назови 5 вещей которые видишь вокруг, 4 которые можешь потрогать, 3 которые слышишь.",
            "Тревога говорит о том что ты заботишься. Но иногда она преувеличивает угрозы. Спроси себя: насколько вероятно что самое плохое действительно случится? 💙",
            "Ты не одна с этим чувством. Тревога пройдёт — она всегда проходит. Я рядом 🤍",
            "Попробуй технику «5-4-3-2-1»: 5 предметов вокруг, 4 звука, 3 ощущения на коже, 2 запаха, 1 вкус. Это возвращает в настоящий момент.",
            "Страх и тревога — это сигналы, а не факты. Ты сильнее своей тревоги 🌿"
        ],
        "sadness": [
            "Мне жаль что тебе сейчас так тяжело. Грусть — это не слабость, это честность с собой. Позволь себе чувствовать 💙",
            "Иногда просто нужно побыть в этом. Ты не обязана быть счастливой прямо сейчас. Я здесь и слушаю тебя.",
            "Грусть приходит и уходит как волны. Ты переживала тёмные периоды раньше — и справилась. Ты справишься и сейчас 🌿",
            "Попробуй сделать что-то маленькое для себя прямо сейчас: выпить тёплый чай, укутаться в плед, послушать любимую музыку.",
            "Ты заслуживаешь тепла и заботы. Если грусть не проходит долго — поговори с кем-то близким или специалистом 🤍",
            "Позволь себе погрустить. Это часть тебя, и это нормально. Я здесь 💙"
        ],
        "sleep": [
            "Бессонница изматывает. Попробуй за час до сна убрать телефон и приглушить свет — мозгу нужен сигнал что пора отдыхать 🌙",
            "Перед сном попробуй технику мышечного расслабления: напрягай и расслабляй каждую группу мышц по очереди, начиная со ступней.",
            "Мысли не дают уснуть? Запиши всё что беспокоит на бумагу — это выгружает голову и помогает отпустить.",
            "Постарайся ложиться и вставать в одно время даже в выходные. Режим — лучшее лекарство от бессонницы 🌿",
            "Попробуй дыхание 4-7-8: вдох на 4, задержка на 7, выдох на 8. Это специально замедляет нервную систему перед сном 🌙",
            "Тёплый душ за час до сна помогает телу расслабиться и настроиться на отдых 🤍"
        ],
        "fatigue": [
            "Усталость — это сигнал тела что ему нужна забота. Ты не обязана работать на износ 💙",
            "Попробуй правило «5 минут»: просто пять минут полного отдыха без телефона и мыслей о делах.",
            "Выгорание — серьёзная вещь. Подумай: что из твоих дел действительно важно прямо сейчас, а что можно отложить?",
            "Твоё тело просит отдыха. Послушай его. Даже короткая прогулка на свежем воздухе может вернуть немного энергии 🌿",
            "Ты делаешь много. Но ты тоже важна — не только то что ты делаешь. Позволь себе восстановиться 🤍",
            "Иногда лучшее что можно сделать — это ничего не делать. Просто побыть. Без задач и целей 💙"
        ],
        "anger": [
            "Злость — это нормальная эмоция. Она говорит что что-то важное для тебя нарушено. Что именно тебя задело? 💙",
            "Когда злость накрывает, попробуй физически разрядиться: быстрая прогулка, несколько прыжков, глубокие выдохи через рот.",
            "Прежде чем реагировать, попробуй досчитать до 10. Это даёт мозгу время переключиться с эмоций на разум.",
            "Злость часто скрывает под собой боль или страх. Попробуй спросить себя: что стоит за этой злостью на самом деле?",
            "Ты имеешь право злиться. Важно найти способ выразить это так чтобы не навредить себе и другим 🌿",
            "Злость — это энергия. Её можно направить в спорт, творчество или честный разговор 💙"
        ],
        "stress": [
            "Стресс накапливается незаметно. Давай разберём: что сейчас самое главное из всего что давит? 💙",
            "Попробуй метод «помидора»: 25 минут работы, 5 минут отдыха. Это помогает не перегружаться.",
            "Ты не можешь сделать всё сразу. Выбери одну задачу — самую важную — и сосредоточься только на ней.",
            "Стресс в теле — это напряжение. Потяни плечи назад, опусти их, сделай медленный выдох 🌿",
            "Ты справляешься с большим. Не забывай что отдых — это часть продуктивности, не её враг 🤍",
            "Иногда достаточно просто выписать всё что тревожит на бумагу. Это освобождает голову и снижает давление 💙"
        ],
        "loneliness": [
            "Одиночество — одно из самых тяжёлых чувств. Знай что ты не одна прямо сейчас — я здесь 💙",
            "Иногда одиночество — это сигнал что нам нужна более глубокая связь. Есть ли человек которому ты могла бы написать прямо сейчас?",
            "Близость начинается с малого — с одного честного разговора. Написать «привет, я скучаю» уже достаточно.",
            "Ты заслуживаешь людей которые тебя видят и ценят. Иногда нужно время чтобы найти своих 🌿",
            "Попробуй сделать что-то для себя с удовольствием — хобби, прогулка, книга. Хорошие отношения с собой притягивают хороших людей 🤍",
            "Одиночество бывает очень громким. Ты не невидима — просто пока не нашла своих. Они есть 💙"
        ],
        "positive": [
            "Как здорово! Рада слышать что у тебя всё хорошо 🌿 Что сегодня особенно порадовало?",
            "Это замечательно! Лови это ощущение и запомни его — оно пригодится в трудные моменты ☀️",
            "Ты молодец! Хорошее настроение — это тоже результат твоих усилий 💙",
            "Приятно это слышать! Береги это состояние и делись им с близкими 🌸",
            "Отлично! Кстати, это хороший момент чтобы записать что-то в дневник — зафиксировать хорошее 🤍",
            "Так держать! Радость — это тоже навык. Ты её замечаешь, а это уже много 🌿"
        ]
    ]

    // MARK: - Recommendations
    private let recommendations: [String: String] = [
        "anxiety": "💡 Кстати, если захочешь — попробуй медитацию «Дыхание покоя» в разделе Медитация. Она помогает снизить тревогу буквально за 5 минут через дыхательные техники.",
        "sadness": "💡 Если будет желание — тест на эмоции в разделе Интересное помогает лучше понять что происходит внутри. Иногда просто назвать чувство уже облегчает.",
        "sleep": "💡 Кстати, в разделе Медитация есть «Мягкое засыпание» — специально для тех кто не может уснуть. Помогает отпустить мысли и расслабить тело перед сном 🌙",
        "fatigue": "💡 Может быть попробуешь короткую медитацию «Тепло и свет» в разделе Медитация? Всего 12 минут — но многие говорят что после неё чувствуют себя будто перезагрузились.",
        "anger": "💡 Если захочешь разобраться глубже — тест на эмоции в разделе Интересное помогает понять что стоит за злостью. Иногда это совсем другое чувство.",
        "stress": "💡 Кстати, тест на стресс в разделе Интересное может показать насколько сильно он влияет на тебя прямо сейчас. Это первый шаг чтобы что-то изменить.",
        "loneliness": "💡 Может быть стоит попробовать написать в дневник? Иногда когда не с кем поговорить — бумага становится хорошим слушателем 📓",
        "positive": "💡 Отличный момент чтобы записать это в дневник! Хорошие воспоминания — это ресурс на трудные времена 🌿"
    ]

    private let fallbackResponses = [
        "Я слышу тебя. Расскажи мне больше — я здесь чтобы поддержать 💙",
        "Спасибо что поделилась. Как ты себя чувствуешь прямо сейчас?",
        "Я рядом. Что бы ты хотела чтобы я знала о том как тебе сейчас? 🌿",
        "Ты не одна. Я слушаю тебя 🤍",
        "Расскажи подробнее — мне важно понять что ты чувствуешь 💙"
    ]

    // MARK: - UI
    private let tableView = UITableView()
    private let messageInputContainer = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)

    // MARK: - COLORS
    private let accent     = UIColor(red: 0.58, green: 0.46, blue: 0.42, alpha: 1)
    private let pageBg     = UIColor(red: 0.96, green: 0.94, blue: 0.91, alpha: 1)
    private let textDark   = UIColor(red: 0.20, green: 0.15, blue: 0.10, alpha: 1)
    private let textMid    = UIColor(red: 0.48, green: 0.40, blue: 0.32, alpha: 1)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = pageBg
        setupUI()
        showWelcomeMessage()
        setupKeyboardObservers()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Welcome
    private func showWelcomeMessage() {
        messages.append(Message(
            text: "Привет! Я здесь чтобы поддержать тебя 🌿 Расскажи как ты себя чувствуешь?",
            isUser: false
        ))
        tableView.reloadData()
    }

    // MARK: - Hybrid Classification
    private func classify(_ input: String) -> String {
        let lowered = input.lowercased()

        // 1. Пробуем ML модель
        if let prediction = try? model.prediction(text: input) {
            let label = prediction.label

            // Проверяем уверенность через NLTagger если доступно,
            // иначе дополнительно валидируем ключевыми словами
            let mlConfident = validateWithKeywords(label: label, text: lowered)

            if mlConfident {
                return label
            }
        }

        // 2. Фолбэк: словарь ключевых слов
        var scores: [String: Int] = [:]
        for (label, words) in keywords {
            let count = words.filter { lowered.contains($0) }.count
            if count > 0 { scores[label] = count }
        }

        if let best = scores.max(by: { $0.value < $1.value }) {
            return best.key
        }

        // 3. Если ничего не нашли
        return "unknown"
    }

    /// Проверяет: совпадает ли ML метка хотя бы с одним ключевым словом
    private func validateWithKeywords(label: String, text: String) -> Bool {
        guard let words = keywords[label] else { return true }
        // Если хоть одно ключевое слово совпадает — доверяем ML
        let hasMatch = words.contains { text.contains($0) }
        // Если нет совпадений, но текст очень короткий — всё равно доверяем ML
        let isShortInput = text.split(separator: " ").count <= 3
        return hasMatch || isShortInput
    }

    private func generateResponse(for input: String) -> String {
        let label = classify(input)
        messageCount += 1

        guard label != "unknown" else {
            return fallbackResponses.randomElement()!
        }

        let pool = responses[label] ?? fallbackResponses
        var response = pool.randomElement()!

        // Рекомендация каждые 2 сообщения
        if messageCount % 2 == 0, let tip = recommendations[label] {
            response += "\n\n" + tip
        }

        return response
    }

    // MARK: - Send
    @objc private func sendButtonTapped() {
        guard let text = messageTextField.text,
              !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        messageTextField.text = ""

        messages.append(Message(text: text, isUser: true))
        tableView.reloadData()
        scrollToBottom()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let response = self.generateResponse(for: text)
            self.messages.append(Message(text: response, isUser: false))
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }

    private func scrollToBottom() {
        guard messages.count > 0 else { return }
        tableView.scrollToRow(
            at: IndexPath(row: messages.count - 1, section: 0),
            at: .bottom, animated: true
        )
    }

    // MARK: - Setup UI
    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "AI Психолог"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = textDark
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Я здесь чтобы выслушать"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = textMid
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(ChatBubbleCell.self, forCellReuseIdentifier: "BubbleCell")
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        view.addSubview(tableView)

        messageInputContainer.backgroundColor = .white
        messageInputContainer.layer.cornerRadius = 24
        messageInputContainer.layer.shadowColor = UIColor.black.cgColor
        messageInputContainer.layer.shadowOpacity = 0.06
        messageInputContainer.layer.shadowOffset = CGSize(width: 0, height: -2)
        messageInputContainer.layer.shadowRadius = 8
        messageInputContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageInputContainer)

        messageTextField.placeholder = "Напиши, как ты себя чувствуешь..."
        messageTextField.borderStyle = .none
        messageTextField.font = .systemFont(ofSize: 15)
        messageTextField.textColor = textDark
        messageTextField.delegate = self
        messageTextField.returnKeyType = .send
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        messageInputContainer.addSubview(messageTextField)

        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        sendButton.tintColor = accent
        sendButton.contentVerticalAlignment = .fill
        sendButton.contentHorizontalAlignment = .fill
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        messageInputContainer.addSubview(sendButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            messageInputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messageInputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            messageInputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            messageInputContainer.heightAnchor.constraint(equalToConstant: 52),

            messageTextField.leadingAnchor.constraint(equalTo: messageInputContainer.leadingAnchor, constant: 18),
            messageTextField.centerYAnchor.constraint(equalTo: messageInputContainer.centerYAnchor),
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),

            sendButton.trailingAnchor.constraint(equalTo: messageInputContainer.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: messageInputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32),

            tableView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputContainer.topAnchor, constant: -8)
        ])
    }

    // MARK: - Keyboard
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        UIView.animate(withDuration: duration) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -frame.height + self.view.safeAreaInsets.bottom)
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        UIView.animate(withDuration: duration) { self.view.transform = .identity }
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { messages.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BubbleCell", for: indexPath) as! ChatBubbleCell
        cell.configure(with: messages[indexPath.row], accent: self.accent, dark: self.textDark)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonTapped(); return true
    }
}

// MARK: - Chat Bubble Cell
class ChatBubbleCell: UITableViewCell {

    private let bubbleView  = UIView()
    private let messageLabel = UILabel()

    private let accent   = UIColor(red: 0.49, green: 0.38, blue: 0.27, alpha: 1)
    private let textDark = UIColor(red: 0.20, green: 0.15, blue: 0.10, alpha: 1)

    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none
        setupBubble()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupBubble() {
        bubbleView.layer.cornerRadius = 18
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)

        messageLabel.font = .systemFont(ofSize: 15)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(messageLabel)

        leadingConstraint  = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 14),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -14)
        ])
    }

    func configure(with message: AIViewController.Message, accent: UIColor, dark: UIColor) {
        messageLabel.text = message.text
            
        leadingConstraint.isActive = !message.isUser
        trailingConstraint.isActive = message.isUser

        if message.isUser {
            bubbleView.backgroundColor = accent
            messageLabel.textColor = .white
            bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
        } else {
            bubbleView.backgroundColor = .white
            messageLabel.textColor = dark
            bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner]
        }
    }
}

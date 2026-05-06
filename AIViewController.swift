import UIKit
import CoreML
import NaturalLanguage

// MARK: - Chat Session Model
struct ChatSession: Codable {
    var id: String
    var title: String
    var date: Date
    var messages: [StoredMessage]
}

struct StoredMessage: Codable {
    let text: String
    let isUser: Bool
}

class ChatStorage {
    static let shared = ChatStorage()
    private let key = "chat_sessions"
    private init() {}

    func saveSessions(_ sessions: [ChatSession]) {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func loadSessions() -> [ChatSession] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let sessions = try? JSONDecoder().decode([ChatSession].self, from: data)
        else { return [] }
        return sessions
    }
}

// MARK: - Chat History List
class ChatHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var sessions: [ChatSession] = []
    private let tableView = UITableView()
    var onSelectSession: ((ChatSession) -> Void)?
    var onNewSession: (() -> Void)?

    private let accent   = UIColor(red: 0.58, green: 0.46, blue: 0.42, alpha: 1)
    private let pageBg   = UIColor(red: 0.96, green: 0.94, blue: 0.91, alpha: 1)
    private let textDark = UIColor(red: 0.20, green: 0.15, blue: 0.10, alpha: 1)
    private let textMid  = UIColor(red: 0.48, green: 0.40, blue: 0.32, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = pageBg
        sessions = ChatStorage.shared.loadSessions()
        setupUI()
    }

    private func setupUI() {
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
        titleLabel.text = "История"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = textDark
        titleLabel.textAlignment = .center

        let divider = UIView()
        divider.backgroundColor = UIColor(red: 0.76, green: 0.68, blue: 0.58, alpha: 0.2)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let newBtn = UIButton(type: .system)
        newBtn.setTitle("+ Новый чат", for: .normal)
        newBtn.setTitleColor(.white, for: .normal)
        newBtn.backgroundColor = accent
        newBtn.layer.cornerRadius = 16
        newBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        newBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        newBtn.addTarget(self, action: #selector(newChatTapped), for: .touchUpInside)

        let headerStack = UIStackView(arrangedSubviews: [dateLabel, titleLabel, divider, newBtn])
        headerStack.axis = .vertical
        headerStack.spacing = 4
        headerStack.setCustomSpacing(14, after: titleLabel)
        headerStack.setCustomSpacing(16, after: divider)
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatSessionCell.self, forCellReuseIdentifier: "SessionCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(headerStack)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func newChatTapped() {
        onNewSession?()
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { sessions.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionCell", for: indexPath) as! ChatSessionCell
        cell.configure(with: sessions[indexPath.row], accent: accent, textDark: textDark, textMid: textMid)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectSession?(sessions[indexPath.row])
        dismiss(animated: true)
    }

    // свайп для удаления
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, done in
            guard let self = self else { return }
            var sessions = ChatStorage.shared.loadSessions()
            sessions.remove(at: indexPath.row)
            ChatStorage.shared.saveSessions(sessions)
            self.sessions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            done(true)
        }
        // переименование
        let rename = UIContextualAction(style: .normal, title: "Переименовать") { [weak self] _, _, done in
            guard let self = self else { return }
            let alert = UIAlertController(title: "Название", message: nil, preferredStyle: .alert)
            alert.addTextField { $0.text = self.sessions[indexPath.row].title }
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { _ in done(false) })
            alert.addAction(UIAlertAction(title: "Сохранить", style: .default) { _ in
                guard let text = alert.textFields?.first?.text, !text.isEmpty else { done(false); return }
                var sessions = ChatStorage.shared.loadSessions()
                sessions[indexPath.row].title = text
                ChatStorage.shared.saveSessions(sessions)
                self.sessions[indexPath.row].title = text
                tableView.reloadRows(at: [indexPath], with: .automatic)
                done(true)
            })
            self.present(alert, animated: true)
        }
        rename.backgroundColor = UIColor(red: 0.58, green: 0.46, blue: 0.42, alpha: 1)
        return UISwipeActionsConfiguration(actions: [delete, rename])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 80 }
}

// MARK: - Session Cell
class ChatSessionCell: UITableViewCell {

    private let cardView    = UIView()
    private let titleLabel  = UILabel()
    private let dateLabel   = UILabel()
    private let previewLabel = UILabel()
    private let floralView  = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        cardView.layer.cornerRadius = 18
        cardView.clipsToBounds = true
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.04
        cardView.translatesAutoresizingMaskIntoConstraints = false

        if let orig = UIImage(named: "floral_pattern") {
            let sz = CGSize(width: orig.size.width / 2.5, height: orig.size.height / 2.5)
            UIGraphicsBeginImageContextWithOptions(sz, false, 0)
            orig.draw(in: CGRect(origin: .zero, size: sz))
            let scaled = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            floralView.image = scaled ?? orig
        }
        floralView.contentMode = .scaleAspectFill
        floralView.alpha = 0.18
        floralView.translatesAutoresizingMaskIntoConstraints = false

        let overlay = UIView()
        overlay.backgroundColor = .white
        overlay.alpha = 0.85
        overlay.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(floralView)
        cardView.addSubview(overlay)

        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.font = .systemFont(ofSize: 11, weight: .regular)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        previewLabel.font = .systemFont(ofSize: 13, weight: .regular)
        previewLabel.numberOfLines = 1
        previewLabel.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(titleLabel)
        cardView.addSubview(dateLabel)
        cardView.addSubview(previewLabel)
        contentView.addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            floralView.topAnchor.constraint(equalTo: cardView.topAnchor),
            floralView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            floralView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            floralView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),

            overlay.topAnchor.constraint(equalTo: cardView.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -8),

            dateLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            dateLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

            previewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            previewLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            previewLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
        ])
    }

    func configure(with session: ChatSession, accent: UIColor, textDark: UIColor, textMid: UIColor) {
        titleLabel.text = session.title
        titleLabel.textColor = textDark

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMM"
        dateLabel.text = formatter.string(from: session.date)
        dateLabel.textColor = textMid

        let lastUserMsg = session.messages.last(where: { $0.isUser })?.text ?? "Нет сообщений"
        previewLabel.text = lastUserMsg
        previewLabel.textColor = textMid
    }
}

// MARK: - Main AI View Controller
class AIViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    struct Message {
        let text: String
        let isUser: Bool
    }

    private var messages: [Message] = []
    private var messageCount = 0
    private var currentSessionId: String = UUID().uuidString
    private var currentSessionTitle: String = "Новый чат"
    private let chatTitleLabel = UILabel()

    private let model: serevia1 = {
        do { return try serevia1(configuration: MLModelConfiguration()) }
        catch { fatalError("Не удалось загрузить модель: \(error)") }
    }()

    private let keywords: [String: [String]] = [
        "anxiety": ["тревог","паник","беспоко","страх","боюсь","нервнич","волну","переживаю","напряж","боязн","тревожн","пугает","пугаюсь","ужас","испуг","мандраж","трясёт","дрожь","не могу успокоиться"],
        "sadness": ["грустн","грущу","плачу","слёзы","слезы","тоск","уныл","подавлен","печаль","горе","скорбь","меланхол","депресс","безнадёжн","пустот","бессмысл","не вижу смысла","темно на душе","душа болит","тяжело на душе","боль внутри"],
        "sleep":   ["не сплю","бессонниц","не могу уснуть","не засыпаю","кошмар","просыпаюсь","сон плох","плохо сплю","не высыпаюсь","засыпаю с трудом","ночью не могу","режим сна","поверхностный сон","сон прерыв"],
        "fatigue": ["устал","устала","усталость","нет сил","выгорел","выгорела","выгорание","апатия","апатичн","нет энергии","нет мотивации","нет желания","лениво","разбит","опустошен","опустошена","всё в тягость","не хочется","сил нет"],
        "anger":   ["злюсь","злость","раздража","бесит","бесят","ярость","злой","злая","агрессия","агрессивн","вспыш","обида","обидно","несправедлив","ненавижу","раздражен","раздражена","кипит","взорвусь","срываюсь"],
        "stress":  ["стресс","стрессовый","дедлайн","нагрузк","перегруз","давлен","не успеваю","много задач","не справляюсь","слишком много","на пределе","хаос","не могу расставить","времени нет","горит"],
        "loneliness": ["одинок","одиночество","никого","не с кем","никто не понимает","чужой","чужая","изоляц","брошен","брошена","невидим","не замечают","нет друзей","нет близких","все далеко","не нужен","не нужна"],
        "positive": ["хорошо","отлично","счастлив","счастлива","радуюсь","радость","прекрасно","замечательно","доволен","довольна","вдохновл","энергия есть","всё получается","лёгко","светло","благодарн","позитив","гармония"]
    ]

    private let responses: [String: [String]] = [
        "anxiety": ["Я слышу тебя. Тревога — это очень тяжело. Попробуй прямо сейчас сделать глубокий вдох на 4 счёта, задержать на 4, и выдохнуть на 4. Это помогает успокоить нервную систему 🌿","Твои чувства абсолютно нормальны. Когда тревога накрывает, попробуй заземлиться: назови 5 вещей которые видишь вокруг, 4 которые можешь потрогать, 3 которые слышишь.","Тревога говорит о том что ты заботишься. Но иногда она преувеличивает угрозы. Спроси себя: насколько вероятно что самое плохое действительно случится? 💙","Ты не одна с этим чувством. Тревога пройдёт — она всегда проходит. Я рядом 🤍","Страх и тревога — это сигналы, а не факты. Ты сильнее своей тревоги 🌿"],
        "sadness": ["Мне жаль что тебе сейчас так тяжело. Грусть — это не слабость, это честность с собой. Позволь себе чувствовать 💙","Иногда просто нужно побыть в этом. Ты не обязана быть счастливой прямо сейчас. Я здесь и слушаю тебя.","Грусть приходит и уходит как волны. Ты переживала тёмные периоды раньше — и справилась. Ты справишься и сейчас 🌿","Позволь себе погрустить. Это часть тебя, и это нормально. Я здесь 💙"],
        "sleep":   ["Бессонница изматывает. Попробуй за час до сна убрать телефон и приглушить свет — мозгу нужен сигнал что пора отдыхать 🌙","Мысли не дают уснуть? Запиши всё что беспокоит на бумагу — это выгружает голову и помогает отпустить.","Попробуй дыхание 4-7-8: вдох на 4, задержка на 7, выдох на 8. Это специально замедляет нервную систему перед сном 🌙"],
        "fatigue": ["Усталость — это сигнал тела что ему нужна забота. Ты не обязана работать на износ 💙","Попробуй правило «5 минут»: просто пять минут полного отдыха без телефона и мыслей о делах.","Ты делаешь много. Но ты тоже важна — не только то что ты делаешь. Позволь себе восстановиться 🤍"],
        "anger":   ["Злость — это нормальная эмоция. Она говорит что что-то важное для тебя нарушено. Что именно тебя задело? 💙","Прежде чем реагировать, попробуй досчитать до 10. Это даёт мозгу время переключиться с эмоций на разум.","Злость — это энергия. Её можно направить в спорт, творчество или честный разговор 💙"],
        "stress":  ["Стресс накапливается незаметно. Давай разберём: что сейчас самое главное из всего что давит? 💙","Ты не можешь сделать всё сразу. Выбери одну задачу — самую важную — и сосредоточься только на ней.","Ты справляешься с большим. Не забывай что отдых — это часть продуктивности, не её враг 🤍"],
        "loneliness": ["Одиночество — одно из самых тяжёлых чувств. Знай что ты не одна прямо сейчас — я здесь 💙","Близость начинается с малого — с одного честного разговора. Написать «привет, я скучаю» уже достаточно.","Одиночество бывает очень громким. Ты не невидима — просто пока не нашла своих. Они есть 💙"],
        "positive": ["Как здорово! Рада слышать что у тебя всё хорошо 🌿 Что сегодня особенно порадовало?","Это замечательно! Лови это ощущение и запомни его — оно пригодится в трудные моменты ☀️","Так держать! Радость — это тоже навык. Ты её замечаешь, а это уже много 🌿"]
    ]

    private let recommendations: [String: String] = [
        "anxiety":    "💡 Попробуй медитацию «Дыхание покоя» в разделе Медитация. Она помогает снизить тревогу буквально за 5 минут.",
        "sadness":    "💡 Тест на эмоции в разделе Интересное помогает лучше понять что происходит внутри.",
        "sleep":      "💡 В разделе Медитация есть «Мягкое засыпание» — специально для тех кто не может уснуть 🌙",
        "fatigue":    "💡 Попробуй медитацию «Тепло и свет» — всего 12 минут, но многие говорят что после неё чувствуют себя будто перезагрузились.",
        "anger":      "💡 Тест на эмоции в разделе Интересное помогает понять что стоит за злостью.",
        "stress":     "💡 Тест на стресс в разделе Интересное покажет насколько сильно он влияет на тебя прямо сейчас.",
        "loneliness": "💡 Попробуй написать в дневник — иногда когда не с кем поговорить, бумага становится хорошим слушателем 📓",
        "positive":   "💡 Отличный момент записать это в дневник! Хорошие воспоминания — ресурс на трудные времена 🌿"
    ]

    private let fallbackResponses = [
        "Я слышу тебя. Расскажи мне больше — я здесь чтобы поддержать 💙",
        "Спасибо что поделилась. Как ты себя чувствуешь прямо сейчас?",
        "Я рядом. Что бы ты хотела чтобы я знала о том как тебе сейчас? 🌿",
        "Ты не одна. Я слушаю тебя 🤍",
        "Расскажи подробнее — мне важно понять что ты чувствуешь 💙"
    ]

    private let tableView = UITableView()
    private let messageInputContainer = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)

    private let accent   = UIColor(red: 0.58, green: 0.46, blue: 0.42, alpha: 1)
    private let pageBg   = UIColor(red: 0.96, green: 0.94, blue: 0.91, alpha: 1)
    private let textDark = UIColor(red: 0.20, green: 0.15, blue: 0.10, alpha: 1)
    private let textMid  = UIColor(red: 0.48, green: 0.40, blue: 0.32, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = pageBg
        setupUI()
        showWelcomeMessage()
        setupKeyboardObservers()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func showWelcomeMessage() {
        messages.append(Message(text: "Привет! Я здесь чтобы поддержать тебя 🌿 Расскажи как ты себя чувствуешь?", isUser: false))
        tableView.reloadData()
    }

    // MARK: - Session management
    private func saveCurrentSession() {
        guard messages.count > 1 else { return } // не сохраняем пустые
        var sessions = ChatStorage.shared.loadSessions()
        let stored = messages.map { StoredMessage(text: $0.text, isUser: $0.isUser) }

        // автоназвание из первого сообщения пользователя
        if currentSessionTitle == "Новый чат",
           let first = messages.first(where: { $0.isUser }) {
            let words = first.text.split(separator: " ").prefix(4).joined(separator: " ")
            currentSessionTitle = String(words)
        }

        if let idx = sessions.firstIndex(where: { $0.id == currentSessionId }) {
            sessions[idx].messages = stored
            sessions[idx].title = currentSessionTitle
        } else {
            let session = ChatSession(id: currentSessionId, title: currentSessionTitle, date: Date(), messages: stored)
            sessions.insert(session, at: 0)
        }
        ChatStorage.shared.saveSessions(sessions)
    }

    private func loadSession(_ session: ChatSession) {
        saveCurrentSession()
        currentSessionId = session.id
        currentSessionTitle = session.title
        chatTitleLabel.text = session.title
        messages = session.messages.map { Message(text: $0.text, isUser: $0.isUser) }
        tableView.reloadData()
        if messages.count > 0 { scrollToBottom() }
    }

    private func startNewSession() {
        saveCurrentSession()
        currentSessionId = UUID().uuidString
        currentSessionTitle = "Новый чат"
        chatTitleLabel.text = "Новый чат"
        messageCount = 0
        messages = []
        tableView.reloadData()
        showWelcomeMessage()
    }

    // MARK: - Classification
    private func classify(_ input: String) -> String {
        let lowered = input.lowercased()
        if let prediction = try? model.prediction(text: input) {
            let label = prediction.label
            if validateWithKeywords(label: label, text: lowered) { return label }
        }
        var scores: [String: Int] = [:]
        for (label, words) in keywords {
            let count = words.filter { lowered.contains($0) }.count
            if count > 0 { scores[label] = count }
        }
        if let best = scores.max(by: { $0.value < $1.value }) { return best.key }
        return "unknown"
    }

    private func validateWithKeywords(label: String, text: String) -> Bool {
        guard let words = keywords[label] else { return true }
        return words.contains { text.contains($0) } || text.split(separator: " ").count <= 3
    }

    private func generateResponse(for input: String) -> String {
        let label = classify(input)
        messageCount += 1
        guard label != "unknown" else { return fallbackResponses.randomElement()! }
        let pool = responses[label] ?? fallbackResponses
        var response = pool.randomElement()!
        if messageCount % 2 == 0, let tip = recommendations[label] { response += "\n\n" + tip }
        return response
    }

    @objc private func sendButtonTapped() {
        guard let text = messageTextField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        messageTextField.text = ""
        messages.append(Message(text: text, isUser: true))
        tableView.reloadData()
        scrollToBottom()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let response = self.generateResponse(for: text)
            self.messages.append(Message(text: response, isUser: false))
            self.tableView.reloadData()
            self.scrollToBottom()
            self.saveCurrentSession()
        }
    }

    private func scrollToBottom() {
        guard messages.count > 0 else { return }
        tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
    }

    @objc private func historyTapped() {
        saveCurrentSession()
        let vc = ChatHistoryViewController()
        vc.onSelectSession = { [weak self] session in self?.loadSession(session) }
        vc.onNewSession    = { [weak self] in self?.startNewSession() }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    @objc private func renameTapped() {
        let alert = UIAlertController(title: "Название чата", message: nil, preferredStyle: .alert)
        alert.addTextField { [weak self] tf in tf.text = self?.currentSessionTitle }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            guard let self = self, let text = alert.textFields?.first?.text, !text.isEmpty else { return }
            self.currentSessionTitle = text
            self.chatTitleLabel.text = text
            self.saveCurrentSession()
        })
        present(alert, animated: true)
    }

    // MARK: - UI Setup
    private func setupUI() {
        let dateLabel = UILabel()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE, d MMMM"
        let raw = formatter.string(from: Date())
        dateLabel.text = raw.prefix(1).uppercased() + raw.dropFirst()
        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = textMid.withAlphaComponent(0.7)
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "AI Психолог"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = textDark
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Я здесь чтобы выслушать"
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = textMid
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // кнопки история и переименовать
        let historyBtn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        historyBtn.setImage(UIImage(systemName: "clock.arrow.circlepath", withConfiguration: cfg), for: .normal)
        historyBtn.tintColor = accent
        historyBtn.addTarget(self, action: #selector(historyTapped), for: .touchUpInside)
        historyBtn.translatesAutoresizingMaskIntoConstraints = false

        let renameBtn = UIButton(type: .system)
        renameBtn.setImage(UIImage(systemName: "pencil", withConfiguration: cfg), for: .normal)
        renameBtn.tintColor = accent
        renameBtn.addTarget(self, action: #selector(renameTapped), for: .touchUpInside)
        renameBtn.translatesAutoresizingMaskIntoConstraints = false

        chatTitleLabel.text = currentSessionTitle
        chatTitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        chatTitleLabel.textColor = textMid
        chatTitleLabel.textAlignment = .center
        chatTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // контейнер: история | название | переименовать — симметрично
        let btnRow = UIView()
        btnRow.translatesAutoresizingMaskIntoConstraints = false
        btnRow.addSubview(historyBtn)
        btnRow.addSubview(chatTitleLabel)
        btnRow.addSubview(renameBtn)
        NSLayoutConstraint.activate([
            btnRow.heightAnchor.constraint(equalToConstant: 30),
            historyBtn.leadingAnchor.constraint(equalTo: btnRow.leadingAnchor),
            historyBtn.centerYAnchor.constraint(equalTo: btnRow.centerYAnchor),
            historyBtn.widthAnchor.constraint(equalToConstant: 28),
            historyBtn.heightAnchor.constraint(equalToConstant: 28),
            renameBtn.trailingAnchor.constraint(equalTo: btnRow.trailingAnchor),
            renameBtn.centerYAnchor.constraint(equalTo: btnRow.centerYAnchor),
            renameBtn.widthAnchor.constraint(equalToConstant: 28),
            renameBtn.heightAnchor.constraint(equalToConstant: 28),
            chatTitleLabel.centerXAnchor.constraint(equalTo: btnRow.centerXAnchor),
            chatTitleLabel.centerYAnchor.constraint(equalTo: btnRow.centerYAnchor),
            chatTitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: historyBtn.trailingAnchor, constant: 8),
            chatTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: renameBtn.leadingAnchor, constant: -8)
        ])

        let headerDivider = UIView()
        headerDivider.backgroundColor = UIColor(red: 0.76, green: 0.68, blue: 0.58, alpha: 0.2)
        headerDivider.translatesAutoresizingMaskIntoConstraints = false

        // заголовок-стек
        let headerStack = UIStackView(arrangedSubviews: [dateLabel, titleLabel, subtitleLabel, btnRow, headerDivider])
        headerStack.axis = .vertical
        headerStack.spacing = 4
        headerStack.setCustomSpacing(8, after: subtitleLabel)
        headerStack.setCustomSpacing(12, after: btnRow)
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerStack)

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
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            headerDivider.heightAnchor.constraint(equalToConstant: 1),

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

            tableView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputContainer.topAnchor, constant: -8)
        ])
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { messages.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BubbleCell", for: indexPath) as! ChatBubbleCell
        cell.configure(with: messages[indexPath.row], accent: accent, dark: textDark)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { UITableView.automaticDimension }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { sendButtonTapped(); return true }
}

// MARK: - Chat Bubble Cell
class ChatBubbleCell: UITableViewCell {

    private let bubbleView   = UIView()
    private let messageLabel = UILabel()
    private let floralView   = UIImageView()

    private let botBubbleBg = UIColor(red: 0.91, green: 0.88, blue: 0.84, alpha: 1)

    // два набора констрейнтов — только один активен в каждый момент
    private var userConstraints:  [NSLayoutConstraint] = []
    private var botConstraints:   [NSLayoutConstraint] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none
        setupBubble()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupBubble() {
        bubbleView.layer.cornerRadius = 16
        bubbleView.clipsToBounds = true
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)

        // floral поверх фона — фиксированный размер, не растягивает пузырь
        floralView.contentMode = .scaleAspectFill
        floralView.alpha = 0.15
        floralView.translatesAutoresizingMaskIntoConstraints = false
        if let orig = UIImage(named: "floral_pattern") {
            let sz = CGSize(width: orig.size.width / 3, height: orig.size.height / 3)
            UIGraphicsBeginImageContextWithOptions(sz, false, 0)
            orig.draw(in: CGRect(origin: .zero, size: sz))
            floralView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        bubbleView.addSubview(floralView)

        messageLabel.font = .systemFont(ofSize: 15)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(messageLabel)

        // общие констрейнты
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.72),

            // floral — фиксированный размер в правом верхнем углу, не влияет на layout
            floralView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
            floralView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            floralView.widthAnchor.constraint(equalToConstant: 60),
            floralView.heightAnchor.constraint(equalToConstant: 60),

            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 9),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -9),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12)
        ])

        // пользователь — прижат вправо
        userConstraints = [
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ]
        // бот — прижат влево
        botConstraints = [
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        ]
    }

    func configure(with message: AIViewController.Message, accent: UIColor, dark: UIColor) {
        messageLabel.text = message.text

        // деактивируем оба набора, включаем нужный
        NSLayoutConstraint.deactivate(userConstraints + botConstraints)

        if message.isUser {
            NSLayoutConstraint.activate(userConstraints)
            bubbleView.backgroundColor = accent
            bubbleView.layer.borderWidth = 0
            floralView.isHidden = true
            messageLabel.textColor = .white
            bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
        } else {
            NSLayoutConstraint.activate(botConstraints)
            bubbleView.backgroundColor = botBubbleBg
            bubbleView.layer.borderColor = UIColor(red: 0.72, green: 0.63, blue: 0.53, alpha: 0.45).cgColor
            bubbleView.layer.borderWidth = 1
            floralView.isHidden = false
            messageLabel.textColor = dark
            bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner]
        }
    }
}

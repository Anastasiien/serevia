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
    // запоминаем использованные индексы ответов для каждой категории
    private var usedResponseIndices: [String: Set<Int>] = [:]

    // состояние диалогового потока
    private var dialogState: DialogState = .idle
    private var dialogCategory: String = ""
    private var dialogStep: Int = 0

    enum DialogState { case idle, inProgress, closing }

    private let chatTitleLabel = UILabel()

    private let model: serevia1 = {
        do { return try serevia1(configuration: MLModelConfiguration()) }
        catch { fatalError("Не удалось загрузить модель: \(error)") }
    }()

    private let keywords: [String: [String]] = [
        "anxiety": [
            // одиночные слова
            "тревог","паник","беспоко","страх","боюсь","нервнич","волну","переживаю",
            "напряж","боязн","тревожн","пугает","пугаюсь","ужас","испуг","мандраж",
            "трясёт","дрожь","паникую","нервничаю","беспокоюсь","тревожно","страшно",
            "жутко","жуть","боязливо","мурашки","сердцебиение","колотится",
            // биграммы и фразы
            "не могу успокоиться","не по себе","сердце колотится","накрывает тревога",
            "накрыло тревогой","страшно становится","вдруг что-то","а что если",
            "боюсь что","переживаю что","не нахожу себе места","места не нахожу",
            "всё время думаю","мысли крутятся","не отпускает","тяжело на сердце",
            "комок в горле","дышать тяжело","сжимается грудь","не могу расслабиться"
        ],
        "sadness": [
            "грустн","грущу","плачу","слёзы","слезы","тоск","уныл","подавлен","печаль",
            "горе","скорбь","меланхол","депресс","безнадёжн","пустот","бессмысл",
            "хандра","нытьё","ною","ною","реву","рыдаю","заплакала","заплакал",
            // фразы
            "не вижу смысла","темно на душе","душа болит","тяжело на душе","боль внутри",
            "мне плохо","всё плохо","так плохо","очень плохо","хочется плакать",
            "ничего не радует","не радует","нет радости","пусто внутри",
            "опустились руки","нет настроения","плохое настроение","на душе тяжело",
            "на сердце тяжело","слёзы сами текут","не могу остановить слёзы",
            "хочется выть","так больно","внутри пусто","жить не хочется",
            "нет смысла","зачем всё это","всё бессмысленно","ничего не хочу",
            "не хочу просыпаться","не хочу вставать","лежу и плачу"
        ],
        "sleep": [
            "не сплю","бессонниц","кошмар","просыпаюсь","снится","не засну",
            "засыпаю","засыпал","поверхностный","сон прерыв","храпит","не выспалась",
            // фразы
            "не могу уснуть","не могу заснуть","не засыпаю","не высыпаюсь",
            "засыпаю с трудом","ночью не могу","режим сна","сон плохой","плохо сплю",
            "всю ночь не сплю","ночь не спала","ночь не спал","лежу не сплю",
            "мысли не дают уснуть","голова не отключается","ворочаюсь всю ночь",
            "в 3 ночи","в 4 утра","до утра не сплю","опять не сплю","снова не сплю",
            "уже утро а я не спала","сон как в руку","страшные сны"
        ],
        "fatigue": [
            "устал","устала","усталость","выгорел","выгорела","выгорание","апатия",
            "апатичн","разбит","опустошен","опустошена","лениво","вялость","вялый",
            "вялая","обессилел","обессилела","изможден","изможденная",
            // фразы
            "нет сил","нет энергии","нет мотивации","нет желания","всё в тягость",
            "не хочется","сил нет","вымоталась","вымотался","еле встала","еле встал",
            "ничего не хочу","всё надоело","упадок сил","хочется лежать",
            "устала от всего","нет сил ни на что","не могу встать","не хочу ничего делать",
            "даже думать не хочу","двигаться не хочется","как выжатый лимон",
            "батарейка на нуле","всё через силу","заставляю себя","нет ни на что сил",
            "даже поесть лень","ничего не делаю","лежу целый день"
        ],
        "anger": [
            "злюсь","злость","раздража","бесит","бесят","ярость","злой","злая",
            "агрессия","агрессивн","обида","обидно","ненавижу","раздражен","раздражена",
            "кипит","взорвусь","срываюсь","взбешен","взбешена","взбесило","бешенство",
            // фразы
            "несправедлив","терпеть не могу","меня бесит","хочется кричать",
            "достало","достал","достала","выводит","выводят","не могу сдержаться",
            "вспышка злости","сорвалась","сорвался","накричала","накричал",
            "хочется всё сломать","руки трясутся от злости","внутри всё кипит",
            "так злит","так бесит","это несправедливо","почему так со мной",
            "они меня достали","он меня достал","она меня достала"
        ],
        "stress": [
            "стресс","стрессовый","дедлайн","нагрузк","перегруз","давлен","хаос",
            "перегружена","перегружен","панику","завал","аврал","цейтнот",
            // фразы
            "не успеваю","много задач","не справляюсь","слишком много","на пределе",
            "не могу расставить","времени нет","горит","всё навалилось","не вывожу",
            "не знаю за что хвататься","не успею","сдача","зачёт","экзамен",
            "столько всего","слишком много всего","не знаю с чего начать",
            "всё срочно","всё важно","не успеваю ничего","разрываюсь",
            "везде нужна","везде должна","от меня всего ждут","не оправдываю",
            "подвела всех","подведу всех","не справлюсь","провалюсь"
        ],
        "loneliness": [
            "одинок","одиночество","никого","чужой","чужая","изоляц","брошен","брошена",
            "невидим","один","одна","некому","никому","непонят","непонята",
            // фразы
            "не с кем","никто не понимает","не замечают","нет друзей","нет близких",
            "все далеко","не нужен","не нужна","нет рядом","не понимают",
            "чувствую себя одной","чувствую себя одним","не с кем поговорить",
            "никто не слышит","всем всё равно","никому не нужна","никому не нужен",
            "все заняты","нет никого","совсем одна","совсем один","некому рассказать",
            "не с кем поделиться","все ушли","все отвернулись","меня не замечают",
            "как будто меня нет","invisible","меня не слышат"
        ],
        "positive": [
            "хорошо","отлично","счастлив","счастлива","радуюсь","радость","прекрасно",
            "замечательно","доволен","довольна","вдохновл","лёгко","светло","благодарн",
            "позитив","гармония","кайф","кайфую","рада","рад","супер","классно",
            "великолепно","чудесно","восхитительно","кайфово","балдею","кайфую",
            // фразы
            "энергия есть","всё получается","хорошее настроение","всё хорошо",
            "чувствую себя хорошо","сегодня хороший день","всё супер","всё отлично",
            "на душе легко","на душе хорошо","жизнь прекрасна","всё идёт хорошо",
            "получилось","справилась","справился","сдала","сдал","поступила",
            "влюбилась","влюбился","познакомилась","познакомился","счастливая","счастливый"
        ]
    ]

    private let responses: [String: [String]] = [
        "anxiety": [
            "Я слышу тебя. Тревога — это очень тяжело. Попробуй прямо сейчас сделать глубокий вдох на 4 счёта, задержать на 4, и выдохнуть на 4 🌿",
            "Твои чувства абсолютно нормальны. Когда тревога накрывает, попробуй заземлиться: назови 5 вещей которые видишь вокруг, 4 которые можешь потрогать, 3 которые слышишь.",
            "Тревога — это сигнал, а не факт. Она преувеличивает угрозы. Спроси себя: насколько вероятно что самое плохое действительно случится? 💙",
            "Ты не одна с этим. Тревога пройдёт — она всегда проходит. Я рядом 🤍",
            "Страх и тревога — это сигналы, а не приговор. Ты сильнее своей тревоги 🌿",
            "Положи руку на грудь. Чувствуешь как бьётся сердце? Оно работает, ты в безопасности. Сделай три медленных выдоха 💙",
            "Тревога говорит о том что тебе что-то важно. Это не слабость — это забота о себе 🤍",
            "Попробуй технику «5-4-3-2-1»: 5 предметов вокруг, 4 звука, 3 ощущения на коже, 2 запаха, 1 вкус. Это возвращает в настоящий момент 🌿"
        ],
        "sadness": [
            "Мне жаль что тебе сейчас так тяжело. Грусть — это не слабость, это честность с собой. Позволь себе чувствовать 💙",
            "Иногда просто нужно побыть в этом. Ты не обязана быть счастливой прямо сейчас. Я здесь 🤍",
            "Грусть приходит и уходит как волны. Ты справлялась с тёмными периодами раньше — справишься и сейчас 🌿",
            "Позволь себе погрустить. Это часть тебя, и это нормально. Ты не сломана 💙",
            "Когда больно — это значит что тебе не всё равно. А это говорит о том какой живой и настоящей ты бываешь 🤍",
            "Иногда слёзы — это не слабость, а способ тела выпустить то что слишком тяжело нести 💙",
            "Ты заслуживаешь тепла и заботы — особенно сейчас когда тяжело 🌿",
            "Не торопи себя «взять себя в руки». Горе и грусть требуют времени. Будь к себе нежна 🤍",
            "Самое тёмное время — перед рассветом. Это пройдёт, даже если сейчас так не кажется 💙"
        ],
        "sleep": [
            "Бессонница изматывает. Попробуй за час до сна убрать телефон и приглушить свет — мозгу нужен сигнал что пора отдыхать 🌙",
            "Мысли не дают уснуть? Запиши всё что беспокоит на бумагу — это выгружает голову и помогает отпустить.",
            "Попробуй дыхание 4-7-8: вдох на 4, задержка на 7, выдох на 8. Это замедляет нервную систему 🌙",
            "Иногда помогает представить что ты очень тяжёлая и медленно погружаешься в тёплую воду. Расслабляй каждую часть тела по очереди 🌿",
            "Тело засыпает когда чувствует безопасность. Попробуй сказать себе вслух: «Я в безопасности. Мне ничего не угрожает. Можно отдохнуть» 🤍",
            "Не смотри на часы — это усиливает тревогу. Укройся, сделай темно и позволь себе просто лежать без цели уснуть 🌙",
            "Тёплый душ или ванна за час до сна физически снижает температуру тела потом — это сигнал для засыпания 🌿",
            "Белый шум или звуки дождя помогают мозгу «отцепиться» от мыслей. Попробуй — в нашем приложении есть такие звуки 🌙"
        ],
        "fatigue": [
            "Усталость — это сигнал тела что ему нужна забота. Ты не обязана работать на износ 💙",
            "Попробуй правило «5 минут»: просто пять минут полного отдыха без телефона и мыслей о делах.",
            "Ты делаешь много. Но ты тоже важна — не только то что ты делаешь. Позволь себе восстановиться 🤍",
            "Выгорание — это не лень и не слабость. Это результат того что ты слишком долго давала больше чем получала 💙",
            "Иногда самое продуктивное что можно сделать — это ничего. Просто лечь и разрешить себе отдохнуть 🌿",
            "Тело знает когда надо остановиться. Оно посылает сигналы. Усталость — один из них. Послушай его 🤍",
            "Один маленький шаг считается. Не надо делать всё сразу. Что одно маленькое ты можешь сделать для себя прямо сейчас? 💙",
            "Ты не машина. Людям нужен отдых — это не роскошь, это необходимость 🌿"
        ],
        "anger": [
            "Злость — это нормальная эмоция. Она говорит что что-то важное для тебя нарушено 💙",
            "Прежде чем реагировать, попробуй досчитать до 10. Это даёт мозгу время переключиться с эмоций на разум.",
            "Злость — это энергия. Её можно направить в спорт, творчество или честный разговор 💙",
            "Когда кипит внутри — выйди на улицу и пройдись быстрым шагом. Физическое движение буквально сжигает адреналин 🌿",
            "Злость часто скрывает под собой боль или страх. Что стоит за этой злостью на самом деле? 💙",
            "Ты имеешь право злиться. Важно найти способ выразить это не разрушая себя и других 🤍",
            "Попробуй написать всё что ты чувствуешь — прямо как есть, без цензуры. Это помогает выпустить пар без последствий 💙",
            "Сделай несколько глубоких выдохов через рот — это физически снижает уровень кортизола 🌿"
        ],
        "stress": [
            "Стресс накапливается незаметно. Давай разберём: что сейчас самое главное? 💙",
            "Ты не можешь сделать всё сразу. Выбери одну задачу — самую важную — и только её.",
            "Ты справляешься с большим. Отдых — это часть продуктивности, не её враг 🤍",
            "Когда всё кажется срочным — ничего не кажется возможным. Выпиши всё на бумагу и расставь по важности. Список делает хаос управляемым 💙",
            "Глубокий вдох. Ты уже справляешься — иначе бы не чувствовала этот стресс. Он говорит о том что тебе важно что ты делаешь 🌿",
            "Иногда достаточно сделать один маленький шаг. Не весь путь — один шаг. Что это было бы прямо сейчас? 💙",
            "Ты человек, а не функция. Даже в самый загруженный день ты заслуживаешь хотя бы 10 минут для себя 🤍",
            "Попробуй технику «помидора»: 25 минут работы, 5 минут полного отдыха. Это снижает ощущение перегруза 🌿"
        ],
        "loneliness": [
            "Одиночество — одно из самых тяжёлых чувств. Знай что ты не одна прямо сейчас — я здесь 💙",
            "Близость начинается с малого — с одного честного разговора. Написать «привет, скучаю» уже достаточно.",
            "Ты не невидима — просто пока не нашла своих. Они есть 💙",
            "Иногда одиночество — это сигнал что нам нужна более глубокая связь, а не просто люди рядом 🤍",
            "Хорошие отношения с собой притягивают хороших людей. Как ты сейчас относишься к себе? 💙",
            "Одиночество бывает очень громким внутри. Но ты справляешься — ты здесь и ты ищешь поддержки. Это сила 🌿",
            "Написать кому-то первой — это не слабость. Это смелость. Есть ли хоть один человек которому можно написать? 🤍",
            "Даже короткое общение с кем-то добрым может изменить день. Я здесь и я слушаю тебя 💙"
        ],
        "positive": [
            "Как здорово это слышать! Что именно сделало сегодня таким хорошим? 🌿",
            "Лови это ощущение и запомни его — оно пригодится в трудные моменты ☀️",
            "Радость — это тоже навык. Ты её замечаешь, а это уже много 🌿",
            "Это здорово! Запиши этот момент в дневник — потом будет приятно перечитать 📓",
            "Хорошее настроение заразительно — поделись им с кем-то сегодня ☀️",
            "Ты заслуживаешь этого ощущения. Не торопись его отпускать 🌿",
            "Такие моменты — это ресурс. Мозг запоминает хорошее когда мы его замечаем ☀️",
            "Рада за тебя искренне! Это твоя маленькая победа 🌿"
        ]
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

    // уточняющие вопросы для диалогового потока — шаг 2 и 3
    private let dialogQuestions: [String: [String]] = [
        "anxiety": [
            "Что сейчас помогает тебе немного успокоиться — есть что-то такое?",
            "Ты сейчас одна или рядом кто-то есть?"
        ],
        "sadness": [
            "Ты сейчас больше хочешь побыть в тишине или наоборот чтобы кто-то был рядом?",
            "Есть ли что-то маленькое что обычно тебя немного радует?"
        ],
        "sleep": [
            "Ты уже легла или ещё не пробовала?",
            "Что обычно мешает больше всего — мысли или просто тело не расслабляется?"
        ],
        "fatigue": [
            "Когда ты последний раз делала что-то только для себя — не для работы или учёбы?",
            "Есть ли хоть маленький перерыв который ты могла бы себе позволить сегодня?"
        ],
        "anger": [
            "Ты сейчас можешь уйти куда-то чтобы побыть одной хотя бы несколько минут?",
            "Что обычно помогает тебе выпустить пар — есть что-то такое?"
        ],
        "stress": [
            "Если выбрать одно самое главное из всего что давит — что это было бы?",
            "Есть ли кто-то кому ты могла бы делегировать хоть что-то или попросить помощи?"
        ],
        "loneliness": [
            "Есть ли человек которому ты могла бы написать прямо сейчас — даже просто «привет»?",
            "Когда ты последний раз чувствовала себя по-настоящему понятой?"
        ],
        "positive": [
            "Что именно сделало этот момент особенным?",
            "Есть ли человек с которым тебе хочется этим поделиться?"
        ]
    ]

    // финальный совет после диалога — выводит из потока
    private let dialogClosing: [String: String] = [
        "anxiety":    "Спасибо что поделилась 🤍 Тревога — это сигнал что что-то важно для тебя. Попробуй прямо сейчас сделать несколько глубоких вдохов, а потом загляни в раздел Медитация — там есть «Дыхание покоя» специально для таких моментов 🌿",
        "sadness":    "Я рада что ты рассказала мне это 💙 Позволь себе побыть в этом чувстве — это нормально. А когда будешь готова, попробуй написать в дневник что ты сейчас чувствуешь. Иногда слова на бумаге помогают лучше понять себя 📓",
        "sleep":      "Ты молодец что не игнорируешь это 🌙 Попробуй сегодня вечером послушать медитацию «Мягкое засыпание» в разделе Медитация. Многие говорят что уже после первого раза засыпать становится легче.",
        "fatigue":    "Слышу тебя 🤍 Твоё тело просит паузы — и это важно уважать. Попробуй сегодня сделать хотя бы одно маленькое доброе дело для себя. Даже 10 минут медитации «Тепло и свет» могут дать ощущение что ты не одна в этом.",
        "anger":      "Спасибо что доверилась 💙 Злость говорит о том что что-то важное для тебя нарушено. Попробуй записать в дневник что именно тебя задело — иногда это помогает увидеть ситуацию иначе и выпустить пар без последствий 📓",
        "stress":     "Ты справляешься с очень многим 🌿 Попробуй прямо сейчас выписать на бумагу всё что давит — список делает хаос управляемым. А потом загляни в раздел Тесты — там есть тест на стресс, который поможет понять насколько ты сейчас перегружена.",
        "loneliness": "Я здесь и я слышу тебя 💙 Одиночество — одно из самых тяжёлых чувств. Попробуй написать в дневник прямо сейчас — всё что у тебя внутри. Иногда когда выражаешь это словами, становится чуть легче. Ты не невидима 🤍",
        "positive":   "Как здорово это слышать ☀️ Запиши этот момент в дневник — такие воспоминания становятся ресурсом в трудные дни. Ты умеешь замечать хорошее, а это настоящий навык 🌿"
    ]

    // конкретные ситуации — первый ответ признаёт контекст, не спрашивает причину
    private let contextTriggers: [(keywords: [String], response: String)] = [
        (["гроза","молния","гром","ливень","буря","гремит","сверкает"],
         "Гроза — это правда страшно, особенно когда одна 🤍 Это нормально — бояться того что громко и неожиданно. Попробуй укутаться во что-то тёплое и включить фоновый звук. Ты в безопасности."),
        (["экзамен","зачёт","защита диплома","пересдача","провалила","завалила","не сдала","не сдал"],
         "Это правда стрессово 💙 Волноваться перед важным — нормально. Ты уже сделала всё что могла подготовить. Сейчас главное — выдохнуть."),
        (["сессия","курсовая","диплом","реферат","не успею сдать","дедлайн горит"],
         "Учебная нагрузка умеет давить как мало что другое 💙 Давай по одному: что самое срочное прямо сейчас? Остальное подождёт."),
        (["поссорилась","поругалась","поругались","конфликт","скандал","накричали"],
         "Ссоры с близкими — это очень больно 💙 Дай себе время успокоиться прежде чем что-то делать. Многое становится яснее когда эмоции утихают."),
        (["расстались","бросил","бросила","расставание","разрыв","ушёл","ушла","изменил","изменила"],
         "Это одна из самых тяжёлых вещей 🤍 Боль которую ты сейчас чувствуешь — настоящая. Позволь себе чувствовать это, не торопи себя. Ты справишься — даже если сейчас так не кажется."),
        (["не отвечает","игнорирует","пропал","пропала","не пишет","прочитал но не ответил"],
         "Это мучительно — ждать и не знать 💙 Неопределённость хуже любого ответа. Попробуй переключить внимание на что-то что зависит от тебя, а не от него."),
        (["заболела","болею","температура","болит голова","тошнит","плохо физически","болит живот"],
         "Болеть — это не только физически тяжело, но и морально 🤍 Когда тело плохо себя чувствует, всё остальное тоже кажется тяжелее. Пожалуйста позаботься о себе сегодня."),
        (["болит","хроническ","диагноз","врач сказал","больница","операция","анализы плохие"],
         "Проблемы со здоровьем — это очень тревожно 💙 Страх за здоровье — один из самых глубоких страхов. Ты не одна с этим."),
        (["уволили","сократили","потеряла работу","потерял работу","хочу уволиться"],
         "Это серьёзный стресс 💙 Потеря работы или мысли об уходе — удар по стабильности. Твои чувства абсолютно оправданы."),
        (["начальник","коллеги достали","токсичный","моббинг","не ценят на работе"],
         "Рабочая токсичность изматывает не меньше физической усталости 💙 Ты заслуживаешь места где тебя ценят."),
        (["мама","папа","родители не понимают","поругалась с мамой","дома скандал"],
         "Конфликты с семьёй особенно болезненны — потому что это самые близкие люди 💙 Именно поэтому так больно когда что-то идёт не так."),
        (["умер","умерла","потеря","похороны","скончался","погиб","погибла","потеряла близкого"],
         "Мне очень жаль. Потеря — это невыносимо тяжело 💙 Нет правильного способа переживать горе. Позволь себе столько времени сколько нужно. Я здесь."),
        (["одна дома","темно дома","страшно одной","ночь одна","ночью одна"],
         "Быть одной ночью бывает правда неуютно 🤍 Включи свет, заварь что-то тёплое — маленькие ритуалы помогают почувствовать себя в безопасности."),
        (["нет денег","долг","кредит","не хватает денег","деньги кончились"],
         "Финансовое давление — один из самых изматывающих видов стресса 💙 Твои чувства оправданы. Давай разберёмся что сейчас самое важное."),
        (["некрасивая","толстая","худая","не нравлюсь себе","ненавижу своё тело","комплексы"],
         "То что ты чувствуешь к своему телу — это больно 🤍 Мы все бываем жестоки к себе. Но ты больше чем твоя внешность — намного больше."),
        (["вроде всё хорошо но","без причины плохо","не знаю почему плохо","просто так тревожно"],
         "Иногда тревога или грусть приходят без видимой причины — и это не менее реально 💙 Тело накапливает напряжение которое мы не всегда замечаем. Ты имеешь право чувствовать это."),
        (["устала от людей","не хочу никого видеть","хочу побыть одна","социальная усталость"],
         "Это нормально — иногда нам нужно время только для себя 🌿 Это не эгоизм, это забота о себе. Позволь себе это.")
    ]

    private func checkContextTriggers(_ input: String) -> String? {
        let lowered = input.lowercased()
        for trigger in contextTriggers {
            if trigger.keywords.contains(where: { lowered.contains($0) }) {
                return trigger.response
            }
        }
        return nil
    }

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
        usedResponseIndices = [:]
        dialogState = .idle
        dialogCategory = ""
        dialogStep = 0
        tableView.reloadData()
        showWelcomeMessage()
    }

    // MARK: - Classification
    private func classify(_ input: String) -> String {
        let lowered = input.lowercased()

        // 1. Сначала словарь — надёжнее на разговорном русском
        var scores: [String: Int] = [:]
        for (label, words) in keywords {
            let count = words.filter { lowered.contains($0) }.count
            if count > 0 { scores[label] = count }
        }
        if let best = scores.max(by: { $0.value < $1.value }) { return best.key }

        // 1.5 Нейтральные реплики — перехватываем до CoreML
        // иначе CoreML классифицирует «спасибо» как тревогу
        let neutralPhrases = [
            "спасибо","благодарю","понятно","ясно","окей","окей","ок","хорошо",
            "понял","поняла","буду иметь в виду","учту","попробую","попробую это",
            "звучит хорошо","звучит интересно","не знаю","наверное","может быть",
            "возможно","пожалуй","ладно","договорились","согласна","согласен",
            "точно","именно","именно так","да","нет","ага","угу","мм","хм"
        ]
        if neutralPhrases.contains(where: { lowered.trimmingCharacters(in: .punctuationCharacters) == $0 ||
                                             lowered == $0 }) {
            return "neutral"
        }
        // короткие фразы до 3 слов тоже могут быть нейтральными — не доверяем CoreML
        let wordCount = lowered.split(separator: " ").count
        if wordCount <= 2 && !lowered.contains("!") {
            // проверяем ещё раз через контекст прежде чем отдать CoreML
            let contextResult = classifyByContext(lowered)
            if contextResult != "unknown" { return contextResult }
            return "neutral"
        }

        // 2. Если словарь не нашёл — пробуем CoreML
        if let prediction = try? model.prediction(text: input) {
            return prediction.label
        }

        // 3. Контекстный анализ для фраз которые не попали в словарь
        return classifyByContext(lowered)
    }

    private func classifyByContext(_ text: String) -> String {
        let sad     = ["плохо","тяжело","больно","не радует","не хочу","всё плохо","мне плохо","ничего не хочется"]
        let anx     = ["не знаю","что делать","вдруг","а если","не уверена","не уверен","переживаю за"]
        let fat     = ["вымот","сложно","не тяну","еле","с трудом","столько всего"]
        let str     = ["всё навалилось","не вывожу","слишком много","завал","не успею","столько дел"]
        let lonely  = ["никому","некому","нет рядом","не понимают","сама","один ","одна ","не с кем"]

        if sad.contains(where:    { text.contains($0) }) { return "sadness" }
        if anx.contains(where:    { text.contains($0) }) { return "anxiety" }
        if str.contains(where:    { text.contains($0) }) { return "stress" }
        if fat.contains(where:    { text.contains($0) }) { return "fatigue" }
        if lonely.contains(where: { text.contains($0) }) { return "loneliness" }
        return "unknown"
    }

    private func generateResponse(for input: String) -> String {
        messageCount += 1
        let lowered = input.lowercased()

        // если уже идёт диалог — читаем ответ пользователя и реагируем на него
        if dialogState == .inProgress {
            // сначала проверяем — не сменил ли пользователь тему
            if let contextResponse = checkContextTriggers(input) {
                dialogState = .idle
                dialogCategory = ""
                dialogStep = 0
                return contextResponse
            }

            // реагируем на содержание ответа
            let dialogResponse = handleDialogReply(input: lowered, category: dialogCategory, step: dialogStep)
            if let dr = dialogResponse {
                dialogState = .idle
                dialogCategory = ""
                dialogStep = 0
                return dr
            }

            // стандартный следующий вопрос
            let questions = dialogQuestions[dialogCategory] ?? []
            if dialogStep < questions.count {
                let q = questions[dialogStep]
                dialogStep += 1
                if dialogStep >= questions.count { dialogState = .closing }
                return q
            }
        }

        if dialogState == .closing {
            dialogState = .idle
            dialogStep = 0
            let cat = dialogCategory
            dialogCategory = ""
            return dialogClosing[cat] ?? fallbackResponses.randomElement()!
        }

        // контекстные триггеры — конкретные ситуации
        if let contextResponse = checkContextTriggers(input) {
            let label = classify(input)
            if label != "unknown", let questions = dialogQuestions[label], !questions.isEmpty {
                dialogState = .inProgress
                dialogCategory = label
                dialogStep = 0
            }
            return contextResponse
        }

        // классификация
        let label = classify(input)

        // нейтральные реплики — мягко продолжаем разговор
        if label == "neutral" {
            let neutralReplies = [
                "Я здесь 🌿 Как ты себя чувствуешь прямо сейчас?",
                "Рада что ты здесь 💙 Расскажи — что сегодня на душе?",
                "Хорошо 🤍 Если захочешь поговорить — я слушаю.",
                "Всегда здесь для тебя 🌿 Что происходит?",
                "Конечно 💙 Как ты?"
            ]
            return neutralReplies.randomElement()!
        }

        guard label != "unknown" else {
            let clarifying = [
                "Расскажи мне больше — я хочу лучше понять что ты чувствуешь 💙",
                "Я слышу тебя. Что сейчас происходит — можешь описать подробнее?",
                "Я здесь. Что именно тебя беспокоит прямо сейчас? 🌿",
                "Ты не одна. Расскажи — что тяжелее всего сейчас? 🤍",
                "Попробуй описать что ты чувствуешь — злость, грусть, усталость? Я здесь 💙"
            ]
            return clarifying.randomElement()!
        }

        let pool = responses[label] ?? fallbackResponses
        var used = usedResponseIndices[label] ?? []
        let available = Set(0..<pool.count).subtracting(used)
        let chosenIndex: Int
        if available.isEmpty {
            used = []
            usedResponseIndices[label] = []
            chosenIndex = Int.random(in: 0..<pool.count)
        } else {
            chosenIndex = available.randomElement()!
        }
        used.insert(chosenIndex)
        usedResponseIndices[label] = used

        let response = pool[chosenIndex]

        if let questions = dialogQuestions[label], !questions.isEmpty {
            dialogState = .inProgress
            dialogCategory = label
            dialogStep = 0
        }

        return response
    }

    // читаем ответ пользователя во время диалога и реагируем осмысленно
    private func handleDialogReply(input: String, category: String, step: Int) -> String? {
        let isNegative = ["нет","не","никого","никому","некому","никто","не знаю",
                          "не могу","наверное нет","вряд ли","не особо","нечего"].contains(where: { input.contains($0) })
        let isPositive = ["да","есть","конечно","ага","угу","есть такое","есть человек",
                          "есть кое-что","попробую","хорошо"].contains(where: { input.contains($0) })

        guard isNegative || isPositive else { return nil }

        if isNegative {
            switch category {
            case "positive":
                // пользователь говорит что не с кем поделиться радостью — это грустно
                return "Жаль что не с кем поделиться — радость хочется разделять 🤍 Знаешь, запиши это в дневник. Это твоё и оно никуда не денется. А потом когда появится нужный человек — сможешь рассказать."
            case "anxiety":
                return "Понимаю. Иногда кажется что ничего не помогает — и это само по себе тяжело 💙 Попробуй одно: положи руки на живот и сделай три очень медленных выдоха. Просто выдоха — длиннее чем вдох. Это работает даже когда кажется что нет."
            case "loneliness":
                return "Это больно — когда совсем некому написать 🤍 Но ты написала мне, и это уже что-то. Попробуй сегодня сделать одно маленькое действие навстречу миру — даже просто выйти на 10 минут или написать в какой-нибудь чат. Маленький шаг считается."
            case "sadness":
                return "Когда нет ни человека рядом ни сил что-то делать — это особенно тяжело 💙 Позволь себе просто полежать и не требовать от себя ничего прямо сейчас. Иногда это единственное что нужно."
            case "fatigue":
                return "Значит давно не было настоящего отдыха 🤍 Попробуй сегодня сделать одно — только одно — маленькое доброе дело для себя. Не для продуктивности. Просто потому что ты это заслуживаешь."
            case "stress":
                return "Когда помощи нет и всё на тебе — это изматывает вдвойне 💙 Давай так: выбери одну задачу которую можно сделать за 15 минут и сделай только её. Остальное подождёт."
            default:
                return "Понятно 🤍 Даже если сейчас нет ресурса или нет рядом нужного человека — ты справляешься. Я здесь."
            }
        }

        if isPositive {
            switch category {
            case "positive":
                return "Здорово! Такие моменты становятся ещё лучше когда их разделяешь, поделись с кем-нибудь ☀️ И запиши в дневник тоже — чтобы помнить это ощущение."
            case "anxiety":
                return "Хорошо что есть что-то что помогает 🌿 Держись за это. И если тревога снова накроет — ты уже знаешь что делать. Загляни ещё в медитации — там есть «Дыхание покоя» для таких моментов."
            case "fatigue":
                return "Вот и отлично 🌿 Дай себе этот перерыв без чувства вины — это не лень, это необходимость. Ты заслуживаешь восстановления."
            default:
                return nil // продолжаем диалог штатно
            }
        }

        return nil
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

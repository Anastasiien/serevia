import UIKit

class AIViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    private let tableView = UITableView()
    private let messageInputContainer = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    private var messages: [String] = [] // Здесь будут храниться все сообщения
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAIScreen()
    }
    
    private func setupAIScreen() {
        view.backgroundColor = AppColors.background
        
        // Заголовок
        let titleLabel = UILabel()
        titleLabel.text = "AI Психолог"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = AppColors.primary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Таблица сообщений
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = AppColors.background
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.allowsSelection = false
        
        view.addSubview(tableView)
        
        // Контейнер ввода
        messageInputContainer.backgroundColor = AppColors.card
        messageInputContainer.layer.cornerRadius = 12
        messageInputContainer.layer.borderWidth = 1
        messageInputContainer.layer.borderColor = AppColors.border.cgColor
        messageInputContainer.translatesAutoresizingMaskIntoConstraints = false
        
        messageTextField.placeholder = "Введите сообщение..."
        messageTextField.borderStyle = .none
        messageTextField.delegate = self
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        
        sendButton.setTitle("Отправить", for: .normal)
        sendButton.setTitleColor(AppColors.primary, for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        messageInputContainer.addSubview(messageTextField)
        messageInputContainer.addSubview(sendButton)
        view.addSubview(messageInputContainer)
        
        NSLayoutConstraint.activate([
            messageInputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageInputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            messageInputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            messageInputContainer.heightAnchor.constraint(equalToConstant: 50),
            
            messageTextField.leadingAnchor.constraint(equalTo: messageInputContainer.leadingAnchor, constant: 10),
            messageTextField.centerYAnchor.constraint(equalTo: messageInputContainer.centerYAnchor),
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            
            sendButton.trailingAnchor.constraint(equalTo: messageInputContainer.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: messageInputContainer.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: messageInputContainer.topAnchor, constant: -10)
        ])
    }
    
    @objc private func sendButtonTapped() {
        guard let text = messageTextField.text, !text.isEmpty else { return }
        messages.append("Вы: \(text)")
        messageTextField.text = ""
        tableView.reloadData()
        scrollToBottom()
    }
    
    private func scrollToBottom() {
        if messages.count == 0 { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    // MARK: - UITableViewDataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.textLabel?.text = messages[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.textLabel?.textColor = AppColors.text
        return cell
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonTapped()
        return true
    }
}

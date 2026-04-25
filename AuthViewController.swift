//
//  AuthViewController.swift
//  serevia
//
//  Created by ekatizzz on 15.04.2026.
//

import UIKit

class AuthViewController: UIViewController {

    // MARK: - UI Elements
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let nameTextField = UITextField()
    
    private let actionButton = UIButton(type: .system)
    private let toggleButton = UIButton(type: .system)
    
    // MARK: - State
    private var isSignUpMode = false

    private let accent = UIColor(red: 0.58, green: 0.46, blue: 0.42, alpha: 1)
    private let pageBg = UIColor(red: 0.96, green: 0.94, blue: 0.91, alpha: 1)
    private let textDark = UIColor(red: 0.20, green: 0.15, blue: 0.10, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateMode()
    }
    
    private func setupUI() {
        view.backgroundColor = pageBg
        
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = textDark
        titleLabel.textAlignment = .center
        
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = textDark.withAlphaComponent(0.6)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        
        [nameTextField, emailTextField, passwordTextField].forEach { tf in
            tf.backgroundColor = .white
            tf.layer.cornerRadius = 12
            tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 1))
            tf.leftViewMode = .always
            tf.font = .systemFont(ofSize: 16)
            tf.textColor = textDark
            tf.autocapitalizationType = .none
            tf.layer.borderWidth = 0
            tf.layer.borderColor = UIColor.systemRed.cgColor
        }
        
        nameTextField.placeholder = "Ваше имя"
        
        emailTextField.placeholder = "Email"
        emailTextField.keyboardType = .emailAddress
        emailTextField.textContentType = .emailAddress
        
        passwordTextField.placeholder = "Пароль (минимум 8 символов)"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.keyboardType = .asciiCapable
        
        actionButton.backgroundColor = accent
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        actionButton.layer.cornerRadius = 16
        actionButton.addTarget(self, action: #selector(handleMainAction), for: .touchUpInside)
        
        toggleButton.setTitleColor(accent, for: .normal)
        toggleButton.titleLabel?.font = .systemFont(ofSize: 14)
        toggleButton.addTarget(self, action: #selector(toggleMode), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [nameTextField, emailTextField, passwordTextField, actionButton, toggleButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        
        [titleLabel, subtitleLabel, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            nameTextField.heightAnchor.constraint(equalToConstant: 55),
            emailTextField.heightAnchor.constraint(equalToConstant: 55),
            passwordTextField.heightAnchor.constraint(equalToConstant: 55),
            actionButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func updateMode() {
        let title = isSignUpMode ? "Регистрация" : "С возвращением!"
        let subtitle = isSignUpMode ? "Создайте аккаунт, чтобы сохранять свой прогресс" : "Войдите в свой личный кабинет"
        let buttonTitle = isSignUpMode ? "Создать аккаунт" : "Войти"
        let toggleTitle = isSignUpMode ? "Уже есть аккаунт? Войти" : "Нет аккаунта? Зарегистрироваться"
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
        actionButton.setTitle(buttonTitle, for: .normal)
        toggleButton.setTitle(toggleTitle, for: .normal)
        
        UIView.animate(withDuration: 0.3) {
            self.nameTextField.isHidden = !self.isSignUpMode
            self.nameTextField.alpha = self.isSignUpMode ? 1 : 0
        }
    }
    
    @objc private func toggleMode() {
        isSignUpMode.toggle()
        updateMode()
        emailTextField.layer.borderWidth = 0
        passwordTextField.layer.borderWidth = 0
    }
    
    // MARK: - Validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegEx = "^[a-zA-Z0-9]{8,}$"
        let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
    
    @objc private func handleMainAction() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        
        var isFormValid = true
        
        if !isValidEmail(email) {
            isFormValid = false
            showError(for: emailTextField)
        } else {
            hideError(for: emailTextField)
        }
        
        if !isValidPassword(password) {
            isFormValid = false
            showError(for: passwordTextField)
        } else {
            hideError(for: passwordTextField)
        }
        
        guard isFormValid else { return }
        
        if isSignUpMode {
            let name = nameTextField.text ?? "Пользователь"
            UserDefaults.standard.set(name, forKey: "userName")
            UserDefaults.standard.set(email, forKey: "userEmail")
        }
        
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        setRootToMainApp()
    }
    
    private func showError(for textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderWidth = 1
        }
    }
    
    private func hideError(for textField: UITextField) {
        textField.layer.borderWidth = 0
    }
    
    private func setRootToMainApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let mainTabBar = MainTabBarController()
            window.rootViewController = mainTabBar
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
        }
    }
}

//
//  AccountLoginController.swift
//  Where_Are_You
//
//  Created by 오정석 on 25/5/2024.
//

import UIKit

class AccountLoginController: UIViewController {
    // MARK: - Properties
    let accountLoginView = AccountLoginView()
    private var viewModel: AccountLoginViewModel!
    private var userIdEnter: Bool = false
    private var passwordEnter: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupViewModel()
        setupBindings()
    }
    
    // MARK: - Helpers
    func setupUI() {
        self.view = accountLoginView
        configureNavigationBar(title: "로그인", backButtonAction: #selector(backButtonTapped))
    }
    
    func setupActions() {
        accountLoginView.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        accountLoginView.findAccountButton.button.addTarget(self, action: #selector(findAccountButtonTapped), for: .touchUpInside)
        accountLoginView.signupButton.addTarget(self, action: #selector(registerAccountButtonTapped), for: .touchUpInside)
        
        accountLoginView.idTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        accountLoginView.passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func setupViewModel() {
        let authService = AuthService()
        let authRepository = AuthRepository(authService: authService)
        let accountLoginUseCase = AccountLoginUseCaseImpl(repository: authRepository)
        viewModel = AccountLoginViewModel(accountLoginUseCase: accountLoginUseCase)
    }
    
    func setupBindings() {
        // 로그인 성공
        viewModel.onLoginSuccess = { [weak self] in
            // 메인 화면 이동
            let controller = MainTabBarController()
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self?.present(nav, animated: true, completion: nil)
        }
        
        // 로그인 실패
        viewModel.onLoginFailure = { [weak self] message, isAvailable in
            // 로그인 실패
            self?.updateStatus(label: self?.accountLoginView.idErrorLabel, message: message, isAvailable: isAvailable, textField: self?.accountLoginView.idTextField)
        }
    }
    
    // MARK: - Selectors
    @objc func backButtonTapped() {
        dismiss(animated: true)
    }
    
    // viewmodel에 로그인하기 버튼 활성화 비활성화 로직 추가하기
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let userId = accountLoginView.idTextField.text,
              let password = accountLoginView.passwordTextField.text else { return }
        
        switch textField {
        case accountLoginView.idTextField:
            if userId.isEmpty {
                self.userIdEnter = false
            } else {
                self.userIdEnter = true
            }
        case accountLoginView.passwordTextField:
            if password.isEmpty {
                self.passwordEnter = false
            } else {
                self.passwordEnter = true
            }
        default:
            break
        }
    }
    
    @objc func loginButtonTapped() {
        guard let userId = accountLoginView.idTextField.text, !userId.isEmpty,
              let password = accountLoginView.passwordTextField.text, !password.isEmpty else { return }
        
        viewModel.login(userId: userId, password: password)
    }
    
    @objc func findAccountButtonTapped() {
        let controller = SearchAccountController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @objc func registerAccountButtonTapped() {
        let controller = TermsAgreementViewController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    private func updateStatus(label: UILabel?, message: String, isAvailable: Bool, textField: UITextField?) {
        label?.text = message
        label?.textColor = isAvailable ? .brandColor : .warningColor
        textField?.layer.borderColor = isAvailable ? UIColor.color212.cgColor : UIColor.warningColor.cgColor
    }
}
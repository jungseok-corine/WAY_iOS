//
//  ViewController.swift
//  Where_Are_You
//
//  Created by 오정석 on 24/5/2024.
//

import UIKit

class LoginViewController: UIViewController {
    // MARK: - Properties
    private let loginView = LoginView()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = loginView
        
        buttonAction()
    }
    
    // MARK: - Helpers
    func buttonAction() {
        loginView.kakaoLogin.addTarget(self, action: #selector(kakaoLoginTapped), for: .touchUpInside)
        loginView.appleLogin.addTarget(self, action: #selector(appleLoginTapped), for: .touchUpInside)
        loginView.accountLogin.addTarget(self, action: #selector(accountLoginTapped), for: .touchUpInside)
        loginView.signupButton.button.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
        loginView.findAccountButton.button.addTarget(self, action: #selector(findAccountButtonTapped), for: .touchUpInside)
        loginView.inquiryButton.button.addTarget(self, action: #selector(inquiryButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Selectors
    
    @objc func kakaoLoginTapped() {
        
    }
    
    @objc func appleLoginTapped() {
        
    }
    
    @objc func accountLoginTapped() {
        let controller = AccountLoginController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @objc func signupButtonTapped() {
        let controller = TermsAgreementViewController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @objc func findAccountButtonTapped() {
        let controller = AccountSearchViewController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @objc func inquiryButtonTapped() {
        
    }
}

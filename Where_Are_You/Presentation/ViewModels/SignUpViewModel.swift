//
//  RegisterViewModel.swift
//  Where_Are_You
//
//  Created by 오정석 on 3/6/2024.
//

import Foundation

class SignUpViewModel {
    
    // MARK: - Properties
    private let signUpUseCase: SignUpUseCase
    private let checkUserIDAvailabilityUseCase: CheckUserIDAvailabilityUseCase
    private let checkEmailAvailabilityUseCase: CheckEmailAvailabilityUseCase
    private let sendEmailVerificationCodeUseCase: SendEmailVerificationCodeUseCase
    private let verifyEmailCodeUseCase: VerifyEmailCodeUseCase
    var user = User()
    
    // Input
    var password: String = ""
    var confirmPassword: String = ""
    var email: String = ""
    
    // Output
    var onSignUpSuccess: (() -> Void)?
    var onSignUpFailure: ((String) -> Void)?
    
    var onUserIDAvailabilityChecked: ((String, Bool) -> Void)?
    var onEmailAvailabilityChecked: ((String) -> Void)?
    var onEmailVerificationCodeSent: ((String) -> Void)?
    var onEmailVerificationCodeVerified: ((String) -> Void)?
    
    var onUserIDFormatError: ((String) -> Void)?
    var onPasswordFormatError: ((String) -> Void)?
    var onCheckPasswordFormatError: ((String) -> Void)?
    var onEmailFormatError: ((String) -> Void)?
    var onShowVerificationCodeField: (() -> Void)?
    var onUpdateTimer: ((String) -> Void)?
    
    private var timer: Timer?
    private var timerCount: Int = 300
    
    // MARK: - LifeCycle
    
    init(signUpUseCase: SignUpUseCase,
         checkUserIDAvailabilityUseCase: CheckUserIDAvailabilityUseCase,
         checkEmailAvailabilityUseCase: CheckEmailAvailabilityUseCase,
         sendEmailVerificationCodeUseCase: SendEmailVerificationCodeUseCase,
         verifyEmailCodeUseCase: VerifyEmailCodeUseCase) {
        self.signUpUseCase = signUpUseCase
        self.checkUserIDAvailabilityUseCase = checkUserIDAvailabilityUseCase
        self.checkEmailAvailabilityUseCase = checkEmailAvailabilityUseCase
        self.sendEmailVerificationCodeUseCase = sendEmailVerificationCodeUseCase
        self.verifyEmailCodeUseCase = verifyEmailCodeUseCase
    }
    
    // MARK: - Helpers(로그인, 아이디, 이메일, 코드확인)
    
    func signUp() {
        
        user.password = confirmPassword
        signUpUseCase.execute(request: user) { result in
            switch result {
            case .success:
                self.onSignUpSuccess?()
            case .failure(let error):
                self.onSignUpFailure?(error.localizedDescription)
            }
        }
    }
    
    func checkUserIDAvailability(userId: String) {
        guard isValidUserID(userId) else {
            onUserIDAvailabilityChecked?("영문 소문자와 숫자만 사용하여, 영문 소문자로 시작하는 5~12자의 아이디를 입력해주세요", false)
            return
        }
        
        checkUserIDAvailabilityUseCase.execute(userId: userId) { result in
            switch result {
            case .success(let data):
                if data.isSuccess {
                    self.user.userId = userId
                    self.onUserIDAvailabilityChecked?("사용가능한 아이디입니다.", true)
                } else {
                    self.onUserIDAvailabilityChecked?("중복된 아이디입니다.", false)
                }
            case .failure(let error):
                self.onUserIDAvailabilityChecked?(error.localizedDescription, false)
            }
        }
    }
    
    func checkPasswordAvailability(password: String) {
        if isValidPassword(password) {
            onPasswordFormatError?("사용가능한 비밀번호입니다.")
        } else {
            onPasswordFormatError?("영문 대문자, 소문자로 시작하는 6~20자의 영문 대문자, 소문자, 숫자를 포함해 입력해주세요.")
        }
    }
    
    func checkSamePassword(password: String, checkPassword: String) {
        if isPasswordSame(password, checkpw: checkPassword) {
            onCheckPasswordFormatError?("비밀번호가 일치힙니다.")
        } else {
            onCheckPasswordFormatError?("비밀번호가 일치하지 않습니다.")
        }
    }
    
    func checkEmailAvailability(email: String) {
        guard isValidEmail(email) else {
            onEmailFormatError?("유효하지 않은 이메일 형식입니다.")
            return
        }
        
        checkEmailAvailabilityUseCase.execute(email: email) { result in
            switch result {
            case .success(let data):
                if data.isSuccess {
                    self.sendEmailVerificationCode(email: email)
                }
            case .failure(let error):
                self.onEmailAvailabilityChecked?(error.localizedDescription)
            }
        }
    }
    
    func sendEmailVerificationCode(email: String) {
        sendEmailVerificationCodeUseCase.execute(email: email) { result in
            switch result {
            case .success:
                self.onEmailVerificationCodeSent?("인증코드가 전송되었습니다.")
                self.email = email
            case .failure(let error):
                self.onSignUpFailure?(error.localizedDescription)
            }
        }
    }
    
    // 이 부분을 apiservice를 통해 하는걸로 추가해야함
    func verifyEmailCode(inputCode: String) {
        verifyEmailCodeUseCase.execute(email: email, code: inputCode) { result in
            switch result {
            case .success:
                self.user.email = self.email
                self.onEmailVerificationCodeVerified?("인증코드가 확인되었습니다.")
            case .failure(let error):
                self.onSignUpFailure?(error.localizedDescription)
            }
        }
    }
    
    private func startTimer() {
        timerCount = 300
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timerCount -= 1
            let minutes = self.timerCount / 60
            let seconds = self.timerCount % 60
            let timeString = String(format: "%02d:%02d", minutes, seconds)
            self.onUpdateTimer?(timeString)
            if self.timerCount == 0 {
                self.stopTimer()
                self.onSignUpFailure?("인증 시간이 만료되었습니다. 이메일 인증을 다시 요청하세요.")
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - 아이디, 비밀번호, 이메일 형식 조건
    
    func isValidUserID(_ userID: String) -> Bool {
        let idRegex = "^[a-z][a-z0-9]{4,11}$"
        let userIDPred = NSPredicate(format: "SELF MATCHES %@", idRegex)
        return userIDPred.evaluate(with: userID)
    }
    
    func isValidPassword(_ pw: String) -> Bool {
        let pwRegex = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{6,20}$"
        let pwPred = NSPredicate(format: "SELF MATCHES %@", pwRegex)
        return pwPred.evaluate(with: pw)
    }
    
    func isPasswordSame(_ pw: String, checkpw: String) -> Bool {
        return pw == checkpw
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
//
//  MemberRepository.swift
//  Where_Are_You
//
//  Created by 오정석 on 23/6/2024.
//

import Alamofire

protocol MemberRepositoryProtocol {
    func putUserName(userName: String, completion: @escaping (Result<Void, Error>) -> Void)
    func putProfileImage(images: UIImage, completion: @escaping (Result<Void, Error>) -> Void)
    
    func postSignUp(request: SignUpBody, completion: @escaping (Result<Void, Error>) -> Void)
    func postTokenReissue(request: TokenReissueBody, completion: @escaping (Result<GenericResponse<TokenReissueResponse>, Error>) -> Void)
    func postResetPassword(request: ResetPasswordBody, completion: @escaping (Result<Void, Error>) -> Void)
    func postLogout(completion: @escaping (Result<Void, Error>) -> Void)
    func postLogin(request: LoginBody, completion: @escaping (Result<Void, Error>) -> Void)
    
    func postKakaoJoin(request: KakaoJoinBody, completion: @escaping (Result<Void, Error>) -> Void)
    func postKakaoLogin(request: KakaoLoginBody, completion: @escaping (Result<Void, Error>) -> Void)
    
    func postEmailVerify(request: EmailVerifyBody, completion: @escaping (Result<Void, Error>) -> Void)
    func postEmailVerifyPassword(request: EmailVerifyBody, completion: @escaping (Result<Void, Error>) -> Void)
    func postEmailSend(email: String, completion: @escaping (Result<Void, Error>) -> Void)
    func postEmailSendV2(email: String, completion: @escaping (Result<Void, Error>) -> Void)
    func postAppleJoin(userName: String, code: String, completion: @escaping (Result<Void, Error>) -> Void)
    func postAppleLogin(code: String, fcmToken: String, completion: @escaping (Result<Void, Error>) -> Void)
    
    func getMemberSearch(memberCode: String, completion: @escaping (Result<GenericResponse<MemberSearchResponse>, Error>) -> Void)
    func getMemberDetails(completion: @escaping (Result<GenericResponse<MemberDetailsResponse>, Error>) -> Void)
    
    func deleteMember(request: DeleteMemberBody, completion: @escaping (Result<Void, Error>) -> Void)
}

class MemberRepository: MemberRepositoryProtocol {
    private let memberService: MemberServiceProtocol
    
    init(memberService: MemberServiceProtocol) {
        self.memberService = memberService
    }
    
    // MARK: - PUT

    func putUserName(userName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        memberService.putUserName(userName: userName, completion: completion)
    }
    
    func putProfileImage(images: UIImage, completion: @escaping (Result<Void, any Error>) -> Void) {
        memberService.putProfileImage(images: images) { result in
            switch result {
            case .success(let response):
                let data = response.data
                UserDefaultsManager.shared.saveProfileImage(data)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - POST
    
    func postSignUp(request: SignUpBody, completion: @escaping (Result<Void, Error>) -> Void) {
        memberService.postSignUp(request: request, completion: completion)
    }
    
    func postTokenReissue(request: TokenReissueBody, completion: @escaping (Result<GenericResponse<TokenReissueResponse>, any Error>) -> Void) {
        memberService.postTokenReissue(request: request) { result in
            switch result {
            case .success(let response):
                let data = response.data
                UserDefaultsManager.shared.saveRefreshToken(data.refreshToken)
                UserDefaultsManager.shared.saveMemberSeq(data.memberSeq)
                UserDefaultsManager.shared.saveAccessToken(data.accessToken)
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func postResetPassword(request: ResetPasswordBody, completion: @escaping (Result<Void, Error>) -> Void) {
        memberService.postResetPassword(request: request, completion: completion)
    }
    
    func postLogout(completion: @escaping (Result<Void, Error>) -> Void) {
        memberService.postLogout { result in
            switch result {
            case .success:
                UserDefaultsManager.shared.clearData()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func postLogin(request: LoginBody, completion: @escaping (Result<Void, any Error>) -> Void) {
        memberService.postLogin(request: request) { result in
            switch result {
            case .success(let response):
                UserDefaultsManager.shared.saveLoginData(response.data)
                UserDefaultsManager.shared.saveLoginType("normal")
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func postKakaoJoin(request: KakaoJoinBody, completion: @escaping (Result<Void, any Error>) -> Void) {
        memberService.postKakaoJoin(request: request, completion: completion)
    }
    
    func postKakaoLogin(request: KakaoLoginBody, completion: @escaping (Result<Void, any Error>) -> Void) {
        memberService.postKakaoLogin(request: request) { result in
            switch result {
            case .success(let response):
                UserDefaultsManager.shared.saveLoginData(response.data)
                UserDefaultsManager.shared.saveLoginType("kakao")
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func postEmailVerify(request: EmailVerifyBody, completion: @escaping (Result<Void, Error>) -> Void) {
        memberService.postEmailVerify(request: request, completion: completion)
    }
    
    func postEmailVerifyPassword(request: EmailVerifyBody, completion: @escaping (Result<Void, Error>) -> Void) {
        memberService.postEmailVerifyPassword(request: request, completion: completion)
    }
    
    func postEmailSend(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        memberService.postEmailSend(email: email, completion: completion)
    }
    
    func postEmailSendV2(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        memberService.postEmailSendV2(email: email, completion: completion)
    }
    
    func postAppleJoin(userName: String, code: String, completion: @escaping (Result<Void, Error>) -> Void) {
        memberService.postAppleJoin(userName: userName, code: code, completion: completion)
    }
    
    func postAppleLogin(code: String, fcmToken: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        memberService.postAppleLogin(code: code, fcmToken: fcmToken) { result in
            switch result {
            case .success(let response):
                UserDefaultsManager.shared.saveLoginData(response.data)
                UserDefaultsManager.shared.saveLoginType("apple")
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - GET

    func getMemberSearch(memberCode: String, completion: @escaping (Result<GenericResponse<MemberSearchResponse>, Error>) -> Void) {
        memberService.getMemberSearch(memberCode: memberCode, completion: completion)
    }
    
    func getMemberDetails(completion: @escaping (Result<GenericResponse<MemberDetailsResponse>, Error>) -> Void) {
        memberService.getMemberDetails { result in
            switch result {
            case .success(let response):
                let memberDetailData = response.data
                UserDefaultsManager.shared.saveUserName(memberDetailData.userName)
                UserDefaultsManager.shared.saveProfileImage(memberDetailData.profileImage)
                print("saving userName(\(String(describing: UserDefaultsManager.shared.getUserName()))) and profileImage succeed!")
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - DELETE
    
    func deleteMember(request: DeleteMemberBody, completion: @escaping (Result<Void, any Error>) -> Void) {
        memberService.deleteMember(request: request) { result in
            switch result {
            case .success:
                UserDefaultsManager.shared.clearData()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

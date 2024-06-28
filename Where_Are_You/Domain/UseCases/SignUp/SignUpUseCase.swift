//
//  SignUpUseCase.swift
//  Where_Are_You
//
//  Created by 오정석 on 23/6/2024.
//

import Foundation

protocol SignUpUseCase {
    func execute(request: User, completion: @escaping (Result<GenericResponse<SignUp>, Error>) -> Void)
}

class SignUpUseCaseImpl: SignUpUseCase {
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func execute(request: User, completion: @escaping (Result<GenericResponse<SignUp>, any Error>) -> Void) {
        userRepository.signUp(request: request, completion: completion)
    }
}
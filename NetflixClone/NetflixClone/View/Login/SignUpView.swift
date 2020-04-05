//
//  SignUpView.swift
//  NetflixClone
//
//  Created by 양중창 on 2020/04/05.
//  Copyright © 2020 Netflex. All rights reserved.
//

import UIKit

protocol SignUpViewDelegate: class {
    func signUp(email: String, passWord: String)
}

class SignUpView: UIView {
    
    weak var delegate: SignUpViewDelegate?
    
    private let loginResultBool = false
    private let textLabel = UILabel()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let confirmPWTextField = UITextField()
    private let signUpButton = UIButton()
    private let parentView = UIView()
    
    // 이메일 표현식을 사용하고 있는지
    private var isEmailRegularExpressionSatisfied = false {
        didSet {
            integrityCheck(self.isEmailRegularExpressionSatisfied, textField: emailTextField)
        }
    }
    
    // 비밀번호 정규 표현식을 사용하고 있는지
    private var isPassWordRegularExpressionStatisfied = false {
        didSet {
            integrityCheck(self.isPassWordRegularExpressionStatisfied, textField: passwordTextField)
        }
    }
    
    // 비밀번호 확인의 text가 비밀번호 text와 같은지
    private var isConfirmPassWord = false {
        didSet {
            integrityCheck(self.isConfirmPassWord, textField: confirmPWTextField)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: UI
    
    private func setUI() {
        
        backgroundColor = .setNetfilxColor(name: .black)
        
        addSubview(parentView)
        
        [textLabel, emailTextField, passwordTextField, confirmPWTextField, signUpButton].forEach {
            parentView.addSubview($0)
        }
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPWTextField.delegate = self
        
        textLabel.text = "지금 가입하세요!"
        textLabel.textColor = .white
        textLabel.font = .dynamicFont(fontSize: 30  , weight: .bold)
        textLabel.textAlignment = .center
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.numberOfLines = 2
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: "이메일 주소 또는 전화번호",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.setNetfilxColor(name: .netflixLightGray)])
        
        UITextField.appearance().tintColor = .white
        
        
        emailTextField.backgroundColor = .setNetfilxColor(name: .netflixDarkGray)
        emailTextField.layer.cornerRadius = 5 //emailTextField.bounds.height
        emailTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        emailTextField.keyboardType = .emailAddress
        emailTextField.layer.borderWidth = 1
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "비밀번호(8~16자 영문, 숫자, 특수문자)",
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.setNetfilxColor(name: .netflixLightGray)])
        passwordTextField.backgroundColor = .setNetfilxColor(name: .netflixDarkGray)
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        passwordTextField.passwordRules = .none
        passwordTextField.isSecureTextEntry = true
        passwordTextField.layer.borderWidth = 1
        
        confirmPWTextField.attributedPlaceholder = NSAttributedString(string: "비밀번호 확인",
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.setNetfilxColor(name: .netflixLightGray)])
        confirmPWTextField.backgroundColor = .setNetfilxColor(name: .netflixDarkGray)
        confirmPWTextField.layer.cornerRadius = 5
        confirmPWTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        confirmPWTextField.passwordRules = .none
        confirmPWTextField.isSecureTextEntry = true
        confirmPWTextField.layer.borderWidth = 1
        
        signUpButton.setTitle("회원가입", for: .normal)
        signUpButton.setTitleColor(.setNetfilxColor(name: .netflixLightGray), for: .normal)
        signUpButton.layer.borderWidth = 0.5
        signUpButton.layer.borderColor = UIColor.setNetfilxColor(name: .netflixDarkGray).cgColor
        signUpButton.layer.cornerRadius = 5
        signUpButton.addTarget(self, action: #selector(touchSignUpButton(_:)), for: .touchUpInside)
        signUpButton.setBackgroundColor(.clear, for: .normal)
        signUpButton.setBackgroundColor(.setNetfilxColor(name: .netflixRed), for: .selected)
        
    }
    
    private func setConstraint() {
        let widthMultiplier: CGFloat = 0.85
        let titleYMargin = CGFloat.dynamicYMargin(margin: 100)
        let yMargin = CGFloat.dynamicYMargin(margin: 15)
        let contentsHeight: CGFloat = 50 //CGFloat.dynamicYMargin(margin: 50)
        let guide = safeAreaLayoutGuide
        
        textLabel.snp.makeConstraints({
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        })
        
        emailTextField.snp.makeConstraints({
            $0.leading.trailing.equalTo(parentView)
            $0.top.equalTo(textLabel.snp.bottom).offset(titleYMargin / 2)
            $0.height.equalTo(contentsHeight)
        })
        
        passwordTextField.snp.makeConstraints({
            $0.top.equalTo(emailTextField.snp.bottom).offset(yMargin)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(contentsHeight)
        })
        
        confirmPWTextField.snp.makeConstraints({
            $0.top.equalTo(passwordTextField.snp.bottom).offset(yMargin)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(contentsHeight)
        })
        
        signUpButton.snp.makeConstraints({
            $0.top.equalTo(confirmPWTextField.snp.bottom).offset(yMargin)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(contentsHeight)
            $0.bottom.equalToSuperview()
        })
        
        parentView.snp.makeConstraints({
            $0.top.equalTo(guide).offset(titleYMargin)
            $0.centerX.equalTo(guide)
            $0.width.equalTo(guide).multipliedBy(widthMultiplier)
        })
        
        
    }
    
    @objc private func touchSignUpButton(_ sender: UIButton) {
//        print(delegate)
        guard
            let email = emailTextField.text,
            let pw = passwordTextField.text,
            signUpButton.isSelected else {
            return
        }
        
        delegate?.signUp(email: email, passWord: pw)
    }
    
    //MARK: Action
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.endEditing(true)
    }
    
    // 정규 표현식 또는 비밀번호 확인의 무결성 체크 후 텍스트필드의 borderColor를 적용
    private func integrityCheck(_ integrity: Bool, textField: UITextField) {
        let borderColor: CGColor?
            = integrity ?
                UIColor.setNetfilxColor(name: .positive).cgColor:
                UIColor.setNetfilxColor(name: .negative).cgColor
        
        textField.layer.borderColor = borderColor
    }
    
    // 정규 표현식 체크
    private func checkString(text: String, pattern: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: text)
    }
    
    // 비밀번호 확인 검사 및 비밀번호 정규 표현 체크
    private func checkConfirm(password: String, confirm: String) -> Bool {
        let confirm = password == confirm
        let passWordPattern = "^(?=.*[a-zA-Z])(?=.*[!@#$%^*+=-])(?=.*[0-9]).{8,16}$"
//        let passWordPattern = "^(?=.*[A-Z])(?=.*[!@#$%^*+=-])(?=.*[0-9])(?=.*[a-z]).{8,16}$"
        let result = checkString(text: password, pattern: passWordPattern) && confirm
        return result
    }
    
}

extension SignUpView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let replaceText = (text as NSString).replacingCharacters(in: range, with: string)
        
        switch textField {
        case emailTextField:
            let emailPattern = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
            isEmailRegularExpressionSatisfied = checkString(text: replaceText, pattern: emailPattern)
        case passwordTextField:
            let passWordPattern = "^(?=.*[a-zA-Z])(?=.*[!@#$%^*+=-])(?=.*[0-9]).{8,16}$"
//            let passWordPattern = "^(?=.*[A-Z])(?=.*[!@#$%^*+=-])(?=.*[0-9])(?=.*[a-z]).{8,16}$"
            isPassWordRegularExpressionStatisfied = checkString(text: replaceText, pattern: passWordPattern)
            if let confirmText = confirmPWTextField.text {
                isConfirmPassWord = checkConfirm(password: replaceText, confirm: confirmText)
            }
        case confirmPWTextField:
            if let passWordText = passwordTextField.text {
                isConfirmPassWord = checkConfirm(password: passWordText, confirm: replaceText)
            }
        default:
            print("default")
        }
        if isEmailRegularExpressionSatisfied && isPassWordRegularExpressionStatisfied && isConfirmPassWord {
            signUpButton.isSelected = true
        } else {
            signUpButton.isSelected = false
        }
        return true
    }
    
}
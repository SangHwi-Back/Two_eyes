//
//  SignUpInViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/05/02.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit
import FirebaseAuth
import ChameleonFramework

@IBDesignable
class SignInViewController: UIViewController {
    
    var paramEmail: String? = ""

    //MARK: - Outlet 연결
    @IBOutlet var IDEmailLabel: UILabel!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var allLabels: [UILabel]!
    
    @IBOutlet var IDEmailField: UITextField!
    @IBOutlet var PasswordField: UITextField!
    @IBOutlet var allTextFields: [UITextField]!
    
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var signInButton: UIButton!
    @IBAction func signUpAction(_ sender: UIButton) {
        performSegue(withIdentifier: "signUpSegue", sender: self)
    }
    @IBAction func signInAction(_ sender: UIButton) {
        guard let emailInput = IDEmailField.text else {
            presentAlert(self.emailAction)
            return
        }
        guard let passwordInput = PasswordField.text else {
            presentAlert(self.passwordAction)
            return
        }
        
        Auth.auth().signIn(withEmail: emailInput, password: passwordInput) { [weak self] authResult, error in
            if error != nil {
                self?.presentAlert(self!.emailPasswordNotCorrectedAction)
                return
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor(
//            gradientStyle: UIGradientStyle.topToBottom,
//            withFrame: CGRect(origin: view.frame.origin, size: CGSize(width: view.frame.width, height: view.frame.size.height / 2)),
//            andColors: [UIColor.flatWhite(), UIColor.flatWhiteDark()])
        self.view.backgroundColor = UIColor(gradientStyle: UIGradientStyle.topToBottom, withFrame: CGRect(origin: view.frame.origin, size: view.frame.size), andColors: [UIColor.flatSand(), UIColor.flatSandDark()])
        if paramEmail != "" {
            IDEmailField.text = paramEmail
        }
        
        if let allLabels = allLabels {
            for label in allLabels {
                label.adjustsFontSizeToFitWidth = true
            }
        }
        
        IDEmailLabel.textColor = UIColor.flatOrangeDark()
        passwordLabel.textColor = UIColor.flatOrangeDark()
        IDEmailField.delegate = self
        PasswordField.delegate = self
        IDEmailField.backgroundColor = UIColor.flatWhite()
        PasswordField.backgroundColor = UIColor.flatWhite()
        
        signInButton.adjustsImageSizeForAccessibilityContentSizeCategory = true
        signUpButton.adjustsImageSizeForAccessibilityContentSizeCategory = true
        signInButton.setTitleColor(UIColor.flatOrangeDark(), for: .normal)
        signUpButton.setTitleColor(UIColor.flatOrangeDark(), for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    let alertController = UIAlertController(title: "로그인 에러", message: "", preferredStyle: .alert)
    let emailAction = UIAlertAction(title: "아이디(이메일)을 입력해주시기 바랍니다.", style: .cancel, handler: nil)
    let passwordAction = UIAlertAction(title: "비밀번호를 입력해주시기 바랍니다.", style: .cancel, handler: nil)
    let signInFailedAction = UIAlertAction(title: "로그인에 실패하였습니다.", style: .cancel, handler: nil)
    let emailPasswordNotCorrectedAction = UIAlertAction(title: "아이디와 비밀번호가 맞지 않습니다.", style: .cancel, handler: nil)
    
    func presentAlert(_ action: UIAlertAction) {
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

}
//MARK: - TextFieldDelegates
extension SignInViewController: UITextFieldDelegate {
    //return 키 누르면 텍스트 닫힘.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func keyboardToolBarFactory() -> UIToolbar {
        let toolBarKeyboard = UIToolbar()
        toolBarKeyboard.sizeToFit()
        let btnBar = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(self.nextBtnClicked))
        let nilBar = UIBarButtonItem(title: "Prev", style: .plain, target: self, action: #selector(self.prevBtnClicked))
        toolBarKeyboard.items = [nilBar, btnBar]
        toolBarKeyboard.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        return toolBarKeyboard
    }
    
    @objc func nextBtnClicked(sender: Any) {
        for i in 0 ..< allTextFields.count {
            if allTextFields[i].isFirstResponder {
                allTextFields[ i == allTextFields.count-1 ? 0 : i+1 ].becomeFirstResponder()
                return
            }
        }
    }
    
    @objc func prevBtnClicked(sender: Any) {
        for i in 0..<allTextFields.count {
            if allTextFields[i].isFirstResponder {
                allTextFields[ i == 0 ? allTextFields.count - 1 : i - 1 ].becomeFirstResponder()
                return
            }
        }
    }
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    @objc private func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
}

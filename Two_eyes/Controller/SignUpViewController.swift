//
//  SignUpViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/05/02.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    //MARK: - IBOutlet 연결
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailTextIndicator: UIButton!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var lastNameIndicator: UIButton!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var firstNameIndicator: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordIndicator: UIButton!
    @IBOutlet weak var rePasswordField: UITextField!
    @IBOutlet weak var rePasswordIndicator: UIButton!
    
    @IBOutlet var allTextFields: [UITextField]!
    @IBOutlet var allTextFieldIndicator: [UIButton]!
    
    @IBOutlet weak var getConfirmCodeOutlet: UIButton!
    
    //MARK: - UIAlertController 생성 및 초기화
    private let alertController = UIAlertController(title: "부적절한 값 오류", message: "", preferredStyle: .alert)
    private let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    private let smallCaseAlphabetArray = (0..<26).map { i in String(UnicodeScalar(i + UnicodeScalar(unicodeScalarLiteral: "a").value)!) }
    private let upperCaseAlphabetArray = (0..<26).map { i in String(UnicodeScalar(i + UnicodeScalar(unicodeScalarLiteral: "A").value)!) }
    private let numberArray = (0...9).map{String($0)}
    private var keyboardHeight: CGFloat?
    
    //MARK: - ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        let toolBarKeyBoard = keyboardToolBarFactory()
        
        for textField in allTextFields {
            textField.delegate = self
            textField.minimumFontSize = 10
            textField.inputAccessoryView = toolBarKeyBoard
        }
        
        for indicator in allTextFieldIndicator {
            indicator.tintColor = .red
            indicator.isUserInteractionEnabled = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for textField in allTextFields {
            textField.sizeToFit()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func getConfirmCode(_ sender: UIButton) {
        if emailTextIndicator.tintColor == .red {
            if let text = emailTextField.text {
                Auth.auth().fetchSignInMethods(forEmail: text) { (providers, error) in
                    if let _ = providers {
                        self.showAlert(Constants.duplicateUserDetectedMessage)
                    } else {
                        self.showAlert(Constants.normalErrorMessage)
                    }
                }
            } else {
                self.showAlert(Constants.emailFieldNilMessage)
            }
            return
        } else if lastNameIndicator.tintColor == .red {
            self.showAlert(Constants.lastNameFieldNilMessage)
            return
        } else if firstNameIndicator.tintColor == .red {
            self.showAlert(Constants.firstNameFieldNilMessage)
            return
        } else if passwordIndicator.tintColor == .red || rePasswordField.tintColor == .red {
            self.showAlert(Constants.passwordFieldNilMessage)
            return
        }
        
        self.performSegue(withIdentifier: Constants.confirmSignUpSegueIdentifier, sender: self)
        
    }
    
    private func showAlert(_ message: String) {
        self.alertController.message = message
        self.alertController.addAction(self.defaultAction)
        self.present(self.alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.confirmSignUpSegueIdentifier {
            if let confirmSignUpVeiwController = segue.destination as? ConfirmSignUpViewController {
                confirmSignUpVeiwController.email = emailTextField.text
                confirmSignUpVeiwController.lastName = lastNameField.text
                confirmSignUpVeiwController.firstName = firstNameField.text
                confirmSignUpVeiwController.password = passwordField.text
            }
        }
    }
    @IBAction func emailValidation(_ sender: UITextField) {
        if var text = sender.text ,let atIndex = text.firstIndex(of: "@"), let dotIndex = text.firstIndex(of: ".") {
            if text.startIndex == atIndex || text.endIndex == atIndex {
                emailTextIndicator.tintColor = .red
                return
            } else if text.startIndex == dotIndex || text.endIndex == dotIndex {
                emailTextIndicator.tintColor = .red
                return
            }
            
            if dotIndex < atIndex {
                emailTextIndicator.tintColor = .red
                return
            }
            
            text = text.filter{ $0 != "@" }.filter{ $0 != "." }
            
            let anySpecific = text.map{String($0)}.filter ({
                !numberArray.contains($0) || !smallCaseAlphabetArray.contains($0) || !upperCaseAlphabetArray.contains($0)
            }).isEmpty
            
            emailTextIndicator.tintColor = anySpecific ? .red : .systemGreen
            return
        }
    }
    @IBAction func lastNameValidation(_ sender: UITextField) {
        let anySpecific = sender.text?.isEmpty ?? false
        lastNameIndicator.tintColor = anySpecific ? .red : .systemGreen
    }
    @IBAction func firstNameValidation(_ sender: UITextField) {
        let anySpecific = sender.text?.isEmpty ?? false
        firstNameIndicator.tintColor = anySpecific ? .red : .systemGreen
    }
    @IBAction func passwordValidation(_ sender: UITextField) {
        let anySpecific = sender.text?.isEmpty ?? false
        passwordIndicator.tintColor = anySpecific ? .red : .systemGreen
    }
    @IBAction func rePasswordValidation(_ sender: UITextField) {
        let anySpecific = sender.text?.isEmpty ?? false
        rePasswordIndicator.tintColor = anySpecific ? .red : .systemGreen
    }
}

//MARK: - TextFieldDelegates
extension SignUpViewController: UITextFieldDelegate, UITextInputTraits {
    //return 키 누르면 텍스트 닫힘.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    private func keyboardToolBarFactory() -> UIToolbar {
        let toolBarKeyboard = UIToolbar()
        toolBarKeyboard.sizeToFit()
        let nextBtn = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(self.nextBtnClicked))
        let prevBtn = UIBarButtonItem(title: "Prev", style: .plain, target: self, action: #selector(self.prevBtnClicked))
        toolBarKeyboard.items = [prevBtn, nextBtn]
        toolBarKeyboard.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        return toolBarKeyboard
    }
    
    @objc private func nextBtnClicked(sender: Any) {
        let currentField = allTextFields.filter({$0.isFirstResponder}).first
        if currentField != nil {
            
            currentField!.resignFirstResponder()
            
            if currentField!.tag == 5 {
                allTextFields.filter({$0.tag == 1}).first?.becomeFirstResponder()
                NotificationCenter.default.post(name: UIResponder.keyboardWillShowNotification, object: nil)
                return
            }
            
            for textField in allTextFields.sorted(by: { $0.tag < $1.tag }) {
                if textField.tag == currentField!.tag {
                    continue
                } else if textField.tag == currentField!.tag + 1 {
                    textField.becomeFirstResponder()
                    NotificationCenter.default.post(name: UIResponder.keyboardWillShowNotification, object: nil)
                    break
                }
            }
        }
    }
    
    @objc private func prevBtnClicked(sender: Any) {
        let currentField = allTextFields.filter({$0.isFirstResponder}).first
        if currentField != nil {
            currentField!.resignFirstResponder()
            if currentField!.tag == 1 {
                allTextFields.filter({$0.tag == 5}).first?.becomeFirstResponder()
                NotificationCenter.default.post(name: UIResponder.keyboardWillShowNotification, object: nil)
                return
            }
            
            for textField in allTextFields.sorted(by: { $0.tag < $1.tag }) {
                if textField.tag == currentField!.tag {
                    continue
                } else if textField.tag == currentField!.tag - 1 {
                    textField.becomeFirstResponder()
                    NotificationCenter.default.post(name: UIResponder.keyboardWillShowNotification, object: nil)
                    break
                }
            }
        }
    }
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        if self.keyboardHeight == nil {
            self.keyboardHeight = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!.cgRectValue.height
        }
        
        if let textField = allTextFields.filter({$0.tag == 1 && $0.isFirstResponder}).first {
            textField.keyboardType = .emailAddress
        }
        
        // sender 의 위치가 keyboard의 height 절대값보다 더 많이 내려와 있다면
        let currentTextField = allTextFields.filter{$0.isFirstResponder}.first
        
        UIView.animate(withDuration: 0.5) {
            if let currentTag = currentTextField?.tag, currentTag >= 4 {
                if self.view.frame.origin.y <= self.keyboardHeight! / CGFloat(currentTag) * -1 {
                    self.view.frame.origin.y -= self.keyboardHeight! / CGFloat(currentTag) * -1
                } else if self.view.frame.origin.y >= self.keyboardHeight! / CGFloat(currentTag) * -1 {
                    self.view.frame.origin.y += self.keyboardHeight! / CGFloat(currentTag) * -1
                }
            } else {
                self.view.frame.origin.y = 0
            }
        }
    }
    
    @objc private func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
}

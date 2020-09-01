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
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var rePasswordField: UITextField!
    @IBOutlet var addressField: UITextField!
    
    @IBOutlet var allTextFields: [UITextField]!
    
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var lastNameLabel: UILabel!
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var rePasswordLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet var allLabels: [UILabel]!
    
    @IBOutlet var signUpStackView: UIStackView!
    
    @IBOutlet var getConfirmCodeOutlet: UIButton!
    
    //MARK: - UIAlertController 생성 및 초기화
    private let alertController = UIAlertController(title: "부적절한 값 오류", message: "", preferredStyle: .alert)
    private let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    
    
    //MARK: - ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let toolBarKeyBoard = keyboardToolBarFactory()
        
        for label in allLabels {
            label.numberOfLines = 1
            label.adjustsFontSizeToFitWidth = true
        }
        
        for textField in allTextFields {
            textField.delegate = self
            textField.font = UIFont(name: allLabels.first!.font.fontName, size: allLabels.first!.font.pointSize / 2)
            textField.minimumFontSize = 10
            textField.inputAccessoryView = toolBarKeyBoard
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
        if emailTextField.text == "" {
            alertController.message = Constants.emailFieldNilMessage;
            Auth.auth().fetchSignInMethods(forEmail: emailTextField.text!) { (providers, error) in
                if let _ = error {
                    self.alertController.message = Constants.normalErrorMessage
                } else if let _ = providers {
                    self.alertController.message = Constants.duplicateUserDetectedMessage
                }
            }
        }else if lastNameField.text == "" {
            alertController.message = Constants.lastNameFieldNilMessage
        }else if firstNameField.text == "" {
            alertController.message = Constants.firstNameFieldNilMessage
        }else if passwordField.text == "" {
            alertController.message = Constants.passwordFieldNilMessage
        }else if rePasswordField.text == "" {
            alertController.message = Constants.passwordFieldNilMessage
        }else if addressField.text == "" {
            alertController.message = Constants.addressFieldNilMessage
        }
        
        if alertController.message != "" {
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
            self.performSegue(withIdentifier: Constants.confirmSignUpSegueIdentifier, sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.confirmSignUpSegueIdentifier {
            if let confirmSignUpVeiwController = segue.destination as? ConfirmSignUpViewController {
                confirmSignUpVeiwController.email = emailTextField.text
                confirmSignUpVeiwController.lastName = lastNameField.text
                confirmSignUpVeiwController.firstName = firstNameField.text
                confirmSignUpVeiwController.password = passwordField.text
                confirmSignUpVeiwController.address = addressField.text
            }
        }
    }
}

//MARK: - TextFieldDelegates
extension SignUpViewController: UITextFieldDelegate {
    //return 키 누르면 텍스트 닫힘.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    private func keyboardToolBarFactory() -> UIToolbar {
        let toolBarKeyboard = UIToolbar()
        toolBarKeyboard.sizeToFit()
        let btnBar = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(self.nextBtnClicked))
        let nilBar = UIBarButtonItem(title: "Prev", style: .plain, target: self, action: #selector(self.prevBtnClicked))
        toolBarKeyboard.items = [nilBar, btnBar]
        toolBarKeyboard.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        return toolBarKeyboard
    }
    
    @objc private func nextBtnClicked(sender: Any) {
        for i in 0 ..< allTextFields.count {
            if allTextFields[i].isFirstResponder {
                allTextFields[ i == allTextFields.count-1 ? 0 : i+1 ].becomeFirstResponder()
                return
            }
        }
    }
    
    @objc private func prevBtnClicked(sender: Any) {
        for i in 0..<allTextFields.count {
            if allTextFields[i].isFirstResponder {
                allTextFields[ i == 0 ? allTextFields.count - 1 : i - 1 ].becomeFirstResponder()
                return
            }
        }
    }
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y = 0
        let index = allTextFields.firstIndex(of: allTextFields.filter{$0.isFirstResponder}.first!)!
        self.view.frame.origin.y = ((sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 150) * CGFloat(index+1) * -0.1 // Move view upward
    }
    
    @objc private func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
}

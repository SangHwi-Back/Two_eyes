//
//  SignUpInViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/05/02.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit
import FirebaseAuth

@IBDesignable
class SignInViewController: UIViewController {
    
    var paramEmail: String? = ""
    let indicator = UIActivityIndicatorView()

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
        performSegue(withIdentifier: Constants.signUpSegueIdentifier, sender: self)
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
        
        indicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        Auth.auth().signIn(withEmail: emailInput, password: passwordInput) { [weak self] authResult, error in
            if error != nil {
                self?.presentAlert(self!.emailPasswordNotCorrectedAction)
                self?.indicator.stopAnimating()
                self?.view.isUserInteractionEnabled = true
                return
            } else {
                self?.performSegue(withIdentifier: "signInSegue", sender: self)
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.themeModel?.setDefaultThemeInfo(themeInfo: [
            ThemeInfoModelColors.rootBackgroundViewColor.rawValue: self.view.backgroundColor!,
            ThemeInfoModelColors.navigationBackgroundColor.rawValue: self.view.backgroundColor!,
            ThemeInfoModelColors.buttonBackgroundColor.rawValue: UIColor.clear,
            ThemeInfoModelColors.buttonTintColor.rawValue: signUpButton.tintColor,
            ThemeInfoModelColors.labelTintColor.rawValue: IDEmailLabel.tintColor,
            ThemeInfoModelColors.textFieldTintColor.rawValue: IDEmailField.tintColor,
            ThemeInfoModelColors.collectionViewBackgroundColor.rawValue: self.view.backgroundColor!,
            ThemeInfoModelColors.searchBarBackgroundColor.rawValue: self.view.backgroundColor!
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if paramEmail != "" {
            IDEmailField.text = paramEmail
        }
        
        if let allLabels = allLabels {
            for label in allLabels {
                label.adjustsFontSizeToFitWidth = true
            }
        }
        
        IDEmailField.delegate = self
        PasswordField.delegate = self
        
        signInButton.adjustsImageSizeForAccessibilityContentSizeCategory = true
        signUpButton.adjustsImageSizeForAccessibilityContentSizeCategory = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        indicator.center = self.view.center
        indicator.style = .large
        indicator.hidesWhenStopped = true
        self.view.addSubview(indicator)
    }
    
    private let alertController = UIAlertController(title: Constants.loginAlertMessage, message: "", preferredStyle: .alert)
    private let emailAction = UIAlertAction(title: Constants.emailFieldNilMessage, style: .cancel, handler: nil)
    private let passwordAction = UIAlertAction(title: Constants.passwordFieldNilMessage, style: .cancel, handler: nil)
    private let signInFailedAction = UIAlertAction(title: Constants.signInFailedMessage, style: .cancel, handler: nil)
    private let emailPasswordNotCorrectedAction = UIAlertAction(title: Constants.loginInformationIncorrectMessage, style: .cancel, handler: nil)
    
    private func presentAlert(_ action: UIAlertAction) {
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.indicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

}

//MARK: - TextFieldDelegates
extension SignInViewController: UITextFieldDelegate {
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
        self.view.frame.origin.y = ((sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 150) * -1 // Move view upward
    }
    
    @objc private func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
}

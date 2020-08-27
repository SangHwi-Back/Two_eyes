//
//  ConfirmSignUpViewController.swift
//  Two_eyes
//
//  Created by 백상휘 on 2020/05/02.
//  Copyright © 2020 Sanghwi Back. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseInstanceID
import FirebaseMessaging

class ConfirmSignUpViewController: UIViewController {

    var email: String?
    var password: String?
    var lastName: String?
    var firstName: String?
    var address: String?
    private var remoteTokenTemp: String?
    
    //MARK: - Outlet 연결
    @IBOutlet var remoteToken: UILabel!
    @IBOutlet var confirmCodeTextField: UITextField!
    @IBAction func confirmCodeTextFieldChanged(_ sender: UITextField) {
        confirmCodeValidation()
    }
    
    @IBOutlet var goToFirst: UIButton!
    @IBOutlet var allLabels: [UILabel]!
    
    @IBAction func goToFirstAction(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: self.email!, password: self.password!) { (user, error) in
            //firbase connection Init. created User
            self.alertController.addAction(self.alertAction)
            if error == nil {
                self.alertController.title = Constants.signUpSuccessMessage
                self.present(self.alertController, animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
                
            }else{
                self.alertController.title = Constants.signUpFailedMessageDescription
                self.present(self.alertController, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - AlertController
    private let alertController = UIAlertController(title: Constants.signUpFailedMessage, message: "", preferredStyle: .alert)
    private let alertAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.confirmCodeTextField.delegate = self
        
        // Do any additional setup after loading the view.
        InstanceID.instanceID().instanceID { (result, error) in
            if error != nil {
                self.present(SignInViewController(), animated: true) {
                    self.alertController.addAction(self.alertAction)
                    self.present(self.alertController, animated: true, completion: nil)
                }
            } else if let result = result {
                self.remoteToken.text = String(result.token.prefix(10))
            }
        }
        
        for label in allLabels {
            label.numberOfLines = 1
            label.adjustsFontSizeToFitWidth = true
        }
        
        goToFirst.adjustsImageSizeForAccessibilityContentSizeCategory = true
        goToFirstControl(false)
        confirmCodeControl(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    private func confirmCodeValidation() {
        guard email != nil || password != nil || lastName != nil || firstName != nil || address != nil else { return }
        
        if remoteToken.text == confirmCodeTextField.text {
            goToFirstControl(true)
            confirmCodeControl(false)
        } else {
            return
        }
        
    }
    
    private func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    private func goToFirstControl(_ flag: Bool) {
        goToFirst.isEnabled = flag
    }
    
    private func confirmCodeControl(_ flag: Bool) {
        confirmCodeTextField.isEnabled = flag
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SignInViewController {
            destinationVC.paramEmail = self.email
        }
    }
}
extension ConfirmSignUpViewController: UITextFieldDelegate {
    //return 키 누르면 텍스트 닫힘.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y = ((sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 150) * -1 // Move view upward
    }
    
    @objc private func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
}

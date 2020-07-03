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
import ChameleonFramework

class ConfirmSignUpViewController: UIViewController {

    var email: String?
    var password: String?
    var lastName: String?
    var firstName: String?
    var address: String?
    var remoteTokenTemp: String?
    
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
                self.alertController.title = "사용자 생성을 완료하였습니다. 재로그인해주시기 바랍니다."
                self.present(self.alertController, animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
                
            }else{
                self.alertController.title = "사용자 생성 에러\n사용자 생성 도중 에러가 발생하였습니다.\n관리자에게 문의 바랍니다."
                self.present(self.alertController, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - AlertController
    let alertController = UIAlertController(title: "사용자 생성 에러", message: "", preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.confirmCodeTextField.delegate = self
        self.view.backgroundColor = UIColor(gradientStyle: UIGradientStyle.topToBottom, withFrame: CGRect(origin: view.frame.origin, size: view.frame.size), andColors: [UIColor.flatSand(), UIColor.flatSandDark()])
        
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
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "#ffcd3c")
    }
    
    func confirmCodeValidation() {
        guard email != nil || password != nil || lastName != nil || firstName != nil || address != nil else { return }
        
        if remoteToken.text == confirmCodeTextField.text {
            goToFirstControl(true)
            confirmCodeControl(false)
        } else {
            return
        }
        
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func goToFirstControl(_ flag: Bool) {
        goToFirst.isEnabled = flag
    }
    
    func confirmCodeControl(_ flag: Bool) {
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
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    @objc private func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
}

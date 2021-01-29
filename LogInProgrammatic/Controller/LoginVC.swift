//
//  LoginVC.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/8/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    let logoContainerBGColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: 1)
    
    lazy var extraSafeAreaTopView: UIView = {
        let view = UIView()
        view.backgroundColor = logoContainerBGColor
        return view
    }()
    
    lazy var logoContainerView: UIView = {
        let view = UIView()
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFill
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.backgroundColor = logoContainerBGColor
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.keyboardType = .emailAddress
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handlelogin), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    let donthaveaccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleShowSignup), for: .touchUpInside)
        
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //background color
        view.backgroundColor = .white
        
        //hide nav bar
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor,
            paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
            width: 0, height: 150
        )
        
        view.addSubview(extraSafeAreaTopView)
        extraSafeAreaTopView.anchor(
            top: view.topAnchor, left: view.leftAnchor, bottom: logoContainerView.topAnchor, right: view.rightAnchor,
            paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
            width: 0, height: 150
        )
        
        configureViewComponents()
        
        view.addSubview(donthaveaccountButton)
        donthaveaccountButton.anchor(
            top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor,
            paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
            width: 0, height: 50
        )
    }
    
    @objc func handleShowSignup() {
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc func handlelogin() {
        
        // properties
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text else { return }
        
        // sign user in with email and password
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            // handle error
            if let error = error {
                print("Unable to sign user in with error", error.localizedDescription)
                return
            }
            
            // handle success
            guard let mainTabVC = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController as? MainTabVC else { return }
            
            // confingure view controllers in mainTabVC
            mainTabVC.configureViewControllers()
            mainTabVC.didLogIn()
            
            // dismiss login view controller
            self.dismiss(animated: true, completion: nil)
            
            print("Succesfully logged in user")
        }
    }
    
    @objc func formValidation() {
        // ensures that email and password text fields have text
        guard
        emailTextField.hasText,
        passwordTextField.hasText else {
            // handle cases for above conditions not met
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        // handle cases for conditions were met
        loginButton.isEnabled = true
        loginButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    func configureViewComponents() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 140)
    }

}

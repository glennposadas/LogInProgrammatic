//
//  SignUpVC.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/9/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSelectProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        //Secure text entry for password
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let fullNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full Name"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let occupationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Occupation"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    let alreadyhaveaccountButton: UIButton = {
           let button = UIButton(type: .system)
           let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
           attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
           button.setAttributedTitle(attributedTitle, for: .normal)
           
           button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
           
           return button
       }()
    
    var imageChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        configureViewComponents()
        view.addSubview(alreadyhaveaccountButton)
        alreadyhaveaccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // selected image
        guard let profileImage = info[.editedImage] as? UIImage else { return }
        
        // configure plusPhotoButton with selected image
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 2
        plusPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        // upload profile image to Firebase at SignUp
        self.imageChanged = true
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSelectProfilePhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        //present ImagePicker
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func handleShowLogin() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullName = fullNameTextField.text else { return }
        guard let occupation = occupationTextField.text else { return }
        guard let username = usernameTextField.text?.lowercased() else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            // handle error
            if let error = error {
                print("Failed to create user with error", error.localizedDescription)
                return
            } else {
            // OPTION 1: create user AND upload profile image that user has set
                if self.imageChanged {
                    // Step 1: set profile image
                    guard let profileImage = self.plusPhotoButton.imageView?.image else { return }
                    // Step 2: convert selected image to JPEG (Note: Firebase only accepts JPEG)
                    guard let uploadData = profileImage.jpegData(compressionQuality: 0.3) else { return }
                    // filename and image storage reference
                    let filename = NSUUID().uuidString
                    let storageRef = Storage.storage().reference().child("profile_images").child(filename)
                    // Step 3: place image in Firebase storage
                    storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                        // handle error
                        if let error = error {
                            print("Failed to upload image to Firebase Storage with error", error.localizedDescription)
                            return
                        }
                        // Firebase 5 must retrieve download url
                        storageRef.downloadURL(completion: { (downloadURL, error) in
                            guard let profileImageUrl = downloadURL?.absoluteString else {
                                print("DEBUG: Profile image url is nil")
                                return
                            }
                            // user id
                            guard let uid = user?.user.uid else { return }
                            // user info
                            let dictionaryValues = ["name": fullName,
                                                    "occupation": occupation,
                                                    "username": username,
                                                    "profileImageUrl": profileImageUrl]
                            let values = [uid: dictionaryValues]
                            // saver user info to database
                            USER_REF.updateChildValues(values) { (error, ref) in
                                guard let mainTabVC = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController as? MainTabVC else { return }
                                // configure view controllers in maintabvc
                                mainTabVC.configureViewControllers()
                                // dismiss login controller
                                self.dismiss(animated: true, completion: nil)
                                // Success
                                print("Successfully created user with Firebase")
                            }
                        })
                    }
                } else {
                    // OPTION 2: create user WITHOUT uploading a profile image
                    guard let uid = user?.user.uid else { return }
                    let dictionaryValues = [
                        "name": fullName,
                        "occupation": occupation,
                        "username": username,
                    ]
                    let values = [uid: dictionaryValues]
                    USER_REF.updateChildValues(values) { (error, ref) in
                        guard let mainTabVC = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController as? MainTabVC else { return }
                        // configure view controllers in maintabvc
                        mainTabVC.configureViewControllers()
                        // dismiss login controller
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @objc func formValidation() {
        guard
        emailTextField.hasText,
        passwordTextField.hasText,
        fullNameTextField.hasText,
        occupationTextField.hasText,
        usernameTextField.hasText else {
            signupButton.isEnabled = false
            signupButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        signupButton.isEnabled = true
        signupButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    
    func configureViewComponents() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, fullNameTextField, occupationTextField, usernameTextField, passwordTextField, signupButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 240)
    }

}




// SUCCESSFUL handleSignUp function for FIRESTORE
//    @objc func handleSignUp() {
//        guard let email = emailTextField.text else { return }
//        guard let password = passwordTextField.text else { return }
//        guard let fullName = fullNameTextField.text else { return }
//        guard let username = usernameTextField.text else { return }
//
//        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
//
//            // handle error
//            if let error = error {
//                print("Failed to create user with error: ", error.localizedDescription)
//                return
//            } else {
//
//                // create user AND upload profile image that user has set
//                if self.imageChanged {
//
//                    // set profile image
//                    guard let profileImage = self.plusPhotoButton.imageView?.image else { return }
//
//                    // convert selected image to JPEG (Note: Firebase only accepts JPEG)
//                    guard let uploadData = profileImage.jpegData(compressionQuality: 0.3) else { return }
//
//                    // filename and image reference
//                    let filename = NSUUID().uuidString
//                    let imageRef = Storage.storage().reference()
//                        .child("profile_images").child(filename)
//
//                    // Upload image to Storage
//                    imageRef.putData(uploadData, metadata: nil) { (metadata, error) in
//                        if let error = error {
//                            print("Something went wrong with error 1", error.localizedDescription)
//                            return
//                        }
//
//                        imageRef.downloadURL { (url, error) in
//                            if let error = error {
//                                print("Something went wrong with error 2", error.localizedDescription)
//                                return
//                            }
//                            guard let url = url else {
//                                print("Something went wrong with the URL")
//                                return
//                            }
//
//                            let dataReference = Firestore.firestore().collection("users").document()
//
//                            // let documentUid = dataReference.documentID
//                            guard let uid = user?.user.uid else { return }
//                            let urlString = url.absoluteString
//
//                            let dictionaryValues = [
//                                "name": fullName,
//                                "username": username,
//                                "profileImageURL": urlString
//                            ]
//
//                            // store user values in dictionary
//                            let values = [uid: dictionaryValues]
//
//                            // save to dataReference
//                            dataReference.setData(values) { (error) in
//                                if let error = error {
//                                    print("Something went wrong with error 3", error.localizedDescription)
//                                    return
//                                }
//                                print("Successfully saved to Firestore")
//                            }
//                        }
//                    }
//                } else {
//
//                    // create user WITHOUT uploading a profile image
//                    let dataReference = Firestore.firestore().collection("users").document()
//
//                    // let documentUid = dataReference.documentID
//                    guard let uid = user?.user.uid else { return }
//
//                    let dictionaryValues = [
//                        "name": fullName,
//                        "username": username,
//                    ]
//
//                    // store user values in dictionary
//                    let values = [uid: dictionaryValues]
//
//                    // save to dataReference
//                    dataReference.setData(values) { (error) in
//                        if let error = error {
//                            print("Something went wrong with error 3", error.localizedDescription)
//                            return
//                        }
//                        print("Successfully saved to Firestore")
//                    }
//                }
//
//            }
//        }
//    }

    
    
//            // In order to get download URL must add filename to storage ref like this
//            let storageRef = Storage.storage().reference().child("profile_images").child(filename)
//
//            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
//
//                // handle error
//                if let error = error {
//                    print("Failed to upload image to Firebase Storage with error", error.localizedDescription)
//                    return
//                }
//
//                // UPDATE: - Firebase 5 must now retrieve download url
//                storageRef.downloadURL(completion: { (downloadURL, error) in
//                    guard let profileImageUrl = downloadURL?.absoluteString else {
//                        print("DEBUG: Profile image url is nil")
//                        return
//                    }
//
//                    // user id
//                    guard let uid = authResult?.user.uid else { return }
//
//                    guard let fcmToken = Messaging.messaging().fcmToken else { return }
//
//                    let dictionaryValues = ["name": fullName,
//                                            "fcmToken": fcmToken,
//                                            "username": username,
//                                            "profileImageUrl": profileImageUrl]
//
//                    let values = [uid: dictionaryValues]
//
//                    // save user info to database
//
//
//                    USER_REF.updateChildValues(values, withCompletionBlock: { (error, ref) in
//
//                        guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabVC else { return }
//
//                        // configure view controllers in maintabvc
//                        mainTabVC.configureViewControllers()
//                        mainTabVC.isInitialLoad = true
//
//                        // dismiss login controller
//                        self.dismiss(animated: true, completion: nil)
//                    })
//                })
//            }
//        }
//    }

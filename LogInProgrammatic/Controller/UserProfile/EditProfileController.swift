//
//  EditProfileController.swift
//  LogInProgrammatic
//
//  Created by Mac on 12/26/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage

class EditProfileController: UIViewController {
    
    // MARK: - Properties
    
    var user: User?
    var imageChanged = false
    var fullnameChanged = false
    var occupationChanged = false
    var usernameChanged = false
    var userProfileController: UserProfileVC?
    var updatedFullname: String?
    var updatedOccupation: String?
    var updatedUsername: String?
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Profile Photo", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleChangeProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.textAlignment = .left
        tf.borderStyle = .none
        return tf
    }()
    
    let fullnameTextField: UITextField = {
        let tf = UITextField()
        tf.textAlignment = .left
        tf.borderStyle = .none
        return tf
    }()
    
    let occupationTextField: UITextField = {
        let tf = UITextField()
        tf.textAlignment = .left
        tf.borderStyle = .none
        return tf
    }()
    
    let fullnameLabel: UILabel = {
        let label = UILabel()
        label.text = "Full Name"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let occupationLabel: UILabel = {
        let label = UILabel()
        label.text = "Occupation"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let fullnameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let usernameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let occupationSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        configureViewComponents()
        
        fullnameTextField.delegate = self
        
        occupationTextField.delegate = self
        
        usernameTextField.delegate = self
        
        loadUserData()
    }
    
    
    // MARK: - Handlers
    
    @objc func handleChangeProfilePhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.modalPresentationStyle = .fullScreen
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDone() {
        view.endEditing(true)
        
        if fullnameChanged {
            updateFullname()
        }
        
        if occupationChanged {
            updateOccupation()
        }
        
        if usernameChanged {
            updateUsername()
        }
        
        if imageChanged {
            updateProfileImage()
        }
    }
    
    func loadUserData() {
        guard let user = self.user else { return }
        
        profileImageView.loadImage(with: user.profileImageUrl)
        fullnameTextField.text = user.name
        occupationTextField.text = user.occupation
        usernameTextField.text = user.username
    }
    
    func configureViewComponents() {
        
        view.backgroundColor = .white

        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 150)
        let containerView = UIView(frame: frame)
        containerView.backgroundColor = UIColor.systemGroupedBackground
        view.addSubview(containerView)
        
        containerView.addSubview(profileImageView)
        profileImageView.anchor(top: containerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        profileImageView.layer.cornerRadius = 80 / 2
        
        containerView.addSubview(changePhotoButton)
        changePhotoButton.anchor(top: profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        changePhotoButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        containerView.addSubview(separatorView)
        separatorView.anchor(top: nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        view.addSubview(fullnameLabel)
        fullnameLabel.anchor(top: containerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(usernameLabel)
        usernameLabel.anchor(top: fullnameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(occupationLabel)
        occupationLabel.anchor(top: usernameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(fullnameTextField)
        fullnameTextField.anchor(top: containerView.bottomAnchor, left: fullnameLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: (view.frame.width / 1.6), height: 0)
        
        view.addSubview(usernameTextField)
        usernameTextField.anchor(top: fullnameTextField.bottomAnchor, left: usernameLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: (view.frame.width / 1.6), height: 0)
        
        view.addSubview(occupationTextField)
        occupationTextField.anchor(top: usernameTextField.bottomAnchor, left: occupationLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: (view.frame.width / 1.6), height: 0)
        
        view.addSubview(fullnameSeparatorView)
        fullnameSeparatorView.anchor(top: nil, left: fullnameTextField.leftAnchor, bottom: fullnameTextField.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 12, width: 0, height: 0.5)
        
        view.addSubview(usernameSeparatorView)
        usernameSeparatorView.anchor(top: nil, left: usernameTextField.leftAnchor, bottom: usernameTextField.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 12, width: 0, height: 0.5)
        
        view.addSubview(occupationSeparatorView)
        occupationSeparatorView.anchor(top: nil, left: occupationTextField.leftAnchor, bottom: occupationTextField.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 12, width: 0, height: 0.5)
    }
    
    func configureNavigationBar() {
        
        navigationItem.title = "Edit Profile"
        
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleDone))
        
    }
    
    
    // MARK: - API
    
    func updateFullname() {
        guard let updatedFullname = self.updatedFullname else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard fullnameChanged == true else { return }
        
        USER_REF.child(currentUid).child("name").setValue(updatedFullname) { (err, ref) in
            
            guard let userProfileController = self.userProfileController else { return }
            userProfileController.fetchCurrentUserData()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateOccupation() {
        guard let updatedOccupation = self.updatedOccupation else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard occupationChanged == true else { return }
        
        USER_REF.child(currentUid).child("occupation").setValue(updatedOccupation) { (err, ref) in
            
            guard let userProfileController = self.userProfileController else { return }
            userProfileController.fetchCurrentUserData()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateUsername() {
        guard let updatedUsername = self.updatedUsername else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard usernameChanged == true else { return }
        
        USER_REF.child(currentUid).child("username").setValue(updatedUsername) { (err, ref) in
            
            guard let userProfileController = self.userProfileController else { return }
            userProfileController.fetchCurrentUserData()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateProfileImage() {
        
        guard imageChanged == true else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let user = self.user else { return }
        
        Storage.storage().reference(forURL: user.profileImageUrl).delete(completion: nil)
        
        let filename = NSUUID().uuidString
        guard let updatedProfileImage = profileImageView.image else { return }
        
        let storageRef = Storage.storage().reference().child("profile_images").child(filename)
        guard let imageData = updatedProfileImage.jpegData(compressionQuality: 0.3) else { return }
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            
            if let error = error {
                print("Failed to upload image to storage with error: ", error.localizedDescription)
            }
            
            storageRef.downloadURL { (downloadURL, error) in
                
                guard let updatedProfileImageUrl = downloadURL?.absoluteString else { return }
                USER_REF.child(currentUid).child("profileImageUrl").setValue(updatedProfileImageUrl) { (err, ref) in
                    
                    guard let userProfileController = self.userProfileController else { return }
                    userProfileController.fetchCurrentUserData()
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

        
}

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let selectedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            profileImageView.image = selectedImage
            self.imageChanged = true
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension EditProfileController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let user = self.user else { return }
        
        let fullnameTrimmedString = fullnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let usernameTrimmedString = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let occupationTrimmedString = occupationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if user.name == fullnameTrimmedString {
            fullnameChanged = false
        } else {
            fullnameChanged = true
            updatedFullname = fullnameTrimmedString
        }
        
        if user.occupation == occupationTrimmedString {
            occupationChanged = false
        } else {
            occupationChanged = true
            updatedOccupation = occupationTrimmedString
        }
        
        if user.username == usernameTrimmedString {
            usernameChanged = false
        } else {
            usernameChanged = true
            updatedUsername = usernameTrimmedString?.lowercased()
        }
        
//        guard user.name != fullnameTrimmedString else {
//            print("ERROR: You did not change your full name")
//            fullnameChanged = false
//            return
//        }
//        guard user.username != usernameTrimmedString else {
//            print("ERROR: You did not change your username")
//            usernameChanged = false
//            return
//        }
//
//        updatedFullname = fullnameTrimmedString
//        updatedUsername = usernameTrimmedString?.lowercased()
//        fullnameChanged = true
//        usernameChanged = true
    }
}




// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

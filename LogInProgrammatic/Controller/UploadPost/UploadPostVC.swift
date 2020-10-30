//
//  UploadPostVC.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/14/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase

class UploadPostVC: UIViewController, UITextViewDelegate {

    //MARK: - Properties
    
    var selectedImage: UIImage?
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .blue
        return iv
    }()
    
    let captionTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.groupTableViewBackground
        tv.font = UIFont.systemFont(ofSize: 12)
        return tv
    }()
    
    let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.setTitle("Share", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSharePost), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure view components
        configureViewComponents()
        
        // load image
        loadImage()
        
        // text view delegate
        captionTextView.delegate = self
        
        view.backgroundColor = .white
    }
    
    //MARK: - UITextView
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard !textView.text.isEmpty else {
            
            shareButton.isEnabled = false
            shareButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        
        shareButton.isEnabled = true
        shareButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    
    //MARK: - Handlers
    
    func updateUserFeeds(with postId: String) {
        
        // current user id
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // database values
        let values = [postId: 1]
        
        // update follower feeds
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).updateChildValues(values)
        }
        
        // update current user feed
        USER_FEED_REF.child(currentUid).updateChildValues(values)
        
    }
    
    @objc func handleSharePost() {
        
        // parameters
        
        guard
            let caption = captionTextView.text,
            let postImg = photoImageView.image,
            let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // image upload data
        guard let uploadData = postImg.jpegData(compressionQuality: 0.5) else { return }
        
        // create date
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        // update storage
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_POST_IMAGES_REF.child(filename)
        
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            
            // handle error
            if let error = error {
                print("Failed to upload image to storage with error", error.localizedDescription)
                return
            }
            
            storageRef.downloadURL { (url, error) in
                guard let imageURL = url?.absoluteString else { return }
                
                // post data
                let values = ["caption": caption,
                              "creationDate": creationDate,
                              "likes": 0,
                              "imageUrl": imageURL,
                              "ownerUid": currentUid] as [String: Any]
                
                // post id
                let postId = POSTS_REF.childByAutoId()
                
                // upload information to database
                postId.updateChildValues(values) { (err, ref) in
                    
                    guard let postKey = postId.key else { return }
                    
                    // update user-posts structure
                    USER_POSTS_REF.child(currentUid).updateChildValues([postKey: 1])
                    
                    // update user-feed structure
                    self.updateUserFeeds(with: postKey)
                    
                    // return to home feed
                    self.dismiss(animated: true, completion: {
                        self.tabBarController?.selectedIndex = 0
                        
                    })
                }
            }
            
            
        }
        
        
    }
    
    func configureViewComponents() {
        
        view.addSubview(photoImageView)
        photoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        
        view.addSubview(captionTextView)
        captionTextView.anchor(top: view.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 100)
        
        view.addSubview(shareButton)
        shareButton.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 24, paddingBottom: 0, paddingRight: 24, width: 0, height: 40)
    }

    func loadImage() {
        
        guard let selectedImage = self.selectedImage else { return }
        
        photoImageView.image = selectedImage
    }
}

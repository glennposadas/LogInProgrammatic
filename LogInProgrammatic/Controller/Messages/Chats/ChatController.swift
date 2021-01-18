//
//  ChatController.swift
//  LogInProgrammatic
//
//  Created by Mac on 12/11/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "ChatCell"

class ChatController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    var user: User?
    var message: Message?
    var messages = [Message]()
        
    lazy var containerView: ChatInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
        let containerView = ChatInputAccessoryView(frame: frame)
        containerView.backgroundColor = .white
        containerView.delegate = self
        return containerView
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.keyboardDismissMode = .interactive
        
        configureNavigationBar()
        configureKeyboardObservers()
        
        observeMessages()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false

    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var height: CGFloat = 80

        let message = messages[indexPath.item]

        height = estimateFrameForText(message.messageText).height + 20

        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
        
        cell.message = messages[indexPath.row]
        
        configureMessge(cell: cell, message: messages[indexPath.item])
        
        return cell
    }
    
    // MARK: - Handlers
    
    @objc func handleInfoTapped() {
        let userProfileController = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.user = user
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    @objc func handleKeyboardDidShow() {
        scrollToBottom()
    }
    
    func scrollToBottom() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func configureKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func configureMessge(cell: ChatCell, message: Message) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(message.messageText).width + 32
        cell.frame.size.height = estimateFrameForText(message.messageText).height + 16
        
        if message.fromId == currentUid {
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 0, green: 137, blue: 249)
            cell.textView.textColor = .white
            //cell.profileImageView.isHidden = true
        } else {
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
            cell.textView.textColor = .black
           // cell.profileImageView.isHidden = true
        }
        
    }
    
    func configureNavigationBar() {
        guard let user = self.user else { return }
        
        navigationItem.title = user.name
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.tintColor = .black
        infoButton.addTarget(self, action: #selector(handleInfoTapped), for: .touchUpInside)
        
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButtonItem
    }
    
//    func uploadMessageNotification() {
//
//        guard let fromId = Auth.auth().currentUser?.uid else { return }
//        guard let toId = user?.uid else { return }
//        var messageText: String!
//
//        messageText = containerView.chatTextView.text
//
//        let values = ["fromId": fromId,
//                      "toId": toId,
//                      "messageText": messageText] as [String : Any]
//
//        USER_MESSAGE_NOTIFICATIONS_REF.child(toId).childByAutoId().updateChildValues(values)
//    }
    
    func uploadMessageNotification() {
        
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        guard let user = self.user else { return }
        guard let toId = user.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
            
        let values = ["checked": 0,
                      "creationDate": creationDate,
                      "uid": fromId,
                      "type": MESSAGE_INT_VALUE] as [String : Any]
            
        let notificationRef = NOTIFICATIONS_REF.child(toId).childByAutoId()
        notificationRef.updateChildValues(values)
//        guard let notificationKey = notificationRef.key else { return }
//        notificationRef.updateChildValues(values) { (err, ref) in
//            USER_MESSAGES_REF.child(fromId).child(toId).updateChildValues([notificationKey: notificationRef])
//        }
    }
    
    // MARK: - API
    
    func observeMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let chatPartnerId = self.user?.uid else { return }
        
        USER_MESSAGES_REF.child(currentUid).child(chatPartnerId).observe(.childAdded) { (snapshot) in
            let messageId = snapshot.key
            self.fetchMessage(withMessageId: messageId)
        }
    }
    
    func fetchMessage(withMessageId messageId: String) {
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            let message = Message(dictionary: dictionary)
            self.messages.append(message)
            
//            self.collectionView?.reloadData()
//            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
//            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
            
//            DispatchQueue.main.async(execute: {
//                self.collectionView?.reloadData()
//                let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
//                self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
//            })
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
            }
            
        }
    }
}


extension ChatController: ChatInputAccessoryViewDelegate {
    
    func didSubmit(forChat chat: String) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let user = self.user else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)

        guard let uid = user.uid else { return }

        let messageValues = ["creationDate": creationDate,
                             "fromId": currentUid,
                             "toId": user.uid,
                             "messageText": chat] as [String: Any]

        let messageRef = MESSAGES_REF.childByAutoId()

        guard let messageKey = messageRef.key else { return }

        messageRef.updateChildValues(messageValues) { (err, ref) in
            USER_MESSAGES_REF.child(user.uid).child(currentUid).updateChildValues([messageKey: 1])
            USER_MESSAGES_REF.child(currentUid).child(user.uid).updateChildValues([messageKey: 1])
        }
        
        uploadMessageNotification()
        self.containerView.clearChatTextView()
    }
}


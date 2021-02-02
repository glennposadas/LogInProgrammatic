//
//  MessagesController.swift
//  LogInProgrammatic
//
//  Created by Mac on 12/9/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "MessagesCell"

class MessagesController: UITableViewController {
    
    // MARK: - Properties
    
    static var messages = [Message]()
    static var messagesDictionary = [String: Message]()
    
    var userUid: String?
    var currentKey: String?
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure navigation bar
        configureNavigationBar()
        
        // register cell
        tableView.register(MessageCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // fetch messages
        fetchMessages()
    }
    
    // MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessagesController.messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        cell.delegate = self
        cell.message = MessagesController.messages[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if MessagesController.messages.count > 4 {
            if indexPath.item == MessagesController.messages.count - 1 {
                fetchMessages()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = MessagesController.messages[indexPath.row]
        let chatPartnerId = message.getChatPartnerId()
        
        ProgressHUD.show()
        Database.fetchUser(with: chatPartnerId) { (user) in
            ProgressHUD.dismiss()
            self.showChatController(forUser: user)
            message.setSeen()
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            guard let userUid = userUid else { return }
            
            USER_MESSAGES_REF.child(currentUid).child(userUid).removeValue { (err, ref) in
                MessagesController.messages.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - Handlers
    
    @objc private func popToPrevious() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navigationController = UINavigationController(rootViewController: newMessageController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func showChatController(forUser user: User) {
        let chatController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(popToPrevious)
        )
    }
    
    func configureNavigationBar() {
        navigationItem.title = "Messages"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewMessage))
    }
    
    // MARK: - API
    
    func fetchMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        ProgressHUD.show()
        
        MessagesController.messages.removeAll()
        MessagesController.messagesDictionary.removeAll()
        self.tableView.reloadData()

        MessagesUtils.fetchMessages(userId: currentUid) { (partnerId) in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                ProgressHUD.dismiss()
            }
            
            self.userUid = partnerId
            
            self.tableView.reloadData()
            let indexPath = IndexPath(item: MessagesController.messages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

extension MessagesController: MessageCellDelegate {
    
    func configureUserData(for cell: MessageCell) {
        guard let chatPartnerId = cell.message?.getChatPartnerId() else { return }
        
        Database.fetchUser(with: chatPartnerId) { (user) in
            if let profileImageUrl = user.profileImageUrl {
                cell.profileImageView.loadImage(with: profileImageUrl)
            }
            
            cell.nameLabel.text = user.name
        }
    }
}

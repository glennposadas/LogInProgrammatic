//
//  NotificationsVC.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/14/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

private let reuseIdentifier = "NotificationCell"

class NotificationsVC: UITableViewController, NotitificationCellDelegate {
    
    // MARK: - Properties
    
    var timer: Timer?
    var currentKey: String?
    
    var notifications = [Notification]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // clear separator lines
        tableView.separatorColor = .clear
        
        // configure nav bar
        configureNavigationBar()
        
        // register cell class
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // fetch notifications
        fetchNotifications()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if notifications.count > 4 {
            if indexPath.item == notifications.count - 1 {
                fetchNotifications()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        
        cell.notification = notifications[indexPath.row]
        
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let notification = notifications[indexPath.row]
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = notification.user
        userProfileVC.fromTabBar = false
        navigationController?.pushViewController(userProfileVC, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(popToPrevious)
        )
    }

    // MARK: - NotificationCellDelegate Protocol
    
    func handleFollowTapped(for cell: NotificationCell) {
        
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            // handle unfollow user
            user.unfollow()
            cell.followButton.configure(didFollow: false)
        } else {
            // handle follow user
            user.follow()
            cell.followButton.configure(didFollow: true)
        }
    }
    
    func handlePostTapped(for cell: NotificationCell) {
        
        guard let post = cell.notification?.post else { return }
        
        let feedController = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedController.viewSinglePost = true
        feedController.post = post
        navigationController?.pushViewController(feedController, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(popToPrevious)
        )
    }
    
    // MARK: - Handlers
    
    @objc private func popToPrevious() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleShowMessages() {
        let messagesController = MessagesController()
        navigationController?.pushViewController(messagesController, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(popToPrevious)
        )
    }
    
    func handleReloadTable() {
        
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleSortNotifications), userInfo: nil, repeats: false)
    }
    
    @objc func handleSortNotifications() {
        
        self.notifications.sort { (notification1, notification2) -> Bool in
            return notification1.creationDate > notification2.creationDate
        }
        self.tableView.reloadData()
    }
    
    func configureNavigationBar() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: .plain, target: self, action: #selector(handleShowMessages))
        
        navigationItem.title = "Notifications"
    }
    
    // MARK: - API
    
    func fetchNotifications(withNotificationId notificationId: String, dataSnapshot snapshot: DataSnapshot) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
        guard let uid = dictionary["uid"] as? String else { return }

        Database.fetchUser(with: uid) { (user) in

            // if notification is for post
            if let postId = dictionary["postId"] as? String {

                Database.fetchPost(with: postId) { (post) in
                    let notification = Notification(user: user, post: post, dictionary: dictionary)
                    self.notifications.append(notification)
                    self.handleSortNotifications()
                    self.handleReloadTable()
                }
            } else {
                let notification = Notification(user: user, dictionary: dictionary)
                self.notifications.append(notification)
                self.handleSortNotifications()
                self.handleReloadTable()
            }
        }
        NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").setValue(1)
    }


    func fetchNotifications() {

        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        if currentKey == nil {
            NOTIFICATIONS_REF.child(currentUid).queryLimited(toLast: 12).observeSingleEvent(of: .value) { (snapshot) in

                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }

                allObjects.forEach { (snapshot) in
                    let notificationId = snapshot.key
                    self.fetchNotifications(withNotificationId: notificationId, dataSnapshot: snapshot)
                }
                self.currentKey = first.key
            }
        } else {

            NOTIFICATIONS_REF.child(currentUid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 13).observeSingleEvent(of: .value) { (snapshot) in

                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }

                allObjects.forEach { (snapshot) in
                    let notificationId = snapshot.key

                    if notificationId != self.currentKey {
                        self.fetchNotifications(withNotificationId: notificationId, dataSnapshot: snapshot)
                    }
                }
                self.currentKey = first.key
            }
        }
    }
    
//    func fetchNotifications() {
//
//        guard let currentUid = Auth.auth().currentUser?.uid else { return }
//
//        NOTIFICATIONS_REF.child(currentUid).observe(.childAdded) { (snapshot) in
//
//            let notificationId = snapshot.key
//            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
//            guard let uid = dictionary["uid"] as? String else { return }
//
//            Database.fetchUser(with: uid) { (user) in
//
//                // if the notification has a 'postId' meaning that the notification is for a like or comment in a post
//                if let postId = dictionary["postId"] as? String {
//
//                    Database.fetchPost(with: postId) { (post) in
//
//                        let notification = Notification(user: user, post: post, dictionary: dictionary)
//                        self.notifications.append(notification)
//                        self.tableView.reloadData()
//                    }
//                } else {
//
//                    let notification = Notification(user: user, dictionary: dictionary)
//                    self.notifications.append(notification)
//                    self.tableView.reloadData()
//                }
//            }
//            NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").setValue(1)
//        }
//    }
    
//   func fetchNotifications() {
//       guard let currentUid = Auth.auth().currentUser?.uid else { return }
//
//       NOTIFICATIONS_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
//           guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
//
//           allObjects.forEach({ (snapshot) in
//               let notificationId = snapshot.key
//               guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
//               guard let uid = dictionary["uid"] as? String else { return }
//
//               Database.fetchUser(with: uid, completion: { (user) in
//
//                   // if notification is for post
//                   if let postId = dictionary["postId"] as? String {
//                       Database.fetchPost(with: postId, completion: { (post) in
//                           let notification = Notification(user: user, post: post, dictionary: dictionary)
//                           self.notifications.append(notification)
//                           self.handleReloadTable()
//                       })
//                   } else {
//                       let notification = Notification(user: user, dictionary: dictionary)
//                       self.notifications.append(notification)
//                       self.handleReloadTable()
//                   }
//               })
//               NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").setValue(1)
//           })
//       }
//   }
    
}

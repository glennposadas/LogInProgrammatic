//
//  Extensions.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/8/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import FirebaseDatabase

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension UIButton {
    
    func configure(didFollow: Bool) {
        
        if didFollow {
            
            // handle follow user
            self.setTitle("Following", for: .normal)
            self.setTitleColor(.black, for: .normal)
            self.layer.borderWidth = 0.5
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.backgroundColor = .white
        } else {
            
            // handle unfollow user
            self.setTitle("Follow", for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.layer.borderWidth = 0
            self.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        }
    }
}

extension Date {
    
    func timeAgoToDisplay() -> String {
        
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "SECOND"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "MIN"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "HOUR"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "DAY"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "WEEK"
        } else {
            quotient = secondsAgo / month
            unit = "MONTH"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "S") AGO"
    }
}

extension Date {
    
    func timeOrDateToDisplay(from seconds: Date) -> String {
        
//        let numberOfSeconds = Int(Date().timeIntervalSince(seconds))
//        let day = 86400
                
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        
        if calendar.isDateInToday(seconds) {
            dateFormatter.dateFormat = "hh:mm a"
            return dateFormatter.string(from: seconds)
        } else if calendar.isDateInYesterday(seconds) {
            return "Yesterday"
        } else if calendar.isDate(seconds, inSameDayAs: TWO_DAYS_AGO!) {
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: seconds)
        } else if calendar.isDate(seconds, inSameDayAs: THREE_DAYS_AGO!) {
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: seconds)
        } else if calendar.isDate(seconds, inSameDayAs: FOUR_DAYS_AGO!) {
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: seconds)
        } else if calendar.isDate(seconds, inSameDayAs: FIVE_DAYS_AGO!) {
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: seconds)
        } else if calendar.isDate(seconds, inSameDayAs: SIX_DAYS_AGO!) {
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: seconds)
        } else {
            dateFormatter.dateFormat = "MM/dd/YY"
            return dateFormatter.string(from: seconds)
        }
        
//        if calendar.isDateInToday(seconds) {
//            dateFormatter.dateFormat = "hh:mm a"
//            return dateFormatter.string(from: seconds)
//        } else if calendar.isDateInYesterday(seconds) {
//            return "Yesterday"
//        } else {
//            dateFormatter.dateFormat = "MM/dd/YY"
//            return dateFormatter.string(from: seconds)
//        }
        
        
//        if calendar.isDateInToday(seconds) {
//            dateFormatter.dateFormat = "EEEE"
//            return dateFormatter.string(from: seconds)
//        } else if calendar.isDateInYesterday(seconds) {
//            return "Yesterday"
//        } else {
//            dateFormatter.dateFormat = "MM/dd/YY"
//            return dateFormatter.string(from: seconds)
//        }
        
//        if numberOfSeconds < day {
//            dateFormatter.dateFormat = "hh:mm a"
//        } else {
//            dateFormatter.dateFormat = "MM/dd/YY"
//        }
//
//        return dateFormatter.string(from: seconds)
    }
}


extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension Database {
    
    static func fetchUser(with uid: String, completion: @escaping(User) -> ()) {
        
        USER_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            
            completion(user)
        }
    }
    
    static func fetchPost(with postId: String, completion: @escaping(Post) -> ()) {
        
        POSTS_REF.child(postId).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            guard let ownerUid = dictionary["ownerUid"] as? String else { return }
            
            Database.fetchUser(with: ownerUid) { (user) in
                
                let post = Post(postId: postId, user: user, dictionary: dictionary)
                
                completion(post)
            }
        }
    }
}

//
//  SearchUserCell.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/28/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell {

    // MARK: - Properties
    
    var user: User? {
    
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            guard let userName = user?.username else { return }
            guard let fullName = user?.name else { return }
            
            profileImageView.loadImage(with: profileImageUrl)
            
            self.textLabel?.text = userName
            self.detailTextLabel?.text = fullName
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        // add profile image view
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 48 / 2
        
        self.textLabel?.text = "Username"
        self.detailTextLabel?.text = "Full name"
        
        self.selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y, width: self.frame.width - 108, height: (detailTextLabel?.frame.height)!)
        detailTextLabel?.textColor = .lightGray
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

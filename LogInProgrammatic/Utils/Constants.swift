//
//  Constants.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/18/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import Firebase
import FirebaseDatabase
import FirebaseStorage

// MARK: - Root References

let DB_REF = Database.database().reference()
let STORAGE_REF = Storage.storage().reference()
let STORAGE_PROFILE_IMAGES_REF = STORAGE_REF.child("profile_images")

// MARK: - Database References

let USER_REF = DB_REF.child("users")
let USER_FOLLOWER_REF = DB_REF.child("user-followers")
let USER_FOLLOWING_REF = DB_REF.child("user-following")

let POSTS_REF = DB_REF.child("posts")
let USER_POSTS_REF = DB_REF.child("user-posts")
let STORAGE_POST_IMAGES_REF = STORAGE_REF.child("post_images")

let USER_FEED_REF = DB_REF.child("user-feed")

let USER_LIKES_REF = DB_REF.child("user-likes")
let POST_LIKES_REF = DB_REF.child("post-likes")

let COMMENT_REF = DB_REF.child("comments")

let NOTIFICATIONS_REF = DB_REF.child("notifications")

let MESSAGES_REF = DB_REF.child("messages")
let USER_MESSAGES_REF = DB_REF.child("user-messages")

let LIKE_INT_VALUE = 0
let COMMENT_INT_VALUE = 1
let FOLLOW_INT_VALUE = 2

// MARK: - Date References

let TWO_DAYS_AGO = Calendar.current.date(byAdding: .day, value: -2, to: Date())
let THREE_DAYS_AGO = Calendar.current.date(byAdding: .day, value: -3, to: Date())
let FOUR_DAYS_AGO = Calendar.current.date(byAdding: .day, value: -4, to: Date())
let FIVE_DAYS_AGO = Calendar.current.date(byAdding: .day, value: -5, to: Date())
let SIX_DAYS_AGO = Calendar.current.date(byAdding: .day, value: -6, to: Date())


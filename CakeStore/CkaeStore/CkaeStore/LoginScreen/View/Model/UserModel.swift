//
//  UserModel.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 25/03/25.
//

import Foundation
import Foundation

struct UserModel: Identifiable {
    let id: String
    let name: String?
    let email: String?
    let profileImageURL: String?
    let provider: String? // Google, Facebook, Apple
}

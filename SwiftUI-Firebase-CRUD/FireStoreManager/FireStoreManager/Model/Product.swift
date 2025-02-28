//
//  Product.swift
//  FireStoreManager
//
//  Created by JIDTP1408 on 27/02/25.
//

import Foundation

struct Product: Identifiable {
    var id: String
    var name: String
    var description: String
    var price: Double
    var imageUrl: String?
    var createdAt: Date
}

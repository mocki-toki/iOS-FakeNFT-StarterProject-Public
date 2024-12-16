//
//  User.swift
//  FakeNFT
//
//  Created by Ilya Kalin on 16.12.2024.
//

import Foundation

struct Users: Decodable {
    let name: String
    let avatar: String
    let rating: String
    let description: String
    let website: String
    let id: String
    let nfts: [String]
}

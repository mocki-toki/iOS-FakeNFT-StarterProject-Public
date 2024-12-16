//
//  Profile.swift
//  FakeNFT
//
//  Created by Ilya Kalin on 16.12.2024.
//

import Foundation

struct Profile: Codable {
    var name: String
    var avatar: String
    var description: String
    var website: String
    var nfts: [String]
    var likes: [String]
    let id: String
}

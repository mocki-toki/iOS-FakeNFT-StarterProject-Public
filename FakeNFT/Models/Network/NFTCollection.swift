//
//  Collections.swift
//  FakeNFT
//
//  Created by Ilya Kalin on 16.12.2024.
//

import Foundation

struct nftCollection: Decodable {
    let createdAt: String
    let name: String
    let cover: String
    let nfts: [String]
    let description: String
    let author: String
    let id: String
}

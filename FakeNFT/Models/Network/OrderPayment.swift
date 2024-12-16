//
//  OrderPayment.swift
//  FakeNFT
//
//  Created by Ilya Kalin on 16.12.2024.
//

import Foundation

struct OrderPayment: Decodable {
    let success: Bool
    let orderId: String
    let id: String
}

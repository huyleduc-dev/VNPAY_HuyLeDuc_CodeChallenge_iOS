//
//  Photo.swift
//  VNPAY_HuyLeDuc_CodeChallenge_iOS
//
//  Created by Đức Huy Lê on 12/6/25.
//

import Foundation

struct Photo: Codable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let downloadUrl: String

    enum CodingKeys: String, CodingKey {
        case id, author, width, height
        case downloadUrl = "download_url"
    }
}

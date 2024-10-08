//
//  UpdateFeedBody.swift
//  Where_Are_You
//
//  Created by 오정석 on 8/8/2024.
//

import UIKit

struct ModifyFeedRequest: Codable {
    let feedSeq: Int
    let creatorSeq: Int
    let title: String
    let content: String?
}

//
//  Extensions.swift
//  wcisc
//
//  Created by 李灿晨 on 2/21/20.
//  Copyright © 2020 李灿晨. All rights reserved.
//

import Foundation

extension Date {
    func formattedString(with formatString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = formatString
        return formatter.string(from: self)
    }
}

extension Double {
    func unitString() -> String {
        return String(format: "%.2f", self) + "unit"
    }
}

//
//  ImageCache.swift
//  SimpleInternetRadio
//
//  Created by 宋小伟 on 2023/2/19.
//

import Foundation
import SwiftUI

class ImageCache{
    static private var cache: [String: Image] = [:]
    static subscript(url: String) -> Image?{
        get{
            ImageCache.cache[url]
        }
        set{
            ImageCache.cache[url] = newValue
        }
    }
}

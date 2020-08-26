//
//  URL+relativePathWithQueryItemsAndFragments.swift
//  
//
//  Created by Tiziano Coroneo on 29/02/2020.
//

import Foundation

extension URL {
    /// Get the relative path part out of a `URL`.
    ///
    /// Example: for the url `"https://apple.com/test?query=some#fragment"`, the relative path is `/test?query=some#fragment`, including query items (`?query=some`) and URL fragments (`#fragment`).
    var relativePathWithQueryItemsAndFragments: String? {
        var components = URLComponents(
            url: self,
            resolvingAgainstBaseURL: false)

        components?.host = nil
        components?.scheme = nil
        components?.port = nil
        components?.user = nil

        return components?.string
    }
}

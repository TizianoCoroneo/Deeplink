//
//  String+utilities.swift
//  
//
//  Created by Tiziano Coroneo on 29/02/2020.
//

import Foundation

extension String {
    /// Like the `split(separator:)` function, but only splitting on the first occurrence of the pattern.
    func splitFirstOccurrence(
        of string: String
    ) -> [String] {
        guard let firstOccurrenceRange = self.range(of: string)
            else { return [self] }

        return [
            String(self[
                ..<firstOccurrenceRange.lowerBound]),
            String(self[
                firstOccurrenceRange.upperBound...])
            ]
    }

    /// Removes everything that appears after any character contained in the parameter string.
    func removeAfterAnyCharacterIn(
        string: String
    ) -> String {
        // `components` is never empty even for the empty string 🤔
        components(separatedBy: CharacterSet(charactersIn: string))[0]
    }
}

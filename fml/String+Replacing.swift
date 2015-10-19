import Foundation

extension String {
    func stringByReplacingString(search: String, with: String) -> String {
        return stringByReplacingOccurrencesOfString(search, withString: with, options: .LiteralSearch, range: nil)
    }
}
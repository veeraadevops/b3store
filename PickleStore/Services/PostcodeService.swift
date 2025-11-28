//
//  PostcodeService.swift
//  PickleStore
//
//  Created on 13/11/2025.
//

import Foundation

struct PostcodeResult: Codable {
    let postcode: String
    let region: String?
    let admin_district: String?
    let parish: String?
    let parliamentary_constituency: String?
    let admin_county: String?
    let country: String?
}

struct PostcodeResponse: Codable {
    let status: Int
    let result: PostcodeResult?
}

class PostcodeService {
    static let shared = PostcodeService()
    
    private init() {}
    
    func lookupPostcode(_ postcode: String) async throws -> PostcodeResult {
        // Remove spaces and convert to uppercase
        let cleanedPostcode = postcode.replacingOccurrences(of: " ", with: "").uppercased()
        
        guard let url = URL(string: "https://api.postcodes.io/postcodes/\(cleanedPostcode)") else {
            throw PostcodeError.invalidPostcode
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PostcodeError.networkError
        }
        
        if httpResponse.statusCode == 404 {
            throw PostcodeError.notFound
        }
        
        guard httpResponse.statusCode == 200 else {
            throw PostcodeError.networkError
        }
        
        let decoder = JSONDecoder()
        let postcodeResponse = try decoder.decode(PostcodeResponse.self, from: data)
        
        guard let result = postcodeResponse.result else {
            throw PostcodeError.notFound
        }
        
        return result
    }
}

enum PostcodeError: LocalizedError {
    case invalidPostcode
    case notFound
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidPostcode:
            return "Invalid postcode format"
        case .notFound:
            return "Postcode not found"
        case .networkError:
            return "Network error. Please try again."
        }
    }
}

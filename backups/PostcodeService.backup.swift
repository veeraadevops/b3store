//
//  PostcodeService.swift
//  PickleStore
//
//  Created on 13/11/2025.
//

import Foundation

// Address structure for actual street addresses
struct Address: Identifiable, Codable {
    let id = UUID()
    let line1: String
    let line2: String?
    let city: String
    let postcode: String
    
    var formattedAddress: String {
        var components = [line1]
        if let line2 = line2, !line2.isEmpty {
            components.append(line2)
        }
        components.append(city)
        components.append(postcode)
        return components.joined(separator: ", ")
    }
    
    enum CodingKeys: String, CodingKey {
        case line1 = "line_1"
        case line2 = "line_2"
        case city
        case postcode
    }
}

// IdealPostcodes API Response
struct IdealPostcodesResponse: Codable {
    let result: [IdealPostcodesAddress]?
}

struct IdealPostcodesAddress: Codable {
    let line_1: String
    let line_2: String?
    let post_town: String
    let postcode: String
}

class PostcodeService {
    static let shared = PostcodeService()
    
    // TODO: Replace with your actual API key from https://ideal-postcodes.co.uk
    // Free tier: 10 lookups per day for testing
    private let apiKey = "YOUR_API_KEY_HERE"
    
    private init() {}
    
    // Lookup addresses for a postcode using IdealPostcodes API
    func lookupAddresses(for postcode: String) async throws -> [Address] {
        // Remove spaces and convert to uppercase
        let cleanedPostcode = postcode.replacingOccurrences(of: " ", with: "").uppercased()
        
        // Check if API key is set
        guard apiKey != "YOUR_API_KEY_HERE" else {
            // Fallback to Postcode.io (only validates, doesn't return addresses)
            throw PostcodeError.apiKeyMissing
        }
        
        guard let url = URL(string: "https://api.ideal-postcodes.co.uk/v1/postcodes/\(cleanedPostcode)?api_key=\(apiKey)") else {
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
        let postcodeResponse = try decoder.decode(IdealPostcodesResponse.self, from: data)
        
        guard let results = postcodeResponse.result, !results.isEmpty else {
            throw PostcodeError.notFound
        }
        
        // Convert to Address objects
        return results.map { idealAddress in
            Address(
                line1: idealAddress.line_1,
                line2: idealAddress.line_2,
                city: idealAddress.post_town,
                postcode: idealAddress.postcode
            )
        }
    }
}

enum PostcodeError: LocalizedError {
    case invalidPostcode
    case notFound
    case networkError
    case apiKeyMissing
    
    var errorDescription: String? {
        switch self {
        case .invalidPostcode:
            return "Invalid postcode format"
        case .notFound:
            return "Postcode not found"
        case .networkError:
            return "Network error. Please try again."
        case .apiKeyMissing:
            return "Address lookup requires an API key. Using manual entry."
        }
    }
}

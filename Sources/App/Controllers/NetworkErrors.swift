//
//  File.swift
//  
//
//  Created by Sepand Yadollahifar on 8/4/20.
//

import Foundation

enum Errors {
    
    case network(type: Enums.NetworkError)
    case app(errorDescription: String?)
    
    class Enums {}
}

extension Errors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .network(let type): return type.localizedDescription
        case .app(let errorDescription): return errorDescription
        }
    }
}


extension Errors.Enums {
    
    enum NetworkError {
        case badURL
        case dataTaskError
        case parsingFailed
        case noToken
        case unknownServerResponse
        case userNotFound
        case serverDidNotResponde
        case noInternetConnection
        case timeout
        case custom(errorCode: Int?, errorDescription: String?)
    }
}

extension Errors.Enums.NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .badURL: return "Bad URL Error"
            case .dataTaskError: return "Data Task Error"
            case .parsingFailed: return "Failed To Parse Data"
            case .noToken: return "No Token - Must Login Again"
            case .unknownServerResponse: return "Server Returned Unknown Error"
            case .userNotFound: return "User not found"
            case .serverDidNotResponde: return "Server did not responde."
            case .noInternetConnection: return "No Internet Connection."
            case .timeout: return "Request timed out"
            case .custom(_, let errorDescription): return errorDescription
        }
    }
    
    var errorCode: Int? {
        switch self {
            case .badURL: return 1
            case .dataTaskError: return 2
            case .parsingFailed: return 3
            case .noToken: return 4
            case .unknownServerResponse: return 5
            case .userNotFound: return 403
            case .serverDidNotResponde: return 6
            case .noInternetConnection: return 7
            case .timeout: return 8
            case .custom(let errorCode, _): return errorCode
        }
    }
}

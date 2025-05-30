import Foundation

enum APIEnvironment {
    case development
    case production
    
    var baseURL: String {
        switch self {
        case .development:
            return "http://localhost:4000"
        case .production:
            // Replace with your production URL when ready
            return "http://localhost:4000"
        }
    }
    
    static var current: APIEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
} 
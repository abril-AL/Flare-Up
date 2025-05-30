import Foundation

actor NetworkManager {
    static let shared = NetworkManager()
    private let session: URLSession
    private let environment: APIEnvironment
    
    private init(environment: APIEnvironment = .current) {
        self.environment = environment
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    func request<T: Decodable>(_ endpoint: String,
                              method: String = "GET",
                              body: Data? = nil) async throws -> T {
        guard let url = URL(string: "\(environment.baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(NSError(domain: "", code: -1))
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func post<T: Encodable, U: Decodable>(_ endpoint: String,
                                         body: T) async throws -> U {
        let jsonData = try JSONEncoder().encode(body)
        return try await request(endpoint, method: "POST", body: jsonData)
    }
} 
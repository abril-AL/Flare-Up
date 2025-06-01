public struct MyAuthResponse: Codable {
    public let user: MyUser?
    public let session: MySession?
    
    public enum CodingKeys: String, CodingKey {
        case user
        case session
    }

    public init(user: MyUser?, session: MySession?) {
        self.user = user
        self.session = session
    }
}

public struct MyUser: Codable {
    public let id: String
    public let aud: String?
    public let role: String?
    public let email: String?
    public let phone: String?
    public let emailConfirmedAt: String?
    public let confirmedAt: String?
    public let lastSignInAt: String?
    public let createdAt: String
    public let updatedAt: String?

    public enum CodingKeys: String, CodingKey {
        case id, aud, role, email, phone
        case emailConfirmedAt = "email_confirmed_at"
        case confirmedAt = "confirmed_at"
        case lastSignInAt = "last_sign_in_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct MySession: Codable {
    public let accessToken: String
    public let tokenType: String
    public let expiresIn: Int?
    public let refreshToken: String?
    public let user: MyUser?

    public enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case user
    }
}

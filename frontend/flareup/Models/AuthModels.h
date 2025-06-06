#import <Foundation/Foundation.h>

@interface AuthResponse : NSObject <NSCoding>
@property (nonatomic, strong, nullable) User *user;
@property (nonatomic, strong, nullable) Session *session;
@end

@interface User : NSObject <NSCoding>
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy, nullable) NSString *aud;
@property (nonatomic, copy, nullable) NSString *role;
@property (nonatomic, copy, nullable) NSString *email;
@property (nonatomic, copy, nullable) NSString *phone;
@property (nonatomic, copy, nullable) NSString *emailConfirmedAt;
@property (nonatomic, copy, nullable) NSString *confirmedAt;
@property (nonatomic, copy, nullable) NSString *lastSignInAt;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy, nullable) NSString *updatedAt;
@end

@interface Session : NSObject <NSCoding>
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *tokenType;
@property (nonatomic, assign, nullable) NSNumber *expiresIn;
@property (nonatomic, copy, nullable) NSString *refreshToken;
@property (nonatomic, strong, nullable) User *user;
@end 
// import Foundation

enum Config {
    #if DEBUG
//    static let backendURL = " http://0.0.0.0:4000"   // iOS Simulator

    
    static let backendURL = "http://localhost:4000"  // Alternative for iOS Simulator
//     static let backendURL = "http://131.179.50.54:4000"  // Real device on same network
    // static let backendURL = "http://10.5.0.2:4000"  // Alternative IP for real device
    #else
    static let backendURL = "http://localhost:4000"  // Alternative for iOS Simulator
    #endif
}


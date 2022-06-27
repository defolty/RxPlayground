import Foundation
import RxSwift
import RxRelay

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}
  
example(of: "BehaviorRelay") {
    enum UserSession {
        case loggedIn, loggedOut
    }
    
    enum LoginError: Error {
        case invalidCredentials
    }
    
    let disposeBag = DisposeBag()
    
    // Create userSession BehaviorRelay of type UserSession with initial value of .loggedOut
    let userSession = BehaviorRelay(value: UserSession.loggedOut)
    
    // Subscribe to receive next events from userSession
    userSession
        .subscribe(onNext: {
            print("userSession changed:", $0)
        })
        .disposed(by: disposeBag)
    
    func logInWith(username: String, password: String, completion: (Error?) -> Void) {
        guard username == "johnny@appleseed.com",
              password == "appleseed" else {
            completion(LoginError.invalidCredentials)
            return
        }
        
        // Update userSession
        userSession.accept(.loggedIn)
        
    }
    
    func logOut() {
        // Update userSession
        userSession.accept(.loggedOut)
    }
    
    func performActionRequiringLoggedInUser(_ action: () -> Void) {
        // Ensure that userSession is loggedIn and then execute action()
        guard userSession.value == .loggedIn else {
            print("Log In Failure.")
            return
        }
    }
    
    for i in 1...2 {
        let password = i % 2 == 0 ? "appleseed" : "password"
        
        logInWith(username: "johnny@appleseed.com", password: password) { error in
            guard error == nil else {
                print(error!)
                return
            }
            
            print("User logged in.")
        }
        
        performActionRequiringLoggedInUser {
            print("Successfully did something only a logged in user can do.")
        }
    }
}

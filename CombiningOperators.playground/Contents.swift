import Foundation
import RxSwift
import RxRelay

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}
  
example(of: "startWith") {
    
    // 1
    let numbers = Observable.of(2, 3, 4)
    
    // 2
    let observable = numbers.startWith(1)
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    /** in progress */
}

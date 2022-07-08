import Foundation
import RxSwift
import RxRelay

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}
   
example(of: "zipChallenge") {
    
    let source = Observable.of(1, 3, 5, 7, 9)
     
    let scanObservable = source.scan(0, accumulator: +)
    let observable = Observable.zip(source, scanObservable)
    
    _ = observable.subscribe(onNext: { tuple in
        print("Value = \(tuple.0) Running total = \(tuple.1)")
    })
    
    /* output
     --- Example of: zipChallenge ---
     Value = 1 Running total = 1
     Value = 3 Running total = 4
     Value = 5 Running total = 9
     Value = 7 Running total = 16
     Value = 9 Running total = 25
     */
}
 

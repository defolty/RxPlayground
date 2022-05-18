import Foundation
import RxSwift

// MARK: - Support Code

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}

// MARK: - Observable

example(of: "just, of, from") {
    let one = 1
    let two = 2
    let three = 3
    
    // наблюдаемая последовательность
    let observable = Observable<Int>.just(one)           // <Int>
    let observable2 = Observable.of(one, two, three)     // <Array<Int>>
    let observable3 = Observable.of([one, two, three])   // <Array<Array<Int>>>
    let observable4 = Observable.from([one, two, three]) // <Array<Int>>
    print(type(of: observable), type(of: observable2), type(of: observable3), type(of: observable4))
}

example(of: "subscribe") {
    let one = 1
    let two = 2
    let three = 3
    
    let observable = Observable.of(one, two, three) // next(1) next(2) next(3)
    
    /* № 1
    // subscribe(_ on: @escaping (Event<Int>) -> Void) -> Disposable
    observable.subscribe { event in
        print(event) // completed
    }
     
    № 2
    observable.subscribe { event in
        if let element = event.element {
            print(element) // 3 times | 1 2 3
        }
    }
     */
    
    observable.subscribe(onNext: { element in
      print(element)
    })
}

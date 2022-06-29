import Foundation
import RxSwift

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}

example(of: "never") {
    let observable = Observable<Any>.never()
    let disposeBag = DisposeBag()
    
    observable
//    Challenge #1
//        .do(onSubscribe: {
//            print("Subscribed")
//        })
        .debug("observable")
    /* output
     --- Example of: never ---
     2022-06-27 17:29:35.983: observable -> subscribed
     2022-06-27 17:29:35.991: observable -> isDisposed
     Disposed
     */
        .subscribe(
            onNext: { element in
                print(element)
            },
            onCompleted: {
                print("Completed")
            },
            onDisposed: {
                print("Disposed")
            }
        )
        .disposed(by: disposeBag)
    /* output
     --- Example of: never ---
     Subscribed
     Disposed
     */
}

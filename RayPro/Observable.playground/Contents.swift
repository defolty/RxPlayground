import Foundation
import RxSwift

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}
 

example(of: "creating observable") {
    <#code#>
}

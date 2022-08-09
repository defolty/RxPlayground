import Foundation
import RxSwift

public let episodeI = "The Phantom Menace"
public let episodeII = "Attack of the Clones"
public let theCloneWars = "The Clone Wars"
public let episodeIII = "Revenge of the Sith"
public let solo = "Solo"
public let rogueOne = "Rogue One"
public let episodeIV = "A New Hope"
public let episodeV = "The Empire Strikes Back"
public let episodeVI = "Return Of The Jedi"
public let episodeVII = "The Force Awakens"
public let episodeVIII = "The Last Jedi"
public let episodeIX = "Episode IX"

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}
  
example(of: "creating observable") {
    // .just - всё что делает just это создает наблюдаемую последовательность содержащую только один элемент
    // .just - по идеи это метод, но в RxSwift это назывыается оператор
    let mostPopular: Observable<String> = Observable<String>.just(episodeV)
    
    // это наблюдатель типа String
    let originalTrilogy = Observable.of(episodeIV, episodeV, episodeVI)
    
    // это наблюдаемый массив строк
    let prequelTrilogy = Observable.of([episodeI, episodeII, episodeIII])
    
    // это наблюдатель типа String
    let sequelTrilogy = Observable.from([episodeVII, episodeVIII, episodeIX])
}

example(of: "create") {
    
    enum Droid: Error {
        case OU812
    }
    
    let bag = DisposeBag()
    
    Observable<String>.create { observer in
        observer.onNext("R2-D2")
        observer.onNext("C-3PO")
        observer.onCompleted()
        
        return Disposables.create()
    }
    .subscribe(
        onNext: { print($0) },
        onError: { print("Error", $0) },
        onCompleted: { print("Completed!") },
        onDisposed: { print("Disposed...") }
    )
    .disposed(by: bag)
}

import Foundation
import RxSwift
import RxRelay

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}

/// В RxSwift существует четыре типа `Subject`:
/// `PublishSubject`: Изначально пуст и излучает подписчикам только новые элементы.
/// `BehaviorSubject`: Начинает с начального значения и воспроизводит его или последний элемент новым подписчикам.
/// `ReplaySubject`: Инициализируется с размером буфера и будет поддерживать буфер элементов до этого размера и воспроизводить его новым подписчикам.
/// `AsyncSubject`: Выдает только последнее следующее событие в последовательности, и только тогда, когда субъект получает завершенное событие.
///                Это редко используемый тип субъекта, и вы не будете использовать его в этой книге. Он приведен здесь для полноты картины.

    // MARK: - PublishSubject

// Вы только что создали PublishSubject.
// Это подходящее название, потому что, подобно издателю газеты, он будет получать информацию, а затем публиковать ее подписчикам.
// Он имеет тип String, поэтому может принимать и публиковать только строки.
// После инициализации он готов к приему строк.
// Субъекты публикации удобны, когда вы просто хотите, чтобы подписчики получали уведомления о новых событиях с того момента, когда они подписались, до тех пор,
// пока они не отпишутся, или пока субъект не завершится событием завершения или ошибки.
// -
// RxSwift также предоставляет концепцию под названием `Relays`.
// RxSwift предоставляет два из них, названные `PublishRelay и BehaviorRelay`.
// Они обертывают соответствующие субъекты, но принимают и передают только следующие события.
// Вы не можете добавить завершенное событие или событие ошибки в реле, поэтому они отлично подходят для не завершающихся последовательностей.

example(of: "PublishSubject") {
    
    // Subject действуют как наблюдаемый и как наблюдатель.
    // Ранее вы видели, как они могут получать события, а также быть подписанными на них.
    // В приведенном примере субъект получал следующие события, и для каждого из них он поворачивался и излучал его своему подписчику.
    let subject = PublishSubject<String>()
    
    subject.on(.next("Is anyone listening?"))
    
    let subscriptionOne = subject
        .subscribe(onNext: { string in
            print(string)
        })
    
    subject.on(.next("1"))
    subject.onNext("2")
    /* output
     --- Example of: PublishSubject ---
     1
     2
     */
    
    let subscriptionTwo = subject
        .subscribe { event in
            print("2)", event.element ?? event)
        }
    
    subject.onNext("3")
    /* output
     --- Example of: PublishSubject ---
     1
     2
     3
     2 3 // 3 печатается дважды, один раз для subscriptionOne и один раз для subscriptionTwo.
     */
    
    // Добавьте этот код, чтобы прекратить subscriptionOne, а затем добавьте еще одно следующее событие в тему:
    subscriptionOne.dispose()
    subject.onNext("4")
    // Значение 4 печатается только для subscriptionTwo, потому что subscriptionOne была утилизирована.
     
    // 1 - Добавьте завершенное событие на объект, используя удобный метод для on(.completed). Это завершает наблюдаемую последовательность объекта.
    subject.onCompleted()
    
    // 2 - Добавьте еще один элемент на объект. Он не будет выдан и напечатан, потому что объект уже завершился.
    subject.onNext("5")
    
    // 3 - Утилизируйте подписку.
    subscriptionTwo.dispose()
    
    let disposeBag = DisposeBag()
    
    // 4 - Подпишитесь на объект, на этот раз добавив его одноразовый элемент в мешок утилизации.
    subject
        .subscribe {
            print("3)", $0.element ?? $0)
        }
        .disposed(by: disposeBag)
    
    subject.onNext("?")
    /* output
     2 completed
     3) completed
     -
     Может быть, новый подписчик 3) вернет субъект в рабочее состояние? Нет, но вы все равно получите повторное воспроизведение завершенного события.
     */
}

    // MARK: - BehaviorSubjects

// BehaviorSubjects работают аналогично publishSubjects, за исключением того, что они будут воспроизводить последнее следующее событие новым подписчикам.
// 1 - Определите тип ошибки для использования в последующих примерах.
enum MyError: Error {
    case anError
}

// 2 - Развивая использование тернарного оператора в предыдущем примере, вы создаете вспомогательную функцию для печати элемента,
// если он есть, ошибки, если она есть, или самого события.
func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, (event.element ?? event.error) ?? event)
}
 
example(of: "BehaviorSubjects") {
    // 3 - Создайте новый экземпляр BehaviorSubject. Его инициализатор принимает начальное значение
    let subject = BehaviorSubject(value: "Initial Value")
    let disposeBag = DisposeBag()
    
    subject.onNext("X")
    
    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
    
        .disposed(by: disposeBag)
    
    // 1 - Добавляете событие ошибки в тему.
    subject.onError(MyError.anError)
    
    // 2 - Создаете новую подписку на объект.
    subject
        .subscribe {
            print(label: "2)", event: $0)
        }
    
        .disposed(by: disposeBag)
    /* output
     --- Example of: BehaviorSubjects ---
     1) X
     1) anError
     2) anError
     */
}

    // MARK: - ReplaySubject

example(of: "ReplaySubject") {
    // 1 - Создайте новый объект воспроизведения с размером буфера 2.
    // Объекты воспроизведения инициализируются с помощью метода типа create(bufferSize:).
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    let disposeBag = DisposeBag()
    
    // 2 - Добавьте три элемента к субъекту.
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    
    // 3 - Создайте две подписки на объект.
    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    
    // Последние два элемента воспроизводятся обоим подписчикам; 1 никогда не испускается,
    // потому что 2 и 3 добавляются в субъект воспроизведения с размером буфера 2 до того, как на него подписались.
    
    /* output
     --- Example of: ReplaySubject ---
     1) 2
     1) 3
     2) 2
     2) 3
     */
    
    // С помощью этого кода вы добавляете еще один элемент в тему, а затем создаете новую подписку на него.
    // Первые две подписки получат этот элемент как обычно, потому что они уже были подписаны, когда новый элемент был добавлен в тему,
    // а новый третий подписчик получит последние два буферизованных элемента, воспроизведенные для него.
    subject.onNext("4")
    
    subject.onError(MyError.anError)
    
    subject.dispose()
    // При явном вызове dispose() на субъекте воспроизведения заранее, новые подписчики получат только событие ошибки,
    // указывающее на то, что субъект уже был утилизирован.
    // в консоле изменилась последняя запись:
    // "3) Object `RxSwift.(unknown context at $12e9cb320).ReplayMany<Swift.String>` was already disposed."
    
    subject
        .subscribe {
            print(label: "3)", event: $0)
        }
        .disposed(by: disposeBag)
    /* output without subject.onError
     1) 4
     2) 4
     3) 3
     3) 4
     -
     output with subject.onError
     1) 4
     2) 4
     1) anError
     2) anError
     3) 3
     3) 4
     3) anError
     Что происходит? Субъект воспроизведения завершается с ошибкой, которая будет повторно передана новым подписчикам - вы узнали это ранее.
     Но буфер также все еще остается, поэтому он также будет повторно передан новым подписчикам, прежде чем событие остановки будет повторно передано.
     */
}

    // MARK: - PublishRelay

/// Используя `publishSubject, behaviorSubject или replaySubject`, вы сможете смоделировать практически любую потребность.
/// Однако могут быть случаи, когда вы просто захотите пойти по старинке и спросить у наблюдаемого типа: "Эй, какое у тебя текущее значение?". `PublishRelay` здесь!
/// Ранее вы узнали, что `relay` оборачивает `subject`, сохраняя его поведение при воспроизведении.
/// В отличие от других subjects - и observables в целом - вы добавляете значение в relay с помощью метода `accept(_:)`
/// Другими словами, вы не используете `onNext(_:)`
/// Это связано с тем, что `relay` могут только принимать значения, т.е. вы не можете добавить к ним ошибку или завершенное(`completion`) событие.
/// `PublishRelay` оборачивает `PublishSubject`, а `BehaviorRelay` оборачивает `BehaviorSubject`.
/// `Кудфн` отличаются от своих обернутых `subject` тем, что они гарантированно никогда не завершатся.

example(of: "PublishRelay") {
    let publishRelay = PublishRelay<String>()
    
    let disposeBag = DisposeBag()
    
    publishRelay.accept("Knock knock, anyone home?")
    
    // создаём подписчиков
    publishRelay
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    publishRelay.accept("1")
    /* output
     --- Example of: PublishReplay ---
     1
     Note: Не существует способа добавить ошибку или завершенное событие.
     */
}

    // MARK: - BehaviorRelay

// Помните, что publishRelays обертывает publishSubject и работает точно так же, как и они, за исключением части accept и того, что они не завершаются.
// Как насчет чего-то более интересного? Поприветствуйте моего маленького друга, BehaviorRelay.

// BehaviorRelays также не завершается при completion или error.
// Поскольку он обернут в behaviorSubject, behaviorRelay создается с начальным значением,
// и он будет воспроизводить свое последнее или начальное значение новым подписчикам.
// Особая сила behaviorRelay в том, что вы можете в любой момент запросить у него текущее значение.
// Эта возможность позволяет соединить императивный и реактивный миры полезным способом.
example(of: "BehaviorRelay") {
    
    // 1 - Вы создаете реле поведения (behaviorRelay) с начальным значением.
    // Тип relay выводится, но вы также можете явно объявить тип как BehaviorRelay<String>(value: "Initial value").
    let behaviorRelay = BehaviorRelay(value: "Initial Value")
    let disposeBag = DisposeBag()
    
    // 2 - Добавьте новый элемент к relay.
    behaviorRelay.accept("New Initial Value")
    
    // 3 - Подпишитесь на relay.
    behaviorRelay
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    /* output
     --- Example of: BehaviorRelay ---
     1) New Initial Value
     Note: Подписчик получает последнее значение
     */
    
    // 1 - Добавляем новый элемент в relay
    behaviorRelay.accept("1")
    
    // 2 - Создаём нового подписчика на relay
    behaviorRelay
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    
    // 3 - Добавляем ещё один элемент в relay
    behaviorRelay.accept("2")
    
    /* output
     --- Example of: BehaviorRelay ---
     1) New Initial Value
     1) 1
     2) 1
     1) 2
     2) 2
     
     Существующая подписка 1) получает новое значение 1, добавленное в relay.
     Новая подписка получает это же значение, когда она подписывается, потому что это самое последнее значение.
     И обе подписки получают значение 2, когда оно добавляется в реле
     */
    
    print(behaviorRelay.value)
    // output - 2
    // это последнее добавленное значение в relay
     
    // BehaviorRelays универсальны.
    // Вы можете подписаться на них, чтобы иметь возможность реагировать на каждое новое следующее событие, как и на любой другой subject.
    // Кроме того, они могут удовлетворять разовые потребности, например, когда вам нужно просто проверить текущее значение без подписки на получение обновлений.
}

 
example(of: "tattoo") {
    /*
     if success {
        enjoy
     } else {
        try
     }
     */
}

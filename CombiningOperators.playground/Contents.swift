import Foundation
import RxSwift
import RxRelay

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}
  

    // MARK: - Prefixing and concatenating

example(of: "startWith") {
     
    let numbers = Observable.of(2, 3, 4)
     
    let observable = numbers.startWith(1)
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    /* output
     --- Example of: startWith ---
     1
     2
     3
     4
     */
}

example(of: "Observable.concat") {
    
    let first = Observable.of(1, 2, 3)
    let second = Observable.of(4, 5, 6)
    
    let observable = Observable.concat([first, second])
    
    observable
        .subscribe(onNext: { value in
            print(value)
        })
    
    /* output
     --- Example of: Observable.concat ---
     1
     2
     3
     4
     5
     6
     */
}

example(of: "concat") {
    
    let germanCities = Observable.of("Berlin", "Munich", "Frankfurt")
    let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")
    
    let observable = germanCities.concat(spanishCities)
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    /* output
     --- Example of: concat ---
     Berlin
     Munich
     Frankfurt
     Madrid
     Barcelona
     Valencia
     */
}

///# кложур, который мы передаём в `concatMap(_:)`, возвращает последовательность `Observable`,
///# на которую оператор сначала подписывается, а затем передает значения, которые она выдает,
///# в результирующую последовательность.
///# `concatMap(_:)` гарантирует, что каждая последовательность, которую создает закрытие,
///# выполняется до конца, прежде чем подписываться на следующую.
example(of: "concatMap") {
     
    let sequences = [
        "German cities": Observable.of("Berlin", "Munich", "Frankfurt"),
        "Spanish cities": Observable.of("Madrid", "Barcelona", "Valencia")
    ]
    
    // 1 - последовательность выдает названия стран,
    //     каждая из которых в свою очередь отображается на последовательность, выдающую названия городов для этой страны.
    let observable = Observable.of("German cities", "Spanish citise")
        .concatMap { country in sequences[country] ?? .empty() }
    
    // 2 - выводит полную последовательность для данной страны, прежде чем приступить к рассмотрению следующей
    _ = observable.subscribe(onNext: { string in
        print(string)
    })
    
    /* output
     --- Example of: concatMap ---
     Berlin
     Munich
     Frankfurt
     */
}

    // MARK: - Merging
    // RxSwift предлагает несколько способов объединения последовательностей.
    // Самым простым для начала является merge.
example(of: "merge") {
     
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    // 1 - создаём наблюдателя наблюдателей
    let source = Observable.of(left.asObservable(), right.asObservable())
    
    // 2 - создаём объединяемую наблюдаемую из двух объектов, а также подписку для печати значений
    let observable = source.merge()
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    // 3 - затем нужно случайным образом выбрать и вставить значения в одну из наблюдаемых.
    //     цикл использует все значения из массивов leftValues и rightValues, затем выходит из цикла.
    var leftValues = ["Berlin", "Munich", "Frankfurt"]
    var rightValues = ["Madrid", "Barcelona", "Valencia"]
    repeat {
        switch Bool.random() {
        case true where !leftValues.isEmpty:
            left.onNext("Left: " + leftValues.removeFirst())
        case false where !rightValues.isEmpty:
            right.onNext("Right: " + rightValues.removeFirst())
        default:
            break
        }
    } while !leftValues.isEmpty || !rightValues.isEmpty
     
    left.onCompleted()
    right.onCompleted()
    
    /* output(random)
     --- Example of: merge ---
     Left: Berlin
     Right: Madrid
     Left: Munich
     Right: Barcelona
     Left: Frankfurt
     Right: Valencia
     */
    
    ///# `merge()` observable подписывается на каждую из полученных им последовательностей
    ///# и выдает элементы по мере их поступления - нет никакого предопределенного порядка.
}

example(of: "combineLatest") {
    
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    // 1 - создаём наблюдаемую, которая объединяет последние значения из обоих источников
    let observable = Observable.combineLatest(left, right) {
        lastLeft, lastRight in
        "\(lastLeft) \(lastRight)"
    }
    
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    // 2 - передаём значения наблюдателю
    print("> Sending a value to Left")
    left.onNext("Hello,")
    print("> Sending a value to Right")
    right.onNext("world")
    print("> Sending another value to Right")
    right.onNext("RxSwift") /// в left уже хранится "Hello,"
    print("> Sending another value to Left")
    left.onNext("Have a good day,") /// в right всё ещё хранится "RxSwift"
    
    left.onCompleted()
    right.onCompleted()
    
    /* output
     --- Example of: combineLatest ---
     > Sending a value to Left
     > Sending a value to Right
        Hello, world
     > Sending another value to Right
        Hello, RxSwift
     > Sending another value to Left
        Have a good day, RxSwift
     */
    
    ///# Note: Нужно помнить, что `combineLatest(_:_:resultSelector:)` ждет, пока все его наблюдаемые испустят по одному элементу,
    ///# прежде чем начать вызывать кложур.
    ///# Это частый источник путаницы и хорошая возможность использовать оператор `startWith(_:)`,
    ///# чтобы обеспечить начальное значение для последовательностей, которые могут не сразу выдать значение.
}

example(of: "combine user choise and value") {
    
    let choise: Observable<DateFormatter.Style> = Observable.of(.short, .long)
    let dates = Observable.of(Date())
    
    let observable = Observable.combineLatest(choise, dates) {
        format, when -> String in
        let formatter = DateFormatter()
        formatter.dateStyle = format
        return formatter.string(from: when)
    }
    
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    /* output
     --- Example of: combine user choise and value ---
     7/7/22
     July 7, 2022
     */
    
    ///# Note: `combineLatest` завершается только тогда, когда завершается последняя из его внутренних последовательностей.
    ///# До этого она продолжает посылать комбинированные значения.
    ///# Если некоторые последовательности завершаются, он использует последнее переданное
    ///# значение для объединения с новыми значениями из других последовательностей.
}

example(of: "zip") {
    
    enum Weather {
        case cloudy
        case sunny
    }
    
    let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
    let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")
    
    let observable = Observable.zip(left, right) { weather, city in
        return "It's \(weather) in \(city)"
    }
    
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    /* output
     --- Example of: zip ---
     It's sunny in Lisbon
     It's cloudy in Copenhagen
     It's cloudy in London
     It's sunny in Madrid
     */
    
    ///# Почему не отобразилась `Vienna` ?
    ///# Объяснение кроется в том, как работают операторы `zip`
    ///# Они сопоставляют каждое следующее значение каждой наблюдаемой величины в одной и
    ///# той же логической позиции (1-е с 1-м, 2-е со 2-м и т.д.).
    ///# Это означает, что если в следующей логической позиции нет следующего значения одной из
    ///# внутренних наблюдаемых (т.е. потому что она завершилась, как в примере выше), `zip` больше не будет ничего выдавать.
    ///# Это называется `индексированным секвенированием(indexed sequencing)`,
    ///# которое представляет собой способ последовательного прохождения последовательностей
}

    // MARK: - Triggers

example(of: "withLatestFrom") {
     
    let button = PublishSubject<Void>()
    let textField = PublishSubject<String>()
     
    let observable = button.withLatestFrom(textField)
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
     
    textField.onNext("Par")
    textField.onNext("Pari")
    textField.onNext("Paris")
    button.onNext(()) // 1
    button.onNext(()) // 2
    
    /* output
     --- Example of: withLatestFrom ---
     Paris
     Paris
     */
    
    ///# `withLatestFrom(_:)` полезен во всех ситуациях, когда вы хотите,
    ///# чтобы текущее (последнее) значение испускалось из наблюдаемой,
    ///# но только когда происходит определенный триггер. 
}

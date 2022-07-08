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

    // MARK: - Switches

///# `amb(_:)` и `switchLatest()`.
///# Они оба позволяют вам создавать наблюдаемую последовательность путем переключения между
///# событиями объединенных или исходных последовательностей.
///# Это позволяет вам решать, события какой последовательности будет получать подписчик во время выполнения.
example(of: "amb") {
    
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let observable = left.amb(right)
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    left.onNext("Lisbon")
        right.onNext("Copenhagen")
    left.onNext("London")
    left.onNext("Madrid")
        right.onNext("Vienna")
    
    left.onCompleted()
    right.onCompleted()
    
    /* output
     --- Example of: amb ---
     Lisbon
     London
     Madrid
     */
    
    ///# `amb(_:)` подписывается на левую и правую наблюдаемые.
    ///# Он ждет, пока одна из них не передаст элемент, затем отписывается от другой.
    ///# После этого он передает элементы только от первой активной наблюдаемой.
    ///# Его название действительно происходит от термина `ambiguous`:
    ///# сначала вы не знаете, какая последовательность вас интересует, и хотите решить, когда сработает только одна из них.
    
    ///# Этот оператор часто упускают из виду.
    ///# У него есть несколько отдельных практических применений, например,
    ///# подключение к дублирующим серверам и выбор того, который отвечает первым.
}

example(of: "switchLatest") {
    
    let one = PublishSubject<String>()
    let two = PublishSubject<String>()
    let three = PublishSubject<String>()
    
    let source = PublishSubject<Observable<String>>()
    
    let observable = source.switchLatest()
    let disposable = observable.subscribe(onNext: { value in
        print(value)
    })
    
    source.onNext(one)
    one.onNext("Some text from sequence one")
        two.onNext("Some text from sequence two")
    
    source.onNext(two)
        two.onNext("More text from sequence two")
    one.onNext("and also from sequence one")
    
    source.onNext(three)
        two.onNext("Why don's you see me?")
    one.onNext("I'm alone, help me")
            three.onNext("Hey it's three. I win.")

    source.onNext(one)
    one.onNext("Nope. It's me, one!")
    
    disposable.dispose()
    
    /* output
     --- Example of: switchLatest ---
     Some text from sequence one
     More text from sequence two
     Hey it's three. I win.
     Nope. It's me, one!
     */
    
    ///# подписка печатает только элементы из последней последовательности,
    ///# помещенной в исходную наблюдаемую.
    ///# Это и есть цель `switchLatest()`
}

example(of: "reduce") {
    
    let source = Observable.of(1, 3, 5, 7, 9)
    
    ///# сокращённая форма:
    ///# `let observable = source.reduce(0, accumulator: +)`
    ///# полная форма:
    let observable = source.reduce(0) { summary, newValue in
        return summary + newValue
    }
    ///# Оператор "накапливает" суммарное значение.
    ///# Он начинает с начального значения, которое вы предоставили (в этом примере вы начинаете с 0).
    ///# Каждый раз, когда исходная наблюдаемая выдает элемент, `reduce(_:_:)` вызывает ваше закрытие для получения нового итогового значения.
    ///# Когда исходная наблюдаемая завершается, `reduce(_:_:)` выдает итоговое значение, а затем завершает работу.
    
    ///# Примечание:
    ///# `reduce(_:_:)` выдает свое суммарное (накопленное) значение только тогда,
    ///# когда исходная наблюдаемая завершается.
    ///# Применение этого оператора к последовательностям, которые никогда не завершаются, ничего не выдаст.
    ///# Это частый источник путаницы и скрытых проблем.
    
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    /* output
     --- Example of: reduce ---
     25
     */
}


///# Близким аналогом `reduce(_:_:)` является оператор `scan(_:accumulator:)`
example(of: "scan") {
    
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let observable = source.scan(0, accumulator: +)
    _ = observable.subscribe(onNext: { value in
        print(value)
    })
    
    /* output
     --- Example of: scan ---
     1
     4
     9
     16
     25
     */
    
    ///# Вы получаете одно выходное значение на каждое входное значение.
    ///# Это значение - текущий итог, накопленный закрытием.
    ///# Каждый раз, когда исходная наблюдаемая испускает элемент, `scan(_:accumulator:)` вызывает ваше закрытие.
    ///# Оно передает текущее значение вместе с новым элементом, и закрытие возвращает новое накопленное значение.
    ///# Как и в `reduce(_:_:)`, результирующий тип наблюдаемой является возвращаемым типом закрытия.
    ///# Диапазон использования `scan(_:accumulator:)` довольно велик;
    ///# можно использовать его для вычисления текущих итогов, статистики, состояний и так далее.
    ///# Инкапсуляция информации о состоянии внутри наблюдаемой `scan(_:accumulator:)` - хорошая идея;
    ///# вам не понадобится использовать локальные переменные, и она исчезнет, когда исходная наблюдаемая завершится.
}

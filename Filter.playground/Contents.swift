import Foundation
import RxSwift
import RxRelay

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}
 
    // MARK: - Ignoring operators

///# игнорирует элементы, но пропускает события остановки `completed or error`
example(of: "ignoreElements") {
    // 1 - создаем "strikes" subject
    let strikes = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    
    // 2 - подписываемся на все события strikes
    //     но игнорируем все следующие события
    //     используя ignoreElements
    strikes
        ///# `ignoreElements` полезен, когда вы хотите получать уведомления только
        ///# о завершении работы наблюдаемого объекта по событию завершения или ошибки.
        .ignoreElements()
        .subscribe { _ in
            print("You're out")
        }
        .disposed(by: disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
    
    strikes.onCompleted()
    /* output
     --- Example of: ignoreElements ---
     You're out
     */
}

example(of: "elementAt") {
    
    // 1 - создаем subject
    let strikes = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    
    // 2 - подписываемся на next события, игнорируя все, кроме 3-го следующего события, находящегося в индексе 2
    strikes
        .element(at: 2)
        .subscribe(onNext: { _ in
            print("You're out")
        })
        .disposed(by: disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
    /* output
     --- Example of: ignoreElements ---
     You're out
     */
}

example(of: "filter") {
    
    let disposeBag = DisposeBag()
    
    // 1 - создаем observable из некоторых предопределенных целых чисел.
    Observable.of(1, 2, 3, 4, 5, 6)
        // 2 - filter для применения условного ограничения, чтобы предотвратить попадание нечетных чисел.
        .filter { $0.isMultiple(of: 2) }
        // 3 - подписываемся и распечатываем элементы, прошедшие предикат фильтрации.
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
        /* output
         --- Example of: filter ---
         2
         4
         6
         */
}

example(of: "skip") {
    
    let disposeBag = DisposeBag()
    
    Observable.of(1, 2, 3, 4, 5, 6)
    
        // Используйте skip, чтобы пропустить первые 2 элемента и подписаться на следующие события
        .skip(2)
        .subscribe(onNext: {
            print($0)
        })
    
        .disposed(by: disposeBag)
        /* output
         --- Example of: skip ---
         3
         4
         5
         6
         */
}

///# `skipWhile`(Как и `filter`) позволяет включать предикат для определения того, что будет пропущено.
///# Однако в отличие от `filter`, который фильтрует элементы в течение всего срока действия подписки,
///# `skipWhile` пропускает только до тех пор, пока что-то не будет пропущено, и с этого момента пропускает все остальное.
///# При использовании `skipWhile` возвращение true приводит к тому, что элемент пропускается,
///# а возвращение `false` пропускает его. Это противоположность `filter`
example(of: "skipWhile") {
    
    let disposeBag = DisposeBag()
    
    Observable.of(2, 2, 3, 4, 4)
    
        .skip(while: { $0.isMultiple(of: 2) }) // deprecated { $0.isMultiple(of: 2) }
        .subscribe(onNext: {
            print($0)
        })
    
        .disposed(by: disposeBag)
        /* output
         skip пропускает элементы только до первого соответствующего условию элемента,
         а затем пропускаются все оставшиеся элементы
         -
         --- Example of: skipWhile ---
         3
         4
         4
         */
}

///# до сего момента статически, далее динамически
///# `skipUntil`  будет продолжать пропускать элементы из исходной наблюдаемой
///# - той, на которую вы подписаны,
///# - до тех пор, пока не будет испущена какая-либо другая срабатывающая наблюдаемая
example(of: "skipUntil") {
    let disposeBag = DisposeBag()
    
    // 1 - создаем subject для моделирования данных,
    // с которыми будем работать,
    // и другой subject для работы в качестве триггера.
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    // 2 - используем skipUntil и передаем subject'y триггер.
    // когда триггер сработает, skipUntil перестанет пропускать.
    subject
        .skip(until: trigger)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    subject.onNext("A")
    subject.onNext("B")
    
    // это заставляет skipUntil прекратить пропуск.
    // С этого момента все элементы пропускаются.
    trigger.onNext("X")
    
    subject.onNext("C")
}

///# `Taking Operators`
///# `take` - это противоположность пропуску.
///# Когда вы хотите взять элементы, `RxSwift` поможет вам в этом.
///# Первый оператор - это take, который, берет первый из указанного вами количества элементов.
example(of: "take") {
    
    let disposeBag = DisposeBag()
    
    // 1 - создаем наблюдаемое число целых чисел
    Observable.of(1, 2, 3, 4, 5, 6)
        // 2 - берём первые 3 элемента с помощью функции take.
        .take(3)
        .subscribe(onNext: {
            print($0)
        })
    
        .disposed(by: disposeBag)
    /* output
     --- Example of: take ---
     1
     2
     3
     */
}

///# Оператор `takeWhile` работает аналогично оператору `skipWhile`, только вместо skip вы take.
///# Кроме того, если вы хотите ссылаться на индекс испускаемого элемента, вы можете использовать оператор `enumerated`.
///# Он выдает кортежи, содержащие индекс и элемент каждого испускаемого элемента из наблюдаемой,
///# аналогично тому, как работает метод `enumerated` в стандартной библиотеке Swift.
example(of: "takeWhile") {
    
    let disposeBag = DisposeBag()
    
    // 1 - создаем наблюдаемое число целых чисел
    Observable.of(2, 2, 4, 4, 6, 6)
    
         // 2 - оператор enumerated для получения кортежей, содержащих индекс и значение каждого испускаемого элемента.
        .enumerated()
    
         // 3 - используем оператор takeWhile и разбиваем кортеж на отдельные аргументы.
        .take(while: { index, integer in
            
            // 4 - передаем предикат, который будет принимать элементы до тех пор, пока условие не выполнится.
            integer.isMultiple(of: 2) && index < 3
        })
    
        // 5 - используем map чтобы войти в кортеж, возвращенный оператором takeWhile, и получить элемент
        .map(\.element)
    
        // 6 - подписываемся на следующие элементы и выводим их.
        .subscribe(onNext: {
            print($0)
        })
    
        .disposed(by: disposeBag)
        /* output
         В результате получаем элементы только до тех пор,
         пока целые числа четные, вплоть до того момента,
         когда индекс элемента равен 3 или больше
         --- Example of: takeWhile ---
         2
         2
         4
         */
}

///# В отличие от оператора takeWhile, существует оператор takeUntil, который берет элементы до тех пор, пока не будет выполнен предикат.
///# Он также принимает в качестве первого параметра аргумент behavior, который указывает,
///# нужно ли включать или исключать последний элемент, соответствующий предикату.
example(of: "takeUntil") {
    
    let disposeBag = DisposeBag()
     
    Observable.of(1, 2, 3, 4, 5)
        // 1 - используем оператор takeUntil с инклюзивным поведением.(inclusive - включает последний элемент, соответствующий предикату)
        .take(until: { $0.isMultiple(of: 4) }, behavior: .exclusive) // deprecated .takeUntil(.inclusive) { $0.isMultiple(of: 4) }
        .subscribe(onNext: {
            print($0)
        })
    
        .disposed(by: disposeBag)
    
    /* output .inclusive                        output .exclusive
     --- Example of: takeUntil ---              --- Example of: takeUntil ---
     1                                          1
     2                                          2
     3                                          3
     4
     */
}

example(of: "takeUntil trigger") {
    
    let disposeBag = DisposeBag()
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    // 2 - используем takeUntil, передавая trigger, который заставит takeUntil прекратить прием, как только он испустит сигнал.
    subject
        .take(until: trigger)
        .subscribe(onNext: {
            print($0)
        })
    
        .disposed(by: disposeBag)
     
    subject.onNext("1")
    subject.onNext("2")
    
    /* output before trigger
     --- Example of: takeUntil trigger ---
     1
     2
     Элементы будут выведены на печать,
     так как takeUntil находится в режиме принятия.
     */
    
    trigger.onNext("X")
    
    subject.onNext("3")
    
    /* output with trigger
     --- Example of: takeUntil trigger ---
     1
     2
     X останавливает принятие, поэтому 3 не пропускается и больше ничего не печатается.
     */
}

///# Операторы различия
///# Следующая пара операторов позволяет предотвратить прохождение дубликатов смежных элементов.
example(of: "distinctUntilChanged") {
    
    let disposeBag = DisposeBag()
    
    Observable.of("A", "A", "B", "B", "A")
        ///# 1 - используем distinctUntilChanged, чтобы предотвратить прохождение !!! `последовательных` !!! дубликатов
        .distinctUntilChanged()
        .subscribe(onNext: {
            print($0)
        })
    
        .disposed(by: disposeBag)
    
    /* output
     --- Example of: distinctUntilChanged ---
     A
     B
     A
     -
     Оператор distinctUntilChanged предотвращает только последовательные дубликаты,
     поэтому второй A и второй B не пропускаются,
     поскольку они равны своему предыдущему элементу.
     Однако третий A пропускается, поскольку он не равен своему предыдущему элементу.
     */
}

///# `distinctUntilChanged(_:)` для создания собственной логики проверки на равенство -  параметр, который вы передаете, является сравнивающим
example(of: "distinctUntilChanged") {
    
    let disposeBag = DisposeBag()
    
    // 1 - форматер чисел, чтобы прописать каждое число.
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    // 2 - создаём наблюдаемую переменную NSNumbers вместо Ints,
    //     чтобы вам не пришлось преобразовывать целые числа при последующем использовании форматера
    Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
        // 3 - используем distinctUntilChanged(_:), который принимает предикат closure, получающий каждую последовательную пару элементов.
        .distinctUntilChanged { a, b in
            // 4 - guard для условного связывания компонентов элемента, разделенных пустым пробелом
            guard let aWords = formatter
                .string(from: a)?
                .components(separatedBy: " "),
                  let bWords = formatter
                .string(from: b)?
                .components(separatedBy: " ")
            else { return false }
         
            var containsMatch = false
            
            // 5 - итерация каждого слова в первом массиве и проверка, содержится ли оно во втором массиве
            for aWord in aWords where bWords.contains(aWord) {
                containsMatch = true
                break
            }
            
            return containsMatch
        }
     
        .subscribe(onNext: {
            // 6 - выписываем и распечатываем элементы,
            //     которые считаются различными на основе предоставленной вами логики сравнения
            print($0)
        })
    
        .disposed(by: disposeBag)
    
        /* output
         В результате печатаются только отдельные целые числа, с учетом того,
         что в каждой паре целых чисел одно не содержит ни одного из слов-компонентов другого.
     
         --- Example of: distinctUntilChanged ---
         10
         20
         200
         */
    
    ///# Оператор `distinctUntilChanged(_:)` также полезен,
    ///# когда вы хотите однозначно предотвратить дублирование для типов, которые не соответствуют `Equatable`
}

import Foundation
import RxSwift
import RxRelay

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}
 
    // MARK: - Transforming Operators
 
example(of: "toArray") {
    
    let disposeBag = DisposeBag()
     
    Observable.of("A", "B", "C")
    // 2 - используем toArray для преобразования отдельных элементов в массив.
        .toArray()
        .subscribe(onSuccess: {
            print($0)
        })
    
        .disposed(by: disposeBag)
    
    /* output
     --- Example of: toArray ---
     ["A", "B", "C"]
     */
}

///# Оператор `map` в RxSwift работает так же, как и стандартный `map` в Swift,
///# за исключением того, что он оперирует наблюдаемыми
example(of: "map") {
    
    let disposeBag = DisposeBag()
    
    // 1 - formatter чисел для написания каждого числа
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    // formatter.locale = Locale(identifier: "ru_Ru")
    
    // 2 - наблюдаемая переменная Int.
    Observable<Int>.of(123, 4, 56)
    
        // 3 - используем map, передавая кложур, который получает и возвращает результат использования форматера
        //     для возврата String с написанным числом - или пустую строку, если эта операция возвращает nil.
        .map {
            formatter.string(for: $0) ?? ""
        }
        .subscribe(onNext: {
            print($0)
        })
    
        .disposed(by: disposeBag)
    
    /* output
     --- Example of: map ---
     one hundred twenty-three
     four
     fifty-six
     */
}

example(of: "enumerated and map") {
    
    let disposeBag = DisposeBag()
     
    Observable.of(1, 2, 3, 4, 5, 6)
    
        // 1 - enumerated для создания кортежа пар из каждого элемента и его индекса.
        .enumerated()
    
        // 2 - map и разделите кортеж на отдельные аргументы.
        //     eсли индекс элемента больше 2, умножить его на 2 и вернуть : в противном случае вернуть его как есть.
        .map { index, integer in
            index > 2 ? integer * 2 : integer
        }
     
        .subscribe(onNext: {
            print($0)
        })
    
        .disposed(by: disposeBag)
}

///# Оператор `compactMap` - это комбинация операторов `map` и `filter`,
///# которая специально отфильтровывает значения `nil`, аналогично своему аналогу в стандартной библиотеке Swift
example(of: "compactMap") {
    
    let disposeBag = DisposeBag()
    
    // 1 - создаём наблюдаемую String?, которую оператор of выводит из значений
    Observable.of("To", "be", nil, "or", "not", "to", "be", nil)
    
        // 2 - compactMap, чтобы получить развернутое значение и отфильтровать nil.
        .compactMap { $0 }
    
        // 3 - toArray для преобразования наблюдаемой в Single, который выдает массив всех своих значений.
        .toArray()
    
        // 4 - map, чтобы соединить значения вместе, разделив их пробелом.
        .map { $0.joined(separator: " ") }
     
        .subscribe(onSuccess: {
            print($0)
        })
    
        .disposed(by: disposeBag)
    
    /* output
     --- Example of: compactMap ---
     To be or not to be
     */
}

    // MARK: - Transforming inner observables

struct Student {
    let score: BehaviorSubject<Int>
}
 
/*
 -----(O1)-------(O2)---------(O3)---------------|-->
       ↓          ↓            ↓
     [     flatMap { $0.value    ]
       ↓--(1)-----|------------|-------(4)-------|-->
           |      ↓---(2)------|--------|---(5)--|-->
           |           |       ↓---(3)--|----|---|-->
           ↓           ↓            ↓   ↓    ↓
 ---------(1)---------(2)----------(3)-(4)--(5)--|-->
 */

///# Самый простой способ проследить, что происходит на этой диаграмме -
///# проследить каждый путь от исходной наблюдаемой в верхней строке до целевой наблюдаемой в нижней строке,
///# которая будет доставлять элементы подписчику.

///# Исходная наблюдаемая представляет собой тип объекта со свойством `value`,
///# которое само является наблюдаемой типа `Int`.
///# Начальным значением свойства `value` является номер объекта,
///# то есть начальное значение O1 равно 1, O2 - 2, а O3 - 3.

///# Начиная с O1, `flatMap` получает объект и проецирует его свойство `value` на новую наблюдаемую,
///# созданную только для O1 на 1-й строке ниже `flatMap`
///# Затем эта наблюдаемая сплющивается вниз до целевой наблюдаемой в нижней строке.

///# Позже свойство значения O1 изменяется на 4.
///# Это не представлено визуально на мраморной диаграмме.
///# Однако свидетельством того, что значение O1 изменилось, является то,
///# что оно проецируется на существующую наблюдаемую для O1,
///# а затем сплющивается вниз до целевой наблюдаемой.

///# Следующее значение в исходной наблюдаемой, O2, поступает на `flatMap`
///# Его начальное значение 2 проецируется на новую наблюдаемую для O2,
///# а затем спускается вниз до целевой наблюдаемой.
///# Позже значение O2 изменяется на 5.
///# Затем это значение проецируется и сплющивается до целевой наблюдаемой.

///# Наконец, O3 поступает на `flatMap`, его начальное значение 3 проецируется и спускается.

///# NOTE: `flatMap` проецирует и преобразует значение наблюдаемой как наблюдаемое, а затем сглаживает его до целевой наблюдаемой
 
example(of: "flatMap") {
    
    let disposeBag = DisposeBag()
    
    // 1 - создаём два экземпляра Student: laura и charlotte.
    let laura = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 90))
    
    // 2 - создаём исходный объект типа Student
    let student = PublishSubject<Student>()
    
    // 3 - используем flatMap, чтобы обратиться к предмету student и вывести его оценку
    student
        .flatMap {
            $0.score
        }
    
        // 4 - выводим следующие элементы событий в подписке.
        .subscribe(onNext: {
            print($0)
        })
    
        .disposed(by: disposeBag)
    
    student.onNext(laura)
    /* output
     --- Example of: flatMap ---
     80
     */
    
    laura.score.onNext(85)
    /* output
     --- Example of: flatMap ---
     85
     */
    
    student.onNext(charlotte)
    /* output
     --- Example of: flatMap ---
     90
     */
    
    laura.score.onNext(95)
    /* output laura's new score
     --- Example of: flatMap ---
     95
     */
    ///# Это происходит потому, что `flatMap` поддерживает каждую создаваемую им наблюдаемую,
    ///# по одному для каждого элемента, добавленного к исходной наблюдаемой
    
    charlotte.score.onNext(100)
    /* output charlotte's new score
     --- Example of: flatMap ---
     100
     */
    
    ///# `flatMap` продолжает проецировать изменения из каждой наблюдаемой.
    ///# Note: Однако, когда вы хотите отслеживать только последний элемент в исходной наблюдаемой, используйте оператор `flatMapLatest`
    ///# Оператор `flatMapLatest` фактически является комбинацией двух операторов: `map` и `switchLatest`
    ///# Кратко: - `switchLatest` будет получать значения из самой последней наблюдаемой и отписываться от предыдущей наблюдаемой.
    ///# Из документации по `flatMapLatest`:
    ///# Проецирует каждый элемент наблюдаемой последовательности в новую последовательность наблюдаемых последовательностей,
    ///# а затем преобразует наблюдаемую последовательность наблюдаемых последовательностей в наблюдаемую последовательность,
    ///# производящую значения только из самой последней наблюдаемой последовательности
}

///# `flatMapLatest` работает так же, как и `flatMap`
///# чтобы добраться до элемента наблюдаемой, получить доступ к его свойству наблюдаемой и
///# спроецировать его на новую последовательность для каждого элемента исходной наблюдаемой.
///# Эти элементы сплющиваются в целевую наблюдаемую, которая будет предоставлять элементы подписчику.
///# Отличие `flatMapLatest` заключается в том,
///# что он автоматически переключается на последнюю наблюдаемую и отписывается от предыдущей.
example(of: "flatMapLatest") {
    
    let disposeBag = DisposeBag()
     
    let laura = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 90))
    
    let student = PublishSubject<Student>()
     
    student
        .flatMapLatest {
            $0.score
        }
     
        .subscribe(onNext: {
            print($0)
        })
    
        .disposed(by: disposeBag)
    
    student.onNext(laura)
    laura.score.onNext(85)
    student.onNext(charlotte)
    
    // 1
    laura.score.onNext(95)
    charlotte.score.onNext(100)
    
    /* output
     Изменение оценки Лауры здесь не будет иметь никакого эффекта.
     Он не будет распечатан.
     Это потому, что flatMapLatest переключился на последнюю наблюдаемую, для Шарлотты:
     --- Example of: flatMapLatest ---
     80
     85
     90
     100
     */
    
    ///# Удобно например когда пользователь в поиске набирает каждую букву, s, w, i, f, t,
    ///# вы хотите выполнить новый поиск и игнорировать результаты предыдущего.
}
 
    // MARK: - Observing events

///# Иногда вам может понадобиться преобразовать наблюдаемую в наблюдаемую событий.
///# Один из типичных сценариев, когда это полезно:
///# - когда у вас нет контроля над наблюдаемой, имеющей наблюдаемые свойства,
///# и вы хотите обрабатывать события ошибок, чтобы избежать прерывания внешних последовательностей.
example(of: "materialize and dematerialize") {
    
    enum MyError: Error {
        case anError
    }
    
    let disposeBag = DisposeBag()
    
    // 1 - создаём два экземпляра Student и behaviorSubject с первым студентом laura в качестве начального значения.
    let laura = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 100))
    
    let student = BehaviorSubject(value: laura)
    
    // 2 - создаём наблюдаемую studentScore, используя flatMapLatest,
    //     чтобы обратиться к наблюдаемой student и получить доступ к ее наблюдаемому свойству score.
    let studentScore = student
        .flatMapLatest {
            $0.score // previous: $0.score
        }
    
    // 3 - подписываемся на каждый score и распечатываем его при выдаче.
    studentScore
        .subscribe(onNext: {
            print($0)
        })
    
        .disposed(by: disposeBag)
    
    // 4 - добавляем score, error и еще одну score к текущему студенту.
    laura.score.onNext(85)
    laura.score.onError(MyError.anError)
    laura.score.onNext(90)
    
    // 5 - добавляем вторую студентку Шарлотту в наблюдаемую студента.
    //     поскольку мы использовали flatMapLatest, это переключится на новую студентку и подпишется на ее оценку.
    student.onNext(charlotte)
    
    /* output without .materialize()
     --- Example of: materialize and dematerialize ---
     80
     85
     /* Эта ошибка не обрабатывается. Наблюдаемая studentScore завершается, как и внешняя наблюдаемая student */
     Unhandled error happened: anError
     */
}

example(of: "materialize and dematerialize 'continue'") {
    
    enum MyError: Error {
        case anError
    }
    
    let disposeBag = DisposeBag()
     
    let laura = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 100))
    
    let student = BehaviorSubject(value: laura)
     
    let studentScore = student
        .flatMapLatest {
            $0.score.materialize() // previous: $0.score
        }
     
    ///# Однако теперь вы имеете дело с событиями, а не с элементами.
    ///# Вот тут-то и приходит на помощь дематериализация.
    ///# Она преобразует материализованный наблюдаемый объект обратно в его первоначальную форму.
    studentScore
        
        // 1 - печатаем и фильтруем все ошибки
        .filter {
            guard $0.error == nil else {
                print($0.error!)
                return false
            }
            
            return true
        }
    
        // 2 - используем dematerialize, чтобы вернуть наблюдаемую studentScore к ее первоначальной форме,
        //     испуская оценки и события остановки, а не события оценки и события остановки.
        .dematerialize()
        .subscribe(onNext: {
            print($0)
        })
    
        .disposed(by: disposeBag)
    
    laura.score.onNext(85)
    laura.score.onError(MyError.anError)
    laura.score.onNext(90)
     
    student.onNext(charlotte)
    
    /*
     output with .materialize()
     --- Example of: materialize and dematerialize ---
     next(80)
     next(85)
     error(anError)
     next(100)
     
     output with .dematerialize()
     --- Example of: materialize and dematerialize 'continue' ---
     80
     85
     anError
     100
     */
}


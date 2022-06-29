import Foundation
import RxSwift

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}

// MARK: - just, of, from

example(of: "just, of, from") {
    // 1 - Определите целочисленные константы, которые вы будете использовать в следующих примерах
    let one = 1
    let two = 2
    let three = 3
    
    // 2 - Создайте наблюдаемую последовательность типа Int, используя метод just с одной целочисленной константой.
    let observable = Observable<Int>.just(one)
    /*
     Метод `just` точно назван, потому что все, что он делает, это создает наблюдаемую последовательность, содержащую только `один` элемент.
     Это статический метод  Observable.
     Однако в Rx методы называются "операторами". И орлиные глазки среди вас, вероятно, могут угадать, какого оператора вы собираетесь проверить дальше.
     */
    let observable2 = Observable.of(one, two, three) // type Int
    let observable3 = Observable.of([one, two, three]) // type [Int]
    let observable4 = Observable.from([one, two, three]) // from принимает только массив
    
    print(type(of: observable), type(of: observable2), type(of: observable3), type(of: observable4))
}

// MARK: - subscribe

example(of: "subscribe") {
    let one = 1
    let two = 2
    let three = 3
    
    let observable = Observable.of(one, two, three)
    
    observable.subscribe { event in
        print(event)
    }
    /*
     `output`
     --- Example of: subscribe ---
     next(1)
     next(2)
     next(3)
     completed
     */
    
    observable.subscribe { event in
        if let element = event.element {
            print(element)
        }
        ///`output` \n 1 \n 2 \n 3
    }
    
    // В обработке только следующие элементы события и игнорируете все остальное.
    // Закрытие onNext получает элемент следующего события в качестве аргумента, поэтому вам не нужно вручную извлекать его из события, как вы это делали раньше.
    observable.subscribe(onNext: { element in
        print(element)
    })
    ///`output` \n 1 \n 2 \n 3
}


// MARK: - empty

// Теперь вы знаете, как создать наблюдаемый один элемент и многие элементы.
// Но как насчет наблюдаемого нулевого элемента? Оператор empty создает пустую наблюдаемую последовательность с нулевыми элементами;
// он выдаёт только завершенное событие.
example(of: "empty") {
    let observable = Observable<Void>.empty()
    
    observable.subscribe(
        /// 1 - Обрабатывайте `next` события, как и в предыдущем примере.
        onNext: { element in
            print(element)
        },
        
        /// 2 - Просто распечатайте сообщение, потому что событие `.completed` не включает в себя элемент.
        onCompleted: {
            print("Completed")
            /// `output` --- Example of: empty --- \n Completed
        }
    )
}

// MARK: - never

// Какое использование является пустым наблюдаемым?
// Они удобны, когда вы хотите вернуть наблюдаемое, которое немедленно завершается или намеренно имеет нулевые значения.
// В отличие от пустого оператора, оператор never создает наблюдаемое, которое ничего не испускает и никогда не заканчивается.
// Его можно использовать для представления бесконечной продолжительности. Добавьте этот пример на свою игровую площадку:
example(of: "never") {
    let observable = Observable<Void>.never()
    
    observable.subscribe(
        onNext: { element in
            print(element)
        },
        onCompleted: {
            print("Completed")
            ///`output` Ничего не печатается, кроме заголовка примера. Даже `.completed`.
        }
    )
}

// MARK: - range

example(of: "range") {
    /// 1 - Создайте наблюдаемое с помощью оператора `range`, который принимает начальную целочисленную величину и количество последовательных целых чисел для генерации.
    let observable = Observable<Int>.range(start: 1, count: 10)
    
    observable
        .subscribe(onNext: { i in
            /// 2 - Вычислите и выведите `n-е` число Фибоначчи для каждого испускаемого элемента.
            let n = Double(i)
            
            let fibonacci = Int(
                ((pow(1.61803, n) - pow(0.61803, n)) /
                 2.23606).rounded()
            )
            print(fibonacci)
            /**`output`
             --- Example of: range ---
             0
             1
             2
             3
             5
             8
             13
             21
             34
             55
             */
        })
}

// MARK: - dispose

example(of: "dispose") {
    // 1 - Создайте наблюдаемые строки.
    let observable = Observable.of("A", "B", "C")
    
    // 2 - Подпишитесь на наблюдаемое, на этот раз экономя возвращенный Disposable в виде локальной константы, называемой подпиской.
    let subscription = observable.subscribe { event in
        // 3 - Распечатайте каждое испущенное событие в консоли.
        print(event)
    }
    
    // 4 - отписка
    subscription.dispose()
}

// MARK: - DisposeBag

example(of: "DisposeBag") {
    // 1 - создаём DisposeBag
    let disposeBag = DisposeBag()
    
    // 2 - Создайте наблюдаемое.
    Observable.of("A", "B", "C")
        .subscribe { // 3 - Подпишитесь на наблюдаемое и распечатайте испускаемые события, используя имя аргумента по умолчанию $0.
            print($0)
        }
        .disposed(by: disposeBag) // 4 - Отписка by DisposeBag, как добавить в корзину.
}

// MARK: - create

// Оператор `create` принимает один параметр с именем subscribe.
// Его работа заключается в обеспечении реализации призывной подписки на наблюдаемое.
// Другими словами, он определяет все события, которые будут переданы подписчикам.
// Если вы нажмете на кнопку "create" прямо сейчас, вы не получите документацию по быстрой справке, потому что этот код еще не будет скомпилирован.
// Итак, вот предварительный просмотр
example(of: "create") {
    
    enum MyError: Error {
        case anError
    }
    
    let disposeBag = DisposeBag()
    
    Observable<String>.create { observer in
        // 1 - Добавьте следующее событие наблюдателю. onNext(_:) - это удобный метод для on(.next(_:)).
        observer.onNext("1")
        
        /*
         остановился здесь по книге
         What would happen
         */
        observer.onError(MyError.anError)
        
        // 2 - Добавьте завершенное событие наблюдателю. Аналогично, onCompleted - это удобный метод для on(.completed).
        observer.onCompleted()
        
        // 3 - Добавьте еще одно следующее событие наблюдателю.
        observer.onNext("?")
        
        // 4 - Верните disposable, определив, что произойдет, когда ваш наблюдаемый будет прекращен или утилизирован;
        //     в этом случае очистка не требуется, поэтому вы возвращаете пустой disposable.
        return Disposables.create()
    }.subscribe(
        onNext: { print($0) },
        onError: { print($0) },
        onCompleted: { print("Completed") },
        onDisposed: { print("Disposed") }
    )
    .disposed(by: disposeBag)
    // Вы подписались на наблюдаемое и реализовали все обработчики,
    // используя имена аргументов по умолчанию для элементов и аргументов ошибок,
    // переданных обработчикам onNext и onError соответственно.
    // В результате распечатываются первый следующий элемент события, "Завершено" и "Удалено".
    // Второе следующее событие не печатается, потому что наблюдаемое испустило завершенное событие и завершилось до его добавления.
    // You subscribed to the observable, and implemented all the handlers
    // using default argument names for element and error arguments
    // passed to the onNext and onError handlers, respectively.
    // The result is, the first next event element, "Completed" and "Disposed" are printed out.
    // The second next event is not printed because the observable emitted a completed event and terminated before it is added.
}

// MARK: - deffered

// Вместо того, чтобы создавать наблюдателя, который ждет подписчиков,
// можно создать наблюдаемые фабрики, которые передадут нового наблюдателя каждому подписчику.
example(of: "deferred") { /// Возвращает наблюдаемую последовательность, которая вызывает указанную фабричную функцию всякий раз, когда подписывается новый наблюдатель.
    let disposeBag = DisposeBag()
    
    // 1 - Создайте флаг Bool для переключения возвращаемой наблюдаемой.
    var flip = false
    
    // 2 - Создайте наблюдаемую фабрику Int, используя оператор отсрочки.
    let factory: Observable<Int> = Observable.deferred {
        
        // 3 - Переключение флипа, которое происходит каждый раз при подписке на фабрику.
        flip.toggle()
        
        // 4 - Возвращать разные наблюдаемые в зависимости от того, истинно или ложно переключение.
        if flip {
            return Observable.of(1, 2, 3)
        } else {
            return Observable.of(4, 5, 6)
        }
    }
    
    for _ in 0...3 {
        // Каждый раз, когда вы подписываетесь на фабрику, вы получаете противоположную наблюдаемую.
        // Другими словами, вы получаете 123, затем 456, и эта схема повторяется каждый раз, когда создается новая подписка:
        factory.subscribe(onNext: {
            print($0, terminator: "")
        })
        .disposed(by: disposeBag)
        
        print()
        /* output
         --- Example of: deferred ---
         123
         456
         123
         456
         */
    }
}

// MARK: - Traits | Single
/*
 Одиночные(Single) события выдают либо событие success(value), либо error(error).
 success(value) - это комбинация событий next и completed.
 Это полезно для одноразовых процессов, которые либо преуспеют и дадут значение, либо потерпят неудачу, например, при загрузке данных или загрузке с диска.
 
 Completable будет испускать только событие completed или error(ошибка).
 Он не будет выдавать никаких значений.
 Вы можете использовать Completable, когда вам важно только успешное или неудачное завершение операции, например, при записи файла.
 
 Наконец, Maybe - это объединение Single и Completable.
 Он может выдавать либо success(значение), либо completed, либо error(ошибка).
 Если вам нужно реализовать операцию, которая может быть либо успешной, либо неудачной, и по желанию возвращать значение при успехе, то Maybe - это ваш билет.
 */
example(of: "Single") {
    // 1 - Создаете пакет dispose для последующего использования.
    let disposeBag = DisposeBag()
    
    // 2 - Определите enum Error для моделирования некоторых возможных ошибок, которые могут возникнуть при чтении данных из файла на диске.
    enum FileReadError: Error {
        case fileNotFound, unreadable, encodingFailed
    }
    // 3 - Реализуете функцию для загрузки текста из файла на диске, которая возвращает Single.
    func loadText(from name: String) -> Single<String> {
        // 4 - Создайте и верните Single.
        return Single.create { single in
            // 1 - Создайте Disposable, поскольку закрытие subscribe функции create ожидает его в качестве возвращаемого типа.
            let disposable = Disposables.create()
            
            // 2 - Получите путь к имени файла, иначе добавьте ошибку "Файл не найден" в Single и верните созданный одноразовый файл.
            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                single(.failure(FileReadError.fileNotFound))
                return disposable
            }
            
            // 3 - Получить данные из файла по указанному пути, или добавить ошибку нечитаемости в Single и вернуть disposable.
            guard let data = FileManager.default.contents(atPath: path) else {
                single(.failure(FileReadError.unreadable))
                return disposable
            }
            
            // 4 - Преобразуйте данные в строку; в противном случае добавьте к Single ошибку "encoding failed" и верните disposable". Начинаете видеть здесь закономерность?
            guard let contents = String(data: data, encoding: .utf8) else {
                single(.failure(FileReadError.encodingFailed))
                return disposable
            }
            // 5 - Дошли до этого? Добавьте содержимое в Single в качестве успеха и верните одноразовый объект.
            single(.success(contents))
            return disposable
        }
    }
    
    // 1 - Вызовите loadText(from:) и передайте корневое имя текстового файла.
    loadText(from: "Copyright")
    // 2 - Подпишитесь на событие Single, которое оно возвращает.
        .subscribe {
            // 3 - Включите событие и выведите строку, если оно было успешным, или выведите ошибку, если нет.
            switch $0 {
            case .success(let string):
                print(string)
            case .failure(let error):
                print(error) // "file not found"
            }
        }
        .disposed(by: disposeBag)
    /* output
     --- Example of: Single ---
     fileNotFound
     */
}
























/*
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

example(of: "empty") {
    let observable = Observable<Void>.empty()
    
    observable.subscribe(
        onNext: { element in
            print(element)
        },
         
        onCompleted: {
            print("Completed")
        }
    )
}

example(of: "never") {
    let observable = Observable<Void>.never()
    
    observable.subscribe(
        onNext: { element in
            print(element)
        },
        onCompleted: {
            print("Completed")
        }
    )
}

example(of: "range") {
    let observable = Observable<Int>.range(start: 1, count: 10)
    
    observable
        .subscribe(onNext: { i in
            let n = Double(i)
            
            let fibonacci = Int(
                ((pow(1.61803, n) - pow(0.61803, n)) /
                 2.23606).rounded()
            )
            
            print(fibonacci)
        })
}
 
 */

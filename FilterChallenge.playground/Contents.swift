import Foundation
import RxSwift
import RxRelay

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}
  
/*
 Задача: Создание поиска по телефонному номеру
 Разбирая эту задачу, вам нужно будет использовать несколько операторов фильтрации.
 Вот требования, а также некоторые рекомендации:
 1. Телефонные номера не могут начинаться с 0 - используйте skipWhile.
 2. Каждый входной элемент должен быть однозначным числом - используйте фильтр, чтобы разрешить только элементы, количество которых меньше 10.
 3. Ограничивая этот пример телефонными номерами США, которые состоят из 10 цифр, возьмите только первые 10 цифр - используйте take и toArray.
 
 Примечание: оператор toArray возвращает Single, о котором вы узнали в главе 2, "Наблюдаемые элементы".
 Удобный синтаксис для подписки на Single - subscribe(onSuccess:onError:).
 Если вы хотите обрабатывать получение элемента только в случае успешной подписки на Single, реализуйте только обработчик onSuccess.
 */
 
example(of: "Challenge 1") {
    
    let disposeBag = DisposeBag()
    
    let contacts = [
        "603-555-1212": "Florent",
        "212-555-1212": "Shai",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
    ]
    
    func phoneNumber(from inputs: [Int]) -> String {
        var phone = inputs.map(String.init).joined()
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3)
        )
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7)
        )
        
        return phone
    }
    
    let input = PublishSubject<Int>()
     
    input
        .skip(while: { $0 == 0 })
        .filter({ $0 < 10 })
        .take(10)
        .toArray()
        .subscribe(onSuccess: {
            let phone = phoneNumber(from: $0)
            
            if let contact = contacts[phone] {
                print("Dialing \(contact) (\(phone))...")
            } else {
                print("Contact not found")
            }
        })
    
        .disposed(by: disposeBag)
         
     
    input.onNext(0)
    input.onNext(603)
    
    input.onNext(2)
    input.onNext(1)
    
    // Confirm that 7 results in "Contact not found",
    // and then change to 2 and confirm that Shai is found
    input.onNext(7)
    
    "5551212".forEach {
        if let number = (Int("\($0)")) {
            input.onNext(number)
        }
    }
    
    input.onNext(9)
    
    /* output onNext(7)                              output onNext(2)
     
     --- Example of: Challenge 1 ---                 --- Example of: Challenge 1 ---
     Contact not found                               Dialing Shai (212-555-1212)...
     */
}

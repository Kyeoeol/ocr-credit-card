# OCR: Credit Card

<br>

### Luhn’s Algorithm(룬 알고리즘)
- IBM의 Hans Peter Luhn가 발명했으며, 신용카드 번호 등 식별용 번호가 유효한지 확인하기 위한 알고리즘이다.
- 암호화 해시 함수처럼 악의적인 공격을 막기 위한 것이 아니라, 번호 오기입 등 우연한 실수를 방지하기 위해 고안되었다.
- 카드 종류에 따라 룬 알고리즘으로 유효성을 판별할 수 없는 경우도 있다.(ex. 삼성카드에서 발급한 법인카드)
     
> 1. 뒤에서 2번째 자리 숫자부터 시작해, 하나씩 건너뛰면서 2를 곱해준 뒤, 모든 digit을 합산한다. <br>
> (각 digit의 합산이므로 2를 곱한 결과가 12인 경우 12가 아닌 1과 2를 각각 더한다.)
> 2. 2로 곱하지 않은 모든 digit을 합산한다.
> 3. 총 합계의 마지막 자리가 0이라면(즉 합계 모듈로 10의 결과가 0이라면) 유효한 숫자이다.

 ```swift
 func isValidCardNumber(_ cardNumber: String?) -> Bool {
    guard let cardNumber else { return false }
    var sum = 0
    var alternate = false
    let reversedCardNumber = cardNumber.reversed().map { String($0) }
    
    for digit in reversedCardNumber {
        guard let value = Int(digit) else { return false }
        if alternate {
            sum += (value * 2 > 9) ? (value * 2 - 9) : (value * 2)
        } else {
            sum += value
        }
        alternate.toggle()
    }
    
    return sum % 10 == 0
}
 ```

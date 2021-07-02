# 🧮 계산기 프로젝트
**프로젝트 기간: 2021년 6월 21일 ~ 7월 2일**   
_with Coden, Jamking, vivi(Review)_
&nbsp;   

## Flow Chart

### 전체 흐름

![계산기 프로젝트-계산기](https://user-images.githubusercontent.com/39452092/123240550-5d3c5380-d51b-11eb-9b89-2c9887fe8911.png)

&nbsp;

### 계산 로직

![계산기 프로젝트-계산 수행 함수](https://user-images.githubusercontent.com/39452092/123240541-5c0b2680-d51b-11eb-93fe-e43c404896eb.png)

&nbsp;

### 그외 버튼 로직

![계산기 프로젝트-AC, CE함수](https://user-images.githubusercontent.com/39452092/123240535-5a416300-d51b-11eb-867a-4959b74b7d79.png)

&nbsp;

## UML

### STEP1 수행전

![계산기 프로젝트-UML](https://user-images.githubusercontent.com/39452092/123241001-bf955400-d51b-11eb-8695-6607a80a56bf.png)

&nbsp;

### STEP1 PR 이후

전체적으로 프로토콜과 타입이 많이 생겼다. 이 부분들을 반영하여 UML을 완전히 새로 다시 그려야 할 것 같다. 🥲
**Flow chart와 UML은 불변해야 하는 것이 아니라 코드를 작성하면서 같이 수정해 나가야 하는 것이라고 한다.**

&nbsp;

## STEP1 - Model 구현

### 📖 주요 학습 개념

* `Result<Success, Failure>`

  * 결과값을 처리하는 부분에 있어 Result 타입을 적용해 보았다

  ```swift
  @frozen public enum Result<Success, Failure> where Failure : Error {
      /// A success, storing a `Success` value.
      case success(Success)
      /// A failure, storing a `Failure` value.
      case failure(Failure)
  ```

  * Error 프로토콜을 채택한 타입만이 실패 케이스 연관값에 들어갈 수 있다.

&nbsp;

* 연관값을 추출해내는 방법

  * `Result`를 포함한 여러 열거형들은 연관값을 가질 수 있다.
  * 이 연관값을 얻어내는 방법에는 대표적으로 `switch-case`가 있다.
  * 모든 케이스를 다루지 않고 원하는 케이스의 연관값만 가져오고 싶은 경우 `pattern matching`을 사용하면 된다.

  ```swift
  enum Operator {
    case add(Double, Double)
    case subtract(Double, Double)
    case multiply(Double, Double)
    case divide(Double, Double)
  }
  
  let operatorType = Operator.add(10.0, 20.0)
  
  switch operatorType {
    case .add(let lhs, let rhs):
    	//...
  }
  
  guard case .add(let lhs, let rhs) = operatorType else {
    return
  }
  guard case let .add(lhs, rhs) = operatorType else {
    return
  }
  ```

  * `guard`뿐만 아니라 `if`도 가능하고 `for`도 가능하다.

  &nbsp;

* **중위표현식과 후위표현식, 그리고 스택**

  * 우리가 평소에 사용하는 계산식은 중위표현식 방식이다. 
    * 이항연산자 양쪽에 피연산자 두개가 위치하는 방식
  * 하지만 컴퓨터는 후위표현식 방법을 사용한다.
    * 컴퓨터는 연산자의 우선순위를 모르기 때문에 후위표현식 방법을 사용한다.
    * 후위표현식으로 표현된 식을 앞에서부터 순서대로 읽는 방식으로 수식을 계산한다.

  ```swift
  1 + 2 * 3	//우리가 사용하는 중위표현식
  1 2 3 * +	//컴퓨터가 위의 중위표현식을 제대로 계산하기 위한 후위표현식
  
  ```

  * **중위표현식에서 후위표현식으로**
    1. 입력값을 읽으면서 숫자가 나오면 후위표현식으로 바로 옮긴다.
    2. 입력값을 읽다가 연산자가 나오면 아래의 과정을 수행한다.
       * 연산자 스택이 비어있는 경우 스택에 바로 `push`한다.
       * 연산자 스택에 값이 있는 경우, 가장 상단의 연산자와 우선순위를 비교한다.
       * 만약 스택 상단의 연산자가 우선순위가 같거나 높으면 해당 스택 연산자를 `pop`해서 후위표현식으로 옮긴다.
         * 위의 과정은 반복될 수 있다.
       * 스택이 비게 되거나 현재 연산자가 우선순위가 더 높다면 그대로 `push`한다.
    3. 중위표현식을 모두 읽었다면 스택의 연산자들을 하나씩 `pop`하여 후위표현식에 옮겨준다.
  * **후위표현식을 계산**
    1. 후위표현식을 읽으면서 숫자가 나오면 스택에 `push`한다.
    2. 연산자가 나오는 경우 스택에서 값을 두번 `pop`하여 해당 연산자로 계산을 수행한다.
       * 먼저 나온 피연산자가 rhs이고 늦게 나온 피연산자가 lhs이다.
    3. 계산된 결과를 다시 스택에 `push`한다.
    4. 위의 과정들을 반복하면서 후위표현식을 모두 읽는다.
    5. 마지막 연산결과는 스택에 담겨있게 된다. 이 값이 후위표현식에 대한 최종 연산결과가 된다.
  * **`Stack`**
    * 대표적인 ADT(추상자료형) 중 하나이다. 
    * 후입선출(LIFO)이 특징이다.
    * 배열로 구현할 수도 있고 연결 리스트로 구현할 수도 있다.
    * 대표적 메소드로는 `push`, `pop`, `peek`, `isEmpty` 등이 있다.

&nbsp;

* **Unified Modeling Language**

  * 통합 모델링 언어라고 불리며 대표적으로 클래스 다이어그램, 시퀀스 다이어그램이 있다.

  * 클래스 다이어그램같은 경우 정적 다이어그램이며 클래스간의 의존, 연관, 일반화, 실체화 등의 관계를 표현할 수 있다.
    * *위에서 우리가 그렸던 것은 정적 다이어그램 중 클래스 다이어그램이다.*
  * 시퀀스 다이어그램은 동적 다이어그램이다. 
  * UML은 언제든 변경될 수 있다. 
  * UML은 코드를 설명하기 위한 수단 중 하나이다. 

  ![image](https://user-images.githubusercontent.com/39452092/124301826-52c52e00-db9b-11eb-82f1-97f0f6fba154.png)

  > 출처: [넥스트리 소프트](https://www.nextree.co.kr/p6753/)

&nbsp;

## STEP2 - Unit Test

### 📖 주요 학습 개념

* **Generic**

  * 여러 데이터 타입들을 한번에 다룰 수 있도록, 재사용성을 높여주는 문법이다.

  * 한마디로 범용타입!

  * 표준 라이브러리 대다수는 제네릭 문법을 사용하였다.

  * 제네렉 표기는 `Key`, `Value` `Element`, `T`, `U`, `V` 등이 있을 수 있다.

    * 타입 파라미터와 제네릭 타입 또는 함수가 연관이 있는 경우 `Key`, `Value`, `Element` 등을 쓰고 그렇지 않은 경우 다른 표기를 사용한다.

  * 프로토콜은 제네릭을 `associatedtype`을 이용하여 사용한다.

    ```swift
    protocol Container {
    	associatedtype Item
      func push(_ item: Item)
      func pop() -> Item
    }
    ```

    &nbsp;

* `SOLID`
  * **SRP - Single Responsibility Principle**
    * 하나의 클래스는 단 하나의 책임만을 수행해야 한다.
    * 응집도가 높고 결합도는 낮을수록 SRP를 잘 따른 것이 된다.
    * 나머지 원칙들의 근간이 되는 원칙
  * **OCP - Open-Closed Principle**
    * 확장에 대해 열려있고 수정에 대해 닫혀있다.
    * OCP를 준수하면 경직성이 줄어들고 안정적인 수정이 가능하다.
    * OCP는 추상화에 크게 의존한다.
  * **LSP - liskov substitution principle**
    * 자식객체는 부모객체의 역할을 완벽히 수행할 수 있어야 한다.
    * 추상화된 인터페이스 하나로 공통의 코드를 작성할 수 있다. (OCP를 가능하게 해주는 원칙)
    * LSP를 준수하지 못하는 대표적인 예 - 직사각형과 정사각형
  * **ISP - Interface Segregation Principle** 
    * 클라이언트는 필요로 하지 않는 기능에 의존해서는 안된다.
    * 큰 인터페이스는 작게 분할하여 클라이언트가 필요로 하는 것만 선택적으로 사용할 수 있게 해야한다.
    * 클라이언트란, 어떤 다른 객체를 사용하는 쪽을 일컫는다.
  * **DIP - Dependency Inversion Principle**
    * 추상화에 의존해야하고 구체화에 의존하면 안된다.
    * DIP의 목적은 모듈간의 의존관계를 끊는 방법을 제시하는 것이며, 변경사항이 다른 코드에 미치는 영향을 최소화하는 방법을 제시한다.
    * 상위모듈일수록 추상적이고 하위모듈일수록 구체적이다.

&nbsp;

* `Numeric`

  * 곱셈을 지원하는 값이 있는 타입
  * 덧셈과 뺄셈을 지원하는 값이 있는 타입인 `AdditiveArithmetic`를 상속받은 프로토콜
  * Numeric 타입형태로는 나눗셈이 불가능하다. (Floating Point는 가능)

  ```swift
  extension Sequence where Element: Numeric {
      func doublingAll() -> [Element] {
          return map { $0 * 2 }
      }
  }
  ```

&nbsp;

* 타입 제약조건
  * `<T: Numeric>`도 가능하지만 `where T: Numeric`도 가능하다.
  * 왼쪽의 방식은 상속이나 프로토콜의 채택에 대한 제약조건만을 설정 가능하다. 
  * `where`는 상속이나 채택에 대한 제약조건 뿐만이 아니라 제한적인 `extension`이나 제한적 `for문 돌기` 등에도 사용 가능하다.

&nbsp;

* Unit Test
  * TDD를 하기 위한 방법으로 유닛테스트가 사용된다. 그렇다고 두 개념이 동일한 것은 아니다. 
  * test 메소드를 작성할 때에는 given-when-then 패턴을 주로 사용한다.
  * test 메소드 명은 위의 given-when-then에 맞춰 작성하는 편이다.
  * 입력값은 `expectInput`, 예상 결과값은 `expectResult`, 실제 결과값은 `output`이라는 용어를 포함하여 작성한다.
  * 테스트의 코드 커버리지를 높이려면 필요없는 에러는 줄이고, 에러는 세분화하고, 오류에 대한 테스트를 추가하자. 

&nbsp; 

## STEP3 - UI 연결

### 📖 주요 학습 개념

* `Action Method` 이름
  * 특별한 컨벤션은 없다. 어떤 곳에서는 `didTap`을 쓰지 말라고 하는 곳도 있었고 그 반대도 있었다.(스타일쉐어 컨벤션)
  * 알아본 몇가지 컨벤션 (UIButton)
    * tap으로 시작
    * didTap으로 시작
    * touchUp으로 시작
    * 그 외 동사와 명사의 조합

&nbsp;

* 상수
  * 상수를 선언하는 위치는 일반적으로 `case-less enumeration`이 좋다.
  * 특정 타입에 제한되는 값들은 해당 타입의 extension을 통해 추가하는 것도 좋은 방법이다. 

&nbsp;

이번 프로젝트를 통해 **iOS의 MVC는 일반적인 MVC 패턴과 다르다**는 것을 알 수 있었다. iOS에서의 ViewController는 View와 아주 밀접하게 연결되어 있기 때문에 Controller라고 보기 어려울 수 있다. 그리고 실제로 다른 패턴으로 가면 ViewController도 View요소로 본다.    

계산기를 구현하면서 **MVC**나 **SOLID**에 대해 배웠던 내용들을 적용해보려 노렸했지만, 해당 개념들 자체도 난이도가 꽤 있었던 탓에 원했던 만큼 적용하여 구현하지 못한 것 같다. 처음으로 Unit Test도 사용해봤는데, 코드에 대해 자신감이 생긴다는 말이 어떤 것인지 알 것 같다. 앞으로도 많은 프로젝트에 적용시켜보면서 익숙해지려 노력해야겠다.    

이번 프로젝트에서는 Commit message들을 영어로 써보려 노력했지만 쉽지 않았다. 쓰다보니 맨날 쓰는 단어만 쓰는 것 같았다. 상황에 따라 적절히 사용하면 좋을 것 같다는 생각이 들었다.   

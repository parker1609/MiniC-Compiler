# Mini-C Compiler
MiniC를 기반으로 어휘 분석, 파싱, AST 생성 후 이를 활용하여 중간코드(U-Code)를 생성하는 컴파일러를 구현한다. 그리고 생성된 U-Code가 정상적으로 동작하는지 확인하기 위해 U-Code Interpreter를 활용한다.

## 개발 기간 및 환경
- 기간: 2018.03 ~ 2018.06
- OS: Linux Ubuntu (VirtualBox)
- Language: C, C++, MiniC

## 사용 방법
- 사용 환경: Linux Ubuntu

- 설치
```
make
```

- 컴파일러 실행

예제는 mini C 코드이고, 해당 파일은 ```MiniC``` 파일 안에 있다.

```
./minic ./MiniC/add.mc
./minic ./MiniC/prime.mc
./minic ./MiniC/perfect.mc
```

- U-Code Interpreter 실행
```
./ucode add.uco
./ucode prime.uco
./ucode perfect.uco
```

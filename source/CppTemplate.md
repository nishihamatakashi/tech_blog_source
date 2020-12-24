---
title: C++におけるtemplateについて
---
# 目次
- templateについて
- 完全特殊化・部分特殊化
- 型制約によるコンパイルアサ―ト
- SFINAE
- テンプレートメタプログラミング

# templateについて
静的型付けのプログラミング言語でデータ型を抽象化してコードを書くことができるようにする機能で，C++ではジェネリックプログラミングに用いられる．
C++では下記のtemplateに対応している．
- 関数
- クラス
- 構造体
- 変数

```C++
//template関数
template<typename T>
void testFunc() 
{

}

//templateクラス
template<typename T>
class testClass
{

};

//template構造体
template<typename T>
struct testStruct
{

};

//template変数
template<typename T>
constexpr T pi = static_cast<T>(3.14159265358979323846);

int main() 
{
	return 0;
}
```
また，記述としては`template<typename T>`と`template<class T>`がある．
どちらも，同じ意味になる．一般的にclassは自分で定義したクラス，typenameはリテラル型であることが一般的．

# 完全特殊化・部分特殊化
仮に下記のような自作のprint_number関数を作ったとする．

```C++
#include <stdio.h>
//ただのprintf
template<typename T> inline void print_number(const T& value) 
{
    printf("%d",value);
}

int main() 
{
    int p = 0;
    print_number<int>(p);
    getchar();
}
```
実行結果`0`
上記の場合int型を指定すれば，動作する．しかし，型がfloatなど様々なリテラル型の場合に対応したリテラル指定子に変えたい場合は下記のような特殊化を行う．

```C++
#include <stdio.h>
template<typename T> inline void print_number(const T value) 
{
}

template<> inline void print_number<int>(const int value) 
{
    printf("%d",value);
}

template<> inline void print_number<float>(const float value) 
{
    printf("%f", value);
}

int main() 
{
    int p_int = 0;
    float p_float = 0.0f;
    print_number<int>(p_int);
    print_number<float>(p_float);
    getchar();
}
```
実行結果`0 0.000000`と，型Tに設定した型によってinline展開する関数を変えることができる．

また，template引数が複数ある場合下記のように片方のみを特殊化することができる．
これは部分特殊化となる．

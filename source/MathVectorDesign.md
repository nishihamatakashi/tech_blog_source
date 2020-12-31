---
title: 算術クラスVectorの設計
---

# 概要
算術クラスVectorの設計についてメモ

# 要求定義
- 実数データ型のみ
- 同じ次元数同士の四則演算
- スカラー値の四則演算
- cross積,dot積,norm,正規化
- 次元数1～4
- シリアライズ化
- simd化
- 精度保証
- テストコード
- プロファイリングコード

# 設計
## templateを使用するか
templateを使用する場合：いろんな型 + n次元ベクトルの基底クラスを定義して部分特殊化する。
```C++
namespace math
{
template<typename T, s32 size> struct Vector 
{
    TRA_STATIC_ASSERT_MSG(IsNumericDataType<T>::value, "Error:typename T is not NumericDataType");
    TRA_STATIC_ASSERT_MSG(size > 0, "Error:Size <= 1");
};

template<typename T> struct Vector<T, 1>
{
};

template<typename T> struct Vector<T, 2>
{
};

template<typename T> struct Vector<T, 3>
{
};

template<typename T> struct Vector<T, 4>
{
};
namespace
```

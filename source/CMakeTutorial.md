---
title: CMakeチュートリアル
---
# Step1 HelloWorldプロジェクトの作成
CMakeを利用して，cppのvsプロジェクトの作成，ビルドを行う．

## フォルダ構成
    -code
        |-_build
        |-main.cpp
        |-CMakeLists.txt
## main.cpp
```C++
#include <iostream>

int main()
{
    std::cout << "Hello World" << std::endl;
}
```
## CMakeLists.txt
```CMake
# バージョン保証
cmake_minimum_required(VERSION 3.15.2)

#project作成
project(MyProject VERSION 1.0.0)

#exeプロジェクト作成
add_executable(cmake-good main.cpp)
```
## コマンド
    - cd/_build
    - cmake ../
    - cmake --build ../_build
    - /Debug/cmake-good
    - 実行結果：HelloWorld

# Step2 Out Source Build
Step1では，プロジェクトファイルやビルド成果物を`_build`ディレクトリにまとめるため下記のような操作をした．
- _buildディレクトリ作成
- _buildディレクトリに移動
- CMakeLists.txtのディレクトリを指定してcmake

これをCmakeコマンドのみで実行することで，ビルドツリーとソースツリーを分けることができ，gitへのコミットや成果物の削除が容易になる．

## コマンド
    - cmake -B _build
    - cmake --build _build

# Step3 複数ファイルのコンパイル
ヘッダーファイル(.h)やソースファイル(.cpp)をまとめて，プロジェクトに登録しビルドする．
## フォルダ構成
    - code
        |- include
        |   |- MyMath.h
        |   |- Vector.h
        |-src
            |-Main.cpp
            |-MyMath.cpp
            |-Vector.cpp

## ソースファイル
```C++
/*--------------------------------------------------------
*@file MyMath.h
*/ //-----------------------------------------------------
namespace app
{
    void test_print();
}

/*--------------------------------------------------------
*@file MyMath.cpp
*/ //-----------------------------------------------------
#include <iostream>
#include "MyMath.h"

namespace app
{
    void test_print()
    {
        std::cout << "test" << std::endl;
    }
}

/*--------------------------------------------------------
*@file Vector.h
*/ //-----------------------------------------------------
namespace app
{
    void test_vector();
}

/*--------------------------------------------------------
*@file Vector.cpp
*/ //-----------------------------------------------------
#include <iostream>
#include "Vector.h"

namespace app
{
    void test_vector()
    {
        std::cout << "vector" << std::endl;
    }
}

/*--------------------------------------------------------
*@file Main.cpp
*/ //-----------------------------------------------------
#include "MyMath.h"
#include "Vector.h"

int main() 
{
    app::test_print();
    app::test_vector();
}
```

## CMakeファイル
操作の手順としては下記

- 各種変数を設定
- ソースディレクトリからファイルを収集
- まとめてadd_executableに登録
- includeディレクトリを設定
- vsのプロジェクト内でフィルター毎にファイルが分類されるように設定

```CMake
# バージョン保証
cmake_minimum_required(VERSION 3.15.2)

#CMakeListsのカレントディレクトリ
set(CURRENT_DIR ${CMAKE_CURRENT_SOURCE_DIR})

#ソースディレクトリ
set(SOURCE_DIR ${CURRENT_DIR}/src)

#includeディレクトリ
set(INCLUDE_DIR ${CURRENT_DIR}/include)

set(SOURCES "")

#inludeディレクトリから.hファイルを収集し,SOURCESに追加
file(GLOB_RECURSE INC_SOURCES ${INCLUDE_DIR}/*.h)
LIST(APPEND SOURCES ${INC_SOURCES})

#srcディレクトリから.cppファイルを収集し,SOURCESに追加
file(GLOB_RECURSE SRC_SOURCES ${SOURCE_DIR}/*.cpp)
LIST(APPEND SOURCES ${SRC_SOURCES})

#project名
set(PROJECT_NAME "MyProject")

#project作成
project(${PROJECT_NAME} VERSION 1.0.0)

#インクルードディレクトリの設定
include_directories("${INCLUDE_DIR}")

#ソースをすべてプロジェクトに登録
add_executable(${PROJECT_NAME} ${SOURCES})

#ソースのフィルタ分け
source_group("include" FILES ${INC_SOURCES})
source_group("src" FILES ${SRC_SOURCES})
```
# Step5 プロジェクト別の設定
# Step6 外部ライブラリのリンク
# Step7 構成の設定
# Step8 プリプロセッサマクロの定義
# Step9 コンパイラオプションの設定
# Step10 CMakeファイルの分割
# Step11 サブプロジェクトの追加
# Step12 batファイルで自動化
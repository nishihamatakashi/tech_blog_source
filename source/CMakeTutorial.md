---
title: CMakeチュートリアル
---
# 概要
CMakeを使用してVisual Studioにおける，開発環境の構築をする際のチュートリアルメモ．

主に自分用の備忘録なため，ご注意ください．

# 目次
- Step1：HelloWorldプロジェクトの作成
- Step2：Out Source Build
- Step3：複数ファイルのコンパイル
- Step4：プロジェクト別の設定
- Step5：ライブラリのリンク
- Step6：ビルド構成の設定
- Step7：定義済みマクロの定義
- Step8：コンパイラオプションの設定
- Step9：サブプロジェクトの追加
- Step10：CMakeファイルの分割
- Step11：batファイルで自動化

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
#ソースをすべてプロジェクトに登録
add_executable(${PROJECT_NAME} ${SOURCES})

#ソースのフィルタ分け
source_group("include" FILES ${INC_SOURCES})
source_group("src" FILES ${SRC_SOURCES})
```
# Step4 プロジェクト別の設定
.exe以外に，静的ライブラリlib,動的ライブラリdlllの作成を行う．

## フォルダ構成
    - code
        |- include
        |   |- MyMath.h
        |   |- Vector.h
        |-src
            |-Main.cpp
            |-MyMath.cpp
            |-Vector.cpp

## 静的ライブラリの作成
下記のCMakeListsを作る．
```CMake
# バージョン保証
#project名
set(PROJECT_NAME "MyProject")

#project作成
project(${PROJECT_NAME} VERSION 1.0.0)

#インクルードディレクトリの設定
include_directories("${INCLUDE_DIR}")

#静的ライブラリを作成
add_library(${PROJECT_NAME} STATIC ${SOURCES})

```
そして下記のコマンドを実行
```
cmake -B _build_lib
cmake --build _build_lib
```
以上で，下記の場所にlibファイルができる

    - code
        | - _build_lib
                |- Debug
                    |- MyProject.lib
                    |- MyProject.pbd

## 動的ライブラリの作成
下記のCMakeListsを作る．
```CMake
#project名
set(PROJECT_NAME "MyProject")

#project作成
project(${PROJECT_NAME} VERSION 1.0.0)

#インクルードディレクトリの設定
include_directories("${INCLUDE_DIR}")

#動的ライブラリを作成
add_library(${PROJECT_NAME} SHARED ${SOURCES})
```
そして下記のコマンドを実行
```
cmake -B _build_lib
cmake --build _build_dll
```
以上で，下記の場所にdllファイルができる

    - code
        | - _build_dll
                |- Debug
                    |- MyProject.dll
                    |- MyProject.ilk
                    |- MyProject.pbd
# Step5 ライブラリのリンク
Step3で作成したexeにStep4で作成したlibをリンクさせる．
## ファイル構成
    - code
        | - core
        |    | - include
        |    |    | - Math.h
        |    |    | - Vector.h
        |    | - src
        |         | - Math.cpp
        |         | - Vector.cpp
        | - app
        |    | - include
        |    |    |- Def.h
        |    | - src
        |         |-Main.cpp
        | - CMakeLists

## 静的ライブラリのリンク
```CMake
# バージョン保証
cmake_minimum_required(VERSION 3.15.2)

#CMakeListsのカレントディレクトリ
set(CURRENT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
#ソースディレクトリ
set(SOURCE_DIR ${CURRENT_DIR}/src)
#includeディレクトリ
set(INCLUDE_DIR ${CURRENT_DIR}/include)

#inludeディレクトリから.hファイルを収集し,SOURCESに追加
set(SOURCES "")
file(GLOB_RECURSE INC_SOURCES ${INCLUDE_DIR}/*.h)
LIST(APPEND SOURCES ${INC_SOURCES})
#srcディレクトリから.cppファイルを収集し,SOURCESに追加
file(GLOB_RECURSE SRC_SOURCES ${SOURCE_DIR}/*.cpp)
LIST(APPEND SOURCES ${SRC_SOURCES})

#coreライブラりのディレクトリ
set(CORE_DIR ${CURRENT_DIR}/../core/)
#coreのincludeディレクトリ
set(CORE_INCLUDE_DIR ${CORE_DIR}/include)
#coreのsrcディレクトリ
set(CORE_SOURCE_DIR ${CORE_DIR}/src)

#coreのinludeディレクトリから.hファイルを収集し,SOURCESに追加
set(CORE_SOURCES "")
file(GLOB_RECURSE CORE_INC_SOURCES ${CORE_INCLUDE_DIR}/*.h)
LIST(APPEND CORE_SOURCES ${CORE_INC_SOURCES})
#coreのsrcディレクトリから.cppファイルを収集し,SOURCESに追加
file(GLOB_RECURSE CORE_SRC_SOURCES ${CORE_SOURCE_DIR}/*.cpp)
LIST(APPEND CORE_SOURCES ${CORE_SRC_SOURCES})

#project名
set(PROJECT_NAME "MyProject")

#library名
set(LIB_NAME "Core")

#project作成
project(${PROJECT_NAME} VERSION 1.0.0)

#インクルードディレクトリの設定
include_directories("${INCLUDE_DIR}" "${CORE_INCLUDE_DIR}")

add_library(${LIB_NAME} STATIC ${CORE_SOURCES})

#ソースをすべてプロジェクトに登録
add_executable(${PROJECT_NAME} ${SOURCES})

#${PROJECT_NSMER# バージョン保証
cmake_minimum_required(VERSION 3.15.2)

#CMakeListsのカレントディレクトリ
set(CURRENT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
#ソースディレクトリ
set(SOURCE_DIR ${CURRENT_DIR}/src)
#includeディレクトリ
set(INCLUDE_DIR ${CURRENT_DIR}/include)

#inludeディレクトリから.hファイルを収集し,SOURCESに追加
set(SOURCES "")
file(GLOB_RECURSE INC_SOURCES ${INCLUDE_DIR}/*.h)
LIST(APPEND SOURCES ${INC_SOURCES})
#srcディレクトリから.cppファイルを収集し,SOURCESに追加
file(GLOB_RECURSE SRC_SOURCES ${SOURCE_DIR}/*.cpp)
LIST(APPEND SOURCES ${SRC_SOURCES})

#coreライブラりのディレクトリ
set(CORE_DIR ${CURRENT_DIR}/../core/)
#coreのincludeディレクトリ
set(CORE_INCLUDE_DIR ${CORE_DIR}/include)
#coreのsrcディレクトリ
set(CORE_SOURCE_DIR ${CORE_DIR}/src)

#coreのinludeディレクトリから.hファイルを収集し,SOURCESに追加
set(CORE_SOURCES "")
file(GLOB_RECURSE CORE_INC_SOURCES ${CORE_INCLUDE_DIR}/*.h)
LIST(APPEND CORE_SOURCES ${CORE_INC_SOURCES})
#coreのsrcディレクトリから.cppファイルを収集し,SOURCESに追加
file(GLOB_RECURSE CORE_SRC_SOURCES ${CORE_SOURCE_DIR}/*.cpp)
LIST(APPEND CORE_SOURCES ${CORE_SRC_SOURCES})

#project名
set(PROJECT_NAME "MyProject")

#library名
set(LIB_NAME "Core")

#project作成
project(${PROJECT_NAME} VERSION 1.0.0)

#インクルードディレクトリの設定
include_directories("${INCLUDE_DIR}" "${CORE_INCLUDE_DIR}")

#libを作成
add_library(${LIB_NAME} STATIC ${CORE_SOURCES})

#exeを作成
add_executable(${PROJECT_NAME} ${SOURCES})

#生成したexeにlibをリンクする．
target_link_libraries(${PROJECT_NAME} ${LIB_NAME})

#ソースのフィルタ分け
source_group("include" FILES ${INC_SOURCES})
source_group("src" FILES ${SRC_SOURCES})}
target_link_libraries(${PROJECT_NAME} ${LIB_NAME})

#ソースのフィルタ分け
source_group("include" FILES ${INC_SOURCES})
source_group("src" FILES ${SRC_SOURCES})
```
# Step6 ビルド構成の設定
GeneratorがVisual StudioやXCodeなどの統合開発環境(IDE系)の場合，複数のビルドタイプを保持することができる．

例として,cmakeコマンド入力時下記のようなコマンドを入力すると，ビルド構成が「Debug」,「Develope」,「Release」で分けることができる．
```
cmake -B_build -DCMAKE_CONFIGURATION_TYPES="Debug;Develope;Release"
```

また，CMakeList.txtで入力するときは以下のようにする．
```CMake
# 構成タイプにDebug Develop Releaseを追加
if(CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_CONFIGURATION_TYPES Debug Develop Release)
endif()
```
# Step7 定義済みマクロの定義
CMakeを使用して，定義済みマクロ(プリプロセッサマクロ)の定義を行う．

また，今回はStep6で説明したビルド構成別に定義しているマクロを変更できるようにする．

```CMake
# ビルド構成を設定
if(CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_CONFIGURATION_TYPES Debug Develop Release)
endif()

# ビルド構成毎のプリプロセッサマクロの定義
set(COMPILE_DEFINATIONS_DEBUG MODE_DEBUG MODE_TEST_CODE MODE_PROFILE_CODE)
set(COMPILE_DEFINATIONS_DEVELOP MODE_DEVELOP MODE_TEST_CODE MODE_PROFILE_CODE)
set(COMPILE_DEFINATIONS_RELEASE MODE_RELEASE)

# ビルド構成毎にプリプロセッサマクロを定義する
foreach(CONFIGRATION_TYPE ${CMAKE_CONFIGURATION_TYPES})
    set(COMPILE_DEFINATIONS )

    # Debug/Develop/Releaseで切り替え
    if(${CONFIGRATION_TYPE} MATCHES "Debug")
        set(COMPILE_DEFINATIONS ${COMPILE_DEFINATIONS_DEBUG})
    elseif(${CONFIGRATION_TYPE} MATCHES "Develop")
        set(COMPILE_DEFINATIONS ${COMPILE_DEFINATIONS_DEVELOP})
    elseif(${CONFIGRATION_TYPE} MATCHES "Release")
        set(COMPILE_DEFINATIONS ${COMPILE_DEFINATIONS_RELEASE})
    endif()
    
    # プリプロセッサマクロを設定
    target_compile_definitions(${PROJECT_NAME} PUBLIC $<$<CONFIG:${CONFIGRATION_TYPE}>:${COMPILE_DEFINATIONS}>)
endforeach(CONFIGRATION_TYPE)
```
cmakeコマンドは下記
```
cmake -B_build
```
以上の操作で，下記のようにプリプロセッサマクロを変更できる
- Debug
    - MODE_DEBUG
    - MODE_TEST_CODE
    - MODE_PROFILE_CODE
- Develop
    - MODE_DEVELOP
    - MODE_TEST_CODE
    - MODE_PROFILE_CODE
- Release
    - RELEASE_MODE

# Step8 コンパイラオプションの設定
コンパイラに渡すオプションの設定も行える．この章で設定するのは下記とする．

## MSVCのコンパイラ設定
コンパイラの設定詳細は別ページで
- コード生成
    - 浮動小数点モデル
        - `/fp:fast`：速度有線
    - ランタイムライブラリ
        - Debug
            - `/MDd`：_DEBUG,_MT,_DLLを定義，ライブラリ名MSVCRTD.libが.objファイルに挿入される．
        - Develop/Release
            - `/MD`：_MT,_DLLを定義，ライブラリ名MSVCRTD.libが.objファイルに挿入される．
- 最適化
    - インライン関数の展開
        - `/Ob1`：下記で定義している関数を展開する
            - inline [type] [functionname]
            - __inline [type] [functionname]
            - __forceinline [type] [functionname]
            - クラス宣言で定義されている C++ メンバー関数
    - フレームポインタなし
        - Debug
            - `/Oy-`：フレームポインタあり
        - Develop/Release
            - `/Oy`：フレームポインタなし
    - 最適化
        - Debug
            - `/Od`：最適化しない(デバッグ)
        - Develop/Release
            - `/O2`：速度を最大にする
    - 組み込み関数を使用する
        - Develop/Release
            - `Oi`：高速に実行するコードが生成される 
    - 速度またはサイズを優先
        - `/Ot`：コードの速度を優先
- 詳細設定
    - 特定の警告無視
        - `/wd[番号]`
- 全般
    - デバッグ情報の形式
        - `/Zi`：シンボリックデバッグ情報を持つPDBファイルが生成される
    - 警告レベル
        - `/W4`：警告レベルは4
    - 警告をエラーとして扱う
        - `/WX`：warningもerrorとして扱われるようになる．
```CMake
# プリプロセッサマクロの定義を記述
set(COMPILE_DEFINATIONS_COMMON )
set(COMPILE_DEFINATIONS_DEBUG MODE_DEBUG MODE_TEST_CODE MODE_PROFILE_CODE)
set(COMPILE_DEFINATIONS_DEVELOP MODE_DEVELOP MODE_TEST_CODE MODE_PROFILE_CODE)
set(COMPILE_DEFINATIONS_RELEASE MODE_RELEASE)

# コンパイラオプションを記述
set(COMPILE_OPTIONS_COMMON /fp:fast /Ob1 /Ot /Zi /W4 /WX)
set(COMPILE_OPTIONS_DEBUG /MDd /Oy- /Od)
set(COMPILE_OPTIONS_DEVELOP /MD /Oy /O2)
set(COMPILE_OPTIONS_RELEASE /MD /Oy /O2)

# ビルド構成毎にプリプロセッサマクロとコンパイラオプションを設定
foreach(CONFIGRATION_TYPE ${CMAKE_CONFIGURATION_TYPES})
    # 共通設定で初期化
    set(COMPILE_DEFINATIONS ${COMPILE_DEFINATIONS_COMMON})
    set(COMPILE_OPTIONS ${COMPILE_OPTIONS_COMMON})


    # ビルド構成に応じて追加
    if(${CONFIGRATION_TYPE} MATCHES "Debug")
        list(APPEND COMPILE_DEFINATIONS ${COMPILE_DEFINATIONS_DEBUG})
        list(APPEND COMPILE_OPTIONS ${COMPILE_OPTIONS_DEBUG})
    elseif(${CONFIGRATION_TYPE} MATCHES "Develop")
        list(APPEND COMPILE_DEFINATIONS ${COMPILE_DEFINATIONS_DEVELOP})
        list(APPEND COMPILE_OPTIONS ${COMPILE_OPTIONS_DEVELOP})
    elseif(${CONFIGRATION_TYPE} MATCHES "Release")
        list(APPEND COMPILE_DEFINATIONS ${COMPILE_DEFINATIONS_RELEASE})
        list(APPEND COMPILE_OPTIONS ${COMPILE_OPTIONS_RELEASE})
    endif()

    # プリプロセッサマクロを${PROJECT_NAME}に設定
    target_compile_definitions(${PROJECT_NAME} PUBLIC $<$<CONFIG:${CONFIGRATION_TYPE}>:${COMPILE_DEFINATIONS}>)

    # コンパイルオプションを${PROJECT_NAME}に設定
    target_compile_options(${PROJECT_NAME} PUBLIC $<$<CONFIG:${CONFIGRATION_TYPE}>:${COMPILE_OPTIONS}>)
endforeach(CONFIGRATION_TYPE)
```
# Step9 サブプロジェクトの追加
大規模開発を行う際，ライブラリ毎にプロジェクトを用意してApplication側で依存関係を記述し環境構築を行いたい．

## ファイル構成
```
- root
    |-libs
    |  |-core
    |  |   |-include
    |  |   |  |-Def.h
    |  |   |-src
    |  |   |  |-Def.cpp
    |  |   |-CMakeLists.txt
    |  |-mat
    |      |-include
    |      |  |-Def.h
    |      |-src
    |      |  |-Def.cpp
    |      |-CMakeLists.txt
    |
    |-app
        |-sample
           |-include
           |  |-Def.h
           |-src
           |  |-Main.cpp
           |-CMakeList.txt
```
## coreライブラリのCMakeLists.txt


## mathライブラリのCMakeLists.txt
coreと同じ構成

## ApplicationのCMakeLists.txt

# Step10 CMakeファイルの分割
CMakeは*.cmakeファイルを作成することでモジュールとして使用することが可能となる．

これを使用して，ファイル分割する．

## Common.cmake
## SettingConfigurations.cmake
## SettingCompiler.cmake
## CMakeLists.txt

# Step11 batファイルで自動化
今まで，実行してきたcmakeコマンドをCMakeListsと連携したbat(または，ps1)ファイルに記述し，実行するだけで開発環境が構築できるようにする．


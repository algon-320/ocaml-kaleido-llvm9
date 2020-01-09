# OCaml Kaleidoscope in LLVM9.0.0

## 前提条件
- LLVM9.0.0
- OCamlのllvmパッケージ
    - opamからインストール
    - `llvm  9.0.0  The OCaml bindings distributed with LLVM`
---

## 参考文献
- [OCamlのllvmパッケージのドキュメント](https://llvm.moe/ocaml/)
    - 現状で最新だが、バージョン9.0.0に対応するページを見る必要がある
    - [他のバージョン](https://llvm.moe/)

- [OCaml Kaleidoscope in LLVM5.0.0](https://github.com/ShigekiKarita/ocaml-kaleido-llvm5)

---

## リポジトリの使い方

1. 各Chapterのブランチにチェックアウト
2. `make run`で実行

---

# 各Chapterの問題点とその解決方法

## Chapter 1, 2

- 特に問題なし

---

## Chapter 3

### 問題点3-1

- ビルドが通らない
```
File "codegen.ml", line 5, characters 5-9:
Error: Unbound module Llvm
```

#### 解決方法

- `myocamlbuild.ml`が問題らしい
- 以下の部分を消す
```
ocaml_lib ~extern:true "llvm";;
ocaml_lib ~extern:true "llvm_analysis";;
```

- `ocamlbuild`のオプションに`-use-ocamlfind`を渡す
- `_tags`ファイルを以下のように編集
```
<{lexer,parser}.ml>: use_camlp4, pp(camlp4of)
<*.{byte,native}>: g++, package(llvm, llvm.analysis)
<*.ml>: package(llvm, llvm.analysis)
```

### 問題点3-2

- `add`命令でdouble型の数値を加算しようとすると例外が発生する
```
Integer arithmetic operators only work with integral types!
  %addtmp = add double %a, %b
LLVM ERROR: Broken function found, compilation aborted!
```

#### 解決方法

- `codegen.ml`の`build_add`となっている箇所を`build_fadd`に修正
    - 他の演算子についても同様

---

## Chapter 4

### 問題点4-1

- ビルドが通らない
```
File "toplevel.ml", line 37, characters 25-53:
Error: Unbound module ExecutionEngine
```

#### 解決方法

- APIが変わっている
    - [大きな変更があったコミット](https://github.com/llvm/llvm-project/commit/b1f54ff42f96893591dba930320045c4b54c533b#diff-187401f0e05756f2462a0b9aef8e57c6)
    - `run_function`に相当する関数はなくなっていて、代わりに`get_function_address`を用いる
    - `Ctypes`を用いて明示的に呼び出す必要がある
    - それに伴う変更をいくつか
    - ExecutionEngineをトップレベルの評価のたびに生成するように変更する

### 問題点4-2

- C言語の関数を呼び出そうとするとSegmentation Faultする
    - `ready> extern putchard(X);`
    - `ready> putchard(42);`
    - などとすると落ちる

#### 解決方法

- nativeでビルドするように変更
- C言語側を共有ライブラリの形にしておいて、動的リンクする
    - `$ gcc -shared bindings.c -o libbindings.so`で共有ライブラリを作り、
    - `ocamlbuild`に`-lflags -cclib,-lbinding,-ccopt,-L.`を渡して動的リンクするようにする
    - `$ LD_LIBRARY_PATH=./_build ./toy.native`のように実行する

- `putchard`だけだと標準出力がフラッシュされずに画面に文字が出ないことがあるので注意

---

## Chapter 5, 6, 7

### 問題点

- for文のカウンタで`add`命令が使われているので例外が発生する(問題点3-2と同じ)

#### 解決方法

- `build_add`を`build_fadd`に変更



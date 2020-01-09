# OCaml Kaleidoscope in LLVM9.0.0 (Chapter 4)

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


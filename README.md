# OCaml Kaleidoscope in LLVM9.0.0 (Chapter 5)

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

## Chapter 5, 6, 7

### 問題点

- for文のカウンタで`add`命令が使われているので例外が発生する(問題点3-2と同じ)

#### 解決方法

- `build_add`を`build_fadd`に変更



> This folder includes small programs for TinyScheme.

このフォルダは [TinyScheme](http://tinyscheme.sourceforge.net) で実行できる小さなプログラムを収録しています。
拡張ライブラリも含まれているので gcc や make も必要です。
gcc は termux で `pkg install clang` したものが使えます。
termux/Android で TinyScheme 1.41 を使って動作確認してますが、
termux で `pkg install tinyscheme` したものは使っていません。
同じバージョン 1.41 ですが

- 実行ファイルが STANDALONE で作られている。
- libtinyscheme.so がない。
- ヘッダファイルがない。

なので

- TinyScheme 1.41 を入手
- `make` して実行ファイルと libtinyscheme.so を作る
- libtinyscheme.so は環境変数 LD_LIBRARY_PATH のフォルダにコピー
- 本リポジトリの makefile を編集(ヘッダー、ライブラリのフォルダを設定)
- 本リポジトリを `make`

といった作業が必要。

## 内容
- [tsbase.c](tsbase.c) ごく簡単な拡張ライブラリ getenv, getcwd, chdir 等
- [tsrepl.c](tsrepl.c) TinyScheme 内の REPL を呼び出す拡張ライブラリ
  - 目標は、フック関数から呼び出して使えるものにすること
- [rk4.scm](rk4.scm)
  - 目標は、関数 rk4 が TinyScheme と Simple Scheme 両方で動作すること


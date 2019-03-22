> This folder includes small programs for TinyScheme.

このフォルダは [TinyScheme](http://tinyscheme.sourceforge.net) で実行できる小さなプログラムを収録しています。
拡張ライブラリも含まれているので gcc や make も必要です。
gcc は termux で `pkg install clang` したものが使えます。
termux/Android で TinyScheme 1.41 を基に開発してますが、termux で `pkg install tinyscheme` したものは使っていません。
同じバージョン 1.41 ですが。
理由は
- 実行ファイルが STANDALONE で作られている。
- libtinyscheme.so がない。
- ヘッダファイルがない。

なので

- TinyScheme 1.41 を入手
- `make` して実行ファイルと libtinyscheme.so を作る
- libtinyscheme.so は環境変数 LD_LIBRARY_PATH のフォルダにコピー
- 本リポジトリの makefile を編集(ヘッダーファイルのフォルダを設定)
- 本リポジトリを `make`

といった作業が必要になります。

## Contents
- tsbase.so is a extension for getenv, getcwd, chdir
- tsrepl.so is a extension for REPL
  - not enough implements, now debugging
  - current issues
    - When this REPL nested, tinyscheme gc confused.
    - This REPL has global environment ONLY. I cannot solve this problem.
- rk4.scm is numerical analizing by Runge-Kutta method.
  - I aim at making the code compatible for Simple Scheme. But not completed.

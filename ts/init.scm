;;  for compatible to simple scheme
(define cons?  pair?)
(define empty? null?)
(define empty  '())
;;  for mathematics
(define pi 3.141592653589793)
(define e  2.718281828459045)
;;  for physics
(define c  2.99792458e+8)   ;;  m/s
(define h  6.62607554e-34)  ;;  Js
(define u0 1.256637e-6)     ;;  H/m  (* 4 pi (expt 10 -7))
(define e0 8.854e-12)       ;;  F/m  (/ (expt 10 7) (* 4 pi) (* c c))
(define k  1.380658e-23)    ;;  J/K
(define NA 6.0221367e+23)   ;;  mol^-1
(define G  6.6725985e-11)   ;;  Nm^2kg^-2
(define qe 1.6021773e-19)   ;;  C
(define me 9.109e-31)       ;;  kg
(define mp 1.67262311e-27)  ;;  kg
(define mn 1.67492861e-27)  ;;  kg
;;  for basic functions of tinyscheme
(load           "/data/data/com.termux/files/home/tinyscheme-1.41/init.scm")
;;  my extenntions
(load-extension "/data/data/com.termux/files/home/scheme/ts/tsbase")
(load-extension "/data/data/com.termux/files/home/scheme/ts/tsrepl")

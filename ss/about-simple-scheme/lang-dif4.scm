;lang-dif4.scm
;NG
;(define (fact n)
;  (define (loop acc n)
;    (if (<= n 1)
;      acc
;      (loop (* acc n) (- n 1)))))
;OK
(define (fact n)
  (letrec ([loop (lambda (acc n)
                   (if (<= n 1)
                     acc
                     (loop (* acc n) (- n 1))))])
    (loop 1 n)))
(fact 5) ; => 120

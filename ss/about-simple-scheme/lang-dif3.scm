;lang-dif3.scm
;NG
;(define (fact n)
;  (let loop ((acc 1) (n n))
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

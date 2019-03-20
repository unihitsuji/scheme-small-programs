;lang-dif2.scm
;NG
;(define (raw . lst) lst) ; => Cannot [Run]
;(raw 1 2 3)              ; => I need (list 1 2 3)
;OK
(define (raw lst) lst)
(raw '(1 2 3))            ; => (list 1 2 3)

;lang-dif1.scm
;NG
;(cons 1 2) ; => RuntimeExceptoon: Cannot convert 2 to a list value
;OK
(cons 1 '(2))           ; => (list 1 2)
(cons 1 (cons 2 '()))   ; => (list 1 2)
(cons 1 (cons 2 empty)) ; => (list 1 2)

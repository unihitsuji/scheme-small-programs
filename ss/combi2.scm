(define (combi2 lst1 lst2)
  (letrec
    ((step (lambda (acc e1 lst2)
       (if (empty? lst2)
         acc
         (step (cons (list e1 (car lst2)) acc) e1 (cdr lst2)))))
     (loop (lambda (acc lst1 lst2)
       (if (empty? lst1)
         (reverse acc)
         (loop (step acc (car lst1) lst2) (cdr lst1) lst2)))))
    (loop empty lst1 lst2)))

(combi2 '(1 2 3) '(4 5 6 7 8 9))

;;;;;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
(define (any->string val)
  (letrec
    ((atom->string  (lambda (val)
      (cond
        ((string? val) (string-append "\"" val "\""))
        ((symbol? val) (symbol->string val))
        ((number? val) (number->string val))
        ((empty?  val) "()"))))
     (loop (lambda (val)
      (if (empty? val)
        ""
        (if (not (cons? val))
          (string-append (atom->string val))
          (if (cons? (car val))
            (begin
              (string-append
                "("
                (loop (car val))
                ")"
                (if (empty? (cdr val)) "" " ")
                (loop (cdr val))))
            (begin
              (string-append
                (atom->string (car val))
                (if (empty? (cdr val))
                  ""
                  (string-append " " (loop (cdr val))))))))))))
    (if (cons? val)
      (string-append "(" (loop val) ")")
      (atom->string val))))
;;;;;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
(any->string '(1 2 (3 4) () (5) 6 7 (a (b (c d) e)) ()))
(any->string "Hello")
(any->string 'SYMBOL)
(any->string 123)
(any->string '())

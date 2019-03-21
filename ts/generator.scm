;;;
;;; generator.scm
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (hello-generator) (display "Hello writtern in generator.scm\n") 0)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define g
  (make-environment
    ;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
    (define (iter lst)
      (lambda ()
        (if (null? lst)
          ()
          (let ((ret (car lst)))
	    (set! lst (cdr lst))
	    ret))))
    ;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
    (define (list . lst) (iter lst))
    ;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
    (define (split str delchar)
      (let ((strlst (string->list str)))
        (lambda ()
          (let loop ((acc ()) (lst strlst))
            (if (null? lst)
              (if (null? strlst)
       	        ()
                (begin
                  (set! strlst ())
       	          (list->string (reverse acc))))
              (if (char=? delchar (car lst))
                (begin
                  (set! strlst (cdr lst))
                  (list->string (reverse acc)))
                (loop (cons (car lst) acc) (cdr lst))))))))
    ;;; handles generator. note that itself is not generator
    (define (each lst f)
      (let ((gene (if (closure? lst)
                      lst
                      (iter lst))))
        (let loop ((acc ()) (val (gene)))
          (if (null? val)
            (reverse acc)
            (loop (cons (f val) acc) (gene))))))
    ;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
    (define (map f lst) (each lst f))
    ;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
    (define (repeat lst f)
      (let ((gene (if (closure? lst)
                      lst
                      (iter lst))))
        (let loop ((val (gene)))
          (if (null? val) () (loop (gene))))))))
;;;;;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
(define (hello-generator2) (display "Hello2 writtern in generator.scm\n") 1.2)

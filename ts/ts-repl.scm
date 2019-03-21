;;;
;;; ts-repl.scm
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (hello-tsemb) (display "Hello written in tsemb.scm\n"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define load-path
  "/data/data/com.termux/files/home/empty:/data/data/com.termux/files/home/ts:/data/data/com.termux/files/home/ts-1.41-ext:/data/data/com.termux/home/tinyscheme-1.41:/data/data/com.termux/files/usr/shara/tinyscheme")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define *load-path*
  (if (defined? 'getenv) (getenv "SCHEME_LIBRARY_PATH") load-path))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define *load-file*
  (if (defined? 'load-file) 'load-file 'load))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (take* lst n)
  (let loop ((acc ()) (lst lst) (i n))
    (if (or (null? lst) (<= i 0))
      (reverse acc)
      (loop (cons (car lst) acc) (cdr lst) (- i 1)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (fill n x)
  (let loop ((acc ()) (n n) (x x))
    (if (<= n 0)
       acc
       (loop (cons x acc) (- n 1) x))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (fix-left n str)
  (list->string
    (take*
      (append (string->list str)
              (fill n #\Space))
      n)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(if (not (defined? 'disp4flow))
  (define (disp4flow funcname msg1 msg2)
    (display
     (string-append
      (fix-left 16 funcname) ": "
      (fix-left 22 msg1)     " "
      msg2                   "\n"))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (join  lst delstr)
  (apply string-append
    (reverse
      (let loop ((acc ()) (lst lst))
        (if (null? lst)
          acc
          (if (null? acc)
	    (loop (cons (car lst) acc)               (cdr lst))
            (loop (cons (car lst) (cons delstr acc)) (cdr lst))))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (split str delchar)
  (let ((strlst (string->list str)))
    (let loop ((acc ()) (i 0) (head strlst) (lst strlst))
      (if (null? lst)
        (if (null? head)
          (reverse acc)
          (loop (cons (list->string (take* head i)) acc) 0 lst lst))
	(if (char=? delchar (car lst))
          (loop (cons (list->string (take* head i)) acc) 0 (cdr lst) (cdr lst))
          (loop acc (+ i 1) head (cdr lst)))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (filename . lst)
  (let loop ((acc "") (lst lst))
    (if (null? lst)
      acc
      (if (or (string=? acc "") (string=? (car lst) ""))
        (loop (string-append acc     (car lst)) (cdr lst))
        (loop (string-append acc "/" (car lst)) (cdr lst))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (load-lib name)
  (let loop ((p (split *load-path* #\:)))
    (if (null? p)
      (begin
        (disp4flow "load-lib"
                   (string-append "NG! " (symbol->string *load-file*))
                   name)
        #f)
      (catch (loop (cdr p))
             (disp4flow "load-lib"
                        (string-append "try " (symbol->string *load-file*))
                        (filename (car p) name))
             (if (not ((eval *load-file*) (filename (car p) name)))
               (throw "ERROR !!!!!!!!!!!!!")
               (disp4flow "load-lib"
                          (string-append "ok! " (symbol->string *load-file*))
                          (filename (car p) name)))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(load-lib "generator.scm")

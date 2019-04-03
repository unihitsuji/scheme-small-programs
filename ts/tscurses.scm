(load "/data/data/com.termux/files/home/scheme/ts/string4any.scm")
(load-extension "tscurses")
;;;;;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
(define (record)
  (let ((ret ""))
    (lambda (lst)
      (if (empty? lst)
        ret
        (begin
          (set! ret
            (string-append ret (cadr lst) "  ;;; => "
              (if (< 2 (length lst))
                (caddr lst)
                (string4any (car lst)))
	      "\n"))
          (car lst))))))

(display
 (let*
   ((r (record))
    (stdscr (r (list (initscr) "(initscr)"))))
   (begin
     (r (list (start_color)        "(start_color"))
     (r (list (move 10 20)         "(move 10 20)"))
     (r (list (addstr "Hello")     "(addstr \"Hello\")"))
     (r (list (wmove stdscr 20 20) "(wmove stdscr 20 20)"))
     (r (list (addstr "world")     "(addstr \"world\")"))
     (r (list (getch)              "(getch)"))
     (r (list (endwin)             "(endwin)"))
     (r '()))))

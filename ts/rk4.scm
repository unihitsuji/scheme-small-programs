#!/data/data/com.termux/files/home/tinyscheme-1.41/scheme -1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (hello-rk4) (display "Hello written in rk4.scm\n"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (list-head lst n)
  (reverse
   (let loop ((acc ()) (lst lst) (n n))
     (if (or (null? lst) (<= n 0))
	 acc
	 (loop (cons (car lst) acc) (cdr lst) (- n 1))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (round-n n x)
  (/ (round (* x 1.0 (expt 10 n))) (expt 10 n)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (fill n x)
  (let loop ((acc ()) (n n) (x x))
    (if (<= n 0)
       acc
       (loop (cons x acc) (- n 1) x))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (fix-fp n val)
  (list->string
    (let loop ((acc ())
               (fp #f)
               (n n)
               (lst (append (string->list
			      (number->string
			        (round-n n (+ val 0.0))))
                            (fill n #\0))))
      (if fp
	(if (<= n 0)
          (reverse acc)
          (loop (cons (car lst) acc) fp (- n 1) (cdr lst)))
	(if (char=? (car lst) #\.)
          (loop (cons (car lst) acc) #t n (cdr lst))
          (loop (cons (car lst) acc) fp n (cdr lst)))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (fix-right n str)
  (list->string
    (reverse
      (list-head
        (append (reverse (string->list str))
                (fill n #\Space))
	n))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (fix-left n str)
  (list->string
    (list-head
      (append (string->list str)
              (fill n #\Space))
      n)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define rk4
  (make-environment
    ;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
    (define (drop lst n)
      (if (null? lst) () (if (<= n 0) lst (drop (cdr lst) (- n 1)))))
    ;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
    (define (xcdr lst) (if (pair? lst) (cdr lst) ()))
    ;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
    (define (load-libs lst)
      (if (null? lst)
	()
	(begin
	  (display "------- loading ")
	  (display (car lst))
	  (display "\n")
	  (load (car lst))
	  (load-libs (cdr lst)))))
    ;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
    (define (disp lst fmt)
      (let displines ((lst lst))
	(if (null? lst)
	  ()
	  (begin
	    (let dispcols ((line (car lst)) (fmt fmt))
	      (if (null? line)
	        (begin (display "\n") ())
	        (begin
		  (display (if (and (pair? fmt) (closure? (car fmt)))
			       ((car fmt) (car line))
			       (car line)))
		  (display " ")
	          (dispcols (cdr line) (xcdr fmt)))))
	    (displines (cdr lst) fmt)))))
    ;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
    (define (dispcar lst)
      (if (null? lst)
        ()
        (begin (display (car lst))
	       (display "\n")
	       (dispcar (cdr lst)))))
    ;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
    (define (i131-xe131 x y) (* y -1 0.08664))
    ;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
    (define (half-decay)
      (let ((t0 #f) (x0 #f) (y0 #f))
        (lambda (lst)
          (if (and (number? t0) (number? x0) (number? y0))
	    ;;;
            (or (<= (list-ref (car lst) 5) (/ x0 2))
		(<= (list-ref (car lst) 6) (/ y0 2)))
            (begin
	      (set! t0 (list-ref (car lst) 1))
	      (set! x0 (list-ref (car lst) 2))
	      (set! y0 (list-ref (car lst) 3))
	      #f)))))
    ;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
    (define (go2 h x0 y0 f hook)
      (let ((f     (if (symbol? f)    (eval f)    f))
	    (hook ((if (symbol? hook) (eval hook) hook))))
        (define (k1 x y) (f x y))
        (define (k2 x y) (f (+ x (/ h 2)) (+ y (* (/ h 2) (k1 x y)))))
        (define (k3 x y) (f (+ x (/ h 2)) (+ y (* (/ h 2) (k2 x y)))))
        (define (k4 x y) (f (+ x h) (+ y (* h (k3 x y)))))
        (define (y-next x y)
	  (+ y
	     (* (/ h 6)
	        (+ (k1 x y) (* 2 (k2 x y)) (* 2 (k3 x y)) (k4 x y)))))
        (define (data x y)
	  (list h 0 x y 0 (+ x h) (y-next x y)))
        (define (interrupt?) #f)
        (define (stop? datum) #t)
        (let loop ((acc ()) (x x0) (y y0))
	  (if (or (interrupt?) (and (pair? acc) (hook acc)))
	    (if (stop? acc)
	      (reverse acc)
	      (loop (cons (data x y) acc)
		    (+ x h)
		    (y-next x y)))
	    (loop (cons (data x y) acc)
		  (+ x h)
		  (y-next x y))))))
    ;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
    (define (lotka-volterra-dx/dt t x y) (- (*  0.01 x) (* 0.0001 x y)))
    ;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
    (define (lotka-volterra-dy/dt t x y) (+ (* -0.05 y) (* 0.0001 x y)))
    ;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
    (define (time-over)
      (let ((t0 #f) (x0 #f) (y0 #f))
        (lambda (lst)
          (if (and (number? t0) (number? x0) (number? y0))
	    ;;;
            (<= 800 (list-ref (car lst) 4))
            (begin
	      (set! t0 (list-ref (car lst) 1))
	      (set! x0 (list-ref (car lst) 2))
	      (set! y0 (list-ref (car lst) 3))
	      #f)))))
    ;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
    (define (go3 h t0 x0 y0 fx fy hook)
      (let ((fx    (if (symbol? fx)   (eval fx)   fx))
	    (fy    (if (symbol? fy)   (eval fy)   fy))
	    (hook ((if (symbol? hook) (eval hook) hook))))
        (define (kx1 t x y) (* h (fx t x y)))
        (define (kx2 t x y) (* h (fx (+ t (/ h 2)) (+ x (/ (kx1 t x y) 2)) (+ y (/ (ky1 t x y) 2)))))
        (define (kx3 t x y) (* h (fx (+ t (/ h 2)) (+ x (/ (kx2 t x y) 2)) (+ y (/ (ky2 t x y) 2)))))
        (define (kx4 t x y) (* h (fx (+ t h)       (+ x    (kx3 t x y))    (+ y    (ky3 t x y)))))
	;;;;;;;
        (define (ky1 t x y) (* h (fy t x y)))
        (define (ky2 t x y) (* h (fy (+ t (/ h 2)) (+ x (/ (kx1 t x y) 2)) (+ y (/ (ky1 t x y) 2)))))
        (define (ky3 t x y) (* h (fy (+ t (/ h 2)) (+ x (/ (kx2 t x y) 2)) (+ y (/ (ky2 t x y) 2)))))
        (define (ky4 t x y) (* h (fy (+ t h)       (+ x    (kx3 t x y))    (+ y    (ky3 t x y)))))
        (define (x-next t x y)
	  (+ x
	     (/ (+ (kx1 t x y) (* 2 (kx2 t x y)) (* 2 (kx3 t x y)) (kx4 t x y)) 6)))
        (define (y-next t x y)
	  (+ y
	     (/ (+ (ky1 t x y) (* 2 (ky2 t x y)) (* 2 (ky3 t x y)) (ky4 t x y)) 6)))
        (define (data t x y)
	  (list h t x y (+ t h) (x-next t x y) (y-next t x y)))
        (define (interrupt?) #f)
        (define (stop? datum) #t)
        (let loop ((acc ()) (t t0) (x x0) (y y0))
	  (if (or (interrupt?) (and (pair? acc) (hook acc)))
	    (if (stop? acc)
	      (reverse acc)
	      (loop (cons (data t x y) acc)
		    (+ t h)
		    (x-next t x y)
		    (y-next t x y)))
	    (loop (cons (data t x y) acc)
		  (+ t h)
		  (x-next t x y)
		  (y-next t x y))))))))

(if (defined? '*args*)
  (if (null? *args*)
    ()
    (cond
      ((string=? (car *args*) "help")
       (display "SYNOPSIS\n")
       (display "\n")
       (display "    rk4.scm help\n")
       (display "      displays this message\n")
       (display "\n")
       (display "    rk4.scm go2  h x0 y0 f hook [lib ...]\n")
       (display "      go2 : analyzing differential equation that has 2 variable\n")
       (display "      h   : step-size for x\n")
       (display "      x0  : initial value of x\n")
       (display "      y0  : initial value of y\n")
       (display "      f   : function for dy/dx = f(x,y)\n")
       (display "      hook: no-argument-function to return function\n")
       (display "            that has list argument and stop the iteration of analyzing\n")
       (display "  i.e.\n")
       (display "    rk4.scm go2 0.2 0 100 i131-xe131 half-decay\n")
       (display "\n")
       (display "    rk4.scm go3  h t0 x0 y0 fx fy hook [lib ...]\n")
       (display "      go3 : analyzing differential equation that has 3 variable\n")
       (display "      h   : step-size for x\n")
       (display "      t0  : initial value of t\n")
       (display "      x0  : initial value of x\n")
       (display "      y0  : initial value of y\n")
       (display "      fx  : function for dx/dt = fx(t,x,y)\n")
       (display "      fy  : function for dy/dt = fy(t,x,y)\n")
       (display "      hook: no-argument-function to return function\n")
       (display "            that has list argument and stop the iteration of analyzing\n")
       (display "  i.e.\n")
       (display "    rk4.scm go3 1 0 1000 100 lotka-volterra-dx/dt lotka-volterra-dy/dt time-over\n")
       (display "\n\n")
       (display "DESCRIPTION\n")
       (display "  By Runge-Kutta method (RK4),\n")
       (display "  resolves the differential equation.\n")
       (display "  \n")
       (display "\n"))
      ((string=? (car *args*) "go2")
       (let
	 ((h    (string->number (list-ref  *args* 1)))
	  (x    (string->number (list-ref  *args* 2)))
	  (y    (string->number (list-ref  *args* 3)))
	  (f    (string->symbol (list-ref  *args* 4)))
	  (hook (string->symbol (list-ref  *args* 5)))
	  (libs                 (rk4::drop *args* 6)))
	 (rk4::load-libs libs)
         (let ((datum (rk4::go2 h x y f hook)))
	   (rk4::disp datum
		      (list
		        (lambda (x)
			  (fix-right 4 (fix-fp 2 x)))      ; h
			()                                 ; t
			(lambda (x)
			  (fix-right 5 (fix-fp 2 x)))      ; x
			(lambda (x)
			  (fix-right 7 (fix-fp 2 x)))      ; y
			()                                 ; t+1
		        (lambda (x)
			  (fix-right 5 (fix-fp 2 x)))      ; x+1
			(lambda (x)
			  (fix-right 7 (fix-fp 2 x)))))))) ; y+1
      ((string=? (car *args*) "go3")
       (let
	 ((h    (string->number (list-ref  *args* 1)))
	  (t    (string->number (list-ref  *args* 2)))
	  (x    (string->number (list-ref  *args* 3)))
	  (y    (string->number (list-ref  *args* 4)))
	  (fx   (string->symbol (list-ref  *args* 5)))
	  (fy   (string->symbol (list-ref  *args* 6)))
	  (hook (string->symbol (list-ref  *args* 7)))
	  (libs                 (rk4::drop *args* 8)))
	 (display "go3\n")
	 (rk4::load-libs libs)
         (let ((datum (rk4::go3 h t x y fx fy hook)))
	   (rk4::disp datum
		      (list
		        (lambda (x)
			  (fix-right 3 (fix-fp 1 x)))         ; h
			(lambda (x)
			  (fix-right 6 (fix-fp 1 x)))         ; t
			(lambda (x)
			  (fix-right 6 (fix-fp 1 x)))         ; x
			(lambda (x)
			  (fix-right 6 (fix-fp 1 x)))         ; y
			(lambda (x)
			  (fix-right 6 (fix-fp 1 x)))         ; t+1
		        (lambda (x)
			  (fix-right 6 (fix-fp 1 x)))         ; x+1
			(lambda (x)
			  (fix-right 6 (fix-fp 1 x))))))))))) ; y+1

(display "Loaded rk4.scm\n")

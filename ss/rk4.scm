;;;;;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
(define (any->string val)
  (letrec
    ((atom->string  (lambda (val)
      (cond
        ((string? val) val)
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
;;; very simple diagram
(define (diagram x-range y-range display-size opts datum)
  (letrec ; 1024x600
    ((wx (car  display-size))
     (wy (cadr display-size))
     (ux '(0.09 0.96))
     (uy '(0.05 0.9))
     (tx (lambda (x)
        (letrec ((w (- (cadr x-range) (car x-range)))
                 (m (/ (* wx (- (cadr ux) (car ux))) w)))
          (+ (* m (- x (car x-range))) (* wx (car ux))))))
     (ty (lambda (y)
        (letrec ((w (- (cadr y-range) (car y-range)))
                 (m (/ (* wy (- (cadr uy) (car uy))) w)))
          (- (* wy (cadr uy)) (* m (- y (car y-range)))))))
     (linex (lambda (x0 y0 x1 y1 color scn)
       (add-line scn x0 y0 x1 y1 color)))
     (textx (lambda (align str size shape color x y scn)
       (letrec ((txtimg (text str size shape color))
                (h (image-height txtimg))
                (w (image-width  txtimg)))
         (cond
           ((symbol=? align 'bottom) (place-image txtimg x                (- y (/ h 2)) scn))
           ((symbol=? align 'top   ) (place-image txtimg x                (+ y (/ h 2)) scn))
           ((symbol=? align 'right ) (place-image txtimg (- x (/ w 2) 10) y       scn))
           ((symbol=? align 'left )  (place-image txtimg (+ x (/ w 2) 10) y       scn))
           (else                     (place-image txtimg x                y       scn))))))
     (scale-x (lambda (scn)
       (letrec
         ((start (car  x-range))
          (end   (cadr x-range))
          (div   (if (empty? (cddr x-range)) 1 (caddr x-range)))
          (step (/ (- end start) div))
          (loop (lambda (n scn)
            (let ((z (+ start (* step n))))
              (if (< div n)
                scn
                (loop (+ n 1)
                  (linex (tx z) (- (ty 0) 5) (tx z) (+ (ty 0) 5) "black"
                    (textx 'top (number->string z) 16 "solid" "black" (tx z) (ty 0)
                      scn))))))))
         (loop 0 scn))))
     (scale-y (lambda (scn)
       (letrec
         ((start (car  y-range))
          (end   (cadr y-range))
          (div   (if (empty? (cddr y-range)) 1 (caddr y-range)))
          (step (/ (- end start) div))
          (loop (lambda (n scn)
            (let ((z (+ start (* step n))))
              (if (< div n)
                scn
                (loop (+ n 1)
                  (linex (- (tx 0) 5) (ty z) (+ (tx 0) 5) (ty z) "black"
                    (textx 'right (number->string z) 16 "solid" "black" (tx 0) (ty z)
                      scn))))))))
         (loop 0 scn))))
     (axis (lambda (scn)
       (linex (tx 0) (ty 0) (tx (cadr x-range)) (ty 0) "black"
         (linex (tx 0) (ty 0) (tx 0) (ty (cadr y-range)) "black"
                   scn))))
     (colors (lambda(lst)
       (if (empty? lst)
         (list "purple" "blue" "green" "yellow" "red")
         lst)))
     (draw (lambda (x ys rest cs scn)
       (let ((cs (colors cs)))
         (if (empty? ys)
           (loop rest scn)
           (place-image
             (circle 4 "solid" (car cs))
             (tx x)
             (ty (car ys))
             (draw x (cdr ys) rest (cdr cs) scn))))))
     (parse-options (lambda (scn)
       (letrec
         ((loop (lambda (opts scn)
            (if (empty? opts)
              scn
              (loop (cdr opts)
                (cond
                  ((symbol=? (caar opts) 'cap)
                   (textx (list-ref (car opts) 1)      ; align
                          (list-ref (car opts) 2)      ; str
                          16 "solid" "black"           ; size, shape, color
                          (tx (list-ref (car opts) 3)) ; x
                          (ty (list-ref (car opts) 4)) ; y
                          scn))
                  ((symbol=? (caar opts) 'leg) scn)
                  (else scn)))))))
         (loop opts scn))))
     (loop (lambda (datum scn)
       (if (empty? datum)
         scn
         (draw (caar datum) (cdar datum) (cdr datum) (colors '()) scn)))))
    (show-image
      (parse-options
        (loop datum (scale-x (scale-y (axis (empty-scene)))))))))
;;;;;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
;;; Runge-Kutta method
;;;   for 1 independent variable and N dependet variable
(define (rk4 h ini-vals funcs hook)
  (letrec
    ((N (length funcs))
     (k1 (lambda (n vals)
       (* h ((list-ref funcs n) vals))))
     (k2 (lambda (n vals)
       (* h 
          ((list-ref funcs n)
             (cons (+ (car vals) (/ h 2))
               (letrec
                 ((loop (lambda (acc i)
                    (if (<= N i)
                      (reverse acc)
                      (loop (cons (+ (list-ref vals (+ i 1)) (/ (k1 i vals) 2)) acc) (+ i 1))))))
                 (loop empty 0)))))))
     (k3 (lambda (n vals)
       (* h
          ((list-ref funcs n)
             (cons (+ (car vals) (/ h 2))
               (letrec
                 ((loop (lambda (acc i)
                    (if (<= N i)
                      (reverse acc)
                      (loop (cons (+ (list-ref vals (+ i 1)) (/ (k2 i vals) 2)) acc) (+ i 1))))))
                 (loop empty 0)))))))
     (k4 (lambda (n vals)
       (* h
          ((list-ref funcs n)
             (cons (+ (car vals) h)
               (letrec
                 ((loop (lambda (acc i)
                    (if (<= N i)
                      (reverse acc)
                      (loop (cons (+ (list-ref vals (+ i 1)) (k3 i vals)) acc) (+ i 1))))))
                 (loop empty 0)))))))
     (next (lambda (n vals)
             (+ (list-ref vals (+ n 1))
               (/
                 (+ (k1 n vals)
                    (* 2 (k2 n vals))
                    (* 2 (k3 n vals))
                    (k4 n vals))
                 6))))
     (line (lambda (vals)
             (cons
               (+ h (car vals))
               (letrec
                 ((loop (lambda (acc n)
                          (if (<= N n)
                            (reverse acc)
                            (loop
                              (cons (next n vals) acc)
                              (+ n 1))))))
                 (loop empty 0)))))
     (loop (lambda (acc vals)
               (if (empty? (hook ini-vals vals))
                 (reverse (cons vals acc))
                 (loop (cons vals acc) (line vals))))))
    (loop empty ini-vals)))
;;;;;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
;;; Lotka-Volterra equations
;;;   t: day
;;;   x: number of rabbits
;;;   y: number of foxes
;;;   a = 0.01 / b = 0.05 / c = 0.001
;;;   dx/dt =  ax - cxy = fx(t,x,y)
;;;   dy/dt = -by + cxy = fy(t,x,y)
(define a 0.01)
(define b 0.05)
(define c 0.0001)

(define (fx vals)
  (let ((t (list-ref vals 0))
        (x (list-ref vals 1))
        (y (list-ref vals 2)))
    (- (* a x) (* c x y))))

(define (fy vals)
  (let ((t (list-ref vals 0))
        (x (list-ref vals 1))
        (y (list-ref vals 2)))
    (+ (* (- b) y) (* c x y))))

;;; hook for stopping calculation
(define (hook ini-vals vals)
  (let ((t (list-ref vals 0))
        (x (list-ref vals 1))
        (y (list-ref vals 2)))
    (begin
      ;(println (any->string vals))
      (if (>= t (* 1000)) empty vals))))  ;;; <<== IMPORTANT
;;;;;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
;;; calculates and displays result diagram
(define lotka-volterra (rk4 1.0 (list 0 1000 100) (list fx fy) hook))
(diagram '(0 1000 10) '(0 1000 10)
  ;'(1024 480)  ;;; 1024x0600
  '( 600 924)  ;;; 0600x1024
  (list
    (list 'cap 'left "rabbits" 0 1000)
    (list 'cap 'left "foxes"   0  100)
    (list 'leg 800 1000))
  lotka-volterra)

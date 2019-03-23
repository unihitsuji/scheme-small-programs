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
;;; very simple diagram
(define (diagram x-min2max y-min2max display-size opts datum)
  (letrec
    ((pi 3.141592653589793)
     (e  2.718281828459045)
     (K  1000)
     (M  1000000)
     (wx (car display-size))
     (wy (- (cadr display-size) 120)) ; tool, title and navigation bar
     (ux '(0.09 0.96))
     (uy '(0.05 0.9))
     (scale-base (lambda (lst)
       (if (<= 4 (length lst))
         (let ((x (cond
                    ((symbol=? (list-ref lst 3) 'pi) pi)
                    ((symbol=? (list-ref lst 3) 'e)  e)
                    ((symbol=? (list-ref lst 3) 'K)  K)
                    ((symbol=? (list-ref lst 3) 'M)  M)
                    (else 1))))
           (list (* (list-ref lst 0) x)
                 (* (list-ref lst 1) x)
                    (list-ref lst 2)
                    (list-ref lst 3)
                 x))
         (if (<= 3 (length lst))
           lst
           (list (list-ref lst 0) (list-ref lst 1) 1)))))
     (x-range (scale-base x-min2max))
     (y-range (scale-base y-min2max))
     (tx (lambda (x)
        (letrec ((w (- (cadr x-range) (car x-range)))
                 (m (/ (* wx (- (cadr ux) (car ux))) w)))
          (+ (* m (- x (car x-range))) (* wx (car ux))))))
     (ty (lambda (y)
        (letrec ((w (- (cadr y-range) (car y-range)))
                 (m (/ (* wy (- (cadr uy) (car uy))) w)))
          (- (* wy (cadr uy)) (* m (- y (car y-range)))))))
     (circlex (lambda (color x y scn)
       (place-image (circle 4 "solid" color) x y scn)))
     (linex (lambda (x0 y0 x1 y1 color scn)
       (add-line scn x0 y0 x1 y1 color)))
     (textx (lambda (align str x y scn)
       (letrec ((txtimg (text str 16 "solid" "black"))
                (h (image-height txtimg))
                (w (image-width  txtimg)))
         (cond
           ((symbol=? align 'bottom) (place-image txtimg x             (- y (/ h 2)) scn))
           ((symbol=? align 'top   ) (place-image txtimg x             (+ y (/ h 2)) scn))
           ((symbol=? align 'right ) (place-image txtimg (- x (/ w 2)) y       scn))
           ((symbol=? align 'left )  (place-image txtimg (+ x (/ w 2)) y       scn))
           (else                     (place-image txtimg x             y       scn))))))
     (textx* (lambda (align strs x y scn)
       (if (empty? strs)
         scn
         (textx* align (cdr strs) x (+ y 16)
           (textx align (car strs) x y scn)))))
     (split (lambda (str delimiters)
       (letrec
         ((in? (lambda (delimiters c)
            (if (empty? delimiters)
              #f
              (if (char=? (car delimiters) c)
                #t
                (in? (cdr delimiters) c)))))
          (loop (lambda (acc accs clst)
            (if (empty? clst)
              (if (empty? acc)
                (reverse accs)
                (reverse (cons (list->string (reverse acc)) accs)))
              (if (in? delimiters (car clst))
                (loop empty (cons (list->string (reverse acc)) accs) (cdr clst))
                (loop (cons (car clst) acc) accs (cdr clst)))))))
         (loop empty empty (string->list str)))))
     (colors (lambda(lst)
       (if (empty? lst)
         (list "purple" "blue" "green" "red")
         lst)))
     (limit-fp (lambda (n len)
       (let ((n (if (ormap (lambda (c) (char=? c '.')) (string->list (number->string n)))
                  (/ (round (* n (expt 10 len))) 1.0 (expt 10 len))
                  n)))
         (if (= (abs n) 0.0)
           "0"
           (if (< (abs n) 1)
             (string-append
               (if (< n 0) "-" "")
               (list->string (cdr (string->list (number->string (abs n))))))
             (number->string n))))))
     (scale (lambda (n range)
       (if (< (length range) 5)
         (let* ((nstr (limit-fp n 3))
                (clst (reverse (string->list nstr))))
           (if (and (< 2 (length clst)) (char=? (car clst) '0') (char=? (cadr clst) '.'))
             (list->string (reverse (cddr clst)))
             nstr))
         (let* ((nstr (limit-fp (/ n (list-ref range 4)) 3))
                (clst (reverse (string->list nstr)))
                (p (symbol->string (list-ref range 3))))
           (cond
             ((string=? nstr "0") nstr)
             ((string=? nstr "1.0") p)
             ((string=? nstr "-1.0") (string-append "-" p))
             ((and (< 2 (length clst)) (char=? (car clst) '0') (char=? (cadr clst) '.'))
                 (string-append (list->string (reverse (cddr clst))) p))
             (else (string-append nstr p)))))))
     (scale-x (lambda (scn)
       (letrec
         ((start (list-ref x-range 0))
          (end   (list-ref x-range 1))
          (div   (list-ref x-range 2))
          (step (/ (- end start) (* div 1.0)))
          (loop (lambda (n scn)
            (let ((z (+ start (* step n))))
              (if (< div n)
                scn
                (loop (+ n 1)
                  (linex (tx z) (- (ty 0) 5) (tx z) (+ (ty 0) 5) "black"
                    (textx 'top (scale z x-range) (tx z) (+ (ty 0) 5)
                      scn))))))))
         (loop 0 scn))))
     (scale-y (lambda (scn)
       (letrec
         ((start (list-ref y-range 0))
          (end   (list-ref y-range 1))
          (div   (list-ref y-range 2))
          (step (/ (- end start) (* div 1.0)))
          (loop (lambda (n scn)
            (let ((z (+ start (* step n))))
              (if (< div n)
                scn
                (loop (+ n 1)
                  (linex (- (tx 0) 5) (ty z) (+ (tx 0) 5) (ty z) "black"
                    (textx 'right (scale z y-range) (- (tx 0) 10) (ty z)
                      scn))))))))
         (loop 0 scn))))
     (axis (lambda (scn)
       (linex (tx (car x-range)) (ty 0) (tx (cadr x-range)) (ty 0) "black"
         (linex (tx 0) (ty (car y-range)) (tx 0) (ty (cadr y-range)) "black"
                   scn))))
     (legend (lambda (strs x y px py scn)
       (letrec
         ((loop (lambda (strs x y cs scn)
            (let ((cs (colors cs)))
              (if (empty? strs)
                scn
                (loop (cdr strs) x (+ y py) (cdr cs)
                  (textx 'left (car strs) (+ x px) y
                    (circlex (car cs) x (+ y 5) scn))))))))
         (loop strs (tx x) (ty y) empty scn))))
     (parse-options (lambda (scn)
       (letrec
         ((loop (lambda (opts scn)
            (if (empty? opts)
              scn
              (loop (cdr opts)
                (cond
                  ((symbol=? (caar opts) 'caption)
                   (textx* (list-ref (car opts) 1)      ; align
                           (split (list-ref (car opts) 2) (list '\n'))
                           (tx (list-ref (car opts) 3)) ; x
                           (ty (list-ref (car opts) 4)) ; y
                           scn))
                  ((symbol=? (caar opts) 'legend)
                   (legend (list-ref (car opts) 1) ; strs
                           (list-ref (car opts) 2) ; x
                           (list-ref (car opts) 3) ; y
                           (list-ref (car opts) 4) ; px
                           (list-ref (car opts) 5) ; py
                           scn))
                  (else scn)))))))
         (loop opts scn))))
     (plot-serial (lambda (xys rest cs scn)
       (let ((cs (colors cs)))
         (if (empty? xys)
           (loop rest (cdr cs) scn)
           (circlex
             (car cs)
             (tx (list-ref (car xys) 0))
             (ty (list-ref (car xys) 1))
             (plot-serial (cdr xys) rest cs scn))))))
     (plot-parallel (lambda (x ys rest cs scn)
       (let ((cs (colors cs)))
         (if (empty? ys)
           (loop rest empty scn)
           (circlex
             (car cs)
             (tx x)
             (ty (car ys))
             (plot-parallel x (cdr ys) rest (cdr cs) scn))))))
     (loop (lambda (datum cs scn)
       (if (empty? datum)
         scn
         (if (cons? (caar datum))
           (plot-serial (car datum) (cdr datum) cs scn)
           (plot-parallel (caar datum) (cdar datum) (cdr datum) cs scn))))))
    (show-image
      (parse-options (scale-x (scale-y (axis
        (loop datum empty (empty-scene)))))))))
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
(diagram
  (list 0 1000 10) ;;; x scale from 0 to 1000 step 10
  (list 0 1000 10) ;;; y scale from 0 to 1000 step 10
  ;;; display size case 1024x600
  (list 1024  600)  ;;; landscape
  ;(list  600 1024)  ;;; portrait
  ;;; options
  (list
    (list 'caption 'left "fall of the uppers\n    in food chain" 140 120)
    (list 'legend (list "rabbits" "foxes") 800 800 10 20))
  ;;; datum
  lotka-volterra)

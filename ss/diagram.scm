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
;;; ex1
(define var (build-list 100 (lambda (i) (/ i 10.0))))
(define datum
  (list
    (map (lambda (x) (list x       (* x 10)))             var)
    (map (lambda (x) (list x       (* x x)))              var)
    (map (lambda (x) (list (+ x 1) (* 10 (log (+ x 1))))) (take var 90))))
(diagram (list 0 11 11) (list 0 100 10) ; min max step-count
  (list 1024 600) ; landscape
  (list  ; options
    (list 'caption 'left "diagram function can use\ncaptions and legend." 2 80)
    (list 'caption 'left "multi-line caption is available with \"\\n\""   2 70)
    (list 'caption 'left "log 1 = 0"   0.7 25)
    (list 'legend (list "x * 10" "x^2" "10 log(x + 1)") 9 60 10 20))
  datum)
;;;;;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
;;; ex2
;(define var (build-list 101 (lambda (i) (/ (* 3.14159265358979 (- i 50)) 50))))
;(define datum
;  (list
;    (map (lambda (x) (list x (sin x))) var)
;    (map (lambda (x) (list x (cos x))) var)))
;(diagram (list -2 2 16 'pi) (list -1 1 10) ; min max step-count
;  (list 1024 600) ; landscape
;  (list  ; options
;    (list 'caption 'left "diagram function can use pi scale." (* -1.7 3.14) 0.8)
;    (list 'legend (list "sin" "cos") (* 1.5 3.14) 0.8 10 20))
;  datum)

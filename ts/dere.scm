#!/data/data/com.termux/files/usr/bin/tinyscheme -1

;;;;;; general functions
;;;;;;; >>>>>>> lib.scm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (top sym) (eval sym))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (each lst fx) (map fx lst))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (repeat fx lst)
  (if (null? lst)
      ()
      (begin
	(fx (car lst))
	(repeat fx (cdr lst)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (consr lst acc)
  (if (null? lst)
      acc
      (consr (cdr lst) (cons (car lst) acc))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (flatten lst)
  (define (flatten-inner acc lst)
    (if (null? lst)
      acc
      (if (list? (car lst))
	(flatten-inner
	  (flatten-inner acc (car lst))
	  (cdr lst))
	(flatten-inner (cons (car lst) acc) (cdr lst)))))
  (reverse (flatten-inner '() lst)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (list-head lst n)
  (reverse
   (let loop ((acc ()) (lst lst) (n n))
     (if (or (null? lst) (<= n 0))
	 acc
	 (loop (cons (car lst) acc) (cdr lst) (- n 1))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (list-max lst)
  (foldr (lambda (a b)
	   (if (> a b)
	       (if (exact? b) a (+ a 0.0))
	       (if (exact? a) b (+ b 0.0))))
	 (car lst) (cdr lst)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (list-min lst)
  (foldr (lambda (a b)
	   (if (< a b)
	       (if (exact? b) a (+ a 0.0))
	       (if (exact? a) b (+ b 0.0))))
	 (car lst) (cdr lst)))
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
(define (string<-any val)
  (cond
   ((string? val) val)
   ((symbol? val) (symbol->string val))
   ((number? val) (number->string val))
   ((char?   val) (string val))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (stringer del lst)
  (apply string-append
	 (reverse
	   (let loop ((acc (list (string<-any (car lst))))
	              (del (string<-any del))
		      (lst (cdr lst)))
             (if (null? lst)
               acc
               (loop
                 (cons (string<-any (car lst))
                       (cons del acc))
                 del
                 (cdr lst)))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (stringer* del . lst)
  (stringer del lst))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (place n . base)
  (let ((base (if (null? base) 10 (car base))))
    (let loop ((i 1)) (if (< n (expt base i)) i (loop (+ i 1))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (radix n place . base)
  (let ((base (if (null? base) 10 (car base))))
    (modulo (inexact->exact (floor (/ n (expt base (- place 1)))))
            base)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (generator lst)
  (lambda ()
    (if (null? lst)
      ()
      (let ((ret (car lst)))
	(set! lst (cdr lst))
	ret))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define sort
  (make-environment
    (define (radix lst base key)
      (define (return-list<-vector v)
	(let loop ((i 0))
          (if (>= i base)
            (flatten (vector->list v))
            (begin
              (vector-set! v i (reverse (vector-ref v i)))
              (loop (+ i 1))))))
      (define (sort-place place lst)
        (let ((v (make-vector base ())))
          (let loop ((lst lst))
            (if (null? lst)
              (return-list<-vector v)
              (let ((i ((top 'radix) (key (car lst)) place base)))
                (vector-set! v i (cons (car lst) (vector-ref v i)))
                (loop (cdr lst)))))))
      (let ((max-place (place (apply max (map key lst)) base)))
        (let loop ((p 1) (lst lst))
          (if (< max-place p)
              lst
              (loop (+ 1 p) (sort-place p lst))))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (nth lst n . default)  ;;; different from (list-ref lst n)
  (let ((default (if (null? default) () (car default))))
    (let loop ((lst lst) (n n))
      (if (null? lst)
        default
        (if (<= n 0)
          (car lst)
          (loop (cdr lst) (- n 1)))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (over? a b . keys)
  (let ((k1 (nth keys 0 car)) (k2 (nth keys 1 cdr)))
    (or (<= (k1 a) (k1 b) (k2 a))
	(<= (k1 b) (k1 a) (k2 b)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (merge2 a b . keys)
  (let ((k1 (nth keys 0 car)) (k2 (nth keys 1 cdr)) (cf (nth keys 2 cons)))
    (cf (min (k1 a) (k1 b)) (max (k2 a) (k2 b)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (merge lst . keys)
  (let ((k1 (nth keys 0 car)) (k2 (nth keys 1 cdr)) (cf (nth keys 2 cons)))
    (define (merge-head head remain checked)
      (if (null? remain)
        (cons head (reverse checked))
        (if (over? head (car remain) k1 k2)
          (merge-head
            (merge2 head (car remain) k1 k2 cf)
            (cdr remain)
            checked)
          (merge-head
            head
            (cdr remain)
            (cons (car remain) checked)))))
    (let loop ((acc ()) (lst (sort::radix lst 10 k1)))
      (if (null? lst)
        (reverse acc)
        (let ((merged (merge-head (car lst) (cdr lst) ())))
          (loop
            (cons (car merged) acc)
            (cdr merged)))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (product2 a b . keys)
  (let ((k1 (nth keys 0 car)) (k2 (nth keys 1 cdr)) (cf (nth keys 2 cons)))
    (cf (max (k1 a) (k1 b)) (min (k2 a) (k2 b)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
(define (product as bs . keys)
  (let ((k1 (nth keys 0 car)) (k2 (nth keys 1 cdr)) (cf (nth keys 2 cons)))
    (define (inner acc elem lst)
      (if (null? lst)
        (reverse acc)
        (if (over? elem (car lst) k1 k2)
          (inner
            (cons (product2 elem (car lst) k1 k2 cf) acc)
            elem
	    (cdr lst))
          (inner acc elem (cdr lst)))))
    (let loop ((acc ()) (lst as))
      (if (null? lst)
	(reverse acc)
	(loop
	  (consr (inner '() (car lst) bs) acc)
	  (cdr lst))))))
;;;;;;; <<<<<<< lib.scm

(define dere
  (make-environment
    ;; non-official values
    (define kanari    8.92)
    (define shibaraku 7.43)
    (define sukoshi   5.94)
    (define wazuka    4.46)
    (define isshun    2.97)
    ;; official values
    (define kou       0.600)
    (define chuu      0.525)
    (define pote-tokugi
      '((sr  0 0.01 0.02 0.03 0.04 0.06 0.08 0.10 0.13 0.16 0.20)
	(ssr 0 0.01 0.02 0.03 0.04 0.06 0.08 0.10 0.13 0.16 0.20)))
    (define pote-life
      '((sr  0    1    2    4    6    8   10   12   14   17   20)
	(ssr 0    1    2    4    6    8   10   13   16   19   22)))
    (define pote-appeal
      '((sr  0   60  120  180  250  320  390  460  540  620  700)
	(ssr 0   40   80  120  170  220  270  320  380  440  500)))
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    ;; proper functions
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    (define (resolve val)
      (if (symbol? val) (eval val) val))
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    (define (d2u a b) (- (car b) (car a)))
    (define (u2d a b) (- (car a) (car b)))
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    (define (disp vals)
      (if (null? vals)
          (display "\n")
          (begin
            (display (car vals))
            (disp   (cdr vals)))))
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    (define (disp* . vals) (disp vals))
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    (define (rare     idol)      (car    idol))
    (define (pote     idol)      (cadr   idol))
    (define (freq     idol)      (caddr  idol))
    (define (fire     idol)      (cadddr idol))
    (define (duration idol) (car (cddddr idol)))
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    (define (range len start duration)
      (cons start
	    (if (<= len (+ start duration))
		len
		(+ start duration))))
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    (define (ranges len idols)
      (let ((stop (- len 3)))
        (define (inner acc start freq duration)
          (if (> start stop)
            (reverse acc)
            (inner
              (cons (range len start duration) acc)
              (+ start freq)
              freq
              duration)))
        (let loop ((acc ()) (remain idols))
          (if (null? remain)
	    (apply append (reverse acc))
	    (loop (cons (inner '()                                       ; acc
			       (freq           (resolve (car remain)))   ; start
	                       (freq           (resolve (car remain)))   ; freq
	                       (eval (duration (resolve (car remain))))) ; duration
		        acc)           ; acc
		  (cdr remain))))))    ; remain
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    (define (exclude base-pair pairs)
      (let loop ((acc ()) (base-pair base-pair) (pairs pairs))
        (if (null? pairs)
	  (if (<= (cdr base-pair) (car base-pair))
	    (reverse acc)
	    (reverse (cons base-pair acc)))
	  (loop
            (if (>= (car base-pair) (caar pairs))
              acc
	      (cons
	        (cons (car base-pair) (caar pairs))
	        acc))
            (cons (cdar pairs) (cdr base-pair))
            (cdr pairs)))))
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    (define (cover   len idols)
      (merge (dere::ranges len idols)))
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    (define (uncover len idols)
      (exclude (cons 0 len) (cover len idols)))
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    (define (ratio denomination-pair pairs)
      (/
        (let loop ((acc 0) (pairs pairs))
          (if (null? pairs)
	    acc
	    (loop (+ acc
	            (-
                      (if (< (cdr denomination-pair) (cdar pairs))
                        (cdr  denomination-pair)
                        (cdar pairs))
                      (if (< (caar pairs) (car denomination-pair))
                        (car  denomination-pair)
       	                (caar pairs))))
                  (cdr pairs))))
        (- (cdr denomination-pair) (car denomination-pair))))
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    (define (cover-ratio   len idols)
      (ratio (cons 0 len) (cover len idols)))
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    (define (uncover-ratio len idols)
      (ratio (cons 0 len) (uncover len idols)))
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    (define (tokugi-table-part idol song-bonus center-bonus)
      (let ((prop (resolve idol)))
        (let ((cover (/ (resolve (duration prop)) (freq prop)))
              (fire  (* (resolve (fire  prop))
                        (+ 1 song-bonus center-bonus
                           (list-ref (cdr (assoc (rare prop) pote-tokugi))
                                   (pote prop))))))
          (list
            cover
            (if (< 1 fire) 1     fire)
            (if (< 1 fire) cover (* cover fire))))))
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    (define (tokugi-table-line idol)
      (let ((idol (resolve idol)))
        (list
	  (rare     idol)
	  (pote     idol)
          (freq     idol)
          (fire     idol)
          (duration idol)
          (car   (tokugi-table-part idol 0   0  ))    ; cover
          (cadr  (tokugi-table-part idol 0   0  ))    ; prob
          (caddr (tokugi-table-part idol 0   0  ))    ; expec
          (cadr  (tokugi-table-part idol 0.3 0  ))    ; prob
          (caddr (tokugi-table-part idol 0.3 0  ))    ; expec
          (cadr  (tokugi-table-part idol 0.3 0.3))    ; prob
          (caddr (tokugi-table-part idol 0.3 0.3))    ; expec
          (cadr  (tokugi-table-part idol 0.3 0.4))    ; prob
          (caddr (tokugi-table-part idol 0.3 0.4))    ; expec
          (cadr  (tokugi-table-part idol 0.3 0.5))    ; prob
          (caddr (tokugi-table-part idol 0.3 0.5))))) ; expec
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    (define (tokugi-table idols)
      (let ((keta 3))
        (define (display-round lst)
          (if (null? lst)
            ()
            (begin
              (display (fix-fp keta (round-n keta (car lst))))
              (display " ")
              (display-round (cdr lst)))))
        (define (disp idols)
          (if (null? idols)
            ()
            (let ((idol (tokugi-table-line (car idols))))
              (display " ")
              (display (fix-left  4 (symbol->string (rare     idol)))) (display " ")
              (display (fix-right 4 (number->string (pote     idol)))) (display " ")
              (display (fix-right 4 (number->string (freq     idol)))) (display " ")
              (if (symbol? (fire idol))
                (display (fix-left  5 (symbol->string (fire idol))))
                (display (fix-right 5 (fix-fp 3       (fire idol)))))
              (display " ")
              (if (symbol? (duration idol))
                (display (fix-left  9 (symbol->string (duration idol))))
                (display (fix-right 9 (fix-fp 2       (duration idol)))))
              (display " ")
              (display-round (list-tail idol 5))
	      (if (symbol? (car idols)) (display (symbol->string (car idols))))
	      (display "\n")
              (disp (cdr idols)))))
        (display "+====================================+===========+===========+===========+===========+===========+\n")
        (display "|                                    | s .0 c .0 | s .3 c .0 | s .3 c .3 | s .3 c .4 | s .3 c .5 |\n")
        (display "+----+----+----+-----+---------+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+\n")
        (display "|rare|pote|freq|prob |duration |cover|prob |expec|prob |expec|prob |expec|prob |expec|prob |expec|\n")
        (display "+====+====+====+=====+=========+=====+=====+=====+=====+=====+=====+=====+=====+=====+=====+=====+\n")
        (disp idols)
        (display "+====+====+====+=====+=========+=====+=====+=====+=====+=====+=====+=====+=====+=====+=====+=====+\n")))
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    (define (help)
      (disp* "environment (package) \"dere\"")
      (disp* "")
      (disp* "ranges : Get ranges")
      (disp* "  synopsis")
      (disp* "    (dere::ranges stop len tokugi-properties)")
      (disp* "  i.e.")
      (disp* "    (dere::ranges 117 120 '((9 kou  wazuka)))")
      (disp* "    (dere::ranges 117 120 '((9 kou  wazuka) (12 kou sukoshi) (15 kou shibaraku)))")
      (disp* "    (dere::ranges 117 120 '(uduki rin mio))")
      (disp* "")
      (disp* "merge : Merge ranges")
      (disp* "  synopsis")
      (disp* "    (merge ranges . keys)")
      (disp* "  i.e.")
      (disp* "    (merge (dere::ranges 117 120 '(uduki rin mio)))")
      (disp* "    (merge '((1 . 3) (2 . 3) (6 . 7) (5 . 8) (7 . 9)) car cdr)")
      (disp* "    ;-> ((1 . 3) '(5 . 9))")
      (disp* "")
      (disp* "cover : get cover range by tokugi-properties")
      (disp* "  synopsis")
      (disp* "    (dere:cover len tokugi-properties)")
      (disp* "  i.e.")
      (disp* "    (dere::cover 120 '(uduki rin mio))")
      (disp* "  desciption")
      (disp* "    (dere::cover 120 '(uduki rin mio))")
      (disp* "      =")
      (disp* "    (merge (dere::renges (- 120 3) 120 '(uduki rin mio)))")
      (disp* "")
      (disp* "exclude : Exclude ranges from range")
      (disp* "  synopsis")
      (disp* "    (dere::exclude range ranges")
      (disp* "  i.e.")
      (disp* "    (dere::exclude '(0 . 120) (merge (dere::ranges 117 120 '(uduki rin mio))))")
      (disp* "")
      (disp* "ratio : Get cover ratio (merged-ranges / denomination-range)")
      (disp* "  synopsis")
      (disp* "    (dere::ratio denomination-range ranges)")
      (disp* "  i.e.")
      (disp* "    (dere::ratio '(0 . 120)                           (dere::merge (dere::ranges 117 120 '(uduki rin mio))))")
      (disp* "    (dere::ratio '(0 . 120) (dere::exclude '(0 . 120) (dere::merge (dere::ranges 117 120 '(uduki rin mio)))))")
      (disp* "")
      (disp* "tokugi-table")
      (disp* "  synopsis")
      (disp* "    (dere::tokugi-table tokugi-pote rare tokugi-properties)")
      (disp* "  i.e.")
      (disp* "    (dere::tokugi-table 0 'ssr '(uduki rin mio))")
      (disp* ""))
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;
    ;; for idols
    (define uduki     '(ssr  0  9 kou   wazuka))
    (define rin       '(ssr  0 12 kou   sukoshi))
    (define mio       '(ssr  0 15 kou   shibaraku))
    (define yuuki     '(ssr  0  7 kou   sukoshi))
    (define kanade    '(ssr  0  8 kou   shibaraku))
    (define kirari    '(ssr  0 10 kou   kanari))
    (define anzu      '(ssr  0 10 kou   kanari))
    (define airi      '(ssr  0  8 kou   shibaraku))
    (define miku      '(ssr  0  8 kou   shibaraku))
    (define anastasia '(ssr  0 10 kou   kanari))
    (define kotoka    '(sr   0  7 0.525 5.94))
    (define kotoka    '(sr   0  7 chuu  sukoshi))
    (define miyabi    '(sr   0  7 kou   wazuka))
    (define feifei    '(sr   0  8 chuu  wazuka))
    (define yuka      '(sr   0  9 chuu  shibaraku))
    (define seika     '(sr   0  9 kou   sukoshi))
    (define mai       '(sr   0 11 chuu  kanari))
    (define chika     '(sr   0 11 kou   shibaraku))
    (define mizuki    '(sr   5  7 chuu  sukoshi))
    (define nina      '(sr   5  7 chuu  sukoshi))
    (define nina7     '(sr   7  7 chuu  sukoshi))
    (define nina8     '(sr   8  7 chuu  sukoshi))
    (define nina9     '(sr   9  7 chuu  sukoshi))
    (define nina10    '(sr  10  7 chuu  sukoshi))
    ))

(if (defined? '*args*)
  (if (and (pair? *args*) (string=? (car *args*) "help"))
    (dere::help)
    (begin
      (display "ranges\n")
      (display (dere::ranges 120 '(uduki rin mio)))
      (display "\n\n")
      (display "ranges sort\n")
      (display (sort::radix (dere::ranges 120 '(uduki rin mio)) 10 car))
      (display "\n\n")
      (display "cover       uduki rin mio\n")
      (display (dere::cover 120 '(uduki rin mio)))
      (display "\n")
      (display "cover-ratio uduki rin mio: ")
      (display (dere::cover-ratio 120 '(uduki rin mio)))
      (display "\n")
      (display "cover-ratio uduki: ")
      (display (dere::cover-ratio 120 '(uduki)))
      (display "\n")
      (display "cover-ratio rin  : ")
      (display (dere::cover-ratio 120 '(rin)))
      (display "\n")
      (display "cover-ratio mio  : ")
      (display (dere::cover-ratio 120 '(mio)))
      (display "\n\n")
      (display "cover       uduki rin mio nina\n")
      (display (dere::cover 120 '(uduki rin mio nina)))
      (display "\n")
      (display "cover-ratio uduki rin mio nina: ")
      (display (dere::cover-ratio 120 '(uduki rin mio nina)))
      (display "\n\n")
      (display "uncover       uduki rin mio\n")
      (display (dere::uncover 120 '(uduki rin mio)))
      (display "\n")
      (display "uncover-ratio uduki rin mio: ")
      (display (dere::uncover-ratio 120 '(uduki rin mio)))
      (display "\n\n")
      (display "(cover uduki rin mio))\n")
      (display (dere::cover 120 '(uduki rin mio)))
      (display "\n")
      (display "(cover-ratio uduki rin mio): ")
      (display (dere::cover-ratio 120 '(uduki rin mio)))
      (display "\n")
      (display "(cover kanade)\n")
      (display (dere::cover 120 '(kanade)))
      (display "\n")
      (display "(cover-ratio kanade): ")
      (display (dere::cover-ratio 120 '(kanade)))
      (display "\n")
      (display "(product (cover uduki rin mio) (cover kanade))\n")
      (display (product (dere::cover 120 '(uduki rin mio)) (dere::cover 120 '(kanade))))
      (display "\n")
      (display "(ratio (product (cover uduki rin mio) (cover kanade))): ")
      (display (dere::ratio '(0 . 120) (product (dere::cover 120 '(uduki rin mio)) (dere::cover 120 '(kanade)))))
      (display "\n")
      (dere::tokugi-table '(uduki rin mio kotoka miyabi feifei yuka seika mai chika mizuki nina nina7 nina8 nina9 nina10))
      (display "\n"))))

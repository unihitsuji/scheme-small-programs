;;;;;;;;;1;;;;;;;;;2;;;;;;;;;3;;;;;;;;;4;;;;;;;;;5;;;;;;;;;6;;;;;;;;;7;;;;;;;;;
(define (string4any val)
  (letrec
    ((string4string (lambda (val)
       (letrec
         ((loop (lambda (acc rest)
	    (if (empty? rest)
              (list->string (reverse acc))
       	      (cond
	        ((char=? (car rest) #\newline)             ;; not compatible
                 (loop
		   (cons #\n (cons #\\ acc)) (cdr rest)))  ;; not compatible
                (else
                 (loop (cons (car rest) acc) (cdr rest))))))))
	 (loop empty (string->list val)))))
     (string4atom (lambda (val)
       (cond
         ((string? val) (string-append "\"" (string4string val) "\""))
         ((symbol? val) (symbol->string val))
         ((number? val) (number->string val))
         ((empty?  val) "()")
         (else "anything"))))
     (loop (lambda (val)
       (if (empty? val)
         ""
         (if (not (cons? val))
           (string-append (string4atom val))
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
                 (string4atom (car val))
                 (if (empty? (cdr val))
                   ""
                   (string-append " " (loop (cdr val))))))))))))
    (if (cons? val)
      (string-append "(" (loop val) ")")
      (string4atom val))))

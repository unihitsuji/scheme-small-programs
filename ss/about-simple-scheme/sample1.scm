;sample1.scm
(define center-x 268)
(define center-y 420)

(define (circles n i scn)
  (if (= (* n 2) i)
    scn
    (circles n (++ i)
      (place-image
        (circle (* 1.2 i) "outline" "red")
        (point center-x n i cos)
        (point center-y n i sin)
        scn))))

(define (point off n i fun)
  (+ off (* 3 i (fun (/ (* i pi 1.7) n)))))

(show-image
  (place-image
    (overlay
      (text "Spiral" 60 "outline" "black")
      (text "Spiral" 60 "solid" "#A00F"))
    center-x
    100
    (circles 30 0 (empty-scene))))
(declare-const n Int)
(declare-datatypes () ((Jug Big Small)))
(declare-datatypes () ((Act FillBig FillSmall EmptyBig EmptySmall BigToSmall SmallToBig)))
(declare-fun vol (Jug Int) Int)
(declare-fun act (Int) Act)

(assert (= n 6))
(assert (= (act 0) EmptyBig))
(assert (= (vol Big 0) 0))
(assert (= (vol Small 0) 0))

(assert (forall ((t Int)) 
  (implies (and (>= t 0) (<= t n)) 
    (or (= (act t) FillBig)
      (= (act t) FillSmall)
      (= (act t) EmptyBig)
      (= (act t) EmptySmall)
      (= (act t) BigToSmall)
      (= (act t) SmallToBig)
    ))))


(assert (forall ((t Int)) 
  (implies (and (> t 0) (<= t n)) 
  (or
      ;; Fill Big
      (and
         (= (act t) FillBig)
         (= (vol Big t) 5)
         (= (vol Small t) (vol Small (- t 1)))
      )
      ;; Empty Big
      (and
         (= (act t) EmptyBig)
         (= (vol Big t) 0)
         (= (vol Small t) (vol Small (- t 1)))
      )
      ;; Fill Small
      (and
         (= (act t) FillSmall)
         (= (vol Small t) 3)
         (= (vol Big t) (vol Big (- t 1)))
      )
      ;; Empty Small
      (and
         (= (act t) EmptySmall)
         (= (vol Small t) 0)
         (= (vol Big t) (vol Big (- t 1)))
      )

      ;; Big to Small
      (and
         (= (act t) BigToSmall)
         (let ((sum (+ (vol Big (- t 1)) 
                    (vol Small (- t 1)))))
            (ite (> sum 3)
               (and
                  (= (vol Small t) 3)
                  (let ((small-diff (- 3 (vol Small (- t 1)))))
                     (= (vol Big t) (- (vol Big (- t 1)) small-diff)))
               )
               (and
                  (= (vol Big t) 0)
                  (= (vol Small t) sum)
               )
            )
         )
      )

      ;; Small to Big
      (and
         (= (act t) SmallToBig)
         (let ((sum (+ (vol Big (- t 1)) 
                    (vol Small (- t 1)))))
            (ite (> sum 5)
               (and
                  (= (vol Big t) 5)
                  (let ((big-diff (- 5 (vol Big (- t 1)))))
                     (= (vol Small t) (- (vol Small (- t 1)) big-diff)))
               )
               (and
                  (= (vol Small t) 0)
                  (= (vol Big t) sum)
               )
            )
         )
      )
  ))))

 (assert (exists ((t Int)) 
     (and (> t 0) (<= t n) (= (vol Big t) 4))))
     
(check-sat)

(eval (act 0))
(eval (vol Big 0 ))
(eval (vol Small 0 ))

(eval (act 1))
(eval (vol Big 1 ))
(eval (vol Small 1 ))

(eval (act 2))
(eval (vol Big 2 ))
(eval (vol Small 2 ))

(eval (act 3))
(eval (vol Big 3 ))
(eval (vol Small 3 ))

(eval (act 4))
(eval (vol Big 4 ))
(eval (vol Small 4 ))

(eval (act 5))
(eval (vol Big 5 ))
(eval (vol Small 5 ))

(eval (act 6))
(eval (vol Big 6 ))
(eval (vol Small 6 ))


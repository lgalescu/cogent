;;;;
;;;; W::wickedly
;;;;

(define-words :pos W::adv :templ PRED-VP-TEMPL 
 :words (
	  (W::wickedly
	  (SENSES
	   ((LF-PARENT ONT::acceptability-val)
	    (TEMPL ADJ-OPERATOR-TEMPL)	    
	    (example "his ankles are wickedly swollen" "he is wickedly ill")
	    (SEM (f::gradability +) (f::orientation f::neg) (f::intensity f::hi))
	    (meta-data :origin cardiac :entry-date 20080613 :change-date nil :comments nil :wn nil)
	    )
	   ((LF-PARENT ONT::acceptability-val)
	    (TEMPL PRED-VP-TEMPL)	    
	    (example "he performed wickedly on the exam")
	    (SEM (f::gradability +) (f::orientation f::neg) (f::intensity f::hi))
	    (meta-data :origin cardiac :entry-date 20080613 :change-date nil :comments nil :wn nil)
	    )
	   )
	  )
))


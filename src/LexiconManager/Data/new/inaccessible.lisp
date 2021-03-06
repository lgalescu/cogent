;;;;
;;;; W::inaccessible
;;;;

(define-words :pos W::adj :templ CENTRAL-ADJ-TEMPL
 :words (
   (W::inaccessible
    (wordfeats (W::morph (:FORMS (-LY))))
   (SENSES
    ((LF-PARENT ONT::INACCESSIBLE)
     (example "the routes are inaccessible by helicopter")
     (SEM (F::GRADABILITY F::+))
     (TEMPL central-adj-xp-templ (XP (% W::PP (W::PTYPE (? pt W::on W::for w::by)))))
     (meta-data :origin calo-ontology :entry-date 20051209 :change-date 20090731 :wn ("inaccessible%3:00:00") :comments nil)
     )
    )
   )
))


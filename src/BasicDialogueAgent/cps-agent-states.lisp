;;  Basic Dialogue Agent State Management

(in-package :dagent)

;;(defvar *state-definitions* nil)



(add-state 'propose-cps-act
 (state :action nil ;;'(SAY-ONE-OF  :content ("What do you want to do?"))
	:transitions
	(list
	 #|
	 (transition
	 :description "Forget it.  Let's start over."
	 :pattern '((ONT::SPEECHACT ?!sa (? x ONT::PROPOSE ONT::REQUEST) :what ?!what)
	 (?spec ?!what (? t ONT::FORGET ONT::CANCEL ONT::RESTART))
	 (ont::eval (generate-AKRL-context :what ?!what :result ?akrl-context))
	 (ont::eval (find-attr :result ?goal :feature ACTIVE-GOAL))
	 -propose-restart>
	 (RECORD  CPS-HYPOTHESIS (PROPOSE :content ?!what :context ?akrl-context :active-goal ?goal))
	 (INVOKE-BA :msg (INTERPRET-SPEECH-ACT :content (PROPOSE :content ?!what :context ?akrl-context
	 :active-goal ?goal))))
	 :destination 'handle-csm-response
	 :trigger t)
	 |#

	 (transition
	  :description "proposal/request. eg: Let's build a model/I need to find a treatment for cancer/You put a block on the table; Also: You do it (i.e., change performer); How about building a staircase?"
	  :pattern '((ONT::SPEECHACT ?!sa (? x ONT::PROPOSE ONT::REQUEST ONT::REQUEST-COMMENT) :what ?!what)
		     ;; ((? spec ONT::EVENT ONT::EPI) ?!what ?!t)
		     ;(?!spec ?!what (? t ONT::EVENT-OF-ACTION)) ; "find" is not an EVENT-OF-ACTION
		     (?!spec ?!what ?!t)
		     (ont::eval (generate-AKRL-context :what ?!what :result ?akrl-context))
		     (ont::eval (find-attr :result ?goal :feature ACTIVE-GOAL))
		     -propose-goal>
		     (RECORD CPS-HYPOTHESIS (PROPOSE :content ?!what :context ?akrl-context :active-goal ?goal))
		     (INVOKE-BA :msg (INTERPRET-SPEECH-ACT
				      :content (PROPOSE :content ?!what
							:context ?akrl-context
							:active-goal ?goal)))
		     )
	  :destination 'handle-csm-response
	  :trigger t)
	 	 
	 (transition
	  :description "modification: Let's do X instead"
	  :pattern '((ONT::SPEECHACT ?!sa (? x ONT::PROPOSE ONT::REQUEST ONT::REQUEST-COMMENT) :what ?!what :AS ONT::ALTERNATIVE)
		     ;; ((? spec ONT::EVENT ONT::EPI) ?!what ?!t)
		     ;(?!spec ?!what (? t ONT::EVENT-OF-ACTION)) ; "find" is not an EVENT-OF-ACTION
		     (?!spec ?!what ?!t)
		     (?!spec2 ?v ?type)  ; e.g.. ?type is CHOICE-OPTION but we could expand to others later
		     (ont::eval (generate-AKRL-context :what ?!what :result ?akrl-context))
		     (ont::eval (find-attr :result ?goal :feature ACTIVE-GOAL))
		     -modify-goal>
		     (RECORD CPS-HYPOTHESIS (PROPOSE :content ?!what :context ?akrl-context :active-goal ?goal))
		     (INVOKE-BA :msg (INTERPRET-SPEECH-ACT
				      :content (PROPOSE :content ?!what
							;:as (MODIFY :of ?goal)
							:as (MODIFICATION)
							:context ?akrl-context
							:active-goal ?goal)))
		     )
	  :destination 'handle-csm-response
	  :trigger t)

	 (transition
	  :description "ask-wh. eg: what drug should we use?"
	  :pattern '((ONT::SPEECHACT ?!sa (? s-act ONT::ASK-WHAT-IS) :what ?!what)
		     (?!spec ?!what ?!object-type)
		     (ont::eval (generate-AKRL-context :what ?!what :result ?akrl-context))  
		     (ont::eval (find-attr :result ?goal :feature ACTIVE-GOAL))
		     -propose-goal-via-question>
		     (RECORD CPS-HYPOTHESIS (ONT::ASK-WHAT-IS :content ?!what :context ?akrl-context :active-goal ?goal))
		     (INVOKE-BA :msg (INTERPRET-SPEECH-ACT
				      :content (ONT::ASK-WHAT-IS :content ?!what
								 :context ?akrl-context
								 :active-goal ?goal)))
		     )
	  :destination 'handle-csm-response
	  :trigger t)

	 ;; (not any more) This should go after the previous (-propose-goal-via-question>)
	 (transition
	  :description "ask-if. eg: Does the BRAF-NRAS complex vanish?"
	  :pattern '((ONT::SPEECHACT ?!sa (? s-act ONT::ASK-IF) :what ?!what)
		     (?!spec ?!what ?!type)
		     (ont::eval (generate-AKRL-context :what ?!what :result ?akrl-context))  
		     (ont::eval (find-attr :result ?goal :feature ACTIVE-GOAL))
		     -ask-question>
		     (RECORD CPS-HYPOTHESIS (ONT::ASK-IF :content ?!what :context ?akrl-context :active-goal ?goal))
		     (INVOKE-BA :msg (INTERPRET-SPEECH-ACT
				      :content (ONT::ASK-IF :content ?!what
							    :context ?akrl-context
							    :active-goal ?goal)))
		     )
	  :destination 'handle-csm-response
	  :trigger t)
		      
	 (transition
	  :description "conditional ask-if. eg: is ERK activated if we add X"
	  :pattern '((ONT::SPEECHACT ?!sa ONT::ASK-CONDITIONAL-IF :what ?!what :condition ?!test)
		     ;; (ONT::EVENT ?!what ONT::SITUATION-ROOT)
		     ;; (ONT::EVENT ?!test ONT::EVENT-OF-CAUSATION) 
		     (?!sp1 ?!what (? t1 ONT::SITUATION-ROOT
;;; These are DRUM events.  Eventually they will go into a branch in the ontology.
ONT::ACTIVITY
ONT::DEPLETE
ONT::PHOSPHORYLATION
ONT::UBIQUITINATION
ONT::ACETYLATION
ONT::FARNESYLATION
ONT::GLYCOSYLATION
ONT::HYDROXYLATION
ONT::METHYLATION
ONT::RIBOSYLATION
ONT::SUMOYLATION
ONT::PTM
ONT::EXPRESS
ONT::TRANSCRIBE
ONT::TRANSLATE
ONT::HYDROLYZE
ONT::CATALYZE
ONT::ACTIVATE
ONT::PRODUCE
ONT::DEACTIVATE
ONT::CONSUME
ONT::STIMULATE
ONT::INHIBIT
ONT::INCREASE
ONT::DECREASE
ONT::PPEXPT
ONT::BIND
ONT::BREAK
ONT::TRANSLOCATE
ONT::MODULATE
ONT::NO-CHANGE
ONT::TRANSFORM
ONT::SIGNALING
ONT::INTERACT 
						   ))
		     (?!sp2 ?!test (? t2 ONT::EVENT-OF-CAUSATION
ONT::ACTIVITY
ONT::DEPLETE
ONT::PHOSPHORYLATION
ONT::UBIQUITINATION
ONT::ACETYLATION
ONT::FARNESYLATION
ONT::GLYCOSYLATION
ONT::HYDROXYLATION
ONT::METHYLATION
ONT::RIBOSYLATION
ONT::SUMOYLATION
ONT::PTM
ONT::EXPRESS
ONT::TRANSCRIBE
ONT::TRANSLATE
ONT::HYDROLYZE
ONT::CATALYZE
ONT::ACTIVATE
ONT::PRODUCE
ONT::DEACTIVATE
ONT::CONSUME
ONT::STIMULATE
ONT::INHIBIT
ONT::INCREASE
ONT::DECREASE
ONT::PPEXPT
ONT::BIND
ONT::BREAK
ONT::TRANSLOCATE
ONT::MODULATE
ONT::NO-CHANGE
ONT::TRANSFORM
ONT::SIGNALING
ONT::INTERACT 

				    )) 
		     (ont::eval (generate-AKRL-context :what ?!what :result ?akrl-context))
		     (ont::eval (find-attr :result ?goal :feature ACTIVE-GOAL))
		     -propose-test>
		     (RECORD CPS-HYPOTHESIS (ONT::ASK-CONDITIONAL-IF :content ?!what :condition ?!test :context ?akrl-context :active-goal ?goal))
		     (INVOKE-BA :msg (INTERPRET-SPEECH-ACT
				      :content (ONT::ASK-CONDITIONAL-IF :content ?!what
									:condition ?!test
									:context ?akrl-context
									:active-goal ?goal)))
		     )
	  :destination 'handle-csm-response
	  :trigger t)
		      
	 ; generic TELL.  
	 (transition
	  :description "assertion. eg: Kras activates Raf -- as performing steps in elaborating a model"
	  :pattern '((ONT::SPEECHACT ?!sa ONT::TELL :what ?!root)  ;; we allow intermediate verbs between SA and activate (e.g., KNOW)
		     ;;(ONT::EVENT ?!what ONT::ACTIVATE :agent ?!agent :affected ?!affected)
		     (ont::eval (generate-AKRL-context :what ?!root :result ?akrl-context))
		     (ont::eval (find-attr :result ?goal :feature ACTIVE-GOAL))
		     -refine-goal-with-assertion>
		     (RECORD CPS-HYPOTHESIS (ASSERTION :content ?!root :context ?akrl-context :active-goal ?goal))
		     (INVOKE-BA :msg (INTERPRET-SPEECH-ACT
				      :content (ASSERTION :content ?!root
							  :context ?akrl-context
							  :active-goal ?goal)))
		     )
	  :destination 'handle-csm-response
	  :trigger t)
	 
	 (transition
	  :description "default"
	  :pattern '((?!spec ?sa ?t)
		     -default1
		     (GENERATE :content (ONT::TELL :content (ONT::DONT-UNDERSTAND)))
		     (GENERATE :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))		     
		     )
	  :destination 'segmentend ;'propose-cps-act
	  )

	 )
	
	))


(add-state 'answers
 (state :action nil
	:implicit-confirm t
	:transitions
	(list
	 (transition
	  :description "acceptance, e.g., ok, good"
	  :pattern '((ONT::SPEECHACT ?!sa ONT::ACCEPT)
		     (ont::eval (find-attr :result (?prop :content ?!content :context ?!context) 
				 :feature PROPOSAL-ON-TABLE))
		     -user-response1>
		     (UPDATE-CSM (ACCEPTED :content ?!content :context ?!context))
		     (NOTIFY-BA :msg-type REQUEST
				:msg (COMMIT
				      :content ?!content)) ;; :context ?!context))  SIFT doesn't want the context
		     (RECORD ACTIVE-GOAL ?!content)
		     (RECORD ACTIVE-CONTEXT ?!context)
		     (RECORD PROPOSAL-ON-TABLE nil)
;		     (NOTIFY-BA :msg (SET-SHARED-GOAL
;				      :content ?!content
;				      :context ?!context))
		     )
	  :destination 'what-next-initiative
	  )

	 (transition
	  :description "rejectance"
	  :pattern '((ONT::SPEECHACT ?!sa1 ONT::REJECT )
		     (ont::eval (find-attr :result (?prop :content ?!content :context ?!context) 
				 :feature PROPOSAL-ON-TABLE))
		     -user-response2>
		     (Update-CSM (REJECTED :content ?!content :context ?!context))
		     (RECORD PROPOSAL-ON-TABLE nil)
		     (NOTIFY-BA :msg-type TELL
				:msg (REPORT :content (REJECTED :what ?!content) :context ?!context))
		     (QUERY-CSM :content (ACTIVE-GOAL))
		     ;(GENERATE
		     ; :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))
		     )
	  :destination 'what-next-initiative-on-new-goal ;'segmentend ;'propose-cps-act
	  )

	 (transition
	  :description "acceptance, e.g., yes"
	  :pattern '((ONT::SPEECHACT ?!sa ONT::ANSWER :WHAT ONT::POS)
		     (ont::eval (find-attr :result (?prop :content ?!content :context ?!context) 
				 :feature PROPOSAL-ON-TABLE))
		     -user-response1b> 
		     (UPDATE-CSM (ACCEPTED :content ?!content :context ?!context))
		     (NOTIFY-BA :msg-type REQUEST
				:msg (COMMIT
				      :content ?!content)) ;; :context ?!context))  SIFT doesn't want the context
		     (RECORD ACTIVE-GOAL ?!content)
		     (RECORD ACTIVE-CONTEXT ?!context)
		     (RECORD PROPOSAL-ON-TABLE nil)
;		     (NOTIFY-BA :msg (SET-SHARED-GOAL
;				      :content ?!content
;				      :context ?!context))
		     )
	  :destination 'what-next-initiative
	  )

	 (transition
	  :description "rejectance, e.g., no"
	  :pattern '((ONT::SPEECHACT ?!sa ONT::ANSWER :WHAT ONT::NEG)
		     (ont::eval (find-attr :result (?prop :content ?!content :context ?!context) 
				 :feature PROPOSAL-ON-TABLE))
		     -user-response2b> 
		     (Update-CSM (REJECTED :content ?!content :context ?!context))
		     (RECORD PROPOSAL-ON-TABLE nil)
		     (NOTIFY-BA :msg-type TELL
				:msg (REPORT :content (REJECTED :what ?!content) :context ?!context))
		     (QUERY-CSM :content (ACTIVE-GOAL))
		     ;(GENERATE
		     ; :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))
		     )
	  :destination 'what-next-initiative-on-new-goal ;'segmentend ;'propose-cps-act
	  )
	 
	 (transition
	  :description "I can't do it"  
	  :pattern '((ONT::SPEECHACT ?!sa ONT::TELL :what ?!what)
		     (ONT::F ?!what ONT::EVENT-OF-ACTION :AGENT ?!ag :FORCE ONT::IMPOSSIBLE)
		     (ONT::PRO ?!ag ?t2 :PROFORM (? xx w::I))
		     (ont::eval (find-attr :result (?prop :content ?!content :context ?!context) 
				 :feature PROPOSAL-ON-TABLE))
		     ;(ont::eval (extract-feature-from-act :result ?!goal-id :expr ?!content :feature :what))
		     -user-response3>
		     (Update-CSM (REJECTED :content ?!content :context ?!context))
		     (RECORD PROPOSAL-ON-TABLE nil)
		     (NOTIFY-BA :msg-type TELL
				:msg (REPORT :content (REJECTED :what ?!content :type CANNOT-PERFORM) :context ?!context))
		     (QUERY-CSM :content (ACTIVE-GOAL))
		     ;(GENERATE
		     ; :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))
		     )
	  :destination 'what-next-initiative-on-new-goal ;'segmentend ;'propose-cps-act
	  )

	 #|
	 (transition
	  :description "I will; I can't (answers to both WH and YN questions); green; the green block; How about me?"
	  :pattern '((ONT::SPEECHACT ?!sa (? t ONT::ANSWER ONT::IDENTIFY ONT::REQUEST-COMMENT) :what ?!what)
		     (ont::eval (generate-AKRL-context :what ?!what :result ?akrl-context))
		     (ont::eval (find-attr :result ?goal :feature ACTIVE-GOAL))
		     -user-response4>
		     (RECORD CPS-HYPOTHESIS (ANSWER :content ?!what :context ?akrl-context :active-goal ?goal))
		     (INVOKE-BA :msg (INTERPRET-SPEECH-ACT
				      :content (ANSWER :content ?!what
							:context ?akrl-context
							:active-goal ?goal)))

		     )
	  :destination 'handle-csm-response
	  )
	 |#

	 (transition
	  :description "I will; I can't (answers to both WH and YN questions)"
	  :pattern '((ONT::SPEECHACT ?!sa (? t ONT::ANSWER) :what ?!what)
		     (ONT::F ?!what ONT::ELLIPSIS :NEUTRAL ?!ans)
		     (ont::eval (generate-AKRL-context :what ?!ans :result ?akrl-context))
		     (ont::eval (find-attr :result ?goal :feature ACTIVE-GOAL))
		     -user-response4>
		     (RECORD CPS-HYPOTHESIS (ANSWER :content ?!ans :context ?akrl-context :active-goal ?goal))
		     (INVOKE-BA :msg (INTERPRET-SPEECH-ACT
				      :content (ANSWER :content ?!ans
							:context ?akrl-context
							:active-goal ?goal)))

		     )
	  :destination 'handle-csm-response
	  )

	 (transition
	  :description "green; the green block; How about me?"
	  :pattern '((ONT::SPEECHACT ?!sa (? t ONT::ANSWER ONT::IDENTIFY ONT::REQUEST-COMMENT) :what ?!ans)
		     (?!spec ?!ans (? !t ONT::SITUATION-ROOT)) 
		     (ont::eval (generate-AKRL-context :what ?!ans :result ?akrl-context))
		     (ont::eval (find-attr :result ?goal :feature ACTIVE-GOAL))
		     -user-response4b>
		     (RECORD CPS-HYPOTHESIS (ANSWER :content ?!ans :context ?akrl-context :active-goal ?goal))
		     (INVOKE-BA :msg (INTERPRET-SPEECH-ACT
				      :content (ANSWER :content ?!ans
							:context ?akrl-context
							:active-goal ?goal)))

		     )
	  :destination 'handle-csm-response
	  )
	 

	 #|
	 (transition
	  :description "default"
	  :pattern '((?spec ?sa ?t)
		     -default1b
		     (GENERATE :content (ONT::TELL :content (ONT::DONT-UNDERSTAND)))
		     (GENERATE :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))		     
		     )
	  :destination 'segmentend
	  )
	 |#
	 
	 )
	
	))


(add-state 'handle-CSM-response
 (state :action nil
	:transitions
	(list

	 (transition
	  :description "CSM returns a successful proposal interpretation"
	  :pattern '((BA-RESPONSE X REPORT :psact (? act ADOPT ASSERTION ASSERT ASK-WH ASK-IF) :id ?!goal :as ?as 
		      :content ?content :context ?new-akrl :alternative ?alt-as)
		     ;;(BA-RESPONSE X ?!X :content ((? act ADOPT ASSERTION) :what ?!goal :as ?as :alternative ?alt-as) :context ?new-akrl)
		     -successful-interp1>
		     (UPDATE-CSM (PROPOSED :content ?content
				  :context ?new-akrl))
		     (RECORD PROPOSAL-ON-TABLE (ONT::PROPOSE-GOAL
						:content ?content
						:context ?new-akrl))
		     (RECORD ACTIVE-GOAL ?!goal)
		     (RECORD ALT-AS ?alt-as)
		     (RECORD ACTIVE-CONTEXT ?new-akrl)
		     ;(RECORD LAST-MSG (EVALUATE 
				     ; :content ?content
				     ; :context ?new-akrl))
		     (INVOKE-BA :msg (EVALUATE 
				      :content ?content
				      :context ?new-akrl))
		     )
	  :destination 'propose-cps-act-response
	  )

	 (transition
	  :description "CSM returns a successful ANSWER interpretation"  
	  :pattern '((BA-RESPONSE X REPORT :psact (? act ANSWER) :to ?!to :what ?what :query ?goal :value ?!ans
		      :content ?content :context ?new-akrl)
		     -successful-interp-answer>
		     (UPDATE-CSM (PROPOSED :content ?content
				  :context ?new-akrl))
		     (RECORD PROPOSAL-ON-TABLE (ONT::PROPOSE-GOAL
						:content ?content
						:context ?new-akrl))
		     (RECORD ACTIVE-GOAL ?!to)
		     (RECORD ACTIVE-CONTEXT ?new-akrl)
		     (INVOKE-BA :msg (EVALUATE 
				      :content ?content
				      :context ?new-akrl))
		     )
	  :destination 'propose-cps-act-response
	  )
	 
	 ;; failure: can't identify goal
	 ;;(TELL :RECEIVER DAGENT :CONTENT (REPORT :content (FAILED-TO-INTERPRET :WHAT ONT::V32042 :REASON (MISSING-ACTIVE-GOAL) :POSSIBLE-SOLUTIONS (ONT::BUILD-MODEL)) :context ()) :IN-REPLY-TO IO-32505 :sender CSM)
	 (transition
	  :description "CSM fails to identify the goal, but has a guess"
	  :pattern '((BA-RESPONSE  X REPORT :psact FAILURE :type FAILED-TO-INTERPRET :WHAT ?!content
		      :REASON (MISSING-ACTIVE-GOAL)
		      :POSSIBLE-RESOLUTION (?!possible-goal) :context ?context)
		     (ont::eval  (extract-goal-description :cps-act ?!possible-goal :context ?context :result ?goal-description :goal-id ?goal-id))
		     -intention-failure-with-guess>
		     (RECORD FAILURE (FAILED-TO-INTERPRET :WHAT ?!content :REASON (MISSING-ACTIVE-GOAL) :POSSIBLE-SOLUTIONS (?!possible-goal) :context ?context))
		     (RECORD POSSIBLE-GOAL ?!possible-goal)
		     (RECORD POSSIBLE-GOAL-ID ?goal-id)
		     (RECORD POSSIBLE-GOAL-CONTEXT ?goal-description)
		     )
	  :destination 'clarify-goal
	  )
		      
	 (transition
	  :description "CSM fails to identify the goal, and no guess. Right now we just prompt the user
                        to identify their goal and forget the current utterance"
	  :pattern '((BA-RESPONSE  X REPORT :psact FAILURE :type FAILED-TO-INTERPRET :WHAT ?!content
		      :REASON (MISSING-ACTIVE-GOAL) :context ?context)
		     -intention-complete-failure>
		     (RECORD FAILURE (FAILED-TO-INTERPRET :WHAT ?!content :REASON (MISSING-ACTIVE-GOAL) :context ?context))
		     (RECORD POSSIBLE-GOAL nil)
		     (GENERATE
		      :content (ONT::FAILED-TO-UNDERSTAND-GOAL :content ?!content)
		      :context ?context)
		     (GENERATE :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))
		     )
	  :destination 'segmentend ;'propose-cps-act
	  )

	 (transition
	  :description "CSM fails to identify any relevant events in the ASSERTION"
	  :pattern '((BA-RESPONSE  X REPORT :psact FAILURE :type FAILED-TO-INTERPRET :WHAT ?!content :REASON (NO-EVENTS-IN-CONTEXT) :context ?context)
		     -intention-failure-noevent>
		     (RECORD FAILURE (FAILED-TO-INTERPRET :WHAT ?!content :REASON (NO-EVENTS-IN-CONTEXT) :context ?context))
		     (GENERATE
		      :content (ONT::FAILED-TO-UNDERSTAND-RELEVANCE :content ?!content)
		      :context ?context)		     
		     (GENERATE
		      :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))
		     )
	  :destination 'segmentend ;'propose-cps-act  ; process the next pending speech act, if there is one
	  )

	 (transition
	  :description "CSM fails to identify any relevant events in the ASSERTION"
	  :pattern '((BA-RESPONSE  X REPORT :psact FAILURE :type ?!type :WHAT ?!content :REASON ?r :context ?context)
		     -intention-failure-others>
		     (RECORD FAILURE (?!type :WHAT ?!content :REASON ?r :context ?context))
		     (GENERATE
		      :content (?!type :content ?!content)
		      :context ?context)		     
		     (GENERATE
		      :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))
		     )
	  :destination 'segmentend ;'propose-cps-act  ; process the next pending speech act, if there is one
	  )

	 (transition
	  :description "default"
	  :pattern '((?!spec ?sa ?t)
		     -default2
		     (GENERATE
		      :content (ONT::TELL :content (ONT::SOMETHING-IS-WRONG)))
		     (GENERATE
		      :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))		     
		     )
	  :destination 'segmentend ;'propose-cps-act
	  )

	 )
	))


(add-state 'propose-cps-act-response
 (state :action nil
	:transitions
	(list
	 #|
	 (transition
	  :description "acceptance of an answer to a question (e.g., I will.)"
	  :pattern '((BA-RESPONSE X ACCEPTABLE :what ?!psgoal :context ?!context)
		     ;; (ont::eval (extract-feature-from-act :result (? goal-id ONT::USER ONT::SYS) :expr ?!psgoal :feature :what))
		     (ont::eval (extract-feature-from-act :result (ANSWER :TO ?R) :expr ?!psgoal :feature :as))
		     ;(ont::eval (find-attr :result ?!popgoal :feature POP-GOAL))
		     ;(ont::eval (find-attr :result ?!popcontext :feature POP-CONTEXT))
		     -goal-response-q-answered>
		     (UPDATE-CSM (ACCEPTED :content ?!psgoal :context ?!context))

		     (UPDATE-CSM (SET-OVERRIDE-INITIATIVE :OVERRIDE T :VALUE T))  ; system will take initiative

		     (NOTIFY-BA :msg (COMMIT
				      :content ?!psgoal)) ;; :context ?!context))  SIFT doesn't want the context
		     ;(RECORD POP-GOAL nil)
		     ;(RECORD POP-CONTEXT nil)
		     ;(RECORD ACTIVE-GOAL ?!popgoal)
		     ;(RECORD ACTIVE-CONTEXT ?!popcontext)
		     (QUERY-CSM :content (ACTIVE-GOAL))
		     (GENERATE :content (ONT::ACCEPT))
		     )
	  :destination 'what-next-initiative-on-new-goal)
		      
	 (transition
	  :description "acceptance of changing the agent (e.g., You do it.)"
	  :pattern '((BA-RESPONSE X ACCEPTABLE :what ?!psgoal :context ?!context)
		     (ont::eval (extract-feature-from-act :result (? ag ONT::USER ONT::SYS) :expr ?!psgoal :feature :what))
		     (ont::eval (extract-feature-from-act :result (AGENT :OF ?G) :expr ?!psgoal :feature :as))
		     -goal-response-change-performer>
		     (UPDATE-CSM (ACCEPTED :content (ADOPT :what ?G) :context ?!context))
		     (NOTIFY-BA :msg (COMMIT
				      :content (ADOPT :what ?G))) ;; :context ?!context))  SIFT doesn't want the context
		     (UPDATE-CSM (ACCEPTED :content ?!psgoal :context ?!context))
		     (NOTIFY-BA :msg (COMMIT
				      :content ?!psgoal)) ;; :context ?!context))  SIFT doesn't want the context
		     (RECORD ACTIVE-GOAL ?G)
		     (RECORD ACTIVE-CONTEXT ?!context)
		     (GENERATE :content (ONT::ACCEPT))
		     )
	  :destination 'what-next-initiative)
	 |#

	 (transition
	  :description "acceptance - non query"
	  :pattern '((BA-RESPONSE X REPORT :psact ACCEPTABLE :what ?!psgoal :context ?!context
		      :effect ?mod-goal)
		     ;(ont::eval (extract-feature-from-act :result ?!goal-id :expr ?!psgoal :feature :what))
		     (ont::eval (extract-feature-from-act :result nil :expr ?!psgoal :feature :query))
		     -goal-response-non-query>
		     (UPDATE-CSM (ACCEPTED :content ?!psgoal :context ?!context :effect ?mod-goal))
		     (NOTIFY-BA :msg-type REQUEST
				:msg (COMMIT
				      :content ?!psgoal :effect ?mod-goal)) ;; :context ?!context))  SIFT doesn't want the context
		     (QUERY-CSM :content (ACTIVE-GOAL))
		     ;(RECORD ACTIVE-GOAL ?!goal-id)
		     ;(RECORD ACTIVE-CONTEXT ?!context)
		     (RECORD PROPOSAL-ON-TABLE nil)
		     (GENERATE :content (ONT::ACCEPT :what ?!psgoal) :context ?!context)
		     )
	  :destination 'what-next-initiative-on-new-goal)

 	(transition
	  :description "acceptance - query"
	  :pattern '((BA-RESPONSE X REPORT :psact ACCEPTABLE :what ?!psgoal :context ?!context
		      :effect ?mod-goal)
		     ;(ont::eval (extract-feature-from-act :result ?!goal-id :expr ?!psgoal :feature :what))
		     (ont::eval (extract-feature-from-act :result ?!query :expr ?!psgoal :feature :query))
		     -goal-response-query>
		     (UPDATE-CSM (ACCEPTED :content ?!psgoal :context ?!context :effect ?mod-goal))                
		    
		     (NOTIFY-BA :msg-type REQUEST
				:msg (COMMIT
				      :content ?!psgoal :effect ?mod-goal)) ;; :context ?!context))  SIFT doesn't want the context
		     (RECORD PROPOSAL-ON-TABLE nil)
		     (QUERY-CSM :content (ACTIVE-GOAL))
		     )
	  :destination 'what-next-initiative-on-new-goal)

	 (transition
	  :description "acceptance of an ANSWER"
	  :pattern '((BA-RESPONSE X REPORT :psact ACCEPTABLE :what ?!psgoal :context ?!context :effect ?mod-goal
		      :content (ACCEPTABLE :what (ANSWER)))
		     (ont::eval (extract-feature-from-act :result ?!goal-id :expr ?!psgoal :feature :query))
		     -goal-response-answer>
		     (UPDATE-CSM (ACCEPTED :content ?!psgoal :context ?!context :effect ?mod-goal))
		     (NOTIFY-BA :msg-type REQUEST
				:msg (COMMIT
				      :content ?!psgoal :effect ?mod-goal)) ;; :context ?!context))  SIFT doesn't want the context
		     (UPDATE-CSM (STATUS-REPORT :goal ?!goal-id :status ONT::DONE))
		     (QUERY-CSM :content (ACTIVE-GOAL))
		     ;(RECORD ACTIVE-GOAL ?!goal-id)
		     ;(RECORD ACTIVE-CONTEXT ?!context)
		     (RECORD PROPOSAL-ON-TABLE nil)
		     ;(GENERATE :content (ONT::EVALUATION :content (ONT::GOOD)))
		     (GENERATE :content (ONT::ACCEPT :what ?!psgoal) :context ?!context)
		     )
	  :destination 'what-next-initiative-on-new-goal)

	 #|
	 (transition
	  :description "acceptance with clarification"
	  :pattern '((BA-RESPONSE X ACCEPT-WITH-CLARIFY :what ?!psgoal :context ?!context :reason ?!reason)
		     (ont::eval (extract-feature-from-act :result ?goal-id :expr ?!psgoal :feature :what))
		     -goal-response-with-clarify>
		     (UPDATE-CSM (ACCEPTED :content ?!psgoal :context ?!context))
		     (NOTIFY-BA :msg (COMMIT
				      :content ?!psgoal)) ;; :context ?!context))  SIFT doesn't want the context
		     (UPDATE-CSM (ACCEPTED :content (ADOPT :what ?!reason :as (SUBGOAL :of ?goal-id)) :context ?!context))
		     (NOTIFY-BA :msg (COMMIT
				      :content (ADOPT :what ?!reason :as (SUBGOAL :of ?goal-id)))) ;; :context ?!context))  SIFT doesn't want the context
		     (RECORD ACTIVE-GOAL ?!reason)   ; we don't need QUERY-GOAL then
		     (RECORD ACTIVE-CONTEXT ?!context)
		     (RECORD QUERY-GOAL ?!reason)
		     ;(RECORD POP-GOAL ?goal-id)  ; tmp hack
		     ;(RECORD POP-CONTEXT ?!context)  ; tmp hack
		     (GENERATE :content (ONT::ACCEPT))
		     (GENERATE :content (ONT::QUERY :what ?!reason) :context ?!context)
		     )
	  :destination 'segmentend)
	 |#

	 #|
	 (transition
	  :description "BA rejects the goal (old format -- probably obsolete)"
	  :pattern '((BA-RESPONSE X REPORT :psact (? x REJECT UNACCEPTABLE) :content ?!psobj :context ?!context )
		     ;;(ont::eval (find-attr ?goal  GOAL))
		     -goal-response2>
		     (RECORD REJECTED ?!psobj :context ?context)
		     )
	  :destination 'explore-alt-interp)
	 |#

	 ; *need to fix*: Currently the possible-resolution is ignored on further processing
	 (transition
	  :description "BA finds the goal unacceptable, possibly with a suggestion."
	  :pattern '((BA-RESPONSE  X REPORT :psact UNACCEPTABLE :type ?!type :WHAT ?!content :REASON ?reason :possible-resolution ?poss :context ?context)
		     -BA-failure-with-guess>
		     (RECORD REJECTED (UNACCEPTABLE :type ?!type :WHAT ?!content :REASON ?reason))
		     (RECORD REJECTED-CONTEXT ?context)
		     (RECORD PROPOSAL-ON-TABLE nil)
		     (RECORD POSSIBLE-GOAL ?poss)
		     (UPDATE-CSM (V REJECTED) :context ?context)
		     ;(GENERATE :content (V UNACCEPTABLE) :context ?context)
		     )
	  :destination 'explore-alt-interp)
	 
	 (transition
	  :description "BA fails to understand"
	  :pattern '((BA-RESPONSE  X REPORT :psact FAILURE :type ?!type ;(? x FAILED-TO-INTERPRET CANNOT-IDENTIFY-RELEVANCE)
		      :WHAT ?!content :REASON ?reason :context ?context)
		     -BA-failure-no-guess>
		     (RECORD REJECTED (FAILURE :type ?!type :WHAT ?!content :REASON ?reason))
		     (RECORD PROPOSAL-ON-TABLE nil)
		     (RECORD POSSIBLE-GOAL nil)
                     (UPDATE-CSM (V REJECTED) :context ?context)
		     )
	  :destination 'explore-alt-interp)

	 (transition
	  :description "default"
	  :pattern '((?!spec ?sa ?t)
		     -default3
		     (GENERATE
		      :content (ONT::TELL :content (ONT::SOMETHING-IS-WRONG)))
		     (GENERATE
		      :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))		     
		     )
	  :destination 'segmentend ;'propose-cps-act
	  )
	 
	 
	 )
	))
#||
(add-state 'process-user-response-to-problem
 (state :action nil
	:transitions
	(list
	 (transition
	  :description "goal modification. eg: Let's build a tower instead."
	  :pattern '((ONT::SPEECHACT ?!sa (? x ONT::PROPOSE ONT::REQUEST) :what ?!what)
		     ;; ((? spec ONT::EVENT ONT::EPI) ?!what ?!t)
		     (?!spec ?!what ?!t)
		     (ont::eval (generate-AKRL-context :what ?!what :result ?akrl-context))
		     (ont::eval (find-attr :result ?goal :feature ACTIVE-GOAL))
		     -propose-goal-modify>
		     (RECORD CPS-HYPOTHESIS (PROPOSE :content ?!what :context ?akrl-context :active-goal ?goal))
		     (INVOKE-BA :msg (INTERPRET-SPEECH-ACT
				      :content (PROPOSE :content ?!what
							:as (MODIFY)
							:context ?akrl-context
							:active-goal ?goal)))
		     )
	  :destination 'handle-csm-response
	  ;; :trigger t
	  )
	 )
	))

(add-state 'process-user-response-to-question
 (state :action nil
	:transitions
	(list
	 (transition
	  :description "13; me"
	  :pattern '((ONT::SPEECHACT ?!sa ONT::ANSWER :what ?!what)
		     (?!spec ?!what ?!t)
		     (ont::eval (generate-AKRL-context :what ?!what :result ?akrl-context))
		     (ont::eval (find-attr :result ?goal :feature QUERY-GOAL))
		     -answer-atom>
		     (RECORD CPS-HYPOTHESIS (PROPOSE :content ?!what :context ?akrl-context :active-goal ?goal))
		     (INVOKE-BA :msg (INTERPRET-SPEECH-ACT
				      :content (PROPOSE :content ?!what
							:as (ANSWER :to ?goal)
							:context ?akrl-context
							:active-goal ?goal)))
		     )
	  :destination 'handle-csm-response
	  )
		      
	 (transition
	  :description "I will"
	  :pattern '((ONT::SPEECHACT ?!sa ONT::TELL :what ?!what)
		     (ONT::F ?!what ONT::ELLIPSIS :neutral ?ag)
		     (ONT::PRO ?ag ONT::PERSON :refers-to ?performer)
		     (ont::eval (generate-AKRL-context :what ?!what :result ?akrl-context))
		     (ont::eval (find-attr :result ?goal :feature QUERY-GOAL))
		     -answer-ellipsis>
		     (RECORD CPS-HYPOTHESIS (PROPOSE :content ?performer :as (ANSWER :to ?goal) :context ?akrl-context :active-goal ?goal))
		     (RECORD QUERY-GOAL nil)
		     (RECORD ACTIVE-GOAL ?goal)
		     (RECORD ACTIVE-CONTEXT ?akrl-context)
		     (INVOKE-BA :msg (INTERPRET-SPEECH-ACT
				      :content (PROPOSE :content ?performer
							:as (ANSWER :to ?goal)
							:context ?akrl-context
							:active-goal ?goal)))
		     )
	  :destination 'handle-csm-response)
	 )
	))
||#

(add-state 'explore-alt-interp
 (state :action '(continue)
	:transitions
	(list
	 (transition
	  :description "the CSM has a backup interpretation"
	  :pattern '((continue :arg ?!dummy)
		     (ont::eval (find-attr :result ?!alt :feature ALT-AS))
		     (ont::eval (find-attr :result ?!new-akrl :feature ACTIVE-CONTEXT))
		     -alt-found1>
		     ;; JFA:: something wrong here ?!goal is unbound!
		     (RECORD PROPOSAL-ON-TABLE (ONT::PROPOSE-GOAL :content (ADOPT :what ?!goal :as ?!alt)))
		     (RECORD ALT-AS nil)
		     (INVOKE-BA :msg (EVALUATE 
				      :content ?!alt
				      :context ?!new-akrl))
		     )
	  :destination 'propose-cps-act-response)
	 
	 (transition
	  :description "no backup alt left"
	  :pattern '((continue :arg ?!dummy)
		     (ont::eval (find-attr :result nil :feature ALT-AS))
		     (ont::eval (find-attr :result ?failure :feature REJECTED))
		     (ont::eval (find-attr :result ?failure-context :feature REJECTED-CONTEXT))
		     -failure-with-no-alt>>
		     ;(GENERATE :content (ONT::TELL :content (?failure)))
		     (GENERATE :content ?failure :context ?failure-context)
		     (GENERATE
		      :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))
		     )
;	  :destination 'clarify-goal)
	  :destination 'segmentend ;'propose-cps-act
	  )
	 
	 )
	))

;;  CLARIFICATION MANAGEMENT

(add-state 'clarify-goal 
 (state :action '(GENERATE :content (ONT::CLARIFY-GOAL :content (V possible-goal-id)) :context (V POSSIBLE-GOAL-context))
	:preprocessing-ids '(yes-no)
	:transitions
	(list
	 (transition
	  :description "yes"
	  :pattern '((ANSWER :value YES)
		     (ont::eval (find-attr :result ?context :feature POSSIBLE-GOAL-context))
		     (ont::eval (find-attr :result ?poss-goal :feature possible-goal))
		     -right-guess-on-goal>
		     (INVOKE-BA :msg (EVALUATE 
				      :content ?poss-goal
				      :context ?context))
		     )
	  :destination 'confirm-goal-with-BA)

	 ; ** to fix: currently we just forget the first utterance and go to the top **
	 ; do we need to notify the CSM?
	 (transition
	  :description "no" 
	  :pattern '((ANSWER :value NO)
		     -propose-cps-act>
		     ;(GENERATE :content (ONT::OK))
		     (GENERATE
		      :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))
		     )
	  :destination 'segmentend ;'propose-cps-act
	  )

	 (transition
	  :description "default"
	  :pattern '((?!spec ?sa ?t)
		     -default4
		     (GENERATE :content (ONT::TELL :content (ONT::DONT-UNDERSTAND)))
		     (GENERATE :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))		     
		     )
	  :destination 'segmentend ;'propose-cps-act
	  )
	 )	
	))

(add-state 'confirm-goal-with-BA
 (state :action nil
	:transitions
	(list
	 (transition
	  :description "check with BA that the clarified goal is acceptable"
	  :pattern '((BA-RESPONSE X REPORT :psact ACCEPTABLE :what ?!psgoal :context ?!context)
		     (ont::eval (extract-feature-from-act :result ?goal-id :expr ?!psgoal :feature :what))
		     (ont::eval (find-attr :result ?orig-cps-hyp :feature CPS-HYPOTHESIS))
		     (ont::eval (find-attr :result ?active-goal :feature POSSIBLE-GOAL-ID))
		     (ont::eval (find-attr :result ?active-context :feature POSSIBLE-GOAL-CONTEXT))
		     (ont::eval (replace-feature-val-in-act :result ?new-cps-hyp
				 :act ?orig-cps-hyp :feature :active-goal :newval ?active-goal))
		     -confirmed-clarify-goal>
		     (UPDATE-CSM (ACCEPTED :content ?!psgoal :context ?!context))
		     (RECORD ACTIVE-GOAL ?active-goal)
		     (RECORD ACTIVE-CONTEXT ?active-context)
		     (RECORD CPS-HYPOTHESIS ?new-cps-hyp)
		     (NOTIFY-BA :msg-type REQUEST
				:msg (COMMIT
				      :content ?!psgoal)) ;; :context ?!context))  SIFT doesn't want the context
		     ;(RECORD ACTIVE-GOAL ?goal-id)
		     ;(RECORD ACTIVE-CONTEXT ?!context)
		     (RECORD PROPOSAL-ON-TABLE nil)
		     (GENERATE :content (ONT::EVALUATION :content (ONT::GOOD)))
		     ;;  Now we try to reinterpret the original utterance that caused the clarification
		     (INVOKE-BA :msg (INTERPRET-SPEECH-ACT
				      :content ?new-cps-hyp)))
	  :destination 'handle-CSM-response)

	 ; *need to fix*: Currently the possible-resolution is ignored on further processing
	 (transition
	  :description "BA finds the goal unacceptable, possibly with a suggestion."
	  :pattern '((BA-RESPONSE  X REPORT :psact UNACCEPTABLE :type ?!type :WHAT ?!content :REASON ?reason :possible-resolution ?poss :context ?context)
		     -unacceptable-clarify-goal>
		     (RECORD REJECTED (UNACCEPTABLE :type ?!type :WHAT ?!content :REASON ?reason))
		     ;(RECORD POSSIBLE-GOAL ?poss)
		     (RECORD PROPOSAL-ON-TABLE nil)
		     (UPDATE-CSM (V REJECTED) :context ?context)
		     (GENERATE :content (V REJECTED) :context ?context)
		     (GENERATE
		      :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))		     
		     )
	  :destination 'segmentend ;'propose-cps-act
	  )
	 
	 (transition
	  :description "BA fails to understand"
	  :pattern '((BA-RESPONSE  X REPORT :psact FAILURE :type ?!type ;(? x FAILED-TO-INTERPRET CANNOT-IDENTIFY-RELEVANCE)
		      :WHAT ?!content :REASON ?reason :context ?context)
		     -failure-clarify-goal>
		     (RECORD REJECTED (FAILURE :type ?!type :WHAT ?!content :REASON ?reason))
		     (RECORD POSSIBLE-GOAL nil)
		     (RECORD PROPOSAL-ON-TABLE nil)
                     (UPDATE-CSM (V REJECTED) :context ?context)
		     (GENERATE :content (V REJECTED) :context ?context)
		     (GENERATE :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))		     
		     )
	  :destination 'segmentend ;'propose-cps-act
	  )

	 (transition
	  :description "default"
	  :pattern '((?!spec ?sa ?t)
		     -default5
		     (GENERATE :content (ONT::TELL :content (ONT::SOMETHING-IS-WRONG)))
		     (GENERATE :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))		     
		     )
	  :destination 'segmentend ;'propose-cps-act
	  )
	 
	 )
	))


;; INTITIATIVE MANAGEMENT
;; This state starts an interaction with the BA to determine if the system should take
;; initiative or not

(add-state 'what-next-initiative
 (state :action '(any-pending-speech-acts?)
	:transitions
	(list
	 (transition
	  :description "there's no pending speech act, so we'll ask the CSM"
	  :pattern '((REPORT :content (pending-speech-acts :result NO) :context ?!c)
		     (ont::eval (find-attr :result ?!goal :feature ACTIVE-GOAL))
		     -take-init1>
		     (nop)
		     )
	  :destination 'what-next-initiative-CSM)

	 ; this is here temporarily until the CSM can copy with a nil active-goal
	 (transition
	  :description "there's no pending speech act, and no active goal"
	  :pattern '((REPORT :content (pending-speech-acts :result NO) :context ?!c)
		     (ont::eval (find-attr :result nil :feature ACTIVE-GOAL))
		     -take-init1b>
		     (UPDATE-CSM (INITIATIVE-TAKEN-ON-GOAL :what nil :context nil))
		     (INVOKE-BA :msg (WHAT-NEXT :active-goal nil
				      :context nil))
		     )
	  :destination 'perform-BA-request)

	 (transition
	  :description "there's a pending speech act, end this so it can be processed"
	  :pattern '((REPORT :content (pending-speech-acts :result YES) :context ?!c)
		     -take-init2>
		     (nop))
	  :destination 'segmentend)

	 (transition
	  :description "default: act as if no pending speech act"
	  :pattern '((?!spec ?sa ?t)
		     -default-psa
		     (nop)
		     )
	  :destination 'what-next-initiative-CSM
	  )
	
	 )
	))

(add-state 'what-next-initiative-CSM
 (state :action '(take-initiative? :goal (V active-goal) :context (V active-context))
	:transitions
	(list
	 (transition
	  :description "decided on taking initiative"
	  :pattern '((TAKE-INITIATIVE :result (? r YES MAYBE) :goal ?!result :context ?context)
		     -take-init1-csm>
		     (UPDATE-CSM (INITIATIVE-TAKEN-ON-GOAL :what ?!result :context ?context))
		     (INVOKE-BA :msg (WHAT-NEXT :active-goal ?!result
				      :context ?context))
		     )
	  :destination 'perform-BA-request)
	 
	 ;; initiative declined, enter a wait state
	 (transition
	  :description "no initiative"
	  :pattern '((TAKE-INITIATIVE :result NO)
		     -take-init2-csm>
		     (UPDATE-CSM (NO-INITIATIVE-TAKEN)))
	  :destination 'segmentend)
	 
	 ;; failure to interpret goal, just keep going
	 (transition
	  :description "can't understand"
	  :pattern '((?!spec ?sa ?t) ;(FAILURE :what ?!X)
		     -take-init3-csm>
		     (UPDATE-CSM (NO-INITIATIVE-TAKEN)))
	  :destination 'segmentend)
	 )
	))

(add-state 'perform-BA-request
 (state :action nil
	:transitions
	(list
	 (transition
	  :description "failed trying to achieve the goal"
	  :pattern '((BA-RESPONSE X REPORT :psact FAILURE :what ?!F1 :as ?as-role :context ?context)
		     -failed1>
		     (UPDATE-CSM (FAILED-ON  :what ?!F1 :as ?as-role :context ?context))
		     (GENERATE 
		      :content (ONT::TELL :content (ONT::FAIL :formal ?!F1 :tense PAST))
		      :context ?context)
		     )
	  :destination 'segmentend)
	

	 ;;  OBSOLETE -- delete soon
	 (transition
	  :description "solution to goal reported"
	  :pattern '((BA-RESPONSE X REPORT :psact SOLUTION :what ?!what :goal ?goal :context ?akrl-context)
		     ;;(ont::eval (generate-AKRL-context :what ?!what :result ?akrl-context))
		     -soln1>
		     (UPDATE-CSM (SOLVED :what ?!what :goal ?goal :context ?akrl-context))
		     (GENERATE 
		      :content (ONT::TELL :content ?!what)
		      :context ?akrl-context)
		     )
	  :destination 'segmentend)
	
	 ;;  OBSOLETE -- delete soon			
	 ;; initiative declined, enter a wait state
	 (transition
	  :description "BA has nothing to do"
	  :pattern '((BA-RESPONSE ?!x REPORT :psact WAIT)
		     -wait>
		     (UPDATE-CSM (BA-WAITING)))
	  :destination 'segmentend)
		
	 #|
	  ;;  OBSOLETE -- delete soon	
	 (transition
	  :description "suggestion of user action"
	  :pattern '((BA-RESPONSE ?!X PERFORM :agent *USER* :action ?!action :context ?context)
		     (ont::eval (find-attr :result ?goal :feature ACTIVE-GOAL))
		     -what-next1>
		     (UPDATE-CSM (PROPOSED :content (ADOPT :what ?!action :as (SUBGOAL :OF ?goal)) :context ?context))
		     (RECORD ACTIVE-GOAL ?!action)
		     (RECORD ACTIVE-CONTEXT ?context)
		     (RECORD PROPOSAL-ON-TABLE (ONT::PROPOSE :content (ADOPT :what ?!action :as (SUBGOAL :OF ?goal)) :context ?context))
		     (GENERATE
		      :content (ONT::PROPOSE :content (ONT::PERFORM :action ?!action :context ?context)))
		     )
	  :destination 'proposal-response)
	 |#

	 ;;NEW  -- this is the revised version of the old what-next1>
	 (transition
	  :description "suggestion of goal update or asking a question"
	  :pattern '((BA-RESPONSE ?!X PROPOSE :content ?!ps-action :context ?context)
		     ;;(BA-RESPONSE PROPOSE :content ?!ps-action :context ?context)
		     ;(ont::eval (find-attr :result ?goal :feature ACTIVE-GOAL))
		     (ont::eval (extract-feature-from-act :result ?!goal :expr ?!ps-action :feature :id))
		     (ont::eval (extract-feature-from-act :result nil :expr ?!ps-action :feature :query))
		     -ba-propose-psact>
		     (UPDATE-CSM (PROPOSED :content ?!ps-action :context ?context))
		     (RECORD PROPOSAL-ON-TABLE (ONT::PROPOSE :content ?!ps-action :context ?context))
		     (RECORD ACTIVE-GOAL ?!goal)
		     (RECORD ACTIVE-CONTEXT ?context)
		     (GENERATE
		      :content (ONT::PROPOSE :content ?!ps-action) :context ?context)
		     )
;	  :destination 'proposal-response)
	  :destination 'answers ;'segmentend ;;'propose-cps-act
	  )

	 (transition
	  :description "suggestion of goal update or asking a question"
	  :pattern '((BA-RESPONSE ?!X PROPOSE :content ?!ps-action :context ?context)
		     ;;(BA-RESPONSE PROPOSE :content ?!ps-action :context ?context)
		     ;(ont::eval (find-attr :result ?goal :feature ACTIVE-GOAL))
		     (ont::eval (extract-feature-from-act :result ?!goal :expr ?!ps-action :feature :id))
		     (ont::eval (extract-feature-from-act :result ?!query :expr ?!ps-action :feature :query))
		     -ba-propose-psact-query>
		     (UPDATE-CSM (PROPOSED :content ?!ps-action :context ?context))
		     (RECORD PROPOSAL-ON-TABLE (ONT::PROPOSE :content ?!ps-action :context ?context))
		     (RECORD ACTIVE-GOAL ?!goal)
		     (RECORD ACTIVE-CONTEXT ?context)
		     (GENERATE
		      :content (ONT::PROPOSE :content ?!ps-action) :context ?context)
		     )
;	  :destination 'proposal-response)
	  :destination 'answers ;'segmentend ;;'propose-cps-act
	  )
	 
	 (transition
	  :description "action completed!"
	  :pattern '((BA-RESPONSE ?!X REPORT :psact EXECUTION-STATUS :goal ?!action :status ONT::DONE)
		     -ba-done>
		     (UPDATE-CSM (STATUS-REPORT :goal ?!action :status ONT::DONE))
		     (QUERY-CSM :content (ACTIVE-GOAL))
		     (GENERATE
		      :content (ONT::TELL :content (ONT::DONE :what ?!action)))
		     )
	  :destination 'what-next-initiative-on-new-goal)

	 ;;NEW
	 (transition
	  :description "a goal is in progress"
	  :pattern '((BA-RESPONSE ?!X REPORT :psact EXECUTION-STATUS :goal ?!action 
		      :status (? stat ONT::WAITING-FOR-USER ONT::WORKING-ON-IT))
		     -ba-in-progress>
		     (UPDATE-CSM (STATUS-REPORT :goal ?!action 
				  :status (? stat ONT::WAITING-FOR-USER ONT::WORKING-ON-IT)))
		     (RECORD goal-status (? stat ONT::WAITING-FOR-USER ONT::WORKING-ON-IT))
		     )
	  
	  :destination 'check-timeout-status)
				
	 #|
	  ;;  OBSOLETE -- delete soon	
	 (transition
	  :description "action completed!"
	  :pattern '((BA-RESPONSE ?!X GOAL-ACHIEVED)
		     -what-next3>
		     (UPDATE-CSM (GOAL-ACHIEVED))
		     (GENERATE :content (ONT::EVALUATION :content (ONT::GOOD)))
		     (GENERATE :content (ONT::CLOSE))
		     )


	  :destination 'segmentend)
	 |#
	 
	 (transition
	  :description "answer to a question"
	  :pattern '((BA-RESPONSE X REPORT :psact ANSWER :to ?!to :what ?what :query ?of :value ?!value :justification ?j 
		      :effect ?effect
		      :context ?akrl-context)
		     ;;(ont::eval (generate-AKRL-context :what ?!what :result ?akrl-context))
		     -answer>
		     (UPDATE-CSM (ANSWER :to ?!to :what ?what :query ?of :value ?!value :justification ?j :context ?akrl-context :effect ?effect))
		     (QUERY-CSM :content (ACTIVE-GOAL))
		     (GENERATE 
		      :content (ONT::ANSWER :to ?!to :what ?what :query ?of :value ?!value :justification ?j)
		      :context ?akrl-context)
		     )
	  :destination 'what-next-initiative-on-new-goal)  ;;  wondering if we should be waiting to see how user responds to the answer??

	 (transition
	  :description "default: do nothing, just wait"
	  :pattern '((?!spec ?sa ?t)
		     -default6
		     ;(GENERATE :content (ONT::TELL :content (ONT::SOMETHING-IS-WRONG)))
					;(GENERATE :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))
		     (nop)
		     )
	  :destination 'segmentend
	  )
	 
	 )
	))

(add-state 'what-next-initiative-on-new-goal
 (state :action nil
	:transitions
	(list
	 (transition
	  :description ""
	  :pattern '((REPORT :content (ACTIVE-GOAL :id ?!goal :what ?what)  
		      :context ?context)
		     -set-active-goal>
		     (record active-goal ?!goal)
		     (record active-context ?context))
	  :destination 'what-next-initiative)
	 (transition
	  :description ""
	  :pattern '((REPORT :content  (ACTIVE-GOAL :id nil :what ?what)  :context ?context)
		     -all-done>
		     (record active-goal nil)
		     (record active-context nil)
		     ;(UPDATE-CSM (GOAL-ACHIEVED))
		     (GENERATE :content (ONT::TELL :content (ONT::ACK)))  ; generate something neutral, e.g., ok.  We might have got here because the goal has been abandoned (not accomplished)
		     
		     ; ?? commented this out because perhaps the system wants to propose something next??
		     ; i put it back in for now -- 
		     (GENERATE
		      :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))
		     
		     )
	  :destination 'segmentend
	  )
	 (transition
	  :description "default"
	  :pattern '((?!spec ?sa ?t)
		     -default7
		     (GENERATE :content (ONT::TELL :content (ONT::SOMETHING-IS-WRONG)))
		     (GENERATE :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))		     
		     )
	  :destination 'segmentend ;'propose-cps-act
	  )
	 
	 )
	))

;;;;
;;    Here are the acts starting a dialogue with system intitative


;;  Setting CPS GOALS  -- System Initiative
;; This assume that the CPS state has a preset private system goal that
;; we want to make into a shared goal with the user
;; Note:: this assumes the private system goal is already cached for processing
(add-state 'initiate-CPS-goal
 (state :action nil
	:transitions
	(list
	 (transition
	  :description "we don't have a private goal, we ask the user"
	  :pattern '(;(CSM-RESPONSE ?!x PRIVATE-SYSTEM-GOAL :content (IDENTIFY :neutral ?what :as ?as)
				   ;:context ?context)
		     (CSM-RESPONSE ?!x PRIVATE-SYSTEM-GOAL :id NIL :what NIL :context NIL)
		     -prompt-user-goal>
		     ;;(RECORD PROPOSAL-ON-TABLE (ONT::PROPOSE-GOAL :what ?!content :context ?context))
		     (GENERATE
		      :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))
		     ;(GENERATE
		     ; :content (ONT::QUERY :what ?what :as ?as)
		     ; :context ?context)
		     )
	  :destination 'segmentend ;'propose-cps-act
	  )
	 
	 (transition
	  :description "we know the private goal, so we propose it to the user"
	  :pattern '((CSM-RESPONSE ?!x PRIVATE-SYSTEM-GOAL :id ?!id :what ?!what :context ?context)
		     ;(ont::eval (extract-feature-from-act :result ?!goal :expr ?!content :feature :what))
		     -propose-sys-goal>
		     ;; JFA: introduce an ID here??
		     (UPDATE-CSM (PRIVATE-SYSTEM-GOAL :id ?!id :what ?!what :context ?context))
		     (UPDATE-CSM (PROPOSED :content (ADOPT :id ?!id :WHAT ?!what :AS (GOAL)) :context ?context))
		     (RECORD PROPOSAL-ON-TABLE (ONT::PROPOSE-GOAL :content (ADOPT :id ?!id :WHAT ?!what :AS (GOAL)) :context ?context))
		     (RECORD ACTIVE-GOAL ?!id)
		     (RECORD ACTIVE-CONTEXT ?context)
		     (GENERATE
		      :content (ONT::PROPOSE :content (ADOPT :id ?!id :WHAT ?!what :AS (GOAL)))
		      :context ?context)
		     )
;	  :destination 'initiate-csm-goal-response)
	  :destination 'answers ;'propose-cps-act
	  )

	 (transition
	  :description "default"
	  :pattern '((?!spec ?sa ?t)
		     -default8
		     ;(GENERATE :content (ONT::TELL :content (ONT::SOMETHING-IS-WRONG)))
		     (GENERATE :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))		     
		     )
	  :destination 'segmentend ;'propose-cps-act
	  )
	 
	 )
	))

#|
(add-state 'initiate-csm-goal-response
 (state :action nil
	:implicit-confirm t
	:transitions
	(list
	 ;; If the user rejects this, we ask them to propose something
	 (transition
	  :description "rejectance"
	  :pattern '((ONT::SPEECHACT ?sa1 ONT::REJECT )
		     (ont::eval (find-attr :result (?prop :content ?!content :context ?!context) 
				 :feature PROPOSAL-ON-TABLE))
		     -intitiate-response2>
		     (UPDATE-CSM (REJECTED :content ?!content :context ?!context))
		     (GENERATE
		      :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent *USER*))))
	  :destination 'segmentend)
	 
	 (transition
	  :description "acceptance"
	  :pattern '((ONT::SPEECHACT ?!sa ONT::ACCEPT)
		     (ont::eval (find-attr :result (?prop :content ?!content :context ?!context) 
				 :feature PROPOSAL-ON-TABLE))
		     -initiate-response1>
		     (UPDATE-CSM (ACCEPTED :content ?!content :context ?!context))
		     (NOTIFY-BA :msg (COMMIT
				      :content ?!content)) ;; :context ?!context))  SIFT doesn't want the context
		     (RECORD ACTIVE-GOAL ?!content)
		     (RECORD ACTIVE-CONTEXT ?!context)
;		     (NOTIFY-BA :msg (SET-SHARED-GOAL
;				      :content ?!content
;				      :context ?!context))
		     )
	  :destination 'what-next-initiative)
	 )
	))
|#

(add-state 'user-prompt
 (state :action nil
	:transitions
	(list
	 (transition
	  :description "what next"
	  :pattern '((ONT::WH-TERM ?!sa ONT::REFERENTIAL-SEM :proform w::WHAT)
		     ;; ((? sp ONT::F ONT::EVENT) ?s1 ONT::SEQUENCE-VAL)
		     (ONT::F ?s1 ONT::SEQUENCE-VAL)
		     (ont::eval (find-attr :result ?!result :feature ACTIVE-GOAL))   ; we assume there is an ACTIVE-GOAL
		     (ont::eval (find-attr :result ?context :feature ACTIVE-CONTEXT))
		     -what-next>
		     (INVOKE-BA :msg (WHAT-NEXT :active-goal ?!result
				      :context ?context))
		     )
	  :destination 'perform-BA-request
	  :trigger t)
	 
	 #||
	 ;; this needs to be made more specific -- currently would match any WHAT question!!
	 (transition
	  :description "what should we do next?"
	  :pattern '((ONT::SPEECHACT ?!sa1 ONT::S_ASK-WHAT-IS :focus ?!foc)
		     (ONT::WH-TERM ?!sa ONT::REFERENTIAL-SEM :proform w::WHAT)
		     (ont::eval (find-attr :result ?!result :feature ACTIVE-GOAL))   ; we assume there is an ACTIVE-GOAL
		     (ont::eval (find-attr :result ?context :feature ACTIVE-CONTEXT))
		     -what-next2>
		     (INVOKE-BA :msg (WHAT-NEXT :active-goal ?!result
				      :context ?context))
		     )
	  :destination 'perform-BA-request
	  :trigger t)||#
	 )
	))


#|
(add-state 'proposal-response
 (state :action nil
	:transitions
	(list
	 (transition
	  :description "OK/ accept"
	  :pattern '((ONT::SPEECHACT ?!sa ONT::ACCEPT)
		     (ont::eval (find-attr :result (?prop :content ?!content :context ?!context)  
				 :feature PROPOSAL-ON-TABLE))
		     -proposal-response1>
		     (UPDATE-CSM  (ACCEPTED :content ?!content :context ?!context))
		     (REQUEST :msg (COMMIT
				      :content ?!content)) ;; :context ?!context))  SIFT doesn't want the context
		     (REQUEST :msg (NOTIFY-WHEN-COMPLETED :agent *USER*
				      :content ?!content
				      :context ?!context))
		     )
	  :destination 'expect-action)
				
	 (transition
	  :description "action completed (from BA)"
	  :pattern '((EXECUTION-STATUS :goal ?!act :status ont::DONE)
		     -demonstrate-action1>
		     (QUERY-CSM :content (ACTIVE-GOAL))
		     ;(RECORD ACTIVE-GOAL ?!act)
		     )
	  :destination 'what-next-initiative-on-new-goal)
	 
	 (transition
	  :description "I can't do it"
	  :pattern '((ONT::SPEECHACT ?!sa ONT::TELL :what ?e)
		     (ONT::F ?e ONT::EXECUTE :force (? x IMPOSSIBLE))
		     (ont::eval (find-attr :result (?prop :content ?!content :context ?!context)  
				 :feature PROPOSAL-ON-TABLE))
		     -inability>
		     (UPDATE-CSM (FAILED-ON :what ?!content :context ?!context))
		     )
	  :destination 'what-next-initiative)
		
	 ;;  JFA: probably reqork this as a proposal to the BA
	 (transition
	  :description "you do it"
	  :pattern '((ONT::SPEECHACT ?!sa ONT::TELL :what ?e)
		     (ONT::F ?e ONT::EXECUTE :agent ?ag :force ont::TRUE)
		     (ONT::PRO ?ag ONT::PERSON :refers-to ONT::SYS)
		     (ont::eval (find-attr :result (?prop :content ?!content :context ?!context)  
				 :feature PROPOSAL-ON-TABLE))
		     (ont::eval (extract-feature-from-act :result ?goal-id :expr ?!content :feature :what))
		     -change-performer>
		     
		     (UPDATE-CSM (PROPOSED
				  :content (ADOPT :what ONT::SYS :as (AGENT :of ?goal-id))
				  :context ?!context))
		     (INVOKE-BA :msg (EVALUATE 
				      :content (ADOPT :what ONT::SYS :as (AGENT :of ?goal-id))
				      :context ?!context))
		     )
	  :destination 'propose-cps-act-response)
	 )
	))

;; here we are waiting for something to happen in the world

(add-state 'expect-action
 (state :action nil
	:transitions
	(list
	 (transition
	  :description "action completed (from BA)"
	  :pattern '((EXECUTION-STATUS :goal ?!act :status ont::DONE)
		     -demonstrate-action2>
		     (QUERY-CSM :content (ACTIVE-GOAL))
		     ;(RECORD LAST-ACTION-DONE ?!act)
		     )
	  :destination 'what-next-initiative-on-new-goal)
	 
	 ;;  user might speak while we're waiting for confirmation
	 (transition
	  :description "what next"
	  :pattern '((ONT::WH-TERM ?!sa ONT::REFERENTIAL-SEM :proform ont::WHAT)
		     ;; ((? sp ONT::F ONT::EVENT) ?s1 ONT::SEQUENCE-VAL)
		     (ONT::F ?s1 ONT::SEQUENCE-VAL)
		     -what-next_b>
		     (NOP))
	  :destination 'what-next-initiative)
								
	 ;; OK might have come in after the action was performed
	 (transition
	  :description "OK/ accept"
	  :pattern '((ONT::SPEECHACT ?!sa ONT::ACCEPT)
		     -OK-confirm-done>
		     (NOP)
		     )
	  :destination 'what-next-initiative)
	 
	 (transition
	  :description "ONT::OK from BA"
	  :pattern '((ONT::OK)
		     -confirm>
		     (NOP))
	  :destination 'expect-action)
	 )
	))
|#

(add-state 'done
 (state :action nil
	:transitions
	(list
	 (transition
	  :description "goal accomplished"
	  :pattern '((ONT::F ?!v ONT::HAVE-PROPERTY :FORMAL ?!f)
		     (ONT::F ?!f ONT::FINISHED)
		     (ont::eval (find-attr :result ?!active :feature ACTIVE-GOAL))
		     -done1>
		     (UPDATE-CSM (STATUS-REPORT :GOAL ?!active
		      :STATUS ONT::DONE))  ; what if the active goal isn't the top goal? It seems that "I'm done" could refer to the current goal and not say the task is complete. So I'm going with that right now. So I'm redirecting this back to what-next!! Then if we are done, we'll find out then.
		     (GENERATE :content (ONT::EVALUATION :content (ONT::GOOD)))
		     (QUERY-CSM :content (ACTIVE-GOAL)))
	  :destination 'what-next-initiative-on-new-goal
	  :trigger t)				
	 )
	))

;; here we are setting alarms if we haven't been waiting, and notify the user if we have been waiting
(add-state 'check-timeout-status
 (state :action '(continue)
	:transitions
	(list
	 (transition
	  :description "system is going to wait for user"
	  :pattern '((continue :arg ?!dummy)
		     (ont::eval (find-attr :result ONT::WAITING-FOR-USER :feature GOAL-STATUS))
		     -waiting-for-user>
		     (RECORD WAITING ONT::WAITING-FOR-USER)
		     (SET-ALARM :delay .005 :msg (ONT::WAITING-FOR-USER))
		     )
	  :destination 'segmentend
	  )
	 (transition
	  :description "system is working on it (first check)"
	  :pattern '((continue :arg ?!dummy)
		     (ont::eval (find-attr :result ONT::WORKING-ON-IT :feature GOAL-STATUS))
		     (ont::eval (find-attr :result (? x NO) :feature WAITING))
		     -working-on-it-1>
		     (RECORD WAITING ONT::WORKING-ON-IT)
		     (SET-ALARM :delay .005 :msg (ONT::WORKING-ON-IT))
		     )
	  :destination 'segmentend
	  )
	 (transition
	  :description "system is working on it (second check)"
	  :pattern '((continue :arg ?!dummy)
		     (ont::eval (find-attr :result ONT::WORKING-ON-IT :feature GOAL-STATUS))
		     (ont::eval (find-attr :result (? x ONT::WORKING-ON-IT) :feature WAITING))
		     (ont::eval (find-attr :result ?!active :feature ACTIVE-GOAL))
		     (ont::eval (find-attr :result ?active-context :feature ACTIVE-CONTEXT))
		     -working-on-it-2>
		     (GENERATE
		      :content (ONT::TELL :content (ONT::WORKING-ON-IT :what ?!active))
		      :context ?active-context)
		     ;;(RECORD X Y)
		     (SET-ALARM :delay .005 :msg (ONT::WORKING-ON-IT))
		     )
	  :destination 'segmentend
	  )
	 
	 (transition
	  :description "default"
	  :pattern '((continue :arg ?!dummy)
		     -default9
		     ;(GENERATE :content (ONT::TELL :content (ONT::SOMETHING-IS-WRONG)))
		     ;(GENERATE :content (ONT::REQUEST :content (ONT::PROPOSE-GOAL :agent ONT::USER)))		     
		     (nop)
		     )
	  :destination 'segmentend
	  )

	 )))

(add-state 'alarm-handler
 (state :action nil
	:transitions
	(list
	 (transition
	  :description "nothing has happened for a while ... we exclude cases when waiting-for-user or working-on-it.
                        we recheck with the BA"
	  :pattern '((ALARM ?!x IDLE-CHECK)
		     (ont::eval (find-attr :result (? x NO) :feature WAITING))
		     (ont::eval (find-attr :result ?!active :feature ACTIVE-GOAL))
		     (ont::eval (find-attr :result ?active-context :feature ACTIVE-CONTEXT))
		     -no-interaction-for-a-while>
		     (INVOKE-BA :msg (WHAT-NEXT :active-goal ?!active :context ?active-context
				      )
		     ))
	  :destination 'perform-ba-request
	  )

	 (transition
	  :description "system has been waiting for user for the determined threshold of time"
	  :pattern '((ALARM ?!x ONT::WAITING-FOR-USER)
		     ;;(ont::eval (find-attr :result WAITING-FOR-USER :feature TIMEOUT-TYPE))
		     (ont::eval (find-attr :result ?!active :feature ACTIVE-GOAL))
		     (ont::eval (find-attr :result ?active-context :feature ACTIVE-context))
		     (ont::eval (find-attr :result (? waiting ONT::WAITING-FOR-USER) :feature WAITING))
		     -no-interaction-waiting>
		     (GENERATE
		      :content (ONT::TELL :content (ONT::WAITING :agent *SYS* :what ?!active))
		      :context ?active-context)
		     (SET-ALARM :delay .01 :msg (ONT::WAITING-FOR-USER))  ;; Set alarm for a longr period of time before asking again
		     )
	  :destination 'segmentend
	  )

	 ;; received alarm for working on it -- recheck with BA
	 (transition
	  :description "system has been working on it for the determined threshold of time"
	  :pattern '((ALARM ?!x ONT::WORKING-ON-IT)
		     ;;(ont::eval (find-attr :result ONT::WORKING-ON-IT :feature TIMEOUT-TYPE))
		     (ont::eval (find-attr :result ?!result :feature ACTIVE-GOAL))
		     (ont::eval (find-attr :result ?context :feature ACTIVE-CONTEXT))
		     (ont::eval (find-attr :result (? waiting ONT::WORKING-ON-IT) :feature WAITING))
		     -no-interaction-working>
		     (INVOKE-BA :msg (WHAT-NEXT :active-goal ?!result
				      :context ?context))
		     )
	  :destination 'perform-ba-request
	  )


	 ;; if nothing else matches we just gobble up the message
	 (transition
	  :description "nothing to do"
	  :pattern '((ALARM ?!x ?y)
		     -waiting-for-user-nop>
		     (nop)
		     )
	  :destination 'segmentend
	 )
	 )))


(add-state 'execution-status-handler
 (state :action nil
	:transitions
	(list
	 (transition
	  :description "action is reported as completed"
	  :pattern '((EXECUTION-STATUS :goal ?!action :status ?!status)
		     -ba-exec-status-done>
		     (UPDATE-CSM (STATUS-REPORT :goal ?!action :status ?!status))
		     (QUERY-CSM :content (ACTIVE-GOAL))
		     )
	  :destination 'what-next-initiative-on-new-goal
	  :trigger t)
	 
	 )))



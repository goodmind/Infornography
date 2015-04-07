#!/usr/bin/csi -script

; not strictly necessary but it's cute
; fuck the haters, also use UTF-8
(define-syntax  λ 
	(syntax-rules ()
		((_ . _) (lambda . _))))

; syntactic cheat
(define-syntax $
	(syntax-rules ()
		((_ var) (get-environment-variable
			(symbol->string (quote var))))))

; could also have been a call to map with a lambda
; but, eh, I might do a comparison later
(define dump (λ (array)
	(if (null? array)
		#t ; suspend
		((λ ()
			(if (string? (car array))
				(display (car array))
				(display "Unknown."))
			(dump (cdr array)))))))

; eventually the whole program will be
; a call to `dump' that prints out the 
; ascii art as a list with the values 
; as below.
(dump `(,($ USER) "@" ,($ HOST))) 

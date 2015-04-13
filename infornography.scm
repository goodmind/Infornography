#!/usr/bin/env csi

; Infornography

(use posix)
(use regex)

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

(define os (λ ()
	(car (system-information))))

; get a memory value from meminfo
; now 50% more reusable!
(define (mem#find value)
	(call-with-input-file "/proc/meminfo"
		(lambda (file)
			(string->number 
				(cadr (regex#string-search 
					(string-append value ":\\s+(\\S+)\\s+kB")
						(read-string #f file)))))))

; format bytes
(define formatbytes (λ (size id)
	(inexact->exact (round
		(cond 
			((eq? id #\K) size)
			((eq? id #\M) (/ size 1000))
			((eq? id #\G) (/ (/ size 1000) 1000))
			(else size))))))

; number to human-readable memory representation
(define number->size (λ (size id)
	(string-append 
		(number->string (formatbytes size id)) (string id))))

(define memory (λ (fmt)
	(let* ((total (mem#find "MemTotal")))
		(let ((used (- (- (mem#find "MemTotal") (mem#find "MemFree")) (mem#find "Cached"))))
			(string-append 
				(number->size used fmt) "/" (number->size total fmt))))))

; eventually the whole program will be
; a call to `dump' that prints out the 
; ascii art as a list with the values 
; as below.

(define data `("
                  .......               
              ...............           " ,($ USER) "@" ,(get-host-name) "
            ....................        Shell: " ,($ SHELL) "
          .........................     Memory: " ,(memory #\M) " 
         ...........................    OS: " ,(os) "
        .............................   
       ...............................  
       ..............x................  
       ............xo@................  
       ...........xoo@xxx.............  
      ........o@oxxoo@@@@@@x..xx.....   
       .....xo@oo...o@@@@@@x...o\\./.    
       ....o@@@@@@@@@@@@@@@@@@@o.\\..    
       .....x@@@@@@@@@@@o@@@@@@x/.\\.    
        ......@@@@@@@@@@o@@@@@x....     
        .......@@@@@@@@o@@@@o......     
             .x@@@@@@@@@@ox.. .....     
            .@@@@@@@ooooxxxo.   ...     
         ...x@@@@@@@@@ooooo@... ..      
      ........@@@@@@@....xoo........    
   .............@@@.................... 
........................................
....................x..x................
\n"))

; and now we display the data...
(dump data)
(exit 0)

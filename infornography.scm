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


; total memory in kb
(define (mem#total)
	(call-with-input-file "/proc/meminfo"
		(lambda (file)
			(cadr (regex#string-search "MemTotal:\\s+(.+) kB"
				(read-string #f file))))))

; string to number representation of size
(define string->nsize (λ (sizestr id)
	(let ((size (string->number sizestr)))
	(cond ((eq? id #\K) size)
		((eq? id #\M) (/ size 1000))
		((eq? id #\G) (/ (/ size 1000) 1000))
		(else size)))))

; string to human readable size
(define string->size (λ (sizestr id)
	(string-append
		(number->string (string->nsize sizestr id)) (string id))))

; eventually the whole program will be
; a call to `dump' that prints out the 
; ascii art as a list with the values 
; as below.

(define data `("
                  .......               
              ...............           " ,($ USER) "@" ,(get-host-name) "
            ....................        Shell: " ,($ SHELL) "
          .........................     Memory: " ,(string->size (mem#total) #\M) "
         ...........................    
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

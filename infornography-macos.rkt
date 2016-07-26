#!/usr/bin/env racket
#lang racket

(define-syntax $
  (syntax-rules ()
    ((_ v)
     (getenv (symbol->string (quote v))))))

(define (-> cmd)
  (port->string (car (process cmd))))

(define (hostname)
  (string-trim (-> "hostname")))

(define (filename->string file)
  (call-with-input-file file port->string))

(define (cpu)
  (string-trim (-> "sysctl -n machdep.cpu.brand_string")))

(define (memory:make-pattern name)
  (pregexp (string-append name ":[[:space:]]+([[:digit:]]+)")))

(define (memory:information)
  (let* ((mkpattern memory:make-pattern)
         (meminfo (-> "vm_stat"))
         (total-pages (/ (string->number (string-trim (-> "sysctl -n hw.memsize"))) 4096))        
         (total  (number->string total-pages))
         (free   (cadr (regexp-match (mkpattern "Pages free") meminfo)))
         (speculative (cadr (regexp-match (mkpattern "Pages speculative") meminfo))))
    
    (map (λ (num)
           (round             
            (/ (/ (* (string->number num) 4096) 1024) 1024)))
         `(,total ,free ,speculative))))

(define (memory)
  (let* ((total  (car (memory:information)))
         (free   (cadr (memory:information)))
         (speculative (caddr (memory:information)))
         (used  (- total (+ free speculative))))
    (let ((sforms (map number->string `(,used ,total))))
      (string-join `(,(car sforms) "M/" ,(cadr sforms) "M") ""))))

(define (os)
  (string-trim (-> "uname -s")))

(define data `("
                  .......               
              ...............           " ,($ USER) "@" ,(hostname) "
            ....................        Shell: " ,($ SHELL) "
          .........................     Memory: " ,(memory) "
         ...........................    OS: " ,(os) "
        .............................   Terminal: " ,($ TERM) "
       ...............................  CPU: " ,(cpu) "
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

(for-each (λ (s)
            (if (string? s)
                (display s)
                (display "Unknown."))) data)

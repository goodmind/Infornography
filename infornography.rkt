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
  (let ((cpuinfo (filename->string "/proc/cpuinfo"))
        (pattern #px"model name\\s+:\\s+([[:print:]]+)"))
    (cadr (regexp-match pattern cpuinfo))))

(define (memory:make-pattern name)
  (pregexp (string-append name ":[[:space:]]+([[:digit:]]+)")))

(define (memory:information)
  (let* ((mkpattern memory:make-pattern)
         (meminfo (filename->string "/proc/meminfo"))        
         (total  (cadr (regexp-match (mkpattern "MemTotal") meminfo)))
         (free   (cadr (regexp-match (mkpattern "MemFree") meminfo)))
         (cached (cadr (regexp-match (mkpattern "Cached") meminfo))))
    
    (map (λ (num)
           (round             
            (/ (string->number num) 1000)))
         `(,total ,free ,cached))))

(define (memory)
  (let* ((total  (car (memory:information)))
         (free   (cadr (memory:information)))
         (cached (caddr (memory:information)))
         (used  (- (- total free) cached)))
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

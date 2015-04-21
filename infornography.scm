#!/usr/bin/env csi

; Infornography

(use posix)
(use regex)

; not strictly necessary but it's cute
; fuck the haters, also use UTF-8
(define-syntax  λ 
  (syntax-rules ()
    ((_ . _) (lambda . _))))

(define-syntax $
  (syntax-rules ()
    ((_ v) (get-environment-variable
            (symbol->string (quote v))))))

; could also have been a call to map with a lambda
; but, eh, I might do a comparison later
(define dump 
  (λ (array)
    (if (null? array)
        #t ; suspend
        ((λ ()
           (if (string? (car array))
               (display (car array))
               (display "Unknown."))
           (dump (cdr array)))))))

(define os 
  (λ ()
    (car (system-information))))

; read a line from meminfo
(define (meminfo#find value)
  (call-with-input-file "/proc/meminfo"
    (lambda (file)
      (string->number 
       (cadr (regex#string-search 
              (string-append value ":\\s+(\\S+)\\s+kB")
              (read-string #f file)))))))

; read memory usage from meminfo
(define meminfo 
  (λ (fmt)
    (let* ((total (meminfo#find "MemTotal")))
      (let ((used (- (- (meminfo#find "MemTotal") (meminfo#find "MemFree")) (meminfo#find "Cached"))))
        (string-append 
         (number->size used fmt) "/" (number->size total fmt))))))

; calls appropriate memory function based
; upon reported OS
(define memory
  (λ (fmt)
    (cond
     ((string-ci=? (os) "linux") (meminfo fmt))
     ((string-ci=? (os) "freebsd") (meminfo fmt))
     (else #f))))

; cpuinfo-based cpu model reporting
(define cpuinfo
  (λ ()
     (let ((regex "model name\\s+:\\s+(.+)"))
       (cadr
        (regex#string-search regex
          (call-with-input-file "/proc/cpuinfo"
            (λ (fp)
               (read-string #f fp))))))))    

(define sysctl#osx
  (λ ()
    (let ((regex "machdep.cpu.brand_string:\\s+(.+)"))
      (cadr (regex#string-search regex
        (call-with-input-pipe "sysctl -a"
          (λ (data) (read-string #f data))))))))

; calls appropriate CPU function
(define cpu
  (λ ()
     (cond 
      ((string-ci=? (os) "linux") (cpuinfo))
      ((string-ci=? (os) "freebsd") (cpuinfo))
      ((string-ci=? (os) "darwin") (sysctl#osx))
      (else #f))))
        
; format bytes
(define formatbytes 
  (λ (size id)
    (inexact->exact (round
                     (cond 
                      ((eq? id #\K) size)
                      ((eq? id #\M) (/ size 1000))
                      ((eq? id #\G) (/ (/ size 1000) 1000))
                      (else size))))))

; number to human-readable memory representation
(define number->size 
  (λ (size id)
    (string-append 
     (number->string (formatbytes size id)) (string id))))

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

; and now we display the data...
(dump data)
(exit 0)

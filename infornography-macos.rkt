#!/usr/bin/env racket
#lang racket/base

(require racket/port racket/system racket/string racket/list)

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

(define (get-match pattern string)
  (cadr (regexp-match pattern string)))

(define (cpu)
  (string-trim (-> "sysctl -n machdep.cpu.brand_string")))

(define (memory:make-pattern name)
  (pregexp (string-append name ":[[:space:]]+([[:digit:]]+)")))

(define (memory:information)
  (let* ((mkpattern memory:make-pattern)
         (meminfo (-> "vm_stat"))
         (total-pages (/ (string->number (string-trim (-> "sysctl -n hw.memsize"))) 4096))
         (total  (number->string total-pages))
         (free   (get-match (mkpattern "Pages free") meminfo))
         (speculative (get-match (mkpattern "Pages speculative") meminfo)))

    (map (λ (num)
           (round
            (/ (/ (* (string->number num) 4096) 1024) 1024)))
         (list total free speculative))))

(define (memory)
  (let* ((total  (first (memory:information)))
         (free   (second (memory:information)))
         (speculative (third (memory:information)))
         (used  (- total (+ free speculative))))
    (string-join (list (number->string used) "M/"
                       (number->string total) "M")
                 "")))

(define (kernel)
  (string-trim (-> "uname -s")))

(define (os)
  (let* ((os-name (-> "sw_vers -productName")) 
         (os-version (-> "sw_vers -productVersion")))
    (string-join (map string-trim (list os-name os-version)))))

(define data (list "
                  .......
              ...............           " ($ USER) "@" (hostname) "
            ....................        Shell: " ($ SHELL) "
          .........................     Memory: " (memory) "
         ...........................    Kernel: " (kernel) "
        .............................   OS: " (os) "
       ...............................  Terminal: " ($ TERM) "
       ..............x................  CPU: " (cpu) "
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

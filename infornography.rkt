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
  (let ((cpuinfo (filename->string "/proc/cpuinfo"))
        (pattern #px"model name\\s+:\\s+([[:print:]]+)"))
    (get-match pattern cpuinfo)))

(define (memory:make-pattern name)
  (pregexp (string-append name ":[[:space:]]+([[:digit:]]+)")))

(define (memory:information)
  (let* ((mkpattern memory:make-pattern)
         (meminfo (filename->string "/proc/meminfo"))
         (get-mem-field (λ (str) (get-match (mkpattern str) meminfo)))
         (total (get-mem-field "MemTotal"))
         (free (get-mem-field "MemFree"))
         (cached (get-mem-field "Cached")))
    (map (λ (num)
           (round
            (/ (string->number num) 1000)))
         (list total free cached))))

(define (memory)
  (let* ((total (first (memory:information)))
         (free (second (memory:information)))
         (cached (third (memory:information)))
         (used (- total free cached)))
    (string-join (list (number->string used) "M/"
                       (number->string total) "M")
                 "")))

(define (kernel)
  (string-trim (-> "uname -s")))

(define data (list "
                  .......
              ...............           " ($ USER) "@" (hostname) "
            ....................        Shell: " ($ SHELL) "
          .........................     Memory: " (memory) "
         ...........................    Kernel: " (kernel) "
        .............................   OS: Linux
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

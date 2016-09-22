#!/usr/bin/env racket
#lang racket/base

(require racket/math racket/port racket/system racket/string racket/list)

(define-syntax $
  (syntax-rules ()
    ((_ v)
     (getenv (symbol->string (quote v))))))

(define (-> cmd)
  (port->string (car (process cmd))))

(define (->number cmd)
  (string->number (string-trim (-> cmd))))

(define (hostname)
  (string-trim (-> "hostname")))

(define (filename->string file)
  (call-with-input-file file port->string))

(define (get-match pattern string)
  (cadr (or (regexp-match pattern string) (list "0" "0"))))

(define (cpu)
  (string-trim (-> "sysctl -n hw.model")))

(define (memory:round mem-size [chip-guess (- (/ mem-size 8.0) 1.0)] [chip-size 1])
  (displayln (list mem-size chip-size chip-guess))
  (if (not (zero? (truncate chip-guess)))
    (memory:round mem-size (/ chip-guess 2.0) (* chip-size 2))
    (* (+ (/ mem-size chip-size) 0.19) chip-size)))

(define (memory:make-pattern name)
  (pregexp (string-append name ":[[:space:]]+([[:digit:]]+)")))

(define (memory:information)
  (let* ((mkpattern memory:make-pattern)
         (pagesize    (->number "sysctl -n hw.pagesize"))
         (total-pages (memory:round (->number "sysctl -n hw.physmem")))
         (total       total-pages)
         (inactive    (* (->number "sysctl -n vm.stats.vm.v_inactive_count") pagesize))
         (free        (* (->number "sysctl -n vm.stats.vm.v_free_count") pagesize))
         (speculative (* (->number "sysctl -n vm.stats.vm.v_cache_count") pagesize)))

    (map (λ (num)
           (floor num))
         (list total free speculative inactive))))

(define (memory)
  (let* ((total  (first (memory:information)))
         (free   (second (memory:information)))
         (speculative (third (memory:information)))
         (inactive (fourth (memory:information)))
         (used  (- total (+ free speculative inactive))))
    (string-join (list (number->string (inexact->exact (floor (/ used (* 1024 1024))))) "M/"
                       (number->string (inexact->exact (floor (/ total (* 1024 1024))))) "M")
                 "")))

(define (os)
  (string-trim (-> "uname -s")))

(displayln (memory))
(define data (list "
                  .......
              ...............           " ($ USER) "@" (hostname) "
            ....................        Shell: " ($ SHELL) "
          .........................     Memory: " (memory) "
         ...........................    OS: " (os) "
        .............................   Terminal: " ($ TERM) "
       ...............................  CPU: " (cpu) "
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

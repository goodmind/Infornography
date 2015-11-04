#!/usr/bin/env racket
#lang racket

(define ESC_SEQ
  (string-trim "\e["))

(define (color?)
  (equal? (first (port->lines (car (process "tput colors")))) "256"))

(define (colorize escape)
  (if (color?)
    (string-append ESC_SEQ escape)
    (string-trim "")))  

(define (COL_RESET)
  (colorize "0m"))

(define (COL_SKIN)
  (colorize "38;5;224m"))

(define (COL_HAIR)
  (colorize "38;5;240m"))

(define (COL_BOLD)
  (colorize "1m"))

(define (COL_YELLOW)
  (colorize "38;5;226m"))

(define (COL_BLACK)
  (colorize "38;5;22m"))

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
" ,(COL_HAIR) "                  .......               " ,(COL_RESET) "
" ,(COL_HAIR) "              ...............           " ,(COL_RESET) " " ,($ USER) "@" ,(hostname) "
" ,(COL_HAIR) "            ....................        " ,(COL_RESET) " " ,(COL_BOLD) "Shell" ,(COL_RESET) ": " ,($ SHELL) "
" ,(COL_HAIR) "          .........................     " ,(COL_RESET) " " ,(COL_BOLD) "Memory" ,(COL_RESET) ": " ,(memory) "
" ,(COL_HAIR) "         ...........................    " ,(COL_RESET) " " ,(COL_BOLD) "OS" ,(COL_RESET) ": " ,(os) "
" ,(COL_HAIR) "        .............................   " ,(COL_RESET) " " ,(COL_BOLD) "Terminal" ,(COL_RESET) ": " ,($ TERM) "
" ,(COL_HAIR) "       ...............................  " ,(COL_RESET) " " ,(COL_BOLD) "CPU" ,(COL_RESET) ": " ,(cpu) "
" ,(COL_HAIR) "       .............." ,(COL_SKIN) "x" ,(COL_HAIR) "................  " ,(COL_RESET) " " ,(COL_BOLD) "WM" ,(COL_RESET) ": " ,($ XDG_CURRENT_DESKTOP) "
" ,(COL_HAIR) "       ............" ,(COL_SKIN) "xo@" ,(COL_HAIR) "................  
       ..........." ,(COL_SKIN) "xoo@xxx" ,(COL_HAIR) ".............  
       ........" ,(COL_SKIN) "o@oxxoo@@@@@@x.." ,(COL_HAIR) "xx.....   
       ....." ,(COL_SKIN) "xo@oo...o@@@@@@x..." ,(COL_HAIR) "o" ,(COL_YELLOW) "\\" 
,(COL_HAIR) "." ,(COL_YELLOW) "/" ,(COL_HAIR) ".    
       ...." ,(COL_SKIN) "o@@@@@@@@@@@@@@@@@@@o" ,(COL_HAIR) "." ,(COL_YELLOW) "\\" 
,(COL_HAIR) "..    
       ....." ,(COL_SKIN) "x@@@@@@@@@@@o@@@@@@" ,(COL_HAIR) "x" ,(COL_YELLOW) "/" 
,(COL_HAIR) "." ,(COL_YELLOW) "\\" ,(COL_HAIR) ".    
        ......" ,(COL_SKIN) "@@@@@@@@@@o@@@@@" ,(COL_HAIR) "x....     
        ......." ,(COL_SKIN) "@@@@@@@@o@@@@o" ,(COL_HAIR) "......     
             ." ,(COL_SKIN) "x@@@@@@@@@@ox" ,(COL_HAIR) ".. .....     
            ." ,(COL_SKIN) "@@@@@@@ooooxxxo" ,(COL_HAIR) ".   ...     
" ,(COL_BLACK) "         ..." ,(COL_SKIN) "x@@@@@@@@@ooooo@" ,(COL_BLACK) "... " 
,(COL_HAIR) "..      
" ,(COL_BLACK) "      ........" ,(COL_SKIN) "@@@@@@@....xoo" ,(COL_BLACK) "........    
   ............. " ,(COL_SKIN) "@@@" ,(COL_BLACK) ".................... 
........................................
....................x..x................
\n"))

(for-each (λ (s)
            (if (string? s)
                (display s)
                (display "Unknown."))) data)

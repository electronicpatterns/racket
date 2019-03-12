(module argument-error "pre-base.rkt"

  ; module implements new raise-argument-error and its two forms

  (provide (rename-out [new-raise-argument-error raise-argument-error]))

  ;;; -----------------------------------------------------------------------------------------
  ;;; implementation section
  
  (require "error-reporting.rkt"
           "list.rkt")
  

  ;; --------------------------------------------
  ;; helper section
  
  (define (raise-one-argument-error name expected v [more-info #f])
    (raise
     (exn:fail:contract/error-report (error-report (absent)
                                                   name
                                                   "contract violation"
                                                   (if more-info (list more-info) (absent))
                                                   (list (expected-short-field expected)
                                                         (given-short-field v)))
                                     (current-continuation-marks))))
  

  ; make-bad-positional-argument-section : string?
  ;                                        exact-nonnegative-integer?
  ;                                        (listof any/c)
  ;                                        ->
  ;                                        error-field?
  ;                                        error-field?
  ;                                        error-field?
  ;                                        (or/c error-field? #f)
  ;
  ; Create four error-field? instances forming a error output reporting section for
  ; bad positional argument and other positional arguments.
  ; The fourth error-field? instance may actually be #f if only one positional argument
  ; was given in args.
  (define (make-bad-positional-argument-section expected bad-pos-0-based args)
    (define bad-value (list-ref args bad-pos-0-based))
    (define other-values (remq bad-value args))
    (define pos-ordinal-1-based (let* ([pos-str (number->string (+ bad-pos-0-based 1))]
                                       [last-char (string-ref pos-str (- (string-length pos-str) 1))])
                                  (cond [(char=? last-char #\1) (string-append pos-str "st")]
                                        [(char=? last-char #\2) (string-append pos-str "nd")]
                                        [else (string-append pos-str "th")])))
    (values (expected-short-field expected)
            (given-short-field bad-value)
            (short-field "argument position" pos-ordinal-1-based '~a)
            ; don't bother make ellipsis-field if other-values is '()
            (if (not (null? other-values)) (ellipsis-field "other arguments" other-values) #f)))

  ; make-positional-argument-section : (listof any/c) -> error-field?
  (define (make-positional-argument-section args)
    (ellipsis-field "arguments" args))

  ; make-bad-keyword-argument-section : string?
  ;                                     keyword?
  ;                                     (listof (cons keyword? any/c))
  ;                                     ->
  ;                                     error-field?
  ;                                     error-field?
  ;                                     error-field?
  ;                                     (or/c error-field? #f)
  ;
  ; Create four error-field? instances forming a error output reporting section for
  ; bad keyword argument and other keyword arguments.
  ; The fourth error-field? instance may actually be #f if only one keyword argument pair
  ; was given in kw-args.
  (define (make-bad-keyword-argument-section expected bad-kw kw-args)
    (define bad-kw-pair (assq bad-kw kw-args))
    (define other-kw-pairs (remq bad-kw-pair kw-args))
    (values (expected-short-field expected)
            (given-short-field (cdr bad-kw-pair))
            (short-field "keyword" (car bad-kw-pair) '~a)
            ; don't bother make ellipsis-field if other-kw-pairs is '()
            (if (not (null? other-kw-pairs))
                (ellipsis-field "other keyword arguments"
                                (map (lambda (p)
                                       (format "~a ~v" (car p) (cdr p)))
                                     other-kw-pairs)
                                '~a)
                #f)))

  ; make-keyword-argument-section : (listof (cons keyword? any/c)) -> error-field?
  (define (make-keyword-argument-section kw-args)
    (ellipsis-field "keyword arguments"
                    (map (lambda (p)
                           (format "~a ~v" (car p) (cdr p)))
                         kw-args)
                    '~a))

  ; raise-multiple-arguments-error : symbol?
  ;                                  string?
  ;                                  (or/c exact-nonnegative-integer? keyword?)
  ;                                  (or/c (listof any/c) (listof (cons keyword? any/c)))
  ;                                  (or/c (listof any/c) (listof (cons keyword? any/c)))
  ;                                  (or/c string? #f)
  ;                                  ->
  ;
  ; raise contract exception containing detailed information about bad argument and other
  ; arguments that can be a combination of posiitonal and keyword arguments.
  ;
  ; If bad is a exact-nonnegative-integer? then assumption is that vs represents
  ; a list of positional arguments.
  ; If bad is a keyword? then vs represents a list of keyword argument pairs.
  ;
  ; other-vs is either a list of positional or a list of keyword arguments that are to be reported
  ; in the output along with the bad argument information. It is assumed if bad argument
  ; is for a positional argument then other-vs must be a list of keyword arguments, or vice versa.
  (define (raise-multiple-arguments-error name expected bad vs other-vs [more-info #f])
    (define-values (expected-field given-field bad-arg-indicator-field other-args-field)
      (cond [(keyword? bad) (make-bad-keyword-argument-section expected bad vs)]
            [else (make-bad-positional-argument-section expected bad vs)]))
    
    (define other-vs-section (cond [(null? other-vs) #f]
                                   [(keyword? bad) (make-positional-argument-section other-vs)]
                                   [else (make-keyword-argument-section other-vs)]))

    ; Assemble all the error-fields that will be reported in the error output
    ; going backward from last field to the first.
    (define error-fields (let* ([fields (if other-vs-section (list other-vs-section) (list))]
                                [fields (if other-args-field (cons other-args-field fields) fields)]
                                [fields (cons expected-field
                                              (cons given-field
                                                    (cons bad-arg-indicator-field fields)))])
                           fields))
   
    (raise
     (exn:fail:contract/error-report (error-report (absent)
                                                   name
                                                   "contract violation"
                                                   (if more-info (list more-info) (absent))
                                                   error-fields)
                                     (current-continuation-marks))))

  ; raise-arguments-index-out-of-bounds : symbol?
  ;                                       exact-nonnegative-integer?
  ;                                       exact-nonnegative-integer?
  ;                                       ->
  (define (raise-arguments-index-out-of-bounds-error name index args-c)
    (raise
     (exn:fail:contract/error-report (error-report (absent)
                                                   name
                                                   "position index >= provided argument count"
                                                   (absent)
                                                   (list (short-field "position index" index)
                                                         (short-field "provided argument count" args-c)))
                                     (current-continuation-marks))))

  ;; --------------------------------------------
  ;; raise-argument-error implementation section

  ; new-raise-argument-error : symbol?
  ;                            string?
  ;                            any/c
  ;                            [#:more-info (or/c string? #f)]
  ;                            [(listof any/c)]
  ;                            ->
  ;
  ; Replacement for the primitive `raise-argument-error`.
  ; Enchanced with addition of #:more-info keyword to include more details about the
  ; argument in the exception's reported error output.
  (define (new-raise-argument-error name expected v #:more-info [more-info #f] . other-vs)
    (unless (symbol? name)
      (raise-multiple-arguments-error 'raise-argument-error
                                      "symbol?"
                                      0
                                      ; report positional args
                                      (list* name expected v other-vs)
                                      ; also report #:more-info keyword arg if it was provided
                                      (if more-info (list (cons '#:more-info more-info)) '())))
    (unless (string? expected)
      (raise-multiple-arguments-error 'raise-argument-error
                                      "string?"
                                      1
                                      ; report positional args
                                      (list* name expected v other-vs)
                                      ; also report #:more-info keyword arg if it was provided
                                      (if more-info (list (cons '#:more-info more-info)) '())))
    (unless (or (not more-info) (string? more-info))
      (raise-multiple-arguments-error 'raise-argument-error
                                      "string?"
                                      '#:more-info
                                      ; report keyword args
                                      (list (cons '#:more-info more-info))
                                      ; also report positional args
                                      (list* name expected v other-vs)))

    (cond [(null? other-vs)
           ; no extra vs supplied so assume first form of `raise-argument-error`
           (raise-one-argument-error name expected v more-info)]
          ; otherwise assume second form of `raise-argument-error` so
          ; v must be exact-nonnegative-integer? representing position of the arguments
          [else
           (unless (exact-nonnegative-integer? v)
             (raise-multiple-arguments-error 'raise-argument-error
                                             "exact-nonnegative-integer?"
                                             2
                                             ; report positional args
                                             (list* name expected v other-vs)
                                             ; also report #:more-info keyword arg if it was provided
                                             (if more-info (list (cons '#:more-info more-info)) '())))
           (define other-vs-length (length other-vs))
           (unless (< v other-vs-length)
             (raise-arguments-index-out-of-bounds-error 'raise-argument-error v other-vs-length))
           (if (= other-vs-length 1)
               (raise-one-argument-error name expected (car other-vs) more-info)
               (raise-multiple-arguments-error name
                                               expected
                                               v
                                               other-vs
                                               '()
                                               more-info))]))
  )
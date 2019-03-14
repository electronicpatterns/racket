(load-relative "loadtest.rktl")

(Section 'error)

;; ----- raise-argument-error forms ----- ;;

(err/rt-test (raise-argument-error 'form-1a "expected?" 'other) 
             exn:fail:contract? 
             #rx"form-1a: contract violation\n  expected: expected\\?\n  given: 'other")

(err/rt-test (raise-argument-error 'form-1b #:more-info "informative sentence explaining more about the argument" "expected?" 'other) 
             exn:fail:contract? 
             #rx"form-1b: contract violation;\n informative sentence explaining more about the argument\n  expected: expected\\?\n  given: 'other")

; make sure line break characters inside #:more-info string are properly handled
(err/rt-test (raise-argument-error 'form-1c #:more-info "informative sentence explaining more about the argument\nanother sentence with even more details\none more sentence" "expected?" 'other) 
             exn:fail:contract? 
             #rx"form-1c: contract violation;\n informative sentence explaining more about the argument\n another sentence with even more details\n one more sentence\n  expected: expected\\?\n  given: 'other")

; long detail on same line as label in a field should automatically move to next line and be indented
(err/rt-test (raise-argument-error 'form-1d "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" 'other) 
             exn:fail:contract? 
             #rx"form-1d: contract violation\n  expected:\n   aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n  given: 'other")

(err/rt-test (raise-argument-error 'form-1e "expected?" 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa) 
             exn:fail:contract? 
             #rx"form-1e: contract violation\n  expected: expected\\?\n  given:\n   'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")

(err/rt-test (raise-argument-error 'form-2a "expected?" 0 'other) 
             exn:fail:contract? 
             #rx"form-2a: contract violation\n  expected: expected\\?\n  given: 'other")

(err/rt-test (raise-argument-error 'form-2b "expected?" 0 'other1 'other2 'other3) 
             exn:fail:contract? 
             #rx"form-2b: contract violation\n  expected: expected\\?\n  given: 'other1\n  argument position: 1st\n  other arguments...:\n   'other2\n   'other3")

(err/rt-test (raise-argument-error 'form-2c "expected?" 1 'other1 'other2 'other3) 
             exn:fail:contract? 
             #rx"form-2c: contract violation\n  expected: expected\\?\n  given: 'other2\n  argument position: 2nd\n  other arguments...:\n   'other1\n   'other3")

(err/rt-test (raise-argument-error 'form-2d "expected?" 2 'other1 'other2 'other3) 
             exn:fail:contract? 
             #rx"form-2d: contract violation\n  expected: expected\\?\n  given: 'other3\n  argument position: 3rd\n  other arguments...:\n   'other1\n   'other2")

; make sure ordinal position names are correct for 11, 12, 13
(err/rt-test (raise-argument-error 'form-2e "expected?" 10 'other1 'other2 'other3  'other4 'other5 'other6 'other7 'other8 'other9 'other10 'other11 'other12 'other13 'other14) 
             exn:fail:contract? 
             #rx"form-2e: contract violation\n  expected: expected\\?\n  given: 'other11\n  argument position: 11th\n")

(err/rt-test (raise-argument-error 'form-2f "expected?" 11 'other1 'other2 'other3  'other4 'other5 'other6 'other7 'other8 'other9 'other10 'other11 'other12 'other13 'other14) 
             exn:fail:contract? 
             #rx"form-2f: contract violation\n  expected: expected\\?\n  given: 'other12\n  argument position: 12th\n")

(err/rt-test (raise-argument-error 'form-2g "expected?" 12 'other1 'other2 'other3  'other4 'other5 'other6 'other7 'other8 'other9 'other10 'other11 'other12 'other13 'other14) 
             exn:fail:contract? 
             #rx"form-2g: contract violation\n  expected: expected\\?\n  given: 'other13\n  argument position: 13th\n")

(err/rt-test (raise-argument-error 'form-2h #:more-info "informative sentence explaining more about the argument" "expected?" 0 'other) 
             exn:fail:contract? 
             #rx"form-2h: contract violation;\n informative sentence explaining more about the argument\n  expected: expected\\?\n  given: 'other")

(err/rt-test (raise-argument-error 'form-2i "expected?" 2 'other1 'other2 'other3 #:more-info "informative sentence explaining more about the argument") 
             exn:fail:contract? 
             #rx"form-2i: contract violation;\n informative sentence explaining more about the argument\n  expected: expected\\?\n  given: 'other3\n  argument position: 3rd\n  other arguments...:\n   'other1\n   'other2")

; make sure line break characters inside #:more-info string are properly handled
(err/rt-test (raise-argument-error 'form-2j "expected?" 2 'other1 'other2 'other3 #:more-info "informative sentence explaining more about the argument\nanother sentence with even more details\none more sentence") 
             exn:fail:contract? 
             #rx"form-2j: contract violation;\n informative sentence explaining more about the argument\n another sentence with even more details\n one more sentence\n  expected: expected\\?\n  given: 'other3\n  argument position: 3rd\n  other arguments...:\n   'other1\n   'other2")

(err/rt-test (raise-argument-error 'form-2k "expected?" 3 2 2 1 2 1 2) 
             exn:fail:contract? 
             #rx"form-2k: contract violation\n  expected: expected\\?\n  given: 2\n  argument position: 4th\n  other arguments...:\n   2\n   2\n   1\n   1\n   2")


; Check expected exceptions when raise-argument-error is misused.

(err/rt-test (raise-argument-error 'form-1a "expected?") 
             exn:fail:contract:arity?
             #rx"raise-argument-error: arity mismatch")

(err/rt-test (raise-argument-error "form-1b" "expected?" 'other)
             exn:fail:contract?
             #rx"raise-argument-error: contract violation\n  expected: symbol\\?")

(err/rt-test (raise-argument-error 'form-1c 'expected? 'other)
             exn:fail:contract?
             #rx"raise-argument-error: contract violation\n  expected: string\\?")

(err/rt-test (raise-argument-error 'form-1d "expected?" 'other #:more-info 'not-string)
             exn:fail:contract?
             #rx"raise-argument-error: contract violation\n  expected: string\\?\n  given: 'not-string\n  keyword: #:more-info\n  arguments...:\n   'form-1d\n   \"expected\\?\"\n   'other")

(err/rt-test (raise-argument-error "form-2a" "expected?" 0 'other) 
             exn:fail:contract? 
             #rx"raise-argument-error: contract violation\n  expected: symbol\\?")

(err/rt-test (raise-argument-error 'form-2b 'expected? 0 'other1 'other2 'other3) 
             exn:fail:contract? 
             #rx"raise-argument-error: contract violation\n  expected: string\\?")

(err/rt-test (raise-argument-error 'form-2c "expected?" 'NaN 'other) 
             exn:fail:contract? 
             #rx"raise-argument-error: contract violation\n  expected: exact-nonnegative-integer\\?\n  given: 'NaN")

(err/rt-test (raise-argument-error 'form-2d "expected?" 5 'other1 'other2 'other3) 
             exn:fail:contract? 
             #rx"raise-argument-error: position index >= provided argument count\n  position index: 5\n  provided argument count: 3")

(err/rt-test (raise-argument-error 'form-2e #:more-info 345 "expected?" 0 'other1 'other2 'other3) 
             exn:fail:contract? 
             #rx"raise-argument-error: contract violation\n  expected: string\\?\n  given: 345\n  keyword: #:more-info\n  arguments...:\n")

; make sure keyword argument is properly reported in error output when raise-argument-error is misused
(err/rt-test (raise-argument-error 'form-2f 'expected? 0 'other1 #:more-info "string") 
             exn:fail:contract? 
             #rx"raise-argument-error: contract violation\n  expected: string\\?\n  given: 'expected\\?\n  argument position: 2nd\n  other arguments...:\n   'form-2f\n   0\n   'other1\n  keyword arguments...:\n   #:more-info \"string\"")

(require racket/private/error-reporting)

(err/rt-test (error-report->string 'not-an-error-report)
             exn:fail:contract?
             #rx"expected: error-report\\?")

(let ()
  (define err-rpt (error-report (absent) (absent) (absent) (absent) (absent)))
  (test #t string=? "" (error-report->string err-rpt)))

(let ()
  (define err-rpt (error-report (srcloc "file.rkt" 167 23 4 5) (absent) (absent) (absent) (absent)))
  (test #t string=? "file.rkt:167:23:" (error-report->string err-rpt))

  (err/rt-test (error-report "not a srcloc" (absent) (absent) (absent) (absent))
             exn:fail:contract?
             #rx"expected: srcloc\\?"))

(let ()
  (define err-rpt1 (error-report (absent) #f (absent) (absent) (absent)))
  (test #t string=? "#f:" (error-report->string err-rpt1))

  (define err-rpt2 (error-report (absent) 'name (absent) (absent) (absent)))
  (test #t string=? "name:" (error-report->string err-rpt2))

  (define err-rpt3 (error-report (absent) "name" (absent) (absent) (absent)))
  (test #t string=? "name:" (error-report->string err-rpt3))

  (define err-rpt4 (error-report (absent) (void) (absent) (absent) (absent)))
  (test #t string=? "#<void>:" (error-report->string err-rpt4))

  (define err-rpt5 (error-report (absent) 77 (absent) (absent) (absent)))
  (test #t string=? "77:" (error-report->string err-rpt5)))

(let ()
  (define err-rpt1 (error-report (absent) (absent) "some string message" (absent) (absent)))
  (test #t string=? "some string message" (error-report->string err-rpt1))

  (define err-rpt2 (error-report (absent) (absent) #f (absent) (absent)))
  (test #t string=? "#f" (error-report->string err-rpt2))

  (define err-rpt3 (error-report (absent) (absent) 'message (absent) (absent)))
  (test #t string=? "message" (error-report->string err-rpt3))

  (define err-rpt4 (error-report (absent) (absent) 56 (absent) (absent)))
  (test #t string=? "56" (error-report->string err-rpt4)))

(let ()
  (define err-rpt1 (error-report (absent) (absent) (absent) (list "a continued sentence") (absent)))
  (test #t string=? " a continued sentence" (error-report->string err-rpt1))

  (define err-rpt2 (error-report (absent) (absent) (absent) (list "a continued sentence" 453 'symbolic-message "another sentence") (absent)))
  (test #t string=? " a continued sentence\n 453\n symbolic-message\n another sentence" (error-report->string err-rpt2))

  (define err-rpt3 (error-report (absent) (absent) (absent) (list "a continued sentence" (void) "sentence with line break\n character in middle") (absent)))
  (test #t string=? " a continued sentence\n #<void>\n sentence with line break\n  character in middle" (error-report->string err-rpt3))

  (define err-rpt4 (error-report (absent) (absent) (absent) (list) (absent)))
  (test #t string=? "" (error-report->string err-rpt4))

  (err/rt-test (error-report (absent) (absent) (absent) "not a list" (absent))
             exn:fail:contract?
             #rx"expected: (listof any/c)"))

(let ()
  (define err-rpt1 (error-report (absent) (absent) (absent) (absent) (list)))
  (test #t string=? "" (error-report->string err-rpt1))

  (define err-rpt2 (error-report (absent) (absent) (absent) (absent) (list (short-field "expected" "something"))))
  (test #t string=? "  expected: \"something\"" (error-report->string err-rpt2))

  (define err-rpt3 (error-report (absent) (absent) (absent) (absent) (list (short-field "expected" "something" '~a))))
  (test #t string=? "  expected: something" (error-report->string err-rpt2))

  (define err-rpt4 (error-report (absent) (absent) (absent) (absent) (list (short-field "random label" 'something))))
  (test #t string=? "  random label: 'something" (error-report->string err-rpt4))

  (define err-rpt5 (error-report (absent) (absent) (absent) (absent) (list (short-field "random label" 'something '~a))))
  (test #t string=? "  random label: something" (error-report->string err-rpt5))

  (define err-rpt6 (error-report (absent) (absent) (absent) (absent) (list (long-field "expected" (list "something" 'something 45)))))
  (test #t string=? "  expected:\n   \"something\"\n   'something\n   45" (error-report->string err-rpt6))

  (define err-rpt7 (error-report (absent) (absent) (absent) (absent) (list (long-field "expected" (list "something" 'something 45) '~a))))
  (test #t string=? "  expected:\n   something\n   something\n   45" (error-report->string err-rpt7))

  (define err-rpt8 (error-report (absent) (absent) (absent) (absent) (list (long-field "expected" (list)))))
  (test #t string=? "  expected:\n" (error-report->string err-rpt8))

  (define err-rpt9 (error-report (absent) (absent) (absent) (absent) (list (ellipsis-field "arguments" (list 'something "something")))))
  (test #t string=? "  arguments...:\n   'something\n   \"something\"" (error-report->string err-rpt9))

  (define err-rpt10 (error-report (absent) (absent) (absent) (absent) (list (ellipsis-field "arguments" (list 'something "something") '~a))))
  (test #t string=? "  arguments...:\n   something\n   something" (error-report->string err-rpt10))

  (define err-rpt11 (error-report (absent) (absent) (absent) (absent) (list (ellipsis-field "arguments" (list)))))
  (test #t string=? "  arguments...:\n" (error-report->string err-rpt11))

  (define err-rpt12 (error-report (absent) (absent) (absent) (absent) (list (short-field "expected" "something" '~a)
                                                                            (short-field "given" 'wrong-value)
                                                                            (short-field "argument position" "3rd" '~a)
                                                                            (ellipsis-field "other arguments" (list 'other "stuff" 345))
                                                                            (long-field "doc" (string->path "path to documentation located somewhere in the universe, good luck finding it")))))
  (test #t
        string=?
        "  expected: something\n  given: 'wrong-value\n  argument position: 3rd\n  other arguments...:\n   'other\n   \"stuff\"\n   345\n  doc:\n   #<path:path to documentation located somewhere in the universe, good luck finding it>"
        (error-report->string err-rpt12))

  ; verify if short-field printed error output exceeds limit then it's automatically converted to long-field
  (define err-rpt13 (error-report (absent) (absent) (absent) (absent) (list (short-field "label" "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"))))
  (test #t string=? "  label:\n   \"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\"" (error-report->string err-rpt13))

  (define err-rpt14 (error-report (absent) (absent) (absent) (absent) (list (short-field "label" 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa))))
  (test #t string=? "  label:\n   'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" (error-report->string err-rpt14))

  ; make sure specified detail format style is preserved when short-field is converted to long-field
  (define err-rpt15 (error-report (absent) (absent) (absent) (absent) (list (short-field "label" "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" '~a))))
  (test #t string=? "  label:\n   aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" (error-report->string err-rpt15))

  (err/rt-test (error-report (absent) (absent) (absent) (absent) "not a list")
             exn:fail:contract?
             #rx"expected: (listof error-field\\?)")

  (err/rt-test (error-report (absent) (absent) (absent) (absent) (list 'not-error-field? 43))
             exn:fail:contract?
             #rx"expected: (listof error-field\\?)"))

(let ()
  (define err-rpt1 (error-report (srcloc "file.rkt" 167 23 4 5)
                                 'name
                                 "some string message"
                                 (list "a continued sentence" (void) "sentence with line break\n character in middle")
                                 (list (short-field "expected" "something" '~a)
                                       (short-field "given" 'wrong-value)
                                       (long-field "explanation" (list "sentence1" 'example1)))))
  (test #t
        string=?
        "file.rkt:167:23: name: some string message;\n a continued sentence\n #<void>\n sentence with line break\n  character in middle\n  expected: something\n  given: 'wrong-value\n  explanation:\n   \"sentence1\"\n   'example1"
        (error-report->string err-rpt1))

  (define err-rpt2 (error-report (absent)
                                 'name
                                 "some string message"
                                 (absent)
                                 (list (short-field "expected" "something" '~a)
                                       (short-field "given" 'wrong-value))))
  (test #t
        string=?
        "name: some string message\n  expected: something\n  given: 'wrong-value"
        (error-report->string err-rpt2)))

(let ()
  (err/rt-test (short-field 'not-a-string 'detail)
             exn:fail:contract?
             #rx"expected: string\\?")

  (err/rt-test (long-field 'not-a-string (list))
             exn:fail:contract?
             #rx"expected: string\\?")

  (err/rt-test (ellipsis-field 'not-a-string (list))
             exn:fail:contract?
             #rx"expected: string\\?")

  (err/rt-test (short-field "label" 'detail 'invalid-style)
             exn:fail:contract?
             #rx"expected: (or/c '~a '~v)")

  (err/rt-test (long-field "label" (list) 45)
             exn:fail:contract?
             #rx"expected: (or/c '~a '~v)")

  (err/rt-test (ellipsis-field "label" (list) "~a")
             exn:fail:contract?
             #rx"expected: (or/c '~a '~v)")

  (err/rt-test (long-field "label" "not a list")
             exn:fail:contract?
             #rx"expected: (listof any/c)")

  (err/rt-test (ellipsis-field "label" "not a list")
             exn:fail:contract?
             #rx"expected: (listof any/c)")

  (define sf1 (short-field "label" 23))
  (test #t equal? "label" (error-field-label sf1))
  (test #t equal? 23 (error-field-detail sf1))
  (test #t equal? '~v (error-field-detailsf sf1))

  (define sf2 (short-field "label" 'detail '~a))
  (test #t equal? "label" (error-field-label sf2))
  (test #t equal? 'detail (error-field-detail sf2))
  (test #t equal? '~a (error-field-detailsf sf2))

  (define lf1 (long-field "something" (list 45 'hi)))
  (test #t equal? "something" (error-field-label lf1))
  (test #t equal? (list 45 'hi) (error-field-detail lf1))
  (test #t equal? '~v (error-field-detailsf lf1))

  (define lf2 (long-field "else" (list) '~a))
  (test #t equal? "else" (error-field-label lf2))
  (test #t equal? '() (error-field-detail lf2))
  (test #t equal? '~a (error-field-detailsf lf2))

  (define ef1 (ellipsis-field "something" (list 45 'hi)))
  (test #t equal? "something" (error-field-label ef1))
  (test #t equal? (list 45 'hi) (error-field-detail ef1))
  (test #t equal? '~v (error-field-detailsf ef1))

  (define ef2 (long-field "else" (list) '~a))
  (test #t equal? "else" (error-field-label ef2))
  (test #t equal? '() (error-field-detail ef2))
  (test #t equal? '~a (error-field-detailsf ef2)))

(report-errs)
;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package #:stp-parser)

(defun move-to-start (stream)
  (let ((start-regexp "^Data:$"))
    (loop for line = (read-line stream)
       until (all-matches start-regexp line))))

(defun normalized-read-csv (line)
  (remove-if #'(lambda (x) (= 0 (length x))) (cdar (read-csv line))))

(defun read-header (stream)
  (progn
    (move-to-start stream)
    (mapcar #'strip-string (normalized-read-csv (read-line stream)))))

(defun strip-string (str)
  (let ((pos (position #\| str :from-end t)))
    (if pos (subseq str (1+ pos)) str)))

(defun show-sig-name (signals)
  (loop for signal in signals
       do (format t "~a~10t~%" signal)))

(defun extract-inst (stream signals which)
  (let ((pos (position which signals :test #'string=)))
    (unless pos
      (error "can't find signals, check your input."))
    (loop for line = (read-line stream nil)
       for time from 0 until (not line)
       collect (mips-disassemble (nth pos (normalized-read-csv line))))))

(defun query (csv-file &optional which)
  (with-open-file (csv-stream csv-file)
    (let ((signals (read-header csv-stream)))
      (if which
          (extract-inst csv-stream signals which)
          (show-sig-name signals)))))

(defun mips-disassemble (mc)
  (with-output-to-string (inst)
    (run-program "./mips-disassembly"
                 `(,mc)
                 :output inst
                 :directory #p"~/lisp/stp-parser/mips-disassembly-v1.5-cmdline")))

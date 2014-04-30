;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package #:stp-parser)

(defun find-start (stream)
  (let ((start-regexp "^Data:$"))
    (handler-case
        (loop for line = (read-line stream)
           while (not (cl-ppcre:all-matches start-regexp line))
           finally (return t))
      (condition (c) (declare (ignore c)) nil))))

(defun normalized-read-csv (line)
  (remove-if #'(lambda (x) (= 0 (length x))) (cdar (read-csv line))))

(defun read-stp (file)
  (with-open-file (s file)
    (let ((signals (and (find-start s) (parse-elements (read-line s)))))
      (loop for line = (read-line s nil) when line
         do (mapcar #'(lambda (sig val)
                        (vector-push-extend val (val sig)))
                    signals
                    (normalized-read-csv line))
         while line)
      signals)))

(defclass stp-val ()
  ((name
    :accessor name
    :initarg :name
    :initform nil)
   (val
     :accessor val
     :initarg :val
     :initform (make-array 100 :adjustable t :fill-pointer 0))))

(defun strip-string (str)
  (let ((pos (position #\| str :from-end t)))
    (if pos
        (subseq str (1+ pos))
        str)))

(defun parse-elements (line)
  (let ((csv (normalized-read-csv line)))
    (loop for name in csv
       collect (make-instance 'stp-val :name (strip-string name)))))

(defun show-sig-name (signals)
  (loop for signal in signals
       do (format t "~a~10t~%" (name signal))))

(defun query (csv-file &optional which)
  (let* ((signals (read-stp csv-file)))
    (when (null which)
      (show-sig-name signals)
      (return-from query nil))
    (let ((sig (find-if #'(lambda (sig) (string= (name sig) which)) signals)))
      (loop for val across (val sig)
         for time from 0
         do (format t "[~d]~8,0x~%" time (mips-disassemble val))))))

(defun mips-disassemble (mc)
  (with-output-to-string (inst)
    (run-program "./mips-disassembly"
                 `(,mc)
                 :output inst
                 :directory #p"~/lisp/stp-parser/mips-disassembly-v1.5-cmdline")))

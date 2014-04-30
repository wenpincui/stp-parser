(defpackage #:stp-parser
  (:use
   #:cl
   #:cl-csv
   #:cl-ppcre
   #:sb-ext)
  (:export
   :query
   :mips-disassemble
   :read-stp
   :find-start))

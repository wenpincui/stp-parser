(asdf:defsystem stp-parser
  :version "0"
  :description ""
  :maintainer "wenpin cui <wenpincui@mac>"
  :author "wenpin cui <wenpincui@mac>"
  :licence "BSD-style"
  :depends-on (cl-ppcre cl-csv)
  :serial t
  :components ((:file "package")
               (:file "stp-parser"))
  )

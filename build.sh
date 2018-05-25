set -ex

echo '(load "~/quicklisp/setup.lisp")
(ql:quickload :coleslaw)
(coleslaw:main "/Users/bob/Documents/dcb9/blog")
(quit)' | sbcl


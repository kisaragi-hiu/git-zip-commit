;; -*- mode: lisp-interaction; lexical-binding: t; -*-

(require 'git-zip-commit)
(require 'buttercup)

(describe "hello"
  (it "says hello"
    (expect (pkgname-hello-world)
            :to-equal
            "Hello world!")))

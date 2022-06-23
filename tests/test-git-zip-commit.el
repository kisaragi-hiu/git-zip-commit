;; -*- mode: lisp-interaction; lexical-binding: t; -*-

(require 'git-zip-commit)
(require 'buttercup)

(describe "git-zip-commit--run"
  (it "can run a command"
    (expect (git-zip-commit--run "echo" "hello")
            :to-equal "hello\n"))
  (it "returns nil on failure"
    (expect (git-zip-commit--run "false")
            :to-eq nil)))

(describe "git-zip-commit--commit-message"
  (it "gets the commit message"
    (expect (git-zip-commit--commit-message
             "23d4d974d6d47aa42842b377de1e046d6a772d4d")
            :to-equal "Initial commit"))
  (it "returns nil if it fails"
    (expect (git-zip-commit--commit-message "")
            :to-eq nil)))

(describe "git-zip-commit--commit-changed-files"
  (it "returns list of changed files"
    ;; We need a second commit
    (expect (git-zip-commit--commit-changed-files
             "440109d210efdfa63e72793f47df8804675bb26d")
            :to-have-same-items-as '("tests/test-git-zip-commit.el")))
  (it "returns nil if it fails"
    (expect (git-zip-commit--commit-changed-files "")
            :to-eq nil)
    (expect (git-zip-commit--commit-changed-files
             "23d4d974d6d47aa42842b377de1e046d6a772d4d")
            :to-eq nil)))

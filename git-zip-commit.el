;;; git-zip-commit.el --- Package a commit up as a zip file -*- lexical-binding: t -*-

;; Author: Kisaragi Hiu
;; Version: 0.1.0
;; Package-Requires: ((emacs "25.1") (dash "2.19.1"))


;; This file is not part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.


;;; Commentary:

;; Run (git-zip-commit <path-to-repository> <commit>) to pack the
;; changed files (not patches) of that commit into a zip file, along
;; with a file called "changes" with the commit message inside.
;;
;; This is useful for, say, submitting changes to a Subversion
;; repository that accepts changes as new files. For instance, I use
;; this to submit translations to KDE.

;;; Code:

(require 'dash)
(require 'cl-lib)

(defun git-zip-commit--run (&rest command)
  "Run COMMAND and return result as a string."
  (let (exit-code)
    (with-temp-buffer
      (setq exit-code (apply #'call-process (car command) nil t nil (cdr command)))
      (when (eql exit-code 0)
        (buffer-string)))))

(defun git-zip-commit--commit-message (commit)
  "Return commit message of COMMIT in current repository."
  (-some->
      (git-zip-commit--run "git" "show" "-s" "--format=%B" commit)
    string-trim))

(defun git-zip-commit--commit-changed-files (commit)
  "Return list of files that COMMIT changed in current repository."
  (-some->
      (git-zip-commit--run "git" "diff-tree" "-r" "--no-commit-id" "--name-only" commit)
    (split-string "\n" t)))

(defun git-zip-commit--read-recent-commit (prompt)
  "Ask (with PROMPT) user to select a recent commit in the current repo.

If point is on a `git-revision' (defined by Magit), use that as
the initial input."
  (let ((candidates (-some-> (git-zip-commit--run "git" "log" "--format=oneline")
                      (split-string "\n" t))))
    (-> (completing-read prompt candidates nil nil
                         (thing-at-point 'git-revision))
        (split-string " ")
        car)))

;;;###autoload
(defun git-zip-commit (repo commit)
  "Zip files changed by COMMIT in REPO.

A file called \"changes\" will also be created, containing the
commit message of COMMIT.

The zip will be put in the parent folder of REPO as COMMIT.zip."
  (interactive
   (let ((repo (read-directory-name "Repository: " nil nil t)))
     (cl-assert
      ;; Stripped down version of `magit-git-repo-p'.
      (and (file-directory-p repo)
           (or (file-regular-p (expand-file-name ".git" repo))
               (file-directory-p (expand-file-name ".git" repo)))))
     (let ((default-directory repo))
       (list repo (git-zip-commit--read-recent-commit "Commit: ")))))
  (let ((default-directory repo)
        (zip (concat commit ".zip")))
    ;; Write commit message to file "changes"
    (with-temp-file "changes"
      (insert (git-zip-commit--commit-message commit)))
    (when (apply #'git-zip-commit--run "7z" "a" zip "changes" (git-zip-commit--commit-changed-files commit))
      (rename-file zip (expand-file-name zip ".."))
      (message
       "Commit %s in repo %s has been zipped as %s."
       commit
       repo
       (file-truename
        (expand-file-name zip "..")))
      (delete-file "changes"))))

(provide 'git-zip-commit)

;;; git-zip-commit.el ends here

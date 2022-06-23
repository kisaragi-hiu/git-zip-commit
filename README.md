# git-zip-commit

<kbd>M-x</kbd> `git-zip-commit` <kbd>RET</kbd>, select a repository, select or enter a commit, then the files changed by that commit will be zipped into `<repository>/../<commit>.zip`, along with the commit message as the file `changes` in the zip file.

Requires the `7z` command.

This is really just to make it easier for me to submit zh_TW translations to KDE.

## Install

```elisp
(straight-use-package '(git-zip-commit :type git :host github :repo "kisaragi-hiu/git-zip-commit"))
```

## License

GPLv3.

;;; init.el --- personal configuration  -*- lexical-binding: t; coding: utf-8 -*-

;; TODO: Set up projects from crafted-emacs
;; TODO: Checkout Embark

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (and custom-file
           (file-exists-p custom-file))
  (load custom-file nil :nomessage))

(load "~/.config/crafted-emacs/modules/crafted-init-config")

;; Add package definitions for completion packages
;; to `package-selected-packages'.
(require 'crafted-completion-packages)
(require 'crafted-org-packages)
(require 'crafted-ui-packages)
(require 'crafted-writing-packages)

;; Emacs 31 draws Corfu's popup in terminals itself (tty child frames), and
;; Corfu warns whenever corfu-terminal loads. crafted-completion-config loads
;; it when `display-graphic-p' is nil at init, which is always true in the
;; daemon, so every first client frame opened on that warning. Not installing
;; it makes crafted's `(require 'corfu-terminal nil :noerror)' a no-op.
(when (featurep 'tty-child-frames)
  (setq package-selected-packages
        (delq 'corfu-terminal package-selected-packages)))

;; sudo apt install -y ripgrep
;; https://github.com/Wilfred/deadgrep/blob/master/docs/ALTERNATIVES.md
(add-to-list 'package-selected-packages 'deadgrep)
(add-to-list 'package-selected-packages 'ergoemacs-mode)
(add-to-list 'package-selected-packages 'org-roam)

;; org-ref supplies the cite:/textcite:/ref:/label: link types the TCC's org
;; sources use. Without it `org-latex-export-to-latex' aborts outright:
;;   user-error: Org export aborted.  Unable to resolve link: "cite:edwards2009"
(add-to-list 'package-selected-packages 'org-ref)

;; Git: Magit for status, staging and history; diff-hl marks changed lines in
;; the fringe of the buffer being edited.
(add-to-list 'package-selected-packages 'magit)
(add-to-list 'package-selected-packages 'diff-hl)

;; Picks a spelling correction through the completion UI (vertico).
(add-to-list 'package-selected-packages 'flyspell-correct)

;; Install the packages listed in the `package-selected-packages' list.
(package-install-selected-packages :noconfirm)

(when (executable-find "rg")
  (global-set-key (kbd "<f5>") 'deadgrep))

;; Load configuration for crafted-emacs modules
(require 'crafted-completion-config)
(require 'crafted-defaults-config)
(require 'crafted-startup-config)
(require 'crafted-ui-config)
(require 'crafted-writing-config)

;; Universal Keyboard Shortcuts (Ctrl-C, Ctrl-V)
(require 'ergoemacs-mode)

;; ErgoEmacs places its bindings by physical key position, translating from a
;; `us' layout to whatever `ergoemacs-keyboard-layout' names. It ships `pt' and
;; `pt-nativo' but no Brazilian ABNT2, so with the default `us' every binding
;; that lands on punctuation sits on the wrong physical key here.
;;
;; A layout is just a variable named ergoemacs-layout-<name>: eight rows of
;; fifteen slots, one per physical key (four unshifted, then the same shifted),
;; aligned with `ergoemacs-layout-us'. Values below come from XKB's br(abnt2),
;; which is `latin' plus the overrides for ' = ¨ ´ [ ] ç ~ \ ; / .
(defvar ergoemacs-layout-br
  '(""  "'"  "1" "2" "3" "4" "5" "6" "7" "8" "9" "0" "-" "=" ""
    ""  ""   "q" "w" "e" "r" "t" "y" "u" "i" "o" "p" "´" "[" ""
    ""  ""   "a" "s" "d" "f" "g" "h" "j" "k" "l" "ç" "~" "]" ""
    ""  "\\" "z" "x" "c" "v" "b" "n" "m" "," "." ";" "/" "" ""
    ;; Shifted
    ""  "\"" "!" "@" "#" "$" "%" "¨" "&" "*" "(" ")" "_" "+" ""
    ""  ""   "Q" "W" "E" "R" "T" "Y" "U" "I" "O" "P" "`" "{" ""
    ""  ""   "A" "S" "D" "F" "G" "H" "J" "K" "L" "Ç" "^" "}" ""
    ""  "|"  "Z" "X" "C" "V" "B" "N" "M" "<" ">" ":" "?" "" "")
  "Brazilian ABNT2 layout, from XKB `br(abnt2)'.")

(setq ergoemacs-keyboard-layout "br")

(ergoemacs-mode t)

;; Sane defaults
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)

;; After a prefix such as C-c or C-x v, list what can follow it.
(which-key-mode)

;; Spelling — Hunspell checks against several dictionaries at once, so English
;; terms inside Portuguese text are not flagged; aspell takes one at a time.
;; The combined name must be registered before a buffer asks for it (the TCC
;; does, in .dir-locals.el). The personal dictionary is set explicitly because
;; for a combined name Hunspell would otherwise invent one per combination.
(when (executable-find "hunspell")
  (with-eval-after-load 'ispell
    (setq ispell-program-name "hunspell"
          ispell-dictionary "pt_BR,en_US"
          ispell-personal-dictionary "~/.hunspell_personal")
    ;; Hunspell ignores a personal dictionary that does not exist yet.
    (unless (file-exists-p ispell-personal-dictionary)
      (write-region "" nil ispell-personal-dictionary nil 0))
    (ispell-set-spellchecker-params)
    (ispell-hunspell-add-multi-dic "pt_BR,en_US")))

;; C-; lists the corrections for the misspelled word before point in the
;; minibuffer, instead of cycling through them in place.
(with-eval-after-load 'flyspell
  (keymap-set flyspell-mode-map "C-;" #'flyspell-correct-wrapper))

;; Org-mode
(require 'crafted-org-config)

(with-eval-after-load 'org
  (org-defkey org-mode-map [(meta return)] 'org-meta-return)
  (when (version<= "9.2" (org-version))
    (require 'org-tempo)))

(setq org-startup-folded t)

;; Loaded eagerly rather than autoloaded: the link types have to exist before
;; an export runs, not after the first org-ref command is invoked.
(require 'org-ref)

;; org-ref v3 no longer binds its insert command (v2 took C-c ] itself, which
;; Org otherwise gives to `org-remove-file', an agenda command). No prefix
;; inserts a cite, C-u a ref, C-u C-u a label; on an existing cite link it
;; appends the key to it.
(with-eval-after-load 'org
  (org-defkey org-mode-map (kbd "C-c ]") 'org-ref-insert-link))

;; Citation keys pop up as soon as `cite:', `textcite:' or any other org-ref
;; cite type is typed, rather than after `corfu-auto-prefix' characters of the
;; key. They come from the bibliography org-ref resolves for the buffer, so a
;; project points `bibtex-completion-bibliography' at its .bib (the TCC does it
;; in .dir-locals.el).
(defun my/org-ref-cite-capf ()
  "Complete the citation key at point inside an org-ref cite link."
  (let* ((end (point))
         (beg (save-excursion (skip-chars-backward "^][() \t\n:,;&") (point)))
         (start (save-excursion (skip-chars-backward "^][() \t\n") (point))))
    (when (save-excursion
            (goto-char start)
            (looking-at (concat (regexp-opt (mapcar #'car org-ref-cite-types))
                                ":")))
      (let ((bibtex-completion-bibliography (org-ref-find-bibliography))
            (notes (make-hash-table :test #'equal)))
        (list beg end
              (mapcar
               (lambda (candidate)
                 (let* ((entry (cdr candidate))
                        (key (bibtex-completion-get-value "=key=" entry)))
                   ;; biblatex entries carry `date', not `year', and
                   ;; bibtex-completion only keeps `year'.
                   (puthash key
                            (replace-regexp-in-string
                             "[{}]" ""
                             (format "  %s (%s) %s"
                                     (bibtex-completion-shorten-authors
                                      (bibtex-completion-get-value
                                       "author" entry
                                       (bibtex-completion-get-value
                                        "editor" entry "")))
                                     (bibtex-completion-get-value
                                      "year" entry
                                      (bibtex-completion-get-value
                                       "date" entry ""))
                                     (bibtex-completion-get-value
                                      "title" entry "")))
                            notes)
                   key))
               (bibtex-completion-candidates))
              :exclusive 'no
              :annotation-function (lambda (key) (gethash key notes)))))))

(defun my/org-ref-cite-after-colon ()
  "Open the key completion when the colon of a cite link is typed."
  (when (and (eq last-command-event ?:)
             (my/org-ref-cite-capf))
    (completion-at-point)))

(add-hook 'org-mode-hook
          (lambda ()
            (add-hook 'completion-at-point-functions #'my/org-ref-cite-capf nil t)
            (add-hook 'post-self-insert-hook #'my/org-ref-cite-after-colon nil t)))

;; `ts' blocks: Org looks for a `ts-mode', which does not exist, and leaves the
;; block uncoloured. typescript-ts-mode needs the tree-sitter grammar, which
;; `treesit-install-language-grammar' compiles (a C compiler is required);
;; without it js-mode colours the JavaScript subset, most of a TS snippet.
(with-eval-after-load 'org-src
  (let ((mode (if (treesit-language-available-p 'typescript) 'typescript-ts 'js)))
    (add-to-list 'org-src-lang-modes (cons "ts" mode))
    (add-to-list 'org-src-lang-modes (cons "typescript" mode))))

;; Code in src blocks sits at the column of #+begin_src; the default of 2
;; re-indents every block edited through C-c '.
(setq org-edit-src-content-indentation 0)

;; Chapters that a master .tex pulls in with \input must be exported body-only,
;; or each brings its own \documentclass and preamble. The dispatcher way is
;; C-c C-e C-b l l, and forgetting the C-b breaks the build.
(defun my/org-latex-export-body-only ()
  "Export the buffer to its .tex file as a body-only fragment."
  (interactive)
  (message "Exported %s" (org-latex-export-to-latex nil nil nil t)))

(with-eval-after-load 'org
  (org-defkey org-mode-map (kbd "C-c e") 'my/org-latex-export-body-only))

;; Org-roam
;; ln -s ~/Mega/Data1/Org.d/Roam2/ ~/Notes
;;
;; Only set up when the notes directory is actually here: org-roam-db-autosync-mode
;; scans it during startup, and on a machine without the notes that aborts init
;; with (file-missing "Opening directory"), leaving Emacs in the debugger.
(let ((roam-dir (expand-file-name "~/Data1/Org.d/Roam2/")))
  (if (not (file-directory-p roam-dir))
      (message "org-roam: %s not found, skipping setup" roam-dir)
    (setq-default org-roam-directory (file-truename roam-dir))
    (setq org-roam-dailies-directory "Journal/")

    (setq org-roam-dailies-capture-templates
          '(("d" "default" entry
             "\n* %<%H:%M> %?"
             :if-new (file+head "%<%Y/%m-%d>.org"
                                "#+title: %<%a, %b %d %Y>\n"))))

    (require 'org-roam)
    (with-eval-after-load 'org-roam
      (org-roam-db-autosync-mode))

    (define-key org-mode-map (kbd "C-c n i") 'org-roam-node-insert)
    (global-set-key (kbd "C-c n c") 'org-roam-capture)
    (global-set-key (kbd "C-c n f") 'org-roam-node-find)
    (global-set-key (kbd "C-c n j") 'org-roam-dailies-capture-today)))

;; Git — Magit's status is on C-x g. Refining every hunk word by word is what
;; makes prose diffs readable: without it a changed word in an Org paragraph
;; shows as the whole line removed and added again.
(setq magit-diff-refine-hunk 'all)

;; RET on a diff line visits it in the file, but Org files open folded
;; (`org-startup-folded'), so the line would land inside a hidden subtree.
(add-hook 'magit-diff-visit-file-hook
          (lambda () (when (derived-mode-p 'org-mode) (org-reveal))))

;; diff-hl: C-x v [ and C-x v ] jump between changed hunks, C-x v * shows the
;; old text of the hunk in place, C-x v n reverts it and C-x v S stages it.
;; flydiff updates the marks while typing instead of on save.
(global-diff-hl-mode)
(diff-hl-flydiff-mode)
(add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh)

;; Clipboard — the PGTK (native Wayland) build takes ownership of the selection
;; and then serves no content: anything copied in Emacs is unpastable in other
;; applications, and the copy also wipes whatever was on the clipboard.
;; `emacs -Q' does it too, so it is the build, not this configuration. Reading
;; the clipboard works, so only the write side is replaced — piped through
;; wl-copy, which offers the usual UTF8_STRING/text-plain targets.
;;
;; Guarded on the pgtk feature rather than `window-system', which is nil at
;; init time under --daemon. The X11 build (EMACS_TOOLKIT=gtk on openSUSE) does
;; not need this, and neither does macOS.
(when (and (featurep 'pgtk) (executable-find "wl-copy"))
  (setq interprogram-cut-function
        (lambda (text)
          (let ((proc (make-process :name "wl-copy" :buffer nil :noquery t
                                    :connection-type 'pipe
                                    :command '("wl-copy"))))
            (process-send-string proc text)
            (process-send-eof proc)))))

;; Windows
(if (daemonp)
    (add-to-list 'default-frame-alist '(fullscreen . fullboth))
  (toggle-frame-fullscreen))

;; Startup warnings from openSUSE's site-lisp. These package-owned files have
;; no `lexical-binding' cookie, and Emacs 31 warns about each one. They load
;; from site-start, before early-init.el, so nothing here stops them from being
;; logged:
;;
;; - A standalone Emacs delays startup warnings until after init, so
;;   suppressing their type is enough.
;; - The daemon logs them at once and shows *Warnings* on the first client
;;   frame without checking any suppression. So remove them from the buffer,
;;   kill it if nothing else is left, and skip showing a killed buffer.
;;
;; `warning--display-buffer' is internal (Emacs 31); if it is renamed, the
;; advice does nothing and the warnings come back.
(defconst my/site-lisp-lexbind-files
  '("/usr/share/emacs/site-lisp/suse-start-po-mode.el"            ; gettext-runtime
    "/usr/share/emacs/site-lisp/site-start.d/vterm-init.el")      ; emacs-vterm
  "Package-owned files whose missing `lexical-binding' cookie is not ours to fix.")

(require 'warnings)
(dolist (file my/site-lisp-lexbind-files)
  (add-to-list 'warning-suppress-log-types
               `(files missing-lexbind-cookie ,file)))

(defun my/drop-site-lisp-lexbind-warnings ()
  "Remove warnings about `my/site-lisp-lexbind-files' from *Warnings*."
  (when-let* ((buffer (get-buffer "*Warnings*")))
    (with-current-buffer buffer
      (let ((inhibit-read-only t))
        (dolist (file my/site-lisp-lexbind-files)
          (goto-char (point-min))
          (while (search-forward (format "cookie in %S." file) nil t)
            (let ((start (pos-bol)))
              (search-forward "for more information.")
              (delete-region start (min (1+ (point)) (point-max))))))
        (when (string-blank-p (buffer-string))
          (kill-buffer buffer))))))

(advice-add 'warning--display-buffer :before-while #'buffer-live-p)
(my/drop-site-lisp-lexbind-warnings)

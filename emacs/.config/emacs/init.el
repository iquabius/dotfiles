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

;; Prose wraps while typing, at 80 columns. One space after a period ends a
;; sentence, for filling and for M-a/M-e.
(setq-default fill-column 80)
(add-hook 'text-mode-hook #'auto-fill-mode)
(setq sentence-end-double-space nil)

;; M-q in Org refills the paragraph with one sentence per line (semantic line
;; feeds), the layout of the TCC's sources. ErgoEmacs's M-q fills the paragraph
;; as one block, joining the sentences. Three places neither end a sentence nor
;; take a line break, in M-q or in auto-fill:
;;
;; - after an abbreviation, as in p. ex.;
;; - inside a bracket link, or a citation, [[textcite:x][p. 1 e 21]], would be
;;   split across two lines;
;; - inside an export snippet, so that the TCC's @@latex:\todo{...}@@ notes
;;   stay on one line. The @@ that closes one also closes a sentence.
(defconst gambi/abbreviations '("p" "pp" "ex" "al" "cf" "fig" "e.g" "i.e")
  "Words whose final period does not end a sentence.")

(defun gambi/fill-nobreak-p ()
  "Non-nil after one of `gambi/abbreviations', or inside a link or snippet."
  (or (looking-back (concat "\\(?:^\\|[^[:alnum:]]\\)"
                            (regexp-opt gambi/abbreviations) "\\.[ \t]*")
                    (pos-bol))
      (looking-back "\\[\\[[^]\n]*\\(?:\\]\\[[^]\n]*\\)?" (pos-bol))
      (looking-back "@@[-A-Za-z0-9]+:\\(?:[^@]\\|@[^@]\\)*" (pos-bol))))

(defun gambi/forward-sentence (&optional arg)
  "Like `forward-sentence-default-function', past `gambi/fill-nobreak-p'."
  (if (and arg (< arg 0))
      (forward-sentence-default-function arg)
    (dotimes (_ (or arg 1))
      (let (start)
        (while (progn (setq start (point))
                      (forward-sentence-default-function 1)
                      (and (> (point) start) (gambi/fill-nobreak-p))))))))

(add-hook 'org-mode-hook
          (lambda ()
            (setq-local sentence-end-base "[.?!…‽][]\"'”’)}»›@]*")
            (add-hook 'fill-nobreak-predicate #'gambi/fill-nobreak-p nil t)))

(defun gambi/fill-paragraph-sentences (&optional justify region)
  "Fill the paragraph, or the active region, one sentence per line.
`fill-paragraph-semlf', ending sentences with `gambi/forward-sentence'."
  (interactive (progn
                 (barf-if-buffer-read-only)
                 (list (if current-prefix-arg 'full) t)))
  (let ((forward-sentence-function #'gambi/forward-sentence))
    (fill-paragraph-semlf justify region)))

(with-eval-after-load 'org
  (keymap-set org-mode-map "M-q" #'gambi/fill-paragraph-sentences)
  (keymap-set org-mode-map "<remap> <ergoemacs-compact-uncompact-block>"
              #'gambi/fill-paragraph-sentences))

;; A file:x.org::text link searches the text of x.org, as the TCC's source
;; matrix (texto/fontes/*.org) links each entry to the start of a paragraph.
;; By default Org matches only headlines in an Org file, offers to create
;; one named after the text, and then fails with "No match".
(setq org-link-search-must-match-exact-headline nil)

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

;; Glossary links (`gls:', `glspl:', `Gls:'...) look for the entry only in the
;; buffer itself: a `#+name: glossary' table, a `\newglossaryentry' in a
;; latex header, or an #+INCLUDE'd file. A project that keeps its entries in a
;; LaTeX file loaded by the master document (the TCC: latex/siglas.tex) names
;; that file in `my/org-ref-glossary-files', from .dir-locals.el; the lookup
;; behind the tooltip and the face falls back to it, following the link opens
;; the entry there, and the labels complete after the colon like cite keys.
(defvar-local my/org-ref-glossary-files nil
  "LaTeX files with `\\newglossaryentry' definitions for org-ref gls links.
Relative names resolve from the buffer's directory.")
(put 'my/org-ref-glossary-files 'safe-local-variable
     (lambda (v) (and (listp v) (seq-every-p #'stringp v))))

(defvar my/org-ref-glossary-file-cache (make-hash-table :test #'equal)
  "File name -> (MODTIME . ENTRIES), so fontification does not reread it.")

(defun my/org-ref-glossary-display (latex)
  "LATEX with `\\emph{...}' and `\\textit{...}' turned into italic text.
For the tooltip and the completion annotation, which show the string as is."
  (let ((pos 0) (out ""))
    (while (string-match "\\\\\\(?:emph\\|textit\\){\\([^{}]*\\)}" latex pos)
      (setq out (concat out (substring latex pos (match-beginning 0))
                        (propertize (match-string 1 latex) 'face 'italic))
            pos (match-end 0)))
    (concat out (substring latex pos))))

;; GTK tooltips (the pgtk default) drop text properties, so the italic of a
;; glossary description would not show; Emacs-drawn tooltips keep them.
(setq use-system-tooltips nil)

(defun my/org-ref-glossary-read-file (file)
  "Alist (LABEL . PLIST) of the `\\newglossaryentry' definitions in FILE."
  (let ((modtime (file-attribute-modification-time (file-attributes file)))
        (cached (gethash file my/org-ref-glossary-file-cache)))
    (if (and cached (equal (car cached) modtime))
        (cdr cached)
      (let (entries)
        (with-temp-buffer
          (insert-file-contents file)
          (goto-char (point-min))
          (while (re-search-forward "^[ \t]*\\\\newglossaryentry{\\([^}]+\\)}" nil t)
            (let ((label (match-string 1))
                  (position (match-beginning 0))
                  (plist nil)
                  end)
              (when (re-search-forward "{" nil t)
                (backward-char)
                (setq end (save-excursion (forward-sexp) (point)))
                (dolist (key '("name" "description"))
                  (save-excursion
                    (when (re-search-forward
                           (concat "\\_<" key "[ \t]*=[ \t]*{") end t)
                      (let ((value-start (point)))
                        (backward-char)
                        (forward-sexp)
                        (setq plist
                              (plist-put plist (intern (concat ":" key))
                                         (my/org-ref-glossary-display
                                          (replace-regexp-in-string
                                           "[ \t\n]+" " "
                                           (buffer-substring-no-properties
                                            value-start (1- (point))))))))))))
              (push (cons label (append (list :label label :file file
                                              :tex-position position)
                                        plist))
                    entries))))
        (setq entries (nreverse entries))
        (puthash file (cons modtime entries) my/org-ref-glossary-file-cache)
        entries))))

(defun my/org-ref-glossary-file-entries ()
  "Entries of every readable file in `my/org-ref-glossary-files'."
  (seq-mapcat (lambda (f)
                (let ((file (expand-file-name f)))
                  (when (file-readable-p file)
                    (my/org-ref-glossary-read-file file))))
              my/org-ref-glossary-files))

(defun my/org-ref-glossary-from-files (orig label)
  "Call ORIG for LABEL, then look in `my/org-ref-glossary-files'."
  (or (funcall orig label)
      (cdr (assoc label (my/org-ref-glossary-file-entries)))))

(defun my/org-ref-glossary-follow-tex (orig entry)
  "Open an entry found in a LaTeX glossary file at its definition, else ORIG."
  (let ((data (get-text-property (point) 'or-glossary)))
    (if (plist-get data :tex-position)
        (progn
          (org-mark-ring-push)
          (find-file (plist-get data :file))
          (goto-char (plist-get data :tex-position)))
      (funcall orig entry))))

(with-eval-after-load 'org-ref-glossary
  (advice-add 'or-parse-glossary-entry :around #'my/org-ref-glossary-from-files)
  (advice-add 'or-follow-glossary :around #'my/org-ref-glossary-follow-tex))

(defun my/org-ref-glossary-capf ()
  "Complete the label at point inside an org-ref glossary link."
  (let* ((end (point))
         (beg (save-excursion (skip-chars-backward "^][() \t\n:") (point)))
         (start (save-excursion (skip-chars-backward "^][() \t\n") (point))))
    (when (and my/org-ref-glossary-files
               (boundp 'org-ref-glossary-gls-commands)
               (save-excursion
                 (goto-char start)
                 (let ((case-fold-search nil))
                   (looking-at
                    (concat (regexp-opt (mapcar #'car org-ref-glossary-gls-commands))
                            ":")))))
      (let ((entries (my/org-ref-glossary-file-entries)))
        (list beg end (mapcar #'car entries)
              :exclusive 'no
              :annotation-function
              (lambda (label)
                (let ((entry (cdr (assoc label entries))))
                  (format "  %s: %s" (plist-get entry :name)
                          (plist-get entry :description)))))))))

(defun my/org-ref-cite-after-colon ()
  "Open the completion when the colon of a cite or glossary link is typed."
  (when (and (eq last-command-event ?:)
             (or (my/org-ref-cite-capf) (my/org-ref-glossary-capf)))
    (completion-at-point)))

(add-hook 'org-mode-hook
          (lambda ()
            (add-hook 'completion-at-point-functions #'my/org-ref-cite-capf nil t)
            (add-hook 'completion-at-point-functions #'my/org-ref-glossary-capf nil t)
            (add-hook 'post-self-insert-hook #'my/org-ref-cite-after-colon nil t)))

;; Chapter refs (`ref:chap:results') point at labels the LaTeX master defines
;; (the TCC: `\chapter{Resultados}\label{chap:results}' in latex/tcc.tex), so
;; org-ref never finds them in the Org source: it paints the link as missing,
;; and following it left point at the top of the buffer. A `chap:X' label that
;; is not in the buffer stands for X.org beside the current file, when that
;; file exists; following the link opens it, and the link is not flagged.
;; Export is untouched: the link still becomes \ref{chap:X}.
(defun gambi/org-ref-chapter-file (label)
  "Return X.org beside the current file for LABEL `chap:X', if it exists."
  (when (and buffer-file-name
             (string-prefix-p "chap:" label)
             (not (org-ref-find-label-in-buffer label)))
    (let ((file (expand-file-name (concat (substring label 5) ".org")
                                  (file-name-directory buffer-file-name))))
      (and (file-exists-p file) file))))

(defun gambi/org-ref-jump-to-chapter-file (orig &optional path)
  "Open the chapter file of a `chap:' label at point, else call ORIG with PATH."
  (let* ((label (or (get-text-property (point) 'org-ref-ref-label) path))
         (file (and label (gambi/org-ref-chapter-file label))))
    (if (not file)
        (funcall orig path)
      (org-mark-ring-push)
      (find-file file))))

(defun gambi/org-ref-activate-chapter-file (orig start end path bracketp)
  "Call ORIG, then unflag the `chap:' labels in PATH that name a file."
  (funcall orig start end path bracketp)
  (when org-ref-activate-ref-links
    (save-excursion
      (goto-char start)
      (dolist (label (split-string path ","))
        (when (search-forward label end t)
          (when-let* ((file (gambi/org-ref-chapter-file label)))
            (add-text-properties (match-beginning 0) (match-end 0)
                                 (list 'face 'org-ref-ref-face
                                       'help-echo (concat "Opens "
                                                          (file-name-nondirectory file))))))))))

(advice-add 'org-ref-ref-jump-to :around #'gambi/org-ref-jump-to-chapter-file)
(advice-add 'org-ref-ref-activate :around #'gambi/org-ref-activate-chapter-file)

;; Section labels from the title. ox-latex gives every headline a \label, and
;; without a CUSTOM_ID the key is `org' plus a random number drawn anew on
;; each Emacs run (`org-export-new-reference'), so every export of an
;; unchanged file rewrote every \label{sec:org...}. A project that lists the
;; files of its document in `gambi/org-document-files' (the TCC, from
;; .dir-locals.el) gets sec:<title slug> instead, for the titles of the listed
;; Org files: a title repeated in the document takes first the slug of its
;; nearest ancestor whose title is not repeated (sec:contador-concisao), and
;; -2, -3 settle what still collides with another label of the listed files
;; (a CUSTOM_ID, a #+NAME, a <<target>>, a \label). The export sets the slug
;; as the headline's CUSTOM_ID, which becomes the label only with
;; `org-latex-prefer-user-labels' on (the TCC sets it); a CUSTOM_ID written in
;; the file wins. A file that is not in its own list, like the TCC's source
;; notes under texto/fontes/, where the relative names resolve to nothing, is
;; left alone. The export finds each headline's label by its titles from the
;; top and by how many came before with the same ones, as the whole file has
;; them, less COMMENT trees, the footnotes and the file's #+EXCLUDE_TAGS:
;; exporting a subtree only falls back to the random label, and #+SELECT_TAGS,
;; #+FILETAGS and tag groups are not followed.
;;
;; org-ref finds labels only by searching file text, where these slugs are
;; not. So its label list (`C-c ]' with `C-u') gets every title of the
;; document; choosing one writes the slug as that title's CUSTOM_ID, even in
;; another file, which freezes it: a later rename of the title no longer moves
;; the label. The CUSTOM_ID is written when the label is chosen, before the
;; link goes in, so a C-g after that leaves it, with the same label it would
;; have had anyway. Following a ref: link reaches a title or a label in any
;; listed file; org-ref itself fails in a LaTeX file, unfolding Org headings
;; there, and says a label it did reach in another Org file was not found. A
;; `chap:X' label is listed from the LaTeX master but still opens X.org
;; (`gambi/org-ref-chapter-file'). Only ref links search the listed files:
;; glossary links also read `org-ref-get-included-files'.
(require 'ox)
(require 'ucs-normalize)

(defvar-local gambi/org-document-files nil
  "Files of the document the buffer belongs to, in document order.
Relative names resolve from the buffer's directory, and wildcards expand.
The titles of the Org files get labels from `gambi/org-section-labels';
org-ref also searches every file for labels to ref.")
(put 'gambi/org-document-files 'safe-local-variable
     (lambda (v) (and (listp v) (seq-every-p #'stringp v))))

(defun gambi/org-document-file-list (names dir)
  "Readable files of NAMES, a `gambi/org-document-files' value, from DIR."
  (let ((default-directory dir))
    (seq-uniq
     (seq-filter #'file-readable-p
                 (mapcan (lambda (name)
                           (if (string-match-p "[*?[]" name)
                               (file-expand-wildcards (expand-file-name name))
                             (list (expand-file-name name))))
                         names)))))

(defun gambi/org-document (names file)
  "Files of NAMES, the document FILE belongs to, or nil if FILE is not one."
  (let ((files (gambi/org-document-file-list names (file-name-directory file))))
    (and (member (expand-file-name file) files) files)))

(defun gambi/org-slug (title)
  "TITLE without links, markup or accents, lowercase, words joined by hyphens."
  (let* ((s (ucs-normalize-NFD-string (org-link-display-format title)))
         (s (downcase (replace-regexp-in-string "[^[:ascii:]]" "" s)))
         (s (replace-regexp-in-string "[^a-z0-9]+" "-" s))
         (s (string-trim s "-+" "-+")))
    (if (string-empty-p s) "titulo" s)))

(defun gambi/org-title-path (headline)
  "Raw titles from the top down to HEADLINE, an Org element."
  (nreverse (mapcar (lambda (h) (org-element-property :raw-value h))
                    (seq-filter (lambda (e) (eq (org-element-type e) 'headline))
                                (org-element-lineage headline nil t)))))

(defun gambi/org-own-title (title)
  "The raw title of TITLE, a plist with the :path of its titles from the top."
  (car (last (plist-get title :path))))

(defun gambi/org-exported-headline-p (headline exclude-tags)
  "Non-nil unless HEADLINE or an ancestor is commented, excluded or footnotes.
EXCLUDE-TAGS are the tags that keep a tree out of the export."
  (seq-every-p (lambda (h)
                 (not (or (org-element-property :commentedp h)
                          (org-element-property :footnote-section-p h)
                          (seq-intersection (org-element-property :tags h)
                                            exclude-tags))))
               (seq-filter (lambda (e) (eq (org-element-type e) 'headline))
                           (org-element-lineage headline nil t))))

(defun gambi/org-scan-labels ()
  "Labels org-ref would find in the current buffer, as strings."
  (let ((case-fold-search t)
        (rx (string-join org-ref-ref-label-regexps "\\|"))
        labels)
    (org-with-wide-buffer
     (goto-char (point-min))
     (while (re-search-forward rx nil t)
       (push (match-string-no-properties 1) labels)))
    labels))

(defun gambi/org-scan-titles ()
  "Exported titles of the current Org buffer in order, as plists.
The file's #+EXCLUDE_TAGS replace `org-export-exclude-tags', as in export,
even when empty."
  (org-with-wide-buffer
   (let ((exclude (if-let* ((keyword (assoc "EXCLUDE_TAGS"
                                            (org-collect-keywords '("EXCLUDE_TAGS")))))
                      (mapcan #'split-string (cdr keyword))
                    org-export-exclude-tags)))
     (org-element-map (org-element-parse-buffer 'headline) 'headline
       (lambda (h)
         (when (gambi/org-exported-headline-p h exclude)
           (list :path (gambi/org-title-path h)
                 :custom-id (org-element-property :CUSTOM_ID h)
                 :begin (org-element-property :begin h))))))))

(defvar gambi/org-scan-cache (make-hash-table :test #'equal)
  "File name -> (STAMP . SCAN), so fontification does not reread it.")

(defun gambi/org-file-scan (file)
  "Plist (:titles :labels) of FILE; titles only for an Org file.
A buffer visiting FILE is read instead of the disk, unsaved edits included.
TITLES are plists (:path :custom-id :begin); LABELS are strings."
  (let* ((buffer (find-buffer-visiting file))
         (stamp (if buffer
                    (cons buffer (buffer-chars-modified-tick buffer))
                  (file-attribute-modification-time (file-attributes file))))
         (cached (gethash file gambi/org-scan-cache)))
    (if (equal (car cached) stamp)
        (cdr cached)
      (let* ((org (string-suffix-p ".org" file))
             (scan (lambda ()
                     (list :titles (and org (gambi/org-scan-titles))
                           :labels (gambi/org-scan-labels))))
             (result (if buffer
                         (with-current-buffer buffer (funcall scan))
                       (with-temp-buffer
                         (insert-file-contents file)
                         (when org (delay-mode-hooks (org-mode)))
                         (funcall scan)))))
        (puthash file (cons stamp result) gambi/org-scan-cache)
        result))))

(defvar gambi/org-section-labels-cache nil
  "(FILES SCANS . LABELS) of the last `gambi/org-section-labels'.")

(defun gambi/org-section-labels (files)
  "Labels of the titles of FILES, in document order.
Each is a plist (:label :file :path :n :begin :custom-id), where N counts the
titles of FILE with the same PATH, so that two of them are told apart. A
title with a CUSTOM_ID has it as its label."
  (let ((scans (mapcar #'gambi/org-file-scan files)))
    ;; Fontification asks for this once per ref link on screen: the labels
    ;; are only worked out again when some file has a new scan.
    (if (pcase-let ((`(,old-files ,old-scans . ,_) gambi/org-section-labels-cache))
          (and (equal files old-files)
               (seq-every-p #'identity (cl-mapcar #'eq scans old-scans))))
        (cddr gambi/org-section-labels-cache)
      (let ((labels (gambi/org-section-labels-1 files scans)))
        (setq gambi/org-section-labels-cache (cons files (cons scans labels)))
        labels))))

(defun gambi/org-section-labels-1 (files scans)
  "Labels of FILES, whose scans are SCANS; see `gambi/org-section-labels'."
  (let ((titles
         (cl-mapcan (lambda (file scan)
                      (let ((seen (make-hash-table :test #'equal)))
                        (mapcar (lambda (title)
                                  (let ((n (cl-incf (gethash (plist-get title :path)
                                                             seen 0))))
                                    (append (list :file file :n n) title)))
                                (plist-get scan :titles))))
                    files scans))
        (count (make-hash-table :test #'equal))
        (used (make-hash-table :test #'equal))
        labels)
    (dolist (scan scans)
      (dolist (label (plist-get scan :labels))
        (puthash label t used)))
    (dolist (title titles)
      (cl-incf (gethash (gambi/org-slug (gambi/org-own-title title)) count 0)))
    (dolist (title titles)
      (if-let* ((id (plist-get title :custom-id)))
          (push (append (list :label id) title) labels)
        (let* ((unique (lambda (raw)
                         (= 1 (gethash (gambi/org-slug raw) count 0))))
               (own (gambi/org-own-title title))
               (ancestor (and (not (funcall unique own))
                              (seq-find unique
                                        (cdr (reverse (plist-get title :path))))))
               (base (concat "sec:"
                             (and ancestor (concat (gambi/org-slug ancestor) "-"))
                             (gambi/org-slug own)))
               (label base)
               (i 1))
          (while (gethash label used)
            (setq label (format "%s-%d" base (cl-incf i))))
          (puthash label t used)
          (push (append (list :label label) title) labels))))
    (nreverse labels)))

;; The filter runs in the copy of the buffer that the export parses, and the
;; copy keeps only the local variables named org-* (and a few more, in
;; `org-element--generate-copy-script'), so the file list is read in the
;; buffer the export started from.
(defun gambi/org-latex-section-labels (tree backend info)
  "Give each headline of TREE without a CUSTOM_ID its label from the title."
  (when-let* (((org-export-derived-backend-p backend 'latex))
              (file (plist-get info :input-file))
              (source (or (get-buffer (plist-get info :input-buffer))
                          (current-buffer)))
              (names (buffer-local-value 'gambi/org-document-files source))
              (files (gambi/org-document names file)))
    (let* ((file (expand-file-name file))
           (labels (seq-filter (lambda (l) (equal (plist-get l :file) file))
                               (gambi/org-section-labels files)))
           (seen (make-hash-table :test #'equal)))
      (org-element-map tree 'headline
        (lambda (h)
          (let* ((path (gambi/org-title-path h))
                 (n (cl-incf (gethash path seen 0)))
                 (label (seq-find (lambda (l)
                                    (and (equal (plist-get l :path) path)
                                         (= (plist-get l :n) n)))
                                  labels)))
            (when (and label (not (plist-get label :custom-id))
                       (not (org-element-property :CUSTOM_ID h)))
              (org-element-put-property h :CUSTOM_ID
                                        (plist-get label :label)))))
        info)))
  tree)

(add-hook 'org-export-filter-parse-tree-functions
          #'gambi/org-latex-section-labels)

(defun gambi/org-ref-document ()
  "Files of the document of the current buffer, or nil outside one."
  (and gambi/org-document-files buffer-file-name
       (gambi/org-document gambi/org-document-files buffer-file-name)))

(defun gambi/org-ref-title-labels ()
  "Title labels of the document of the current buffer."
  (when-let* ((files (gambi/org-ref-document)))
    (gambi/org-section-labels files)))

(defun gambi/org-ref-add-title-labels (labels)
  "Add to org-ref's LABELS the title labels of the document.
A CUSTOM_ID org-ref already found stays as it is; one it missed, because
org-ref reads the other files from disk and it is not saved yet, comes in."
  (append labels
          (delq nil
                (mapcar (lambda (l)
                          (let ((path (plist-get l :path)))
                            (unless (assoc (plist-get l :label) labels)
                              (cons (plist-get l :label)
                                    (format "%s: %s %s"
                                            (file-name-nondirectory
                                             (plist-get l :file))
                                            (make-string (length path) ?*)
                                            (gambi/org-own-title l))))))
                        (gambi/org-ref-title-labels)))))

(defun gambi/org-ref-title-label (label)
  "The title label plist of LABEL in the current document, if any."
  (seq-find (lambda (l) (equal (plist-get l :label) label))
            (gambi/org-ref-title-labels)))

(defun gambi/org-ref-to-title (title)
  "Move to the headline of TITLE, a title label plist, in the current buffer."
  (goto-char (plist-get title :begin))
  (unless (and (org-at-heading-p)
               (equal (org-get-heading t t t t) (gambi/org-own-title title)))
    (error "Title %s moved; save and try again" (gambi/org-own-title title))))

(defun gambi/org-ref-goto-title (title)
  "Visit the file of the TITLE label plist and move to its headline."
  (find-file (plist-get title :file))
  (widen)
  (gambi/org-ref-to-title title))

(defun gambi/org-ref-freeze-title-label (label)
  "Write LABEL as the CUSTOM_ID of its title when it is a title label."
  (when-let* ((title (and (stringp label) (gambi/org-ref-title-label label)))
              ((not (plist-get title :custom-id))))
    (with-current-buffer (find-file-noselect (plist-get title :file))
      (save-excursion
        (save-restriction
          (widen)
          (gambi/org-ref-to-title title)
          (org-entry-put nil "CUSTOM_ID" label))))
    (message "CUSTOM_ID %s written in %s" label
             (file-name-nondirectory (plist-get title :file))))
  label)

(defun gambi/org-ref-freeze-completed-link (link)
  "Freeze the title label at the end of LINK, a completed `ref:label'."
  (when (string-match ":" link)
    (gambi/org-ref-freeze-title-label (substring link (match-end 0))))
  link)

(defun gambi/org-ref-label-in-other-file (label)
  "(FILE . POSITION) of LABEL in another listed file, if any."
  (seq-some (lambda (file)
              (and (not (equal file (expand-file-name buffer-file-name)))
                   (member label (plist-get (gambi/org-file-scan file) :labels))
                   (when-let* ((pos (org-ref-find-label-in-file label file)))
                     (cons file pos))))
            (gambi/org-ref-document)))

(defun gambi/org-ref-jump-in-document (orig &optional path)
  "Visit the title or the label at point in another listed file, else ORIG.
ORIG gets PATH. A `chap:' label that opens a chapter file goes to ORIG."
  (let* ((label (or (get-text-property (point) 'org-ref-ref-label) path))
         (here (or (null label) (string-match-p "," label)
                   (gambi/org-ref-chapter-file label)
                   (org-ref-find-label-in-buffer label)))
         (title (and (not here) (gambi/org-ref-title-label label)))
         (other (and (not here) (not title)
                     (gambi/org-ref-label-in-other-file label))))
    (cond (title
           (org-mark-ring-push)
           (gambi/org-ref-goto-title title))
          (other
           (org-mark-ring-push)
           (find-file (car other))
           (goto-char (cdr other))
           (when (derived-mode-p 'org-mode)
             (org-fold-show-entry)))
          (t (funcall orig path)))))

(defvar gambi/org-ref-in-ref-labels nil
  "Non-nil while org-ref gathers or follows ref labels.")

(defun gambi/org-ref-with-document-files (orig &rest args)
  "Call ORIG with ARGS while org-ref ref labels search the document files."
  (let ((gambi/org-ref-in-ref-labels t))
    (apply orig args)))

(defun gambi/org-ref-add-document-files (files)
  "Add the document files to the FILES org-ref searches for ref labels."
  (if-let* ((document (and gambi/org-ref-in-ref-labels (gambi/org-ref-document))))
      (seq-uniq (append files (remove (expand-file-name buffer-file-name) document)))
    files))

(with-eval-after-load 'org-ref-ref-links
  (advice-add 'org-ref-get-labels :filter-return #'gambi/org-ref-add-title-labels)
  (advice-add 'org-ref-select-label :filter-return #'gambi/org-ref-freeze-title-label)
  (advice-add 'org-ref-complete-link :filter-return #'gambi/org-ref-freeze-completed-link)
  (advice-add 'org-ref-ref-jump-to :around #'gambi/org-ref-jump-in-document)
  (advice-add 'org-ref-get-labels-multi-file :around #'gambi/org-ref-with-document-files)
  (advice-add 'org-ref-ref-jump-to :around #'gambi/org-ref-with-document-files)
  (advice-add 'org-ref-get-included-files :filter-return #'gambi/org-ref-add-document-files))

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

;; A `~' right before an em dash is LaTeX's non-breaking space, so that the
;; dash never starts a line: `diferentes~--- aqui' in the TCC. ox-latex escapes
;; every `~' of plain text to \textasciitilde{}, and the PDF printed a tilde.
;; Plain text cannot spell \textasciitilde{} itself, since its `{', `}' and a
;; `\' before a letter are escaped too, so \textasciitilde{}--- there comes from
;; `~---' and goes back to a raw `~'. Any other `~' still prints as a tilde.
;;
;; This advises the LaTeX plain-text transcoder rather than adding an export
;; filter: headlines go through anonymous backends derived from `latex', which
;; hand a filter no backend name to test. Every LaTeX export of every Org file
;; gets it, beamer included; other backends never call it. Verbatim and code
;; (`~x~', `=x=') are not plain text and are untouched, but `~a b~---' is code
;; to Org's parser before any of this runs; `\nbsp{}---' avoids that.
(defun gambi/org-latex-nbsp-before-dash (text)
  "Turn \\textasciitilde{}--- in transcoded plain TEXT into ~---."
  (string-replace "\\textasciitilde{}---" "~---" text))

(with-eval-after-load 'ox-latex
  (advice-add 'org-latex-plain-text :filter-return
              #'gambi/org-latex-nbsp-before-dash))

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

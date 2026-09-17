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

;; sudo apt install -y ripgrep
;; https://github.com/Wilfred/deadgrep/blob/master/docs/ALTERNATIVES.md
(add-to-list 'package-selected-packages 'deadgrep)
(add-to-list 'package-selected-packages 'ergoemacs-mode)
(add-to-list 'package-selected-packages 'org-roam)

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

;; Org-mode
(require 'crafted-org-config)

(with-eval-after-load 'org
  (org-defkey org-mode-map [(meta return)] 'org-meta-return)
  (when (version<= "9.2" (org-version))
    (require 'org-tempo)))

(setq org-startup-folded t)

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

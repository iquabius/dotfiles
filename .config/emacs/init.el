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
(setq-default org-roam-directory (file-truename "~/Data1/Org.d/Roam2/"))
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
(global-set-key (kbd "C-c n j") 'org-roam-dailies-capture-today)

;; Windows
(if (daemonp)
    (add-to-list 'default-frame-alist '(fullscreen . fullboth))
  (toggle-frame-fullscreen))

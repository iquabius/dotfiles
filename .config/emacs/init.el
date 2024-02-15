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

(add-to-list 'package-selected-packages 'ergoemacs-mode)
(add-to-list 'package-selected-packages 'org-roam)

;; Install the packages listed in the `package-selected-packages' list.
(package-install-selected-packages :noconfirm)

;; Load configuration for crafted-emacs modules
(require 'crafted-completion-config)
(require 'crafted-defaults-config)
(require 'crafted-org-config)
(require 'crafted-startup-config)
(require 'crafted-ui-config)
(require 'crafted-writing-config)

;; Universal Keyboard Shortcuts (Ctrl-C, Ctrl-V)
(require 'ergoemacs-mode)
(ergoemacs-mode t)

;; Org-roam
;; ln -s ~/Mega/Data1/Org.d/Roam2/ ~/Notes
(setq-default org-roam-directory (file-truename "~/Notes"))
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

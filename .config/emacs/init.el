(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (and custom-file
           (file-exists-p custom-file))
  (load custom-file nil :nomessage))

(load "~/.config/crafted-emacs/modules/crafted-init-config")

;; Add package definitions for completion packages
;; to `package-selected-packages'.
(require 'crafted-completion-packages)
(require 'crafted-ui-packages)

(add-to-list 'package-selected-packages 'ergoemacs-mode)

;; Install the packages listed in the `package-selected-packages' list.
(package-install-selected-packages :noconfirm)

;; Load configuration for crafted-emacs modules
(require 'crafted-completion-config)
(require 'crafted-defaults-config)
(require 'crafted-startup-config)
(require 'crafted-ui-config)

;; Universal Keyboard Shortcuts (Ctrl-C, Ctrl-V)
(require 'ergoemacs-mode)
(ergoemacs-mode t)

;; Windows
(if (daemonp)
    (add-to-list 'default-frame-alist '(fullscreen . fullboth))
  (toggle-frame-fullscreen))

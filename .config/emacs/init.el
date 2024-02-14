(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (and custom-file
           (file-exists-p custom-file))
  (load custom-file nil :nomessage))

(load "~/.config/crafted-emacs/modules/crafted-init-config")

;; Add package definitions for completion packages
;; to `package-selected-packages'.
(require 'crafted-completion-packages)
(require 'crafted-ui-packages)

;; Install the packages listed in the `package-selected-packages' list.
(package-install-selected-packages :noconfirm)

;; Load configuration for crafted-emacs modules
(require 'crafted-completion-config)
(require 'crafted-defaults-config)
(require 'crafted-ui-config)

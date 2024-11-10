;; You will most likely need to adjust this font size for your system!
(defvar rui/default-font-size 120)
(defvar rui/default-variable-font-size 120)

;; Make frame transparency overridable
(defvar rui/frame-transparency '(100 . 100))

;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(defun rui/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                     (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'rui/display-startup-time)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")
                         ("gnu-devel" . "https://elpa.gnu.org/devel/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

  ;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(when init-file-debug
  (setq use-package-verbose t
        use-package-expand-minimally nil
        use-package-compute-statistics t
        debug-on-error t))

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

;; NOTE: If you want to move everything out of the ~/.emacs.d folder
;; reliably, set `user-emacs-directory` before loading no-littering!
;(setq user-emacs-directory "~/.cache/emacs")

(use-package no-littering)

;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
;; (setq auto-save-file-name-transforms
      ;; `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

;; Put backup files neatly away
(let ((backup-dir "~/.cache/emacs/backups/")
      (auto-saves-dir "~/.cache/emacs/auto-saves/"))
  (dolist (dir (list backup-dir auto-saves-dir))
    (when (not (file-directory-p dir))
      (make-directory dir t)))
  (setq backup-directory-alist `(("." . ,backup-dir))
        auto-save-file-name-transforms `((".*" ,auto-saves-dir t))
        auto-save-list-file-prefix (concat auto-saves-dir ".saves-")
        tramp-backup-directory-alist `((".*" . ,backup-dir))
        tramp-auto-save-directory auto-saves-dir))

(setq backup-by-copying t    ; Don't delink hardlinks
      delete-old-versions t  ; Clean up the backups
      version-control t      ; Use version numbers on backups,
      kept-new-versions 5    ; keep some new versions
      kept-old-versions 2)   ; and some old ones, too

;;remember recently edited files
(recentf-mode 1)
;; save last minibuffer prompts
(setq history-length 25)
(savehist-mode 1)
;; remember last cursor position in opened files
(save-place-mode 1)
;; Move customization variables to a separate file and load it
(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)
;; Revert buffers when the underlying file has changed
(global-auto-revert-mode 1)
;; always follow symlinks to version controlled files
(setq vc-follow-symlinks nil)
;; replace yes-no questions with y-n prompts
(defalias 'yes-or-no-p 'y-or-n-p)
;; disable new frame minibuffer message
(setq server-client-instructions nil)

(use-package undo-tree
  :config
  (global-undo-tree-mode)
  (setq undo-tree-auto-save-history nil))

(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar
;; Disable visible bell
(setopt visible-bell nil)
(setopt ring-bell-function 'ignore)
;; Emacs confirm on exit
(setopt confirm-kill-emacs 'y-or-n-p)
(column-number-mode)
(global-set-key (kbd "M-o") 'other-window)
(global-set-key (kbd "M-p") 'previous-buffer)
(global-set-key (kbd "M-+") 'next-buffer)

;; Set frame transparency
(set-frame-parameter (selected-frame) 'alpha rui/frame-transparency)
(add-to-list 'default-frame-alist `(alpha . ,rui/frame-transparency))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(use-package display-line-numbers
  :ensure nil
  :config (global-display-line-numbers-mode))

(defcustom display-line-numbers-exempt-modes
  '(vterm-mode
    eshell-mode
    shell-mode
    term-mode
    ansi-term-mode
    treemacs-mode
    Info-mode
    jupyter-repl-mode
    org-mode)
  "Major modes on which to disable line numbers."
  :group 'display-line-numbers
  :type 'list
  :version "green")

(defun display-line-numbers--turn-on ()
  "Turn on line numbers except for certain major modes.
Exempt major modes are defined in `display-line-numbers-exempt-modes'."
  (unless (or (minibufferp)
              (member major-mode display-line-numbers-exempt-modes))
    (display-line-numbers-mode)))

(defun rui/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Iosevka Comfy" :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil    :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
  (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch)
  (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
  (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch))

(defun rui/setup-font-faces ()
  (when (display-graphic-p)
    ;; set default font
    (set-face-attribute 'default nil :font "Fira Code" :height rui/default-font-size)
    ;; Set the fixed pitch face
    (set-face-attribute 'fixed-pitch nil :font "Fira Code" :height rui/default-font-size)
    ;; Set the variable pitch face
    (set-face-attribute 'variable-pitch nil :font "Iosevka Comfy" :height rui/default-variable-font-size)
    (with-eval-after-load 'org
      (rui/org-font-setup))))

;; run this hook after we have initialized the first time
(add-hook 'after-init-hook 'rui/setup-font-faces)
;; re-run this hook if we create a new frame from daemonized Emacs
(add-hook 'server-after-make-frame-hook 'rui/setup-font-faces)

;; Enable ligatures for Fira Code
(use-package ligature
  :config
  ;; Enable the www ligature in every possible major mode
  (ligature-set-ligatures 't '("www"))
  ;; Enable ligatures in programming modes
  (ligature-set-ligatures 'prog-mode '("www" "**" "***" "**/" "*>" "*/" "\\\\" "\\\\\\" "{-" "::"
				       ":::" ":=" "!!" "!=" "!==" "-}" "----" "-->" "->" "->>"
				       "-<" "-<<" "-~" "#{" "#[" "##" "###" "####" "#(" "#?" "#_"
				       "#_(" ".-" ".=" ".." "..<" "..." "?=" "??" ";;" "/*" "/**"
				       "/=" "/==" "/>" "//" "///" "&&" "||" "||=" "|=" "|>" "^=" "$>"
				       "++" "+++" "+>" "=:=" "==" "===" "==>" "=>" "=>>" "<="
				       "=<<" "=/=" ">-" ">=" ">=>" ">>" ">>-" ">>=" ">>>" "<*"
				       "<*>" "<|" "<|>" "<$" "<$>" "<!--" "<-" "<--" "<->" "<+"
				       "<+>" "<=" "<==" "<=>" "<=<" "<>" "<<" "<<-" "<<=" "<<<"
				       "<~" "<~~" "</" "</>" "~@" "~-" "~>" "~~" "~~>" "%%"))
  (global-ligature-mode 't))



;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package general
  :after evil
  :config
  (general-create-definer rui/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (rui/leader-keys
    "t"  '(:ignore t :which-key "toggles")
    "tt" '(counsel-load-theme :which-key "choose theme")
    "fde" '(lambda () (interactive) (find-file (expand-file-name "~/.emacs.d/Emacs.org")))))

(defun rui/save-kill-this-buffer ()
  (interactive)
  (save-buffer)
  (kill-this-buffer))

(keymap-global-set "C-x C-z" 'rui/save-kill-this-buffer)
(keymap-global-set "C-x C-q" 'quit-window)

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal)
  (evil-set-undo-system 'undo-tree))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-escape
  :init (evil-escape-mode)
  :custom
  (evil-escape-unordered-key-sequence t))


(use-package perspective
  :bind
  ("C-x C-b" . persp-buffer-menu)
  ("C-x b" . persp-ivy-switch-buffer)
  :custom
  (persp-mode-prefix-key (kbd "C-x x"))
  (persp-state-default-file "~/.cache/emacs/persp-state")
  (persp-sort 'created)
  :init
  (persp-mode))

;; (defun rui/persp-load ()
;;   (when (= 2 (length (visible-frame-list)))
;;     (persp-state-load "~/.cache/emacs/persp-state")
;;     (delete-frame (previous-frame))))

;; (add-hook 'server-after-make-frame-hook 'rui/persp-load)

(use-package command-log-mode
  :commands command-log-mode)

(use-package doom-themes
  :init (load-theme 'doom-palenight t))


(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.3))



(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("C-M-j" . 'counsel-switch-buffer)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (counsel-mode 1))



(use-package ivy-prescient
  :after counsel
  :custom
  (ivy-prescient-enable-filtering nil)
  :config
  ;; Uncomment the following line to have sorting remembered across sessions!
  ;(prescient-persist-mode 1)
  (ivy-prescient-mode 1))



(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))


(use-package hydra
  :defer t)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(rui/leader-keys
  "ts" '(hydra-text-scale/body :which-key "scale text"))



;; Show hidden emphasis markers
(use-package org-appear
  :hook org-mode)

(defun rui/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  :pin org
  :commands (org-capture org-agenda)
  :hook (org-mode . rui/org-mode-setup)
  :custom
  (org-confirm-babel-evaluate nil)
  (org-preview-latex-image-directory "~/.cache/emacs/ltximg/")
  (org-startup-with-inline-images t)
  (org-babel-load-languages '((emacs-lisp . t)
			      (python . t)
			      (jupyter . t)))
  (org-edit-src-content-indentation 0)
  (org-image-actual-width 850)
  :config
  ;; (setq warning-suppress-types (append warning-suppress-types '((org-element-cache))))
  (setq org-ellipsis " ▾")
  (setq org-hide-emphasis-markers t)
  (setq org-pretty-entities t)
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (push '("conf-unix" . conf-unix) org-src-lang-modes)
  (add-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images)
  (setq org-agenda-files
        (append (directory-files-recursively "~/docs" org-agenda-file-regexp)
              (directory-files-recursively "~/projects" org-agenda-file-regexp)
              '("~/.dotfiles")))
  ;; (require 'org-habit)
  ;; (add-to-list 'org-modules 'org-habit)
  ;; (setq org-habit-graph-column 60)

  ;; (setq org-todo-keywords
  ;;   '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
  ;;     (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

  ;; (setq org-refile-targets
  ;;   '(("archive.org" :maxlevel . 1)
  ;;     ("tasks.org" :maxlevel . 1)))

  ;; ;; Save Org buffers after refiling!
  ;; (advice-add 'org-refile :after 'org-save-all-org-buffers)

  ;; (setq org-tag-alist
  ;;   '((:startgroup)
  ;;      ; Put mutually exclusive tags here
  ;;      (:endgroup)
  ;;      ("@errand" . ?E)
  ;;      ("@home" . ?H)
  ;;      ("@work" . ?W)
  ;;      ("agenda" . ?a)
  ;;      ("planning" . ?p)
  ;;      ("publish" . ?P)
  ;;      ("batch" . ?b)
  ;;      ("note" . ?n)
  ;;      ("idea" . ?i)))

  ;; ;; Configure custom agenda views
  ;; (setq org-agenda-custom-commands
  ;;  '(("d" "Dashboard"
  ;;    ((agenda "" ((org-deadline-warning-days 7)))
  ;;     (todo "NEXT"
  ;;       ((org-agenda-overriding-header "Next Tasks")))
  ;;     (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

  ;;   ("n" "Next Tasks"
  ;;    ((todo "NEXT"
  ;;       ((org-agenda-overriding-header "Next Tasks")))))

  ;;   ("W" "Work Tasks" tags-todo "+work-email")

  ;;   ;; Low-effort next actions
  ;;   ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
  ;;    ((org-agenda-overriding-header "Low Effort Tasks")
  ;;     (org-agenda-max-todos 20)
  ;;     (org-agenda-files org-agenda-files)))

  ;;   ("w" "Workflow Status"
  ;;    ((todo "WAIT"
  ;;           ((org-agenda-overriding-header "Waiting on External")
  ;;            (org-agenda-files org-agenda-files)))
  ;;     (todo "REVIEW"
  ;;           ((org-agenda-overriding-header "In Review")
  ;;            (org-agenda-files org-agenda-files)))
  ;;     (todo "PLAN"
  ;;           ((org-agenda-overriding-header "In Planning")
  ;;            (org-agenda-todo-list-sublevels nil)
  ;;            (org-agenda-files org-agenda-files)))
  ;;     (todo "BACKLOG"
  ;;           ((org-agenda-overriding-header "Project Backlog")
  ;;            (org-agenda-todo-list-sublevels nil)
  ;;            (org-agenda-files org-agenda-files)))
  ;;     (todo "READY"
  ;;           ((org-agenda-overriding-header "Ready for Work")
  ;;            (org-agenda-files org-agenda-files)))
  ;;     (todo "ACTIVE"
  ;;           ((org-agenda-overriding-header "Active Projects")
  ;;            (org-agenda-files org-agenda-files)))
  ;;     (todo "COMPLETED"
  ;;           ((org-agenda-overriding-header "Completed Projects")
  ;;            (org-agenda-files org-agenda-files)))
  ;;     (todo "CANC"
  ;;           ((org-agenda-overriding-header "Cancelled Projects")
  ;;            (org-agenda-files org-agenda-files)))))))

  ;; (setq org-capture-templates
  ;;   `(("t" "Tasks / Projects")
  ;;     ("tt" "Task" entry (file+olp "~/Projects/Code/emacs-from-scratch/OrgFiles/Tasks.org" "Inbox")
  ;;          "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

  ;;     ("j" "Journal Entries")
  ;;     ("jj" "Journal" entry
  ;;          (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
  ;;          "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
  ;;          ;; ,(dw/read-file-as-string "~/Notes/Templates/Daily.org")
  ;;          :clock-in :clock-resume
  ;;          :empty-lines 1)
  ;;     ("jm" "Meeting" entry
  ;;          (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
  ;;          "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
  ;;          :clock-in :clock-resume
  ;;          :empty-lines 1)

  ;;     ("w" "Workflows")
  ;;     ("we" "Checking Email" entry (file+olp+datetree "~/Projects/Code/emacs-from-scratch/OrgFiles/Journal.org")
  ;;          "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)

  ;;     ("m" "Metrics Capture")
  ;;     ("mw" "Weight" table-line (file+headline "~/Projects/Code/emacs-from-scratch/OrgFiles/Metrics.org" "Weight")
  ;;      "| %U | %^{Weight} | %^{Notes} |" :kill-buffer t)))

  ;; (define-key global-map (kbd "C-c j")
  ;;   (lambda () (interactive) (org-capture nil "jj")))
  (rui/org-font-setup))

(use-package org-bullets
  :hook org-mode
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(use-package visual-fill-column
  :custom
  (visual-fill-column-width 100)
  (visual-fill-column-center-text t)
  :hook (org-mode Info-mode LaTeX-mode))

(setopt fill-column 90)

(with-eval-after-load 'org
  ;; This is needed as of Org 9.2
  (require 'org-tempo)

  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("ju" . "src jupyter-python")))

(defun rui/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode)
  (lsp-enable-which-key-integration))

(use-package lsp-mode
  :hook ((lsp-mode . rui/lsp-mode-setup)
	 (c++-mode . lsp-deferred))
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :custom
  (lsp-clients-clangd-args '("--header-insertion=never" "--enable-config")))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy
  :after lsp)



;; (use-package dap-mode
;;   ;; Uncomment the config below if you want all UI panes to be hidden by default!
;;   ;; :custom
;;   ;; (lsp-enable-dap-auto-configure nil)  ;; :config
;;   ;; (dap-ui-mode 1)
;;   :commands dap-debug
;;   :config
;;   ;; Set up Node debugging
;;   (require 'dap-node)
;;   (dap-node-setup) ;; Automatically installs Node debug adapter if needed

;;   ;; Bind `C-c l d` to `dap-hydra` for easy access
;;   (general-define-key
;;     :keymaps 'lsp-mode-map
;;     :prefix lsp-keymap-prefix
;;     "d" '(dap-hydra t :wk "debugger")))



(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config
  (setq typescript-indent-level 2))



(use-package python-mode
  :hook (python-mode . lsp-deferred)
  :custom
  ;; NOTE: Set these if Python 3 is called "python3" on your system!
  ;; (python-shell-interpreter "python3")
  ;; (dap-python-executable "python3")
  ;; (dap-python-debugger 'debugpy)
  (python-indent-guess-indent-offset-verbose nil))

(use-package pyvenv
  ;; :after python-mode
  :config
  (pyvenv-mode 1))

(use-package jupyter
  :after org
  :demand t
  ;; :config
  ;; (org-babel-do-load-languages
  ;;  'org-babel-load-languages
  ;;  '((emacs-lisp . t)
  ;;    (python . t)
  ;;    (jupyter . t)))
  ;; (org-babel-jupyter-override-src-block "python")
  :bind (:map jupyter-repl-mode-map
	      ("<up>" . jupyter-repl-history-previous)
	      ("<down>" . jupyter-repl-history-next)
	      ("M-d" . jupyter-repl-clear-cells)))

(defun rui/c++-mode-hook ()
  (c-set-offset 'innamespace '0))

(add-hook 'c++-mode-hook 'rui/c++-mode-hook)
(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

(use-package cmake-mode)

(use-package cmake-font-lock
  :hook (cmake-mode . cmake-font-lock-activate))

(use-package company
  :after lsp-mode
  :hook (prog-mode LaTeX-mode jupyter-repl-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package projectile
  :diminish projectile-mode
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (projectile-mode +1)
  (setq projectile-project-search-path '("~/projects/" "~/.dotfiles"))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :after projectile
  :config (counsel-projectile-mode))

(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
(use-package forge
  :after magit)

(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package electric
  :ensure nil
  :hook (prog-mode . electric-pair-local-mode))

(use-package gdb-mi
  :ensure nil
  :custom (gdb-many-windows t))

;; (use-package whitespace
;;   :ensure nil
;;   :hook prog-mode
;;   :custom (whitespace-style (face
;; 			     trailing
;; 			     tabs
;; 			     spaces
;; 			     lines-tail
;; 			     missing-newline-at-eof
;; 			     empty
;; 			     indentation
;; 			     space-after-tab
;; 			     space-before-tab
;; 			     space-mark
;; 			     tab-mark)))

(use-package simple
  :ensure nil
  :custom (indent-tabs-mode nil))

(use-package yasnippet
  :hook (yas-before-expand-snippet . (lambda () (evil-insert 0)))
  :config (yas-global-mode t))

(use-package yasnippet-snippets)

;; helper function to print the src language in the transclusion blocks
(defun rui/lang-name (filename) (pcase (file-name-extension filename)
  ("el" "emacs-lisp")
  ("py" "python")))

(use-package flyspell
  :ensure nil
  :hook ((text-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode)))

(use-package ispell
  :ensure nil
  :bind ("C-ç" . ispell-word))

(add-hook 'text-mode-hook 'auto-fill-mode)

(use-package tex
  :ensure auctex
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  ;; (TeX-electric-math t)
  :config
  (setq-default TeX-master nil)
  (TeX-source-correlate-mode)
  (add-to-list 'TeX-view-program-selection
               '(output-pdf "Zathura")))

(use-package term
  :ensure nil
  :commands term
  :config
  (setq explicit-shell-file-name "zsh") ;; Change this to zsh, etc
  ;;(setq explicit-zsh-args '())         ;; Use 'explicit-<shell>-args for shell-specific args

  ;; Match the default Bash shell prompt.  Update this if you have a custom prompt
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *"))

;; (use-package eterm-256color
;;   :hook (term-mode . eterm-256color-mode))

(use-package vterm
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")  ;; Set this to match your custom shell prompt
  ;;(setq vterm-shell "zsh")                       ;; Set this to customize the shell to launch
  (setq vterm-max-scrollback 10000))

(use-package multi-vterm
  :bind
  ("M-<return>" . multi-vterm)
  ("M-SPC" . multi-vterm-next)
  :config
  (add-hook 'vterm-mode-hook
	    (lambda ()
	      (setq-local evil-insert-state-cursor 'box)
	      (evil-insert-state)))
  (define-key vterm-mode-map [return]                      #'vterm-send-return)
  (define-key vterm-mode-map (kbd "M-SPC")       #'multi-vterm-next)

  (setq vterm-keymap-exceptions nil))
  ;; (evil-define-key 'insert vterm-mode-map (kbd "C-e")      #'vterm--self-insert)
  ;; (evil-define-key 'insert vterm-mode-map (kbd "C-f")      #'vterm--self-insert)
  ;; (evil-define-key 'insert vterm-mode-map (kbd "C-a")      #'vterm--self-insert)
  ;; (evil-define-key 'insert vterm-mode-map (kbd "C-v")      #'vterm--self-insert)
  ;; (evil-define-key 'insert vterm-mode-map (kbd "C-b")      #'vterm--self-insert)
  ;; (evil-define-key 'insert vterm-mode-map (kbd "C-w")      #'vterm--self-insert)
  ;; (evil-define-key 'insert vterm-mode-map (kbd "C-u")      #'vterm--self-insert)
  ;; (evil-define-key 'insert vterm-mode-map (kbd "C-d")      #'vterm--self-insert)
  ;; (evil-define-key 'insert vterm-mode-map (kbd "C-n")      #'vterm--self-insert)
  ;; (evil-define-key 'insert vterm-mode-map (kbd "C-m")      #'vterm--self-insert)
  ;; (evil-define-key 'insert vterm-mode-map (kbd "C-p")      #'vterm--self-insert)
  ;; (evil-define-key 'insert vterm-mode-map (kbd "C-j")      #'vterm--self-insert)
  ;; (evil-define-key 'insert vterm-mode-map (kbd "C-k")      #'vterm--self-insert)
  ;; (evil-define-key 'insert vterm-mode-map (kbd "C-r")      #'vterm--self-insert)
  ;; (evil-define-key 'insert vterm-mode-map (kbd "C-t")      #'vterm--self-insert)
  ;; (evil-define-key 'insert vterm-mode-map (kbd "C-g")      #'vterm--self-insert)
  ;; (evil-define-key 'insert vterm-mode-map (kbd "C-c")      #'vterm--self-insert)
  ;; (evil-define-key 'insert vterm-mode-map (kbd "C-SPC")    #'vterm--self-insert)
  ;; (evil-define-key 'normal vterm-mode-map (kbd "C-d")      #'vterm--self-insert)
  ;; (evil-define-key 'normal vterm-mode-map (kbd ",c")       #'multi-vterm)
  ;; (evil-define-key 'normal vterm-mode-map (kbd ",n")       #'multi-vterm-next)
  ;; (evil-define-key 'normal vterm-mode-map (kbd ",p")       #'multi-vterm-prev)
  ;; (evil-define-key 'normal vterm-mode-map (kbd "i")        #'evil-insert-resume)
  ;; (evil-define-key 'normal vterm-mode-map (kbd "o")        #'evil-insert-resume)
  ;; (evil-define-key 'normal vterm-mode-map (kbd "<return>") #'evil-insert-resume))



(when (eq system-type 'windows-nt)
  (setq explicit-shell-file-name "powershell.exe")
  (setq explicit-powershell.exe-args '()))

(defun rui/configure-eshell ()
  ;; Save command history when commands are entered
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  ;; Bind some useful keys for evil-mode
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "C-r") 'counsel-esh-history)
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "<home>") 'eshell-bol)
  (evil-normalize-keymaps)

  (setq eshell-history-size         10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t))

(use-package eshell-git-prompt
  :after eshell)

(use-package eshell
  :ensure nil
  :hook (eshell-first-time-mode . rui/configure-eshell)
  :config

  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim")))

  (eshell-git-prompt-use-theme 'powerline))



(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom
  (dired-listing-switches "-agho --group-directories-first")
  (dired-kill-when-opening-new-dired-buffer t) 
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-up-directory
    "l" 'dired-find-file
    "N" 'mkdir))

;; (use-package dired-single
;;   :commands (dired dired-jump))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :commands (dired dired-jump)
  :config
  ;; Doesn't work as expected!
  ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "feh")
                                ("mkv" . "mpv"))))

;; (use-package dired-hide-dotfiles
;;   :hook (dired-mode . dired-hide-dotfiles-mode)
;;   :config
;;   (evil-collection-define-key 'normal 'dired-mode-map
;;     "H" 'dired-hide-dotfiles-mode))



(setq holiday-general-holidays
      '((holiday-fixed 1 1 "New Year's Day")
	(holiday-fixed 2 14 "Valentine's Day")
	(holiday-fixed 3 8 "Women's Day")
	(holiday-fixed 4 1 "April Fools' Day")
	(holiday-fixed 5 1 "Workers' Day")
	(holiday-fixed 10 31 "Halloween")
	(holiday-fixed 12 25 "Christmas")))

;; Portugal national holidays
(setopt holiday-local-holidays
      '((holiday-fixed 1 1 "Dia de Ano Novo")
	(holiday-easter-etc -47 "Entrudo")
	(holiday-fixed 3 19 "Dia do Pai")
	(holiday-easter-etc -2 "Sexta-Feira Santa")
	(holiday-easter-etc 0 "Páscoa")
	(holiday-fixed 4 25    "Dia da Liberdade")
	(holiday-fixed 5 1 "Dia do Trabalhador")
	(holiday-float 5 0 0 "Dia da Mãe")
	(holiday-easter-etc 60   "Corpo de Deus")
	(holiday-fixed 6 10  "Dia de Portugal")
	(holiday-fixed 8 15   "Assunção de Nossa Senhora")
	(holiday-fixed 10 5   "Implantação da República")
	(holiday-fixed 11 1   "Dia de Todos os Santos")
	(holiday-fixed 12 1   "Restauração da Independência")
	(holiday-fixed 12 8   "Imaculada Conceição")
	(holiday-fixed 12 25   "Natal")))

(setopt holiday-christian-holidays nil)
(setopt holiday-hebrew-holidays nil)
(setopt holiday-islamic-holidays nil)
(setopt holiday-bahai-holidays nil)
(setopt holiday-oriental-holidays nil)

(message "Ensuring packages loaded")

(require 'package)
;; (add-to-list 'package-archives
;;              '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)

(when (null package-archive-contents)
  (package-refresh-contents))

(require 'cask "~/.cask/cask.el")
(cask-initialize)

(setq-default ispell-program-name "aspell")

(set-face-foreground 'vertical-border "white")

(when (<= (display-color-cells) 8)
  (defun hl-line-mode () (interactive)))

(global-set-key (kbd "C-c C-j") 'cider-jack-in)

(global-set-key (kbd "C-c f") 'find-file-in-project)

(add-hook 'prog-mode-hook
          (defun my-kill-word-key ()
            (local-set-key (kbd "C-M-h") 'backward-kill-word)))

(global-set-key (kbd "C-M-h") 'backward-kill-word)

(global-set-key (kbd "C-x C-i") 'imenu)

(global-set-key (kbd "C-x M-f") 'ido-find-file-other-window)
(global-set-key (kbd "C-c y") 'bury-buffer)
(global-set-key (kbd "C-c r") 'revert-buffer)

(global-set-key (kbd "C-x O") (lambda () (interactive) (other-window -1)))
(global-set-key (kbd "C-x C-o") (lambda () (interactive) (other-window 2)))

(global-set-key (kbd "C-x m") 'eshell)
(global-set-key (kbd "C-x C-m") 'shell)

(global-set-key (kbd "C-c q") 'join-line)
(global-set-key (kbd "C-c g") 'magit-status)

(global-set-key (kbd "C-c n")
                (defun pnh-cleanup-buffer () (interactive)
                  (delete-trailing-whitespace)
                  (untabify (point-min) (point-max))
                  (indent-region (point-min) (point-max))))

(global-set-key (kbd "C-c b")
                (defun pnh-blog () (interactive)
                  (shell-command (format "rake post POST=%s"
                                         (car (split-string (buffer-name)
                                                            "\\."))))))
(eval-after-load 'paredit
  ;; need a binding that works in the terminal
  '(progn
     (define-key paredit-mode-map (kbd "M-)") 'paredit-forward-slurp-sexp)
     (define-key paredit-mode-map (kbd "M-(") 'paredit-backward-slurp-sexp)))

;;; eshell

(defun eshell/rgrep (&rest args)
  "Use Emacs grep facility instead of calling external grep."
  (eshell-grep "rgrep" args t))

(defun eshell/cdg ()
  "Change directory to the project's root."
  (eshell/cd (locate-dominating-file default-directory ".git")))

;;; programming

(add-hook 'prog-mode-hook 'whitespace-mode)
(add-hook 'prog-mode-hook 'idle-highlight-mode)
(add-hook 'prog-mode-hook 'hl-line-mode)

;;; Clojure
(add-to-list 'auto-mode-alist  '("\\.clj$" . clojure-mode))
(add-to-list 'auto-mode-alist  '("\\.cljs$" . clojure-mode))
(add-to-list 'auto-mode-alist  '("\\.cljx$" . clojure-mode))
(add-to-list 'auto-mode-alist  '("\\.edn$" . clojure-mode))

(add-hook 'clojure-mode-hook 'smartparens-strict-mode)
(add-hook 'clojure-mode-hook 'sp-use-paredit-bindings)
(add-hook 'clojure-mode-hook
          (defun hd-setup-sp ()
            ;; (setq fill-paragraph-function 'sp-indent-defun)
            (define-key clojure-mode-map (kbd "M-q") 'sp-indent-defun)
            (setq sp-autoinsert-if-followed-by-word t)
            (setq fill-paragraph-function 'lisp-fill-paragraph)
            (sp-pair "``" nil :actions :rem)
            (sp-pair "'" nil :actions :rem)))
;; (add-hook 'clojure-mode-hook 'paredit-mode)
(add-hook 'clojure-test-mode-hook
          (defun hd-add-ediff-cleanup ()
            (add-hook 'ediff-cleanup-hook 'clojure-test-ediff-cleanup)))

(add-hook 'cider-repl-mode-hook
          (defun my-cider-repl-mode-hook ()
            (setq cider-popup-stacktraces t)
            (setq cider-repl-popup-stacktraces t)
            (setq cider-auto-select-error-buffer t)
            (setq cider-repl-history-file "~/.cider-history")
            (define-key cider-repl-mode-map
              (kbd "M-r") 'cider-repl-previous-matching-input)
            (define-key cider-repl-mode-map
              (kbd "M-s") 'cider-repl-next-matching-input)))
(add-hook 'cider-repl-mode-hook 'cider-turn-on-eldoc-mode)
(add-hook 'cider-repl-mode-hook 'smartparens-strict-mode)
(add-hook 'cider-repl-mode-hook 'subword-mode)

(defun hd-switch-repl (arg)
  (interactive "P")
  (when arg
    (cider-repl-set-ns (cider-current-ns)))
  (cider-switch-to-repl-buffer))

(add-hook 'cider-mode-hook
          (defun my-cider-mode-hook ()
            (setq cider-auto-select-error-buffer t)
            (setq cider-switch-to-repl-command
                  'cider-switch-to-current-repl-buffer)
            (define-key cider-mode-map
              (kbd "C-c C-z") 'hd-switch-repl)
            (setq cider-server-command
                  "/Users/duncan/bin/lein repl :headless")))
(add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)
(add-hook 'cider-mode-hook 'subword-mode)


(setq whitespace-style '(face trailing lines-tail tabs))

(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'emacs-lisp-mode-hook 'elisp-slime-nav-mode)
(add-hook 'emacs-lisp-mode-hook 'paredit-mode)

(define-key emacs-lisp-mode-map (kbd "C-c v") 'eval-buffer)

(define-key read-expression-map (kbd "TAB") 'lisp-complete-symbol)
(define-key lisp-mode-shared-map (kbd "RET") 'reindent-then-newline-and-indent)

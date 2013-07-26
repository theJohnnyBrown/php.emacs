(setq inhibit-splash-screen t)

(require 'package)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))
(package-initialize)

;; built-in packages
(require 'uniquify)

;; installed packages
(defvar my-packages
  '(coffee-mode autopair php-extras php-mode mmm-mode)
  "A list of packages to ensure are installed at launch.")

(defun my-packages-installed-p (packages)
  (and (package-installed-p (car packages))
       (my-packages-installed-p (cdr packages))))

(unless (my-packages-installed-p my-packages)
  ;; check for new packages (package versions)
  (message "%s" "Emacs Prelude is now refreshing its package database...")
  (package-refresh-contents)
  (message "%s" " done.")
  ;; install the missing packages
  (dolist (p my-packages)
    (when (not (package-installed-p p))
      (package-install p))))

(require 'coffee-mode)
(require 'autopair) ;; generates compiler warnings when installed

(require 'php-extras) ;; install and compile, ignore warnings, restart emacs
;; after that php-mode should compile w/o warnings
(require 'php-mode)

(require 'mmm-auto) ;; mmm generates compiler errors
(setq mmm-global-mode 'maybe)
(mmm-add-mode-ext-class 'html-mode "\\.php\\'" 'html-php)



(defun coffee-custom ()
  "coffee-mode-hook"
  (set (make-local-variable 'tab-width) 4)
  (define-key coffee-mode-map "\C-j" 'coffee-newline-and-indent))

(add-hook 'coffee-mode-hook
  '(lambda() (coffee-custom)))
(define-key coffee-mode-map [(meta r)] 'coffee-compile-buffer)
(setq-default indent-tabs-mode nil)


;; (defun my-flymake-show-next-error()
;;     (interactive)
;;     (flymake-goto-next-error)
;;     )
;; (global-set-key "\C-c\C-j" 'my-flymake-show-next-error)


(setq py-python-command-args '("--colors=Linux"))

;; One-True-Style window switching
(defun select-next-window ()
  "Switch to the next window" 
  (interactive)
  (select-window (next-window)))

(defun select-previous-window ()
  "Switch to the previous window" 
  (interactive)
  (select-window (previous-window)))

(global-set-key (kbd "M-s-<right>") 'select-next-window)
(global-set-key (kbd "M-s-<left>")  'select-previous-window)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;use codequality for type and style checking
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (when (load "flymake" t)
;;   (defun flymake-codequality-init ()
;;     (let* ((temp-file (flymake-init-create-temp-buffer-copy
;;                'flymake-create-temp-inplace))
;;        (local-file (file-relative-name
;;             temp-file
;;             (file-name-directory buffer-file-name))))
;;       (list "codequality" (list local-file))))
;;   (add-to-list 'flymake-allowed-file-name-masks
;;            '("\\.py\\'" flymake-codequality-init))
;;   (add-to-list 'flymake-allowed-file-name-masks
;;            '("\\.js\\'" flymake-codequality-init))
;;   (add-hook 'find-file-hook 'flymake-find-file-hook))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ns-command-modifier (quote meta))
 '(ns-option-modifier (quote super))
 '(coffee-tab-width 4)
 '(column-number-mode t)
 '(global-linum-mode t)
 '(show-paren-mode t))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PERSONAL IDIOSYNCRACIES 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Changes all yes/no questions to y/n type
(fset 'yes-or-no-p 'y-or-n-p)
;; Scroll down with the cursor,move down the buffer one 
;; line at a time, instead of in larger amounts.
(setq scroll-step 1)
;; do not make backup files
(setq make-backup-files nil)

(setq uniquify-buffer-name-style 'post-forward)

(define-key global-map (kbd "RET") 'newline-and-indent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Surround word or region with html tags
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun tag-word-or-region (&optional start-reg end-reg tag)
    "Surround current word or region with a given tag."
    (interactive "r\nsEnter tag (without <>): ")
    (let (pos1 pos2 bds start-tag end-tag)
        (setq start-tag (concat "<" tag ">"))
        (setq end-tag (concat "</" (car (split-string tag " ")) ">"))
            (progn
                (goto-char end-reg)
                (insert end-tag)
                (goto-char start-reg)
                (insert start-tag))))

(global-set-key "\C-xt" 'tag-word-or-region)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DEBUG STATEMENTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'python-mode-hook
	  (lambda ()
	    (local-set-key (kbd "C-c d")
			   (lambda () (interactive)
			     (insert "import ipdb; ipdb.set_trace()")))))
(add-hook 'js-mode-hook
	  (lambda ()
	    (local-set-key (kbd "C-c d") (lambda () (interactive)
					   (insert "debugger;")))))
(add-hook 'coffee-mode-hook
	  (lambda ()
	    (local-set-key (kbd "C-c d") (lambda ()
					   (interactive)
					   (insert "debugger;")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; autopair
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(autoload 'enable-paredit-mode "paredit"
    "Turn on pseudo-structural editing of Lisp code."
    t)
(autopair-global-mode)
;; handle python triple-quote strings
 (defun handle-trip-strings ()
	      (setq autopair-handle-action-fns
		    (list #'autopair-default-handle-action
			  #'autopair-python-triple-quote-action)))
(add-hook 'python-mode-hook 'handle-trip-strings)
(add-hook 'ein:connect-mode-hook 'handle-trip-strings)
(add-hook 'ein:notebook-multilang-mode-hook 'handle-trip-strings)

(put 'downcase-region 'disabled nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; color themes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/midnight-theme/")
(load-theme 'midnight t)

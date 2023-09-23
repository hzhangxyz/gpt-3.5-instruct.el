;;; gpt-3.5-instruct.el --- GPT-3.5 Instruct For Emacs -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Hao Zhang

;; Author: Hao Zhang <hzhangxyz@outlook.com>
;; Keywords: gpt, completion
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provide the completion by gpt-3.5 instruct

;;; Code:

(require 'url)
(require 'json)

(defvar gpt-endpoint "https://api.openai.com/v1/completions" "the endpoint of GPT API")
(defvar gpt-apikey nil "API key obtained from OpenAI")
(defvar gpt-temperature 1 "GPT completion temperature")
(defvar gpt-stop nil "GPT completion stopper")

;;;###autoload
(defun gpt-buffer-completion ()
  "Gpt buffer completion."
  (interactive)
  (message "GPT completing")
  (let* ((url gpt-endpoint)
         (content (buffer-string))
         (data (json-encode `((model . "gpt-3.5-turbo-instruct")
                              (prompt . ,content)
                              (temperature . ,gpt-temperature)
                              (stop . ,gpt-stop)
                              (echo . t)
                              (max_tokens . 256)
                              (n . 1))))
         (url-request-method "POST")
         (url-request-extra-headers
          `(("Content-Type" . "application/json")
            ("Authorization" . ,(concat "Bearer " gpt-apikey))))
         (url-request-data data))
    (url-retrieve
     url
     (lambda (status parent-buffer)
       (goto-char (point-min))
       (re-search-forward "^$")
       (delete-region (point) (point-min))
       (let* ((json-string (buffer-string))
              (json-data (json-read-from-string json-string))
              (json-choice (assoc-default 'choices json-data))
              (json-result (aref json-choice 0))
              (json-text (assoc-default 'text json-result)))
         (with-current-buffer parent-buffer
           (delete-region (point-min) (point-max))
           (insert (decode-coding-string json-text 'utf-8)))
         (kill-buffer)))
     `(,(current-buffer))))
  nil)

(provide 'gpt-3.5-instruct)
;;; gpt-3.5-instruct.el ends here

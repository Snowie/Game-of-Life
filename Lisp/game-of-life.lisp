(in-package :cl-user)

(defpackage #:my-new-package
  (:nicknames #:newpack)
  (:use :cl :cl-user)
  (:export #:sum-nine #:make-field #:randomize-field #:step-field #:print-field))

(in-package :my-new-package)

(defun sum-nine(field y x)
  "Sums from a corner of a square."
  (let ((s 0))
    (dotimes (j 3)
      (dotimes (k 3)
        (setf s (+ s
          (if (array-in-bounds-p field 0 (+ y j) (+ x k))
            (if (equal (aref field 0 (+ y j) (+ x k)) T)
              1
              0)
            0)))))
  s))

(defun make-field(x y)
  "Generate a field for the game of life"
  (make-array `(2 ,y ,x) :element-type 'boolean :initial-element nil))

(defun randomize-field(field)
  "Randomize a life field"
  (dotimes (y (array-dimension field 1))
    (dotimes (x (array-dimension field 2))
      (setf (aref field 0 y x) (if (< (random 2) 1) T nil)))))

(defun step-field(field)
  "Do some logic and then step the future state to current."
  (dotimes (y (array-dimension field 1))
    (dotimes (x (array-dimension field 2))
        (setf (aref field 1 y x)
          (if (equal (sum-nine field y x) 3)
            T
            (if (equal (sum-nine field (- y 1) (- x 1)) 4)
              (aref field 1 y x)
              nil)))))

  (dotimes (y (array-dimension field 1))
    (dotimes (x (array-dimension field 2))
        (setf (aref field 0 y x) (aref field 1 y x)))))

(defun print-field(field)
  "Print a pretty represenation of the field."
  (dotimes (y (array-dimension field 1))
    (progn (dotimes (x (array-dimension field 2))
      (if (equal (aref field 0 y x) T)
        (princ "O")
        (princ " ")))
      (princ #\linefeed))))

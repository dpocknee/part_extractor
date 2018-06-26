; Part Extractor Version 3
; by David Pocknee 5 July 2012
; Based on:
; DivideScannedImages.scm
; and
; by Rob Antonishen
; http://ffaat.pointclark.net

(define (script_fu_PartExtractor img inLayer inX inY inWidth inHeight inSaveFiles inDir inSaveType inFileName inFileNumber inPaper)
  (let*
    (
      (width (car (gimp-image-width img)))
      (height (car (gimp-image-height img)))
      (newpath 0)
      (strokes 0)
      (tempVector 0)
      (tempImage 0)
      (tempLayer 0)
      (bounds 0)
      (count 0)
      (numextracted 0)
      (saveString "")
      (newFileName "")
      (tempdisplay 0)
      (buffname "dsibuff")
      (pathchar (if (equal? (substring gimp-dir 0 1) "/") "/" "\\"))
	(newdpi 0)
	(tempwidth 0)	
	(tempheight 0)
	(brandwidth 0)
	(brandheight 0)
	(ratio 0)
	(paperchoose 0)
    )
(gimp-rect-select img inX inY inWidth inHeight REPLACE 0 0) 


    (gimp-context-push)
    (gimp-image-undo-disable img)

    (if (= inSaveFiles TRUE)
      (set! saveString
      (cond 
        (( equal? inSaveType 0 ) ".jpg" )
        (( equal? inSaveType 1 ) ".bmp" )
        (( equal? inSaveType 2 ) ".png" )
      )
))
(begin
          (set! buffname (car (gimp-edit-named-copy inLayer buffname)))
          (set! tempImage (car (gimp-edit-named-paste-as-new buffname)))
          (set! tempLayer (car (gimp-image-get-active-layer tempImage)))
          (gimp-image-undo-disable tempImage)
          (set! tempdisplay (car (gimp-display-new tempImage)))
      (gimp-layer-flatten tempLayer)
          (gimp-image-undo-enable tempImage)
(set! newdpi (car (gimp-image-get-resolution img)))
          (gimp-image-set-resolution tempImage newdpi newdpi)


(set! paperchoose
      (cond 
        (( equal? inPaper 0 ) 7.5 )
        (( equal? inPaper 1 ) 11.5 )
	(( equal? inPaper 2 ) 15.5 )
	(( equal? inPaper 3 ) 9.5 )
	(( equal? inPaper 4 ) 13.5)      )
)

	(set! tempwidth (car (gimp-image-width tempImage)))
	(set! tempheight (car (gimp-image-height tempImage)))
	(set! ratio (/ paperchoose (/ tempwidth newdpi)))
	(set! brandwidth      (* ratio tempwidth))
	(set! brandheight     (* ratio tempheight))
	(gimp-image-scale tempImage brandwidth brandheight)

          ;save file
          (if (= inSaveFiles TRUE)
          (begin
            (set! newFileName (string-append inDir pathchar inFileName 
                                       (substring "00000" (string-length (number->string (+ inFileNumber numextracted)))) 
                                       (number->string (+ inFileNumber numextracted)) saveString))
            (gimp-file-save RUN-NONINTERACTIVE tempImage tempLayer newFileName newFileName)
            (gimp-display-delete tempdisplay)
)
  ))
       
          (set! numextracted (+ numextracted 1))
          
      (set! count (+ count 1))


    ;input drawable name should be set to 1919191919 if in batch
    (if (and (> numextracted 0) (equal? (car (gimp-drawable-get-name inLayer)) "1919191919"))
      (gimp-drawable-set-name inLayer (number->string (+ 1919191919 numextracted))))

    ;delete temp path
    (gimp-selection-none img)
    
    ;done
    (gimp-image-undo-enable img)
    (gimp-progress-end)
    (gimp-displays-flush)
    (gimp-context-pop)
  )
)


(define (script_fu_BatchPartExtractor inSourceDir inLoadType inX inY inWidth inHeight inDestDir inSaveType inFileName inFileNumber inPaper)
(let*
    (
      (varLoadStr "")
      (varFileList 0)
      (varCounter inFileNumber)
      (pathchar (if (equal? (substring gimp-dir 0 1) "/") "/" "\\"))
    )
    
    (define split
      (lambda (ls)
        (letrec ((split-h (lambda (ls ls1 ls2)
                            (cond
                              ((or (null? ls) (null? (cdr ls)))
                               (cons (reverse ls2) ls1))
                              (else (split-h (cddr ls)
                                      (cdr ls1) (cons (car ls1) ls2)))))))
          (split-h ls ls '()))))
          
    (define merge
      (lambda (pred ls1 ls2)
        (cond
          ((null? ls1) ls2)
          ((null? ls2) ls1)
          ((pred (car ls1) (car ls2))
           (cons (car ls1) (merge pred (cdr ls1) ls2)))
          (else (cons (car ls2) (merge pred ls1 (cdr ls2)))))))

    ;pred is the comparison, i.e. <= for an ascending numeric list, or 
    ;string<=? for a case sensitive alphabetical sort, 
    ;string-ci<=? for a case insensitive alphabetical sort, 
    (define merge-sort
      (lambda (pred ls)
        (cond
          ((null? ls) ls)
          ((null? (cdr ls)) ls)
          (else (let ((splits (split ls)))
                  (merge pred
                    (merge-sort pred (car splits))
                    (merge-sort pred (cdr splits))))))))

    ;begin here
    (set! varLoadStr
    (cond 
    (( equal? inLoadType 0 ) ".[jJ][pP][gG]" )
    (( equal? inLoadType 1 ) ".[bB][mM][pP]" )
    (( equal? inLoadType 2 ) ".[pP][nN][gG]" )
    ))  

    (set! varFileList (merge-sort string<=? (cadr (file-glob (string-append inSourceDir pathchar "*" varLoadStr)  1))))
    (while (not (null? varFileList))
      (let* ((filename (car varFileList))
             (image (car (gimp-file-load RUN-NONINTERACTIVE filename filename)))
             (drawable (car (gimp-image-get-active-layer image))))

        ;flag for batch mode
        (gimp-drawable-set-name drawable "1919191919")
        (gimp-progress-set-text (string-append "Working on ->" filename))
      
        (script_fu_PartExtractor image drawable inX inY inWidth inHeight TRUE inDestDir inSaveType inFileName varCounter inPaper)
 
        ;increment by number extracted.
        (set! varCounter (+ varCounter (- (string->number (car (gimp-drawable-get-name drawable))) 1919191919)))
        (gimp-image-delete image)
      )
      (set! varFileList (cdr varFileList))
    )
  )
)

(script-fu-register "script_fu_BatchPartExtractor"
                    "<Toolbox>/File/Part Extractor..."
                    "Extracts parts from hand-written music scores"
                    "Rob Antonishen modified by David Pocknee"
                    "Rob Antonishen, modified by David Pocknee"
                    "April 2010"
                    ""
                    SF-DIRNAME    "Load from" ""
                    SF-OPTION     "Load File Type" (list "jpg" "bmp" "png") 
                    SF-ADJUSTMENT "X Co-ordinate of upper-left corner"  (list 0 0 9000 1 100 0 SF-SPINNER)
                    SF-ADJUSTMENT "Y Co-ordinate of upper-left corner"  (list 0 0 9000 1 100 0 SF-SPINNER)       
                    SF-ADJUSTMENT "Width Of Selection"          	(list 0 0 9000 1 100 0 SF-SPINNER)                         
                    SF-ADJUSTMENT "Height Of Selection"          	(list 0 0 9000 1 100 0 SF-SPINNER)
                    SF-DIRNAME    "Save Directory"                      ""
                    SF-OPTION     "Save File Type"                      (list "jpg" "bmp" "png")
                    SF-STRING     "Save File Base Name"                 "IMAGE"
                    SF-ADJUSTMENT "Save File Start Number"              (list 0 0 9000 1 100 0 SF-SPINNER)       
			SF-OPTION     "Paper Size of Part" (list "A4 Portrait" "A4 Landscape" "A3 Landscape" "B4 Portrait" "B4 Landscape")
)
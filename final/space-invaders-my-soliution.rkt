;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname space-invaders-my-soliution) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/universe)
(require 2htdp/image)

;; Space Invaders


;; =================
;; Constants:

(define WIDTH  300)
(define HEIGHT 500)

(define INVADER-X-SPEED 1.5)  ;speeds (not velocities) in pixels per tick
(define INVADER-Y-SPEED 1.5)
(define TANK-SPEED 2)
(define MISSILE-SPEED 10)

(define HIT-RANGE 10)

(define INVADE-RATE 50)
(define INVADER-MAX-SPEED 10)

(define BACKGROUND (empty-scene WIDTH HEIGHT))

(define INVADER
  (overlay/xy (ellipse 10 15 "outline" "blue")              ;cockpit cover
              -5 6
              (ellipse 20 10 "solid"   "blue")))            ;saucer

(define TANK
  (overlay/xy (overlay (ellipse 28 8 "solid" "black")       ;tread center
                       (ellipse 30 10 "solid" "green"))     ;tread outline
              5 -14
              (above (rectangle 5 10 "solid" "black")       ;gun
                     (rectangle 20 10 "solid" "black"))))   ;main body

(define TANK-HEIGHT/2 (/ (image-height TANK) 2))

(define MISSILE (ellipse 5 15 "solid" "red"))



;; =================
;; Data Definitions:

(define-struct game (invaders missiles tank tick))
;; Game is (make-game  (listof Invader) (listof Missile) Tank Natural)
;; interp. the current state of a space invaders game
;;         with the current invaders, missiles and tank position

;; Game constants defined below Missile data definition

#;
(define (fn-for-game s)
  (... (fn-for-loinvader (game-invaders s))
       (fn-for-lom (game-missiles s))
       (fn-for-tank (game-tank s))
       (fn-for-tick (game-tick s))))



(define-struct tank (x dir))
;; Tank is (make-tank Number Integer[-1, 1])
;; interp. the tank location is x, HEIGHT - TANK-HEIGHT/2 in screen coordinates
;;         the tank moves TANK-SPEED pixels per clock tick left if dir -1, right if dir 1

(define T0 (make-tank (/ WIDTH 2) 1))   ;center going right
(define T1 (make-tank 50 1))            ;going right
(define T2 (make-tank 50 -1))           ;going left

#;
(define (fn-for-tank t)
  (... (tank-x t) (tank-dir t)))



(define-struct invader (x y dx))
;; Invader is (make-invader Number Number Number)
;; interp. the invader is at (x, y) in screen coordinates
;;         the invader moves along x by dx pixels per clock tick

(define I1 (make-invader 150 100 12))           ;not landed, moving right
(define I2 (make-invader 150 HEIGHT -10))       ;exactly landed, moving left
(define I3 (make-invader 150 (+ HEIGHT 10) 10)) ;> landed, moving right


#;
(define (fn-for-invader invader)
  (... (invader-x invader) (invader-y invader) (invader-dx invader)))


(define-struct missile (x y))
;; Missile is (make-missile Number Number)
;; interp. the missile's location is x y in screen coordinates

(define M1 (make-missile 150 300))                               ;not hit I1
(define M2 (make-missile (invader-x I1) (+ (invader-y I1) 10)))  ;exactly hit I1
(define M3 (make-missile (invader-x I1) (+ (invader-y I1)  5)))  ;> hit I1

#;
(define (fn-for-missile m)
  (... (missile-x m) (missile-y m)))



(define G0 (make-game empty empty T0 0))
(define G1 (make-game empty empty T1 0))
(define G2 (make-game (list I1) (list M1) T1 0))
(define G3 (make-game (list I1 I2) (list M1 M2) T1 0))
(define G4 (make-game empty empty T2 0))



;; ListOfInvader is one of:
;; - empty
;; - (cons Invader ListOfInvader)
;; interp. A list of invaders.
(define LOI0 empty)
(define LOI1 (list I1))
(define LOI2 (list I1 I2))
(define LOI3 (list I1 I2 I3))

#;
(define (fn-for-loi loi)
  (cond [(empty? loi) (...)]
        [else
         (... (fn-for-invader (first loi))
              (fn-for-loi (rest loi)))]))


;; ListOfMissile is one of:
;; - empty
;; - (cons Missile ListOfMissile)
;; interp. A list of missiles.
(define LOM0 empty)
(define LOM1 (list M1))
(define LOM2 (list M1 M2))
(define LOM3 (list M1 M2 M3))

#;
(define (fn-for-lom lom)
  (cond [(empty? lom) (...)]
        [else
         (... (fn-for-missile (first lom))
              (fn-for-lom (rest lom)))]))



;; =================
;; Functions:

;; Game -> Game
;; start the world with (main (make-game empty empty T0))
(define (main g)
  (big-bang g                 ; Game
    (on-tick   advance-game)  ; Game -> Game
    (to-draw   render-game)   ; Game -> Image
    (on-key    handle-key)    ; Game KeyEvent -> Game
    (stop-when game-over?)))  ; Game -> Boolean


;; Game -> Game
;; produce the next game state
(check-expect (advance-game G0)
              (make-game empty
                         empty
                         (make-tank (+ (tank-x T0)
                                       (* (tank-dir T0)
                                          TANK-SPEED))
                                    (tank-dir T0))
                         1))
(check-expect (advance-game (make-game (list (make-invader 150 100 12))
                                       (list (make-missile 150 300))
                                       (make-tank 50 1)
                                       0))
              (make-game (list (make-invader (+ 150 12)
                                             (+ 100 INVADER-Y-SPEED)
                                             12))
                         (list (make-missile 150
                                             (- 300 MISSILE-SPEED)))
                         (make-tank (+ 50
                                       (* 1 TANK-SPEED))
                                    1)
                         1))

;(define (advance-game g) g) ;stub

(define (advance-game g)
  (handle-collisions (maybe-spawn-invader (make-game (advance-invaders (game-invaders g))
                                                     (advance-missiles (game-missiles g))
                                                     (advance-tank (game-tank g))
                                                     (add1 (game-tick g))))))


;; Game -> Game
;; remove collided invaders and missiles
(check-expect (handle-collisions (make-game empty empty T0 0))
              (make-game empty empty T0 0))
(check-expect (handle-collisions (make-game (list I1 I2)
                                            (list M1)
                                            T0
                                            0))
              (make-game (list I1 I2)
                         (list M1)
                         T0
                         0))
(check-expect (handle-collisions (make-game (list I1 I2)
                                            (list M2)
                                            T0
                                            0))
              (make-game (list I2)
                         empty
                         T0
                         0))
(check-expect (handle-collisions (make-game (list I1 I2)
                                            (list M3)
                                            T0
                                            0))
              (make-game (list I2)
                         empty
                         T0
                         0))

;(define (handle-collisions g) g) ;stub

(define (handle-collisions g)
  (make-game (remove-hit-invaders (game-invaders g) (game-missiles g))
             (remove-hit-missiles (game-missiles g) (game-invaders g))
             (game-tank g)
             (game-tick g)))


;; ListOfInvader ListOfMissile -> ListOfInvader
;; remove invaders collided with missiles
(check-expect (remove-hit-invaders empty empty) empty)
(check-expect (remove-hit-invaders empty
                                   (list M1))
              empty)
(check-expect (remove-hit-invaders (list I1)
                                   empty)
              (list I1))
(check-expect (remove-hit-invaders (list I1 I2)
                                   (list M1))
              (list I1 I2))
(check-expect (remove-hit-invaders (list I1 I2)
                                   (list M2))
              (list I2))
(check-expect (remove-hit-invaders (list I1 I2)
                                   (list M3))
              (list I2))

;(define (remove-hit-invaders invaders missiles) invaders) ;stub

(define (remove-hit-invaders invaders missiles)
  (cond [(empty? invaders) invaders]
        [else
         (if (invader-safe? (first invaders) missiles)
             (cons (first invaders)
                   (remove-hit-invaders (rest invaders) missiles))
             (remove-hit-invaders (rest invaders) missiles))]))


;; Invader ListOfMissile -> Boolean
;; return true if invader doesn't collide with any one of missiles
(check-expect (invader-safe? I1 empty) true)
(check-expect (invader-safe? I1 (list M1)) true)
(check-expect (invader-safe? I2 (list M2)) true)
(check-expect (invader-safe? I1 (list M2)) false)
(check-expect (invader-safe? I1 (list M3)) false)

;(define (invader-safe? invader missiles) false) ;stub

(define (invader-safe? invader missiles)
  (cond [(empty? missiles) true]
        [else 
         (if (invader-hit-by-missile? invader (first missiles))
             false
             (invader-safe? invader (rest missiles)))]))


;; Invader Missile -> Boolean
;; return true if invader collides with missile
(check-expect (invader-hit-by-missile? I1 M1) false)
(check-expect (invader-hit-by-missile? I2 M1) false)
(check-expect (invader-hit-by-missile? I1 M2) true)
(check-expect (invader-hit-by-missile? I1 M3) true)

;(define (invader-hit-by-missile? invader missile) false) ;stub

(define (invader-hit-by-missile? invader missile)
  (collision? missile invader))


;; Missile Invader -> Boolean
;; return true if there is a collision between given missile and invader
(check-expect (collision? (make-missile 150 300)
                          (make-invader 150 100 12))
              false)

; collisions depending on y coordinates
(check-expect (collision? (make-missile 150 (+ 100 10))
                          (make-invader 150 100 12))
              true)
(check-expect (collision? (make-missile 150 (+ 100 5))
                          (make-invader 150 100 12))
              true)
(check-expect (collision? (make-missile 150 (- 100 10))
                          (make-invader 150 100 12))
              true)
(check-expect (collision? (make-missile 150 (- 100 5))
                          (make-invader 150 100 12))
              true)

; collisions depending on x coordinates
(check-expect (collision? (make-missile (- 150 10) (+ 100 10))
                          (make-invader 150 100 12))
              false)
(check-expect (collision? (make-missile (- 150 5) (+ 100 10))
                          (make-invader 150 100 12))
              true)
(check-expect (collision? (make-missile (+ 150 6) (+ 100 5))
                          (make-invader 150 100 12))
              false)
(check-expect (collision? (make-missile (+ 150 1) (+ 100 5))
                          (make-invader 150 100 12))
              true)

;(define (collision? m i) false) ;stub

(define (collision? m i)
  (and (<= (- (invader-x i)
              5)
           (missile-x m)
           (+ (invader-x i)
              5))
       (<= (- (invader-y i)
              10)
           (missile-y m)
           (+ (invader-y i)
              10))))


;; ListOfMissile ListOfInvader -> ListOfMissile
;; remove missiles collided with invaders
(check-expect (remove-hit-missiles empty empty) empty)
(check-expect (remove-hit-missiles empty
                                   (list I1))
              empty)
(check-expect (remove-hit-missiles (list M1)
                                   empty)
              (list M1))
(check-expect (remove-hit-missiles (list M1)
                                   (list I1 I2))
              (list M1))
(check-expect (remove-hit-missiles (list M2)
                                   (list I1 I2))
              empty)
(check-expect (remove-hit-missiles (list M3)
                                   (list I1 I2))
              empty)
(check-expect (remove-hit-missiles (list M1 M3)
                                   (list I1 I2))
              (list M1))

;(define (remove-hit-missiles missiles invaders) missiles) ;stub

(define (remove-hit-missiles missiles invaders)
  (cond [(empty? missiles) missiles]
        [else
         (if (missile-safe? (first missiles) invaders)
             (cons (first missiles)
                   (remove-hit-missiles (rest missiles) invaders))
             (remove-hit-missiles (rest missiles) invaders))]))


;; Missile ListOfInvader -> Boolean
;; return true if missile doesn't collide with any one of invaders
(check-expect (missile-safe? M1 empty) true)
(check-expect (missile-safe? M1 (list I1)) true)
(check-expect (missile-safe? M2 (list I2)) true)
(check-expect (missile-safe? M2 (list I1)) false)
(check-expect (missile-safe? M3 (list I1)) false)

;(define (missile-safe? invader missiles) false) ;stub

(define (missile-safe? missile invaders)
  (cond [(empty? invaders) true]
        [else 
         (if (missile-hit-invader? missile (first invaders))
             false
             (missile-safe? missile (rest invaders)))]))


;; Missile Invader -> Boolean
;; return true if missile collides with invader
(check-expect (missile-hit-invader? M1 I1) false)
(check-expect (missile-hit-invader? M1 I2) false)
(check-expect (missile-hit-invader? M2 I1) true)
(check-expect (missile-hit-invader? M3 I1) true)

;(define (missile-hit-invader? missile invader) false) ;stub

(define (missile-hit-invader? missile invader)
  (collision? missile invader))


;; ListOfInvader -> ListOfInvader
;; move invaders in accordance to their speed and direction
(check-expect (advance-invaders empty) empty)
(check-expect (advance-invaders (list (make-invader 150 100 12)))
              (list (make-invader (+ 150 12)
                                  (+ 100 INVADER-Y-SPEED)
                                  12)))
(check-expect (advance-invaders (list (make-invader 150 100 -12)))
              (list (make-invader (+ 150 -12)
                                  (+ 100 INVADER-Y-SPEED)
                                  -12)))
(check-expect (advance-invaders (list (make-invader 150 100 12)
                                      (make-invader 150 100 -12)))
              (list (make-invader (+ 150 12)
                                  (+ 100 INVADER-Y-SPEED)
                                  12)
                    (make-invader (+ 150 -12)
                                  (+ 100 INVADER-Y-SPEED)
                                  -12)))

;(define (advance-invaders loi) loi) ;stub

(define (advance-invaders loi)
  (cond [(empty? loi) loi]
        [else
         (cons (move-invader (first loi))
               (advance-invaders (rest loi)))]))


;; Invader -> Invader
;; move single invader in accordance to its speed and direction

; move
(check-expect (move-invader (make-invader 150 100 12))
              (make-invader (+ 150 12)
                            (+ 100 INVADER-Y-SPEED)
                            12))
(check-expect (move-invader (make-invader 150 100 -12))
              (make-invader (+ 150 -12)
                            (+ 100 INVADER-Y-SPEED)
                            -12))

; bounce from the edge and change direction
; exact collision with right wall:
(check-expect (move-invader (make-invader (+ WIDTH (/ (image-width INVADER) 2))
                                          150
                                          10))
              (make-invader (- (+ WIDTH (/ (image-width INVADER) 2))
                               10)
                            (+ 150 INVADER-Y-SPEED)
                            -10))

; > collision with right wall:
(check-expect (move-invader (make-invader (+ WIDTH 3 (/ (image-width INVADER) 2))
                                          150
                                          10))
              (make-invader (- (+ WIDTH 3 (/ (image-width INVADER) 2))
                               10)
                            (+ 150 INVADER-Y-SPEED)
                            -10))

; exact collision with left wall:
(check-expect (move-invader (make-invader (- 0 (/ (image-width INVADER) 2))
                                          150
                                          -10))
              (make-invader (+ (- 0 (/ (image-width INVADER) 2))
                               10)
                            (+ 150 INVADER-Y-SPEED)
                            10))

; > collision with left wall:
(check-expect (move-invader (make-invader (- 0 3 (/ (image-width INVADER) 2))
                                          150
                                          -10))
              (make-invader (+ (- 0 3 (/ (image-width INVADER) 2))
                               10)
                            (+ 150 INVADER-Y-SPEED)
                            10))

;(define (move-invader i) i) ;stub

(define (move-invader i)
  (cond [(<= (invader-x i) 0)
         (make-invader (+ (invader-x i)
                          (- (invader-dx i)))
                       (+ (invader-y i)
                          INVADER-Y-SPEED)
                       (- (invader-dx i)))]
        [(>= (invader-x i) WIDTH)
         (make-invader (- (invader-x i)
                          (invader-dx i))
                       (+ (invader-y i)
                          INVADER-Y-SPEED)
                       (- (invader-dx i)))]
        [else
         (make-invader (+ (invader-x i)
                          (invader-dx i))
                       (+ (invader-y i)
                          INVADER-Y-SPEED)
                       (invader-dx i))]))


;; ListOfMissile -> ListOfMissile
;; move missiles up and filter those out of bounds
(check-expect (advance-missiles empty) empty)
(check-expect (advance-missiles (list (make-missile 150 300)))
              (list (make-missile 150 (- 300 MISSILE-SPEED))))
(check-expect (advance-missiles (list (make-missile 150 -10)))
              empty)
(check-expect (advance-missiles (list (make-missile 150 -10)
                                      (make-missile 150 300)))
              (list (make-missile 150 (- 300 MISSILE-SPEED))))

(define (advance-missiles missiles)
  (filter-missiles (move-missiles missiles)))


;; ListOfMissiles -> ListOfMissiles
;; filter missiles with y < 0
(check-expect (filter-missiles empty) empty)
(check-expect (filter-missiles (list (make-missile 150 300)))
              (list (make-missile 150 300)))
(check-expect (filter-missiles (list (make-missile 150 -10)))
              empty)
(check-expect (filter-missiles (list (make-missile 150 100)
                                     (make-missile 150 300)))
              (list (make-missile 150 100)
                    (make-missile 150 300)))
(check-expect (filter-missiles (list (make-missile 150 100)
                                     (make-missile 150 -10)))
              (list (make-missile 150 100)))

;(define (filter-missiles missiles) missiles) ;stub

(define (filter-missiles missiles)
  (cond [(empty? missiles) missiles]
        [else
         (if (out-of-bounds? (first missiles))
             (filter-missiles (rest missiles))
             (cons (first missiles) (filter-missiles (rest missiles))))]))


;; Missile -> Boolean
;; return true if missile's y coordinate < 0
(check-expect (out-of-bounds? (make-missile 150 100)) false)
(check-expect (out-of-bounds? (make-missile 150 0)) false)
(check-expect (out-of-bounds? (make-missile 150 -10)) true)

;(define (out-of-bounds? m) false) ;stub

(define (out-of-bounds? m)
  (< (missile-y m) 0))


;; ListOfMissile -> ListOfMissile
;; move missiles up in accordance to missile speed
(check-expect (move-missiles empty) empty)
(check-expect (move-missiles (list (make-missile 150 300)))
              (list (make-missile 150 (- 300 MISSILE-SPEED))))

(check-expect (move-missiles (list (make-missile 150 300)
                                   (make-missile 150 0)))
              (list (make-missile 150 (- 300 MISSILE-SPEED))
                    (make-missile 150 (- 0 MISSILE-SPEED))))

;(define (move-missiles missiles) missiles) ;stub

(define (move-missiles missiles)
  (cond [(empty? missiles) missiles]
        [else
         (cons (move-missile (first missiles))
               (move-missiles (rest missiles)))]))


;; Missile -> Missile
;; move single missile up in accordance to missile speed
(check-expect (move-missile (make-missile 150 300))
              (make-missile 150 (- 300 MISSILE-SPEED)))
(check-expect (move-missile (make-missile 150 0))
              (make-missile 150 (- 0 MISSILE-SPEED)))

;(define (move-missile missile) missile) ;stub

(define (move-missile m)
  (make-missile (missile-x m)
                (- (missile-y m)
                   MISSILE-SPEED)))


;; Tank -> Tank
;; move tank in accordance to its speed and direction
(check-expect (advance-tank (make-tank (/ WIDTH 2) 1))
              (make-tank (+ (/ WIDTH 2) (* TANK-SPEED 1))
                         1))
(check-expect (advance-tank (make-tank 50 -1))
              (make-tank (+ 50 (* TANK-SPEED -1))
                         -1))
; prevent moving beyond left wall:
(check-expect (advance-tank (make-tank (/ TANK-SPEED 2) -1))
              (make-tank 0 -1))
; prevent moving beyond right wall:
(check-expect (advance-tank (make-tank (- WIDTH (/ TANK-SPEED 2)) 1))
              (make-tank WIDTH 1))

;(define (advance-tank t) t) ;stub

(define (advance-tank t)
  (cond [(and (> 0 (- (tank-x t) TANK-SPEED))
              (= (tank-dir t) -1))
         (make-tank 0 (tank-dir t))]
        [(and (< WIDTH (+ (tank-x t) TANK-SPEED))
              (= (tank-dir t) 1))
         (make-tank WIDTH (tank-dir t))]
        [else
         (make-tank (+ (tank-x t)
                       (* TANK-SPEED (tank-dir t)))
                    (tank-dir t))]))


;; Game -> Image
;; render the game onto BACKGROUND
(check-expect (render-game (make-game empty empty (make-tank (/ WIDTH 2) 1) 0))
              (place-image TANK
                           (/ WIDTH 2)
                           (- HEIGHT TANK-HEIGHT/2)
                           BACKGROUND))

(check-expect (render-game (make-game (list (make-invader 150 100 12))
                                      (list (make-missile 150 300))
                                      (make-tank 50 1)
                                      0))
              (place-image INVADER
                           150
                           100
                           (place-image MISSILE
                                        150
                                        300
                                        (place-image TANK
                                                     50
                                                     (- HEIGHT TANK-HEIGHT/2)
                                                     BACKGROUND))))


;(define (render-game g) BACKGROUND) ;stub

(define (render-game g)
  (render-invaders (game-invaders g)
                   (render-missiles (game-missiles g)
                                    (render-tank (game-tank g)
                                                 BACKGROUND))))

;; ListOfInvader Image -> Image
;; render invaders on the given image
(check-expect (render-invaders empty BACKGROUND) BACKGROUND)
(check-expect (render-invaders (list (make-invader 150 100 12)) BACKGROUND)
              (place-image INVADER
                           150
                           100
                           BACKGROUND))
(check-expect (render-invaders (list (make-invader 150 100 12)
                                     (make-invader 200 130 -5))
                               BACKGROUND)
              (place-image INVADER
                           150
                           100
                           (place-image INVADER
                                        200
                                        130
                                        BACKGROUND)))

;(define (render-invaders invaders image) image) ;stub

(define (render-invaders invaders image)
  (cond [(empty? invaders) image]
        [else
         (render-invader (first invaders)
                         (render-invaders (rest invaders) image))]))


;; Invader Image -> Image
;; render single ivander on the given image
(check-expect (render-invader (make-invader 150 100 12) BACKGROUND)
              (place-image INVADER
                           150
                           100
                           BACKGROUND))

;(define (render-invader i image) image) ;stub

(define (render-invader i image)
  (place-image INVADER
               (invader-x i)
               (invader-y i)
               image))


;; ListOfMissile Image -> Image
;; render missiles on the given image
(check-expect (render-missiles empty BACKGROUND) BACKGROUND)
(check-expect (render-missiles (list (make-missile 150 300)) BACKGROUND)
              (place-image MISSILE
                           150
                           300
                           BACKGROUND))
(check-expect (render-missiles (list (make-missile 150 300)
                                     (make-missile 200 150))
                               BACKGROUND)
              (place-image MISSILE
                           150
                           300
                           (place-image MISSILE
                                        200
                                        150
                                        BACKGROUND)))

;(define (render-missiles missiles image) image) ;stub

(define (render-missiles missiles image)
  (cond [(empty? missiles) image]
        [else
         (render-missile (first missiles)
                         (render-missiles (rest missiles) image))]))


;; Missile Image -> Image
;; render single missile on the given image
(check-expect (render-missile (make-missile 150 300) BACKGROUND)
              (place-image MISSILE
                           150
                           300
                           BACKGROUND))

;(define (render-missile m image) image) ;stub

(define (render-missile m image)
  (place-image MISSILE
               (missile-x m)
               (missile-y m)
               image))


;; Tank Image -> Image
;; render tank on the given image
(check-expect (render-tank (make-tank (/ WIDTH 2) 1) BACKGROUND)
              (place-image TANK
                           (/ WIDTH 2)
                           (- HEIGHT TANK-HEIGHT/2)
                           BACKGROUND))

;(define (render-tank t image) image) ;stub

(define (render-tank t image)
  (place-image TANK
               (tank-x t)
               (- HEIGHT TANK-HEIGHT/2)
               image))


;; Game KeyEvent -> Game
;; change tank direction when pressing arrow keys, fire missiles when pressing space bar
(check-expect (handle-key G2 "q") G2)
(check-expect (handle-key (make-game (list I1) (list M1) T1 0) " ")
              (make-game (list I1)
                         (list (make-missile (tank-x T1) (- HEIGHT TANK-HEIGHT/2))
                               M1)
                         T1
                         0))
(check-expect (handle-key (make-game (list I1)
                                     (list M1)
                                     (make-tank 100 1)
                                     0)
                          "left")
              (make-game (list I1)
                         (list M1)
                         (make-tank 100 -1)
                         0))
(check-expect (handle-key (make-game (list I1)
                                     (list M1)
                                     (make-tank 100 -1)
                                     0)
                          "right")
              (make-game (list I1)
                         (list M1)
                         (make-tank 100 1)
                         0))

;(define (handle-key g ke) g) ;stub

(define (handle-key g key)
  (cond [(key=? key "left")
         (make-game (game-invaders g)
                    (game-missiles g)
                    (switch-tank-dir-to-left (game-tank g))
                    (game-tick g))]
        [(key=? key "right")
         (make-game (game-invaders g)
                    (game-missiles g)
                    (switch-tank-dir-to-right (game-tank g))
                    (game-tick g))]
        [(key=? key " ")
         (fire-missile g)]
        [else g]))


;; Tank -> Tank
;; switch tank direction to the left
(check-expect (switch-tank-dir-to-left (make-tank 100 1))
              (make-tank 100 -1))
(check-expect (switch-tank-dir-to-left (make-tank 100 -1))
              (make-tank 100 -1))

;(define (switch-tank-dir-to-left t) t) ;stub

(define (switch-tank-dir-to-left t)
  (if (= (tank-dir t) 1)
      (make-tank (tank-x t) -1)
      t))


;; Tank -> Tank
;; switch tank direction to the right
(check-expect (switch-tank-dir-to-right (make-tank 100 -1))
              (make-tank 100 1))
(check-expect (switch-tank-dir-to-right (make-tank 100 1))
              (make-tank 100 1))

;(define (switch-tank-dir-to-right t) t) ;stub

(define (switch-tank-dir-to-right t)
  (if (= (tank-dir t) -1)
      (make-tank (tank-x t) 1)
      t))


;; Game -> Game
;; returns game with new missile fired
(check-expect (fire-missile (make-game (list I1) (list M1) T1 0))
              (make-game (list I1)
                         (list (make-missile (tank-x T1) (- HEIGHT TANK-HEIGHT/2))
                               M1)
                         T1
                         0))

;(define (fire-missile g) g) ;stub

(define (fire-missile g)
  (make-game (game-invaders g)
             (cons (make-missile (tank-x (game-tank g))
                                 (- HEIGHT TANK-HEIGHT/2))
                   (game-missiles g))
             (game-tank g)
             (game-tick g)))


;; Game -> Boolean
;; return true if there is at least one landed invader, otherwise return false
(check-expect (game-over? (make-game (list I1) (list M1 M2) T1 0)) false)
(check-expect (game-over? (make-game (list (make-invader 150 HEIGHT 10)) (list M1 M2) T1 0)) true)

;(define (game-over? g) false) ;stub

(define (game-over? g)
  (has-landed-invaders? (game-invaders g)))


;; ListOfInvaders -> Boolean
;; return true if there is at least one landed invader in the given list, otherwise return false
(check-expect (has-landed-invaders? empty) false)
(check-expect (has-landed-invaders? (list I1)) false)
(check-expect (has-landed-invaders? (list I1 (make-invader 150 HEIGHT 10))) true)

;(define (has-landed-invaders? invaders) false) ;stub

(define (has-landed-invaders? invaders)
  (cond [(empty? invaders) false]
        [else
         (if (landed? (first invaders))
             true
             (has-landed-invaders? (rest invaders)))]))


;; Invader -> Boolean
;; return true if invader's y coordinate >= HEIGHT
(check-expect (landed? (make-invader 100 100 10)) false)
(check-expect (landed? (make-invader 100 (- HEIGHT 10) 10)) false)
(check-expect (landed? (make-invader 100 HEIGHT 10)) true)
(check-expect (landed? (make-invader 100 (+ HEIGHT 10) 10)) true)

;(define (landed? i) false) ;stub

(define (landed? i)
  (>= (invader-y i) HEIGHT))


;; Game -> Game
;; spawns invader if neccessary
(check-random (maybe-spawn-invader (make-game empty empty T0 10))
              (make-game empty empty T0 10))
(check-random (maybe-spawn-invader (make-game empty empty T0 100))
              (make-game (list (make-invader (random WIDTH) 0 (random-sign-int (random INVADER-MAX-SPEED)))) empty T0 100))

;(define (maybe-spawn-invader g) g) ;stub

(define (maybe-spawn-invader g)
  (if (should-spawn-invader? (game-tick g))
      (spawn-invader g)
      g))


;; () -> Integer
;; generates random sign for the given integer
(define (random-sign-int i)
  (if (= (random 2) 0)
      (+ 1 i)
      (- (+ 1 i))))


;; Natural -> Boolean
;; returns true if the remainder of dividing the given number by INVADE-RATE is 0, otherwise return false
(check-expect (should-spawn-invader? 20) false)
(check-expect (should-spawn-invader? 100) true)
(check-expect (should-spawn-invader? 140) false)
(check-expect (should-spawn-invader? 200) true)

;(define (should-spawn-invader? i) false) ;stub

(define (should-spawn-invader? i)
  (= (remainder i INVADE-RATE) 0))


;; Game -> Game
;; create and add new invader at the random x coordinate at the top, with random dx from -INVADER-MAX-SPEED to INVADER-MAX-SPEED excluding 0
(check-random (spawn-invader (make-game empty empty T0 100))
              (make-game (list (make-invader (random WIDTH) 0 (random-sign-int (random INVADER-MAX-SPEED)))) empty T0 100))

;(define (spawn-invader g) g) ;stub

(define (spawn-invader g)
  (make-game (cons (make-invader (random WIDTH)
                                 0
                                 (random-sign-int (random INVADER-MAX-SPEED)))
                   (game-invaders g))
             (game-missiles g)
             (game-tank g)
             (game-tick g)))









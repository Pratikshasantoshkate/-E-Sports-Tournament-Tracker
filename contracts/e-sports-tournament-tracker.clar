;; ------------------------------------------------------------
;; E-Sports Tournament Tracker
;; A minimal Clarity smart contract to track tournaments & winners
;; ------------------------------------------------------------

;; Data Map: tournament-id => { name, prize-pool, winner }
(define-map tournaments uint
  {
    name: (string-ascii 50),
    prize-pool: uint,
    winner: (optional principal)
  }
)

;; Counter for total tournaments created
(define-data-var total-tournaments uint u0)

;; Error constants
(define-constant err-invalid-id (err u100))
(define-constant err-invalid-data (err u101))

;; ------------------------------------------------------------
;; 1. Add a new tournament
;; ------------------------------------------------------------
(define-public (add-tournament (name (string-ascii 50)) (prize-pool uint))
  (begin
    ;; Validate data
    (asserts! (> prize-pool u0) err-invalid-data)

    ;; Increment total tournaments
    (var-set total-tournaments (+ (var-get total-tournaments) u1))

    ;; Save new tournament
    (map-set tournaments (var-get total-tournaments)
             {
               name: name,
               prize-pool: prize-pool,
               winner: none
             })

    ;; Return ID of new tournament
    (ok (var-get total-tournaments))
  )
)

;; ------------------------------------------------------------
;; 2. Set the winner for a given tournament
;; ------------------------------------------------------------
(define-public (set-winner (tournament-id uint) (winner principal))
  (match (map-get? tournaments tournament-id)
    tournament-data
      (begin
        (map-set tournaments tournament-id
                 {
                   name: (get name tournament-data),
                   prize-pool: (get prize-pool tournament-data),
                   winner: (some winner)
                 })
        (ok true))
    (err err-invalid-id)
  )
)

;; ------------------------------------------------------------
;; Read-only: Get tournament details by ID
;; ------------------------------------------------------------
(define-read-only (get-tournament (tournament-id uint))
  (match (map-get? tournaments tournament-id)
    tournament-data
      (ok {
            name: (get name tournament-data),
            prize-pool: (get prize-pool tournament-data),
            winner: (get winner tournament-data)
          })
    (err err-invalid-id)
  )
)

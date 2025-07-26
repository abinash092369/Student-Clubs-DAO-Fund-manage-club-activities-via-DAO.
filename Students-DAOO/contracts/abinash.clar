
(define-map clubs 
  uint ;; club-id
  {
    name: (string-ascii 32),
    owner: principal,
    fund: uint
  })

;; Define Errors
(define-constant err-not-owner (err u100))
(define-constant err-invalid-amount (err u101))
(define-constant err-club-not-found (err u102))

;; Function 1: Create a new club
(define-public (create-club (club-id uint) (club-name (string-ascii 32)))
  (begin
    (asserts! (is-none (map-get? clubs club-id)) (err u103)) ;; prevent duplicate
    (map-set clubs club-id {
      name: club-name,
      owner: tx-sender,
      fund: u0
    })
    (ok club-id)
  )
)

;; Function 2: Fund a club (send STX)
(define-public (fund-club (club-id uint) (amount uint))
  (let ((club-data (map-get? clubs club-id)))
    (match club-data club
      (begin
        (asserts! (> amount u0) err-invalid-amount)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (map-set clubs club-id {
          name: (get name club),
          owner: (get owner club),
          fund: (+ (get fund club) amount)
        })
        (ok true)
      )
      err-club-not-found
    )
  )
)


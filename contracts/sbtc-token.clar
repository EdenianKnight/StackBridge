;; Basic Fungible Token for sBTC (Placeholder)
;; In a real scenario, this would be a more robust FT implementation (like SIP-010)

(define-fungible-token sbtc)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-INSUFFICIENT-SUPPLY (err u500))

(define-data-var token-name (string-ascii 32) "Stacks Bitcoin")
(define-data-var token-symbol (string-ascii 6) "sBTC")
(define-data-var token-decimals uint u8)
(define-data-var total-supply uint u0)

;; --- Authorization Check ---
(define-public (is-authorized (caller principal))
  (ok (is-eq caller CONTRACT-OWNER)) ;; Simple check: only deployer
  ;; To allow the bridge contract:
  ;; (ok (is-eq caller .sbtc-bridge)) ;; Replace .sbtc-bridge with the actual deployed bridge contract ID
)

;; --- Public Functions ---
(define-public (get-name)
  (ok (var-get token-name))
)

(define-public (get-symbol)
  (ok (var-get token-symbol))
)

(define-public (get-decimals)
  (ok (var-get token-decimals))
)

(define-public (get-total-supply)
  (ok (var-get total-supply))
)

(define-public (get-balance (account principal))
  (ok (ft-get-balance sbtc account))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    ;; Add validation checks for amount and sender
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (asserts! (is-eq tx-sender sender) ERR-UNAUTHORIZED)
    (ft-transfer? sbtc amount sender recipient)
  )
)

;; --- Minting and Burning (Called by the Bridge) ---
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (> amount u0) ERR-INVALID-AMOUNT) ;; Check for valid amount
    
    ;; Verify authorization
    (let ((auth-result (is-authorized tx-sender)))
      (asserts! (is-ok auth-result) ERR-UNAUTHORIZED)
      (asserts! (unwrap-panic auth-result) ERR-UNAUTHORIZED)
      
      ;; Update supply and mint tokens
      (var-set total-supply (+ (var-get total-supply) amount))
      (ft-mint? sbtc amount recipient)
    )
  )
)

(define-public (burn (amount uint))
  (begin
    (asserts! (> amount u0) ERR-INVALID-AMOUNT) ;; Check for valid amount
    
    ;; Verify authorization
    (let ((auth-result (is-authorized tx-sender)))
      (asserts! (is-ok auth-result) ERR-UNAUTHORIZED)
      (asserts! (unwrap-panic auth-result) ERR-UNAUTHORIZED)
      
      ;; Check sufficient supply
      (asserts! (>= (var-get total-supply) amount) ERR-INSUFFICIENT-SUPPLY)
      
      ;; Update supply and burn tokens
      (var-set total-supply (- (var-get total-supply) amount))
      (ft-burn? sbtc amount tx-sender)
    )
  )
)

;; Initialize (optional, can set decimals etc.)
(begin
  (var-set token-decimals u8) ;; Bitcoin has 8 decimals
)
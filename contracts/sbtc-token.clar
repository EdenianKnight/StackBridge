;; Basic Fungible Token for sBTC (Placeholder)
;; In a real scenario, this would be a more robust FT implementation (like SIP-010)

(define-fungible-token sbtc)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u101))

(define-data-var token-name (string-ascii 32) "Stacks Bitcoin")
(define-data-var token-symbol (string-ascii 6) "sBTC")
(define-data-var token-decimals uint u8)
(define-data-var total-supply uint u0)

;; --- Authorization Check ---
;; Only allow the contract owner (deployer) or potentially the bridge contract to mint/burn
;; In a real bridge, you'd likely grant authorization specifically to the bridge contract address.
(define-private (is-authorized)
(ok (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)) ;; Simple check: only deployer
;; To allow the bridge contract:
;; (ok (asserts! (is-eq tx-sender .sbtc-bridge) ERR-UNAUTHORIZED)) ;; Replace .sbtc-bridge with the actual deployed bridge contract ID
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
(asserts! (is-eq tx-sender sender) ERR-UNAUTHORIZED)
(ft-transfer? sbtc amount sender recipient)
)
)

;; --- Minting and Burning (Called by the Bridge) ---
(define-public (mint (amount uint) (recipient principal))
(begin
(try! (is-authorized)) ;; Ensure caller is authorized (e.g., the bridge contract)
(let ((new-supply (+ (var-get total-supply) amount)))
(var-set total-supply new-supply)
(ft-mint? sbtc amount recipient)
)
)
)

(define-public (burn (amount uint) (owner principal))
(begin
(try! (is-authorized)) ;; Ensure caller is authorized
(asserts! (is-eq tx-sender owner) ERR-UNAUTHORIZED) ;; Ensure the owner is initiating the burn via the bridge
(let ((new-supply (- (var-get total-supply) amount)))
(asserts! (>= (var-get total-supply) amount) (err u500)) ;; Ensure sufficient total supply
(var-set total-supply new-supply)
(ft-burn? sbtc amount owner)
)
)
)

;; Initialize (optional, can set decimals etc.)
(begin
(var-set token-decimals u8) ;; Bitcoin has 8 decimals
)
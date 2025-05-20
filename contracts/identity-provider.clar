;; Identity Provider Verification Contract
;; Validates credential issuers in the system

(define-data-var admin principal tx-sender)

;; Map to store approved identity providers
(define-map approved-providers principal bool)

;; Error codes
(define-constant err-not-admin (err u100))
(define-constant err-already-approved (err u101))
(define-constant err-not-approved (err u102))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Add a new identity provider
(define-public (add-provider (provider principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (asserts! (is-none (map-get? approved-providers provider)) err-already-approved)
    (ok (map-set approved-providers provider true))))

;; Remove an identity provider
(define-public (remove-provider (provider principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (asserts! (is-some (map-get? approved-providers provider)) err-not-approved)
    (ok (map-delete approved-providers provider))))

;; Check if a provider is approved
(define-read-only (is-approved-provider (provider principal))
  (default-to false (map-get? approved-providers provider)))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (ok (var-set admin new-admin))))

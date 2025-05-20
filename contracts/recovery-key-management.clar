;; Recovery Key Management Contract
;; Secures backup access methods for identity recovery

;; Data structures
(define-map user-recovery-keys
  principal
  {
    primary-key: (buff 33),
    backup-key: (buff 33),
    last-updated: uint
  })

;; Error codes
(define-constant err-unauthorized (err u200))
(define-constant err-no-keys-found (err u201))

;; Register recovery keys for a user
(define-public (register-keys (primary-key (buff 33)) (backup-key (buff 33)))
  (ok (map-set user-recovery-keys tx-sender
    {
      primary-key: primary-key,
      backup-key: backup-key,
      last-updated: block-height
    })))

;; Update recovery keys
(define-public (update-keys (primary-key (buff 33)) (backup-key (buff 33)))
  (begin
    (asserts! (is-some (map-get? user-recovery-keys tx-sender)) err-no-keys-found)
    (ok (map-set user-recovery-keys tx-sender
      {
        primary-key: primary-key,
        backup-key: backup-key,
        last-updated: block-height
      }))))

;; Get user's recovery keys (only accessible by the user)
(define-read-only (get-my-keys)
  (map-get? user-recovery-keys tx-sender))

;; Check if a key matches the user's primary key
(define-read-only (verify-primary-key (user principal) (key-to-check (buff 33)))
  (let ((user-keys (map-get? user-recovery-keys user)))
    (if (is-some user-keys)
      (is-eq key-to-check (get primary-key (unwrap-panic user-keys)))
      false)))

;; Check if a key matches the user's backup key
(define-read-only (verify-backup-key (user principal) (key-to-check (buff 33)))
  (let ((user-keys (map-get? user-recovery-keys user)))
    (if (is-some user-keys)
      (is-eq key-to-check (get backup-key (unwrap-panic user-keys)))
      false)))

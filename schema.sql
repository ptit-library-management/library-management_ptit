-- PTIT Library Management - reference schema
-- Target: MySQL 8.0+
-- WARNING: standalone baseline. Review/merge with teammates' ERD before running.
-- Do not run against an existing production/team database without backup.

CREATE DATABASE IF NOT EXISTS ptit_library
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE ptit_library;

CREATE TABLE IF NOT EXISTS Role (
    role_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    role_name VARCHAR(30) NOT NULL,
    PRIMARY KEY (role_id),
    CONSTRAINT uq_role_name UNIQUE (role_name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `User` (
    user_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    role_id BIGINT UNSIGNED NOT NULL,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(190) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    account_status ENUM('ACTIVE', 'LOCKED', 'DISABLED') NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    CONSTRAINT uq_user_email UNIQUE (email),
    CONSTRAINT fk_user_role FOREIGN KEY (role_id)
      REFERENCES Role(role_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_user_role_status (role_id, account_status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Book (
    book_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (book_id),
    CONSTRAINT uq_book_isbn UNIQUE (isbn),
    INDEX idx_book_title (title)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS BookCopy (
    copy_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    book_id BIGINT UNSIGNED NOT NULL,
    barcode VARCHAR(80) NOT NULL,
    copy_status ENUM('AVAILABLE', 'RESERVED', 'BORROWED', 'LOST', 'DAMAGED') NOT NULL DEFAULT 'AVAILABLE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (copy_id),
    CONSTRAINT uq_bookcopy_barcode UNIQUE (barcode),
    CONSTRAINT fk_bookcopy_book FOREIGN KEY (book_id)
      REFERENCES Book(book_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_bookcopy_book_status (book_id, copy_status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS BorrowRecord (
    borrow_record_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    reader_id BIGINT UNSIGNED NOT NULL,
    copy_id BIGINT UNSIGNED NOT NULL,
    approved_by BIGINT UNSIGNED NULL,
    requested_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approved_at DATETIME NULL,
    borrowed_at DATETIME NULL,
    due_at DATETIME NULL,
    returned_at DATETIME NULL,
    status ENUM(
      'PENDING', 'APPROVED', 'REJECTED', 'CANCELLED',
      'BORROWING', 'OVERDUE', 'RETURNED'
    ) NOT NULL DEFAULT 'PENDING',
    rejection_reason VARCHAR(500) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (borrow_record_id),
    CONSTRAINT fk_borrow_reader FOREIGN KEY (reader_id)
      REFERENCES `User`(user_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_borrow_copy FOREIGN KEY (copy_id)
      REFERENCES BookCopy(copy_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_borrow_approver FOREIGN KEY (approved_by)
      REFERENCES `User`(user_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_borrow_due_after_borrow
      CHECK (due_at IS NULL OR borrowed_at IS NULL OR due_at >= borrowed_at),
    CONSTRAINT chk_borrow_return_after_borrow
      CHECK (returned_at IS NULL OR borrowed_at IS NULL OR returned_at >= borrowed_at),
    INDEX idx_borrow_reader_status (reader_id, status),
    INDEX idx_borrow_status_due (status, due_at),
    INDEX idx_borrow_copy_status (copy_id, status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Fine (
    fine_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    borrow_record_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    reason ENUM('LATE_RETURN', 'DAMAGED_BOOK', 'LOST_BOOK', 'OTHER') NOT NULL DEFAULT 'LATE_RETURN',
    status ENUM('UNPAID', 'PAID', 'WAIVED') NOT NULL DEFAULT 'UNPAID',
    assessed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    paid_at DATETIME NULL,
    confirmed_by BIGINT UNSIGNED NULL,
    note VARCHAR(500) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (fine_id),
    CONSTRAINT uq_fine_borrow_record UNIQUE (borrow_record_id),
    CONSTRAINT fk_fine_borrow_record FOREIGN KEY (borrow_record_id)
      REFERENCES BorrowRecord(borrow_record_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_fine_confirmer FOREIGN KEY (confirmed_by)
      REFERENCES `User`(user_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_fine_amount CHECK (amount >= 0),
    CONSTRAINT chk_fine_paid_at CHECK (
      (status = 'PAID' AND paid_at IS NOT NULL) OR
      (status <> 'PAID' AND paid_at IS NULL)
    ),
    INDEX idx_fine_status_assessed (status, assessed_at)
) ENGINE=InnoDB;

-- Minimal role seed. Password hashes and user accounts must be created securely by the app.
INSERT INTO Role (role_name)
VALUES ('READER'), ('LIBRARIAN'), ('ADMIN')
ON DUPLICATE KEY UPDATE role_name = VALUES(role_name);

CREATE TABLE IF NOT EXISTS categories (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(255)
);
CREATE TABLE IF NOT EXISTS authors (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  bio TEXT
);
CREATE TABLE IF NOT EXISTS publishers (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  address VARCHAR(255)
);
CREATE TABLE IF NOT EXISTS books (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  isbn VARCHAR(20) NOT NULL UNIQUE,
  publish_year INT,
  description TEXT,
  cover_image VARCHAR(255),
  category_id BIGINT NOT NULL,
  publisher_id BIGINT NOT NULL,
  CONSTRAINT fk_books_category FOREIGN KEY (category_id) REFERENCES categories(id),
  CONSTRAINT fk_books_publisher FOREIGN KEY (publisher_id) REFERENCES publishers(id)
);
CREATE TABLE IF NOT EXISTS book_authors (
  book_id BIGINT NOT NULL,
  author_id BIGINT NOT NULL,
  PRIMARY KEY (book_id, author_id),
  CONSTRAINT fk_ba_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
  CONSTRAINT fk_ba_author FOREIGN KEY (author_id) REFERENCES authors(id)
);
CREATE TABLE IF NOT EXISTS book_copies (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  book_id BIGINT NOT NULL,
  barcode VARCHAR(50) NOT NULL UNIQUE,
  status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',
  CONSTRAINT fk_copies_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
);

-- Dữ liệu mẫu để thử form
INSERT IGNORE INTO categories (name, description) VALUES
 ('Công nghệ thông tin','Lập trình, CSDL, mạng'),('Văn học','Tiểu thuyết, truyện ngắn'),('Kinh tế','Quản trị, tài chính');
INSERT IGNORE INTO publishers (name, address) VALUES
 ('NXB Giáo dục','Hà Nội'),('NXB Trẻ','TP.HCM');
INSERT INTO authors (name, bio) SELECT 'Nguyễn Nhật Ánh','Nhà văn Việt Nam' WHERE NOT EXISTS (SELECT 1 FROM authors WHERE name='Nguyễn Nhật Ánh');
INSERT INTO authors (name, bio) SELECT 'Robert C. Martin','Tác giả Clean Code' WHERE NOT EXISTS (SELECT 1 FROM authors WHERE name='Robert C. Martin');

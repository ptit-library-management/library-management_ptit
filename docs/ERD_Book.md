# ERD – Phần Sách

```mermaid
erDiagram
    CATEGORIES ||--o{ BOOKS : "phân loại"
    PUBLISHERS ||--o{ BOOKS : "xuất bản"
    BOOKS }o--o{ AUTHORS : "book_authors"
    BOOKS ||--o{ BOOK_COPIES : "có nhiều bản"
    CATEGORIES { BIGINT id PK  VARCHAR name UK  VARCHAR description }
    AUTHORS { BIGINT id PK  VARCHAR name  TEXT bio }
    PUBLISHERS { BIGINT id PK  VARCHAR name UK  VARCHAR address }
    BOOKS {
        BIGINT id PK
        VARCHAR title
        VARCHAR isbn UK
        INT publish_year
        TEXT description
        VARCHAR cover_image
        BIGINT category_id FK
        BIGINT publisher_id FK
    }
    BOOK_COPIES {
        BIGINT id PK
        BIGINT book_id FK
        VARCHAR barcode UK
        VARCHAR status "AVAILABLE | BORROWED | LOST | DAMAGED"
    }
```

- **Book** là đầu sách (thông tin chung); **BookCopy** là từng cuốn vật lý, có mã vạch riêng.
- Số lượng còn lại của một sách = số BookCopy có `status = AVAILABLE`.
- Phần Mượn/Trả sẽ tham chiếu `book_copies.id` và đổi trạng thái AVAILABLE <-> BORROWED.

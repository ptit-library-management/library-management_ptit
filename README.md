# MySQL DDL

## Tạo schema mẫu
Mở MySQL Workbench hoặc terminal MySQL, sau đó chạy `schema.sql`.

```bash
mysql -u root -p < database/schema.sql
```

Hoặc trong MySQL Workbench: mở `schema.sql` → Execute.

## Kiểm tra
```sql
USE ptit_library;
SHOW TABLES;
DESCRIBE BorrowRecord;
DESCRIBE Fine;
```

## Cảnh báo
`schema.sql` là schema tham chiếu độc lập vì repository hiện chưa có DDL/ERD của các thành viên khác để đối chiếu. Không chạy trên database đang có dữ liệu nếu chưa backup. Nếu nhóm đã tạo `User`, `Book`, `BookCopy` bằng tên hoặc cấu trúc khác, cần hợp nhất thay vì chạy nguyên file để tránh xung đột.

# Quản lý thư viện – PTIT

Spring Boot 3 · Java 17 · Thymeleaf (MVC) · Spring Data JPA · MySQL · Spring Security

## Chạy dự án
1. Tạo database: `CREATE DATABASE library_db CHARACTER SET utf8mb4;`
2. Chạy lần lượt `sql/01_user_role.sql`, `sql/02_book.sql`
3. Copy `src/main/resources/application.properties.example` thành `application.properties`, điền mật khẩu MySQL (file này đã nằm trong .gitignore)
4. `mvn spring-boot:run` rồi mở http://localhost:8080

## Cấu trúc thư mục (MVC)
```
src/main/java/com/ptit/library/
  config/       cấu hình (SecurityConfig...)
  controller/   nhận request, trả view
  service/      xử lý nghiệp vụ
  repository/   truy vấn DB (JPA)
  model/        entity
  dto/          form/dữ liệu truyền giữa view và controller
src/main/resources/
  templates/    giao diện Thymeleaf (mỗi module 1 thư mục), fragments/ dùng chung
  static/css/   style.css dùng chung
sql/            script tạo bảng + dữ liệu mẫu (đánh số 01, 02...)
docs/           ERD, use case, đặc tả
```

## Quy ước code
- Class: PascalCase; biến/hàm: camelCase; bảng/cột DB: snake_case, tên bảng số nhiều.
- Controller không viết nghiệp vụ, nghiệp vụ nằm trong service.
- URL: `/librarian/...` cho thủ thư, `/admin/...` cho quản trị, `/` và `/books` cho độc giả.
- Mỗi trang dùng `fragments/layout` (head + nav) và `static/css/style.css`.

## Quy ước Git
- Không push thẳng vào `main`/`develop`. Nhánh: `feature/<module>-<việc>`.
- Commit: `feat(book): ...`, `fix(...)`, `docs(...)`.
- Mở Pull Request vào `develop`, ít nhất 1 bạn review trước khi merge.

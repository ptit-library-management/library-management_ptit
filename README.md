# PTIT Library Management — BorrowRecord / Fine & MySQL DDL

Phần bàn giao của Nguyễn Minh Thức:
- ERD cho `BorrowRecord` và `Fine`
- State machine cho vòng đời phiếu mượn
- MySQL DDL mẫu để nhóm tích hợp

> **Lưu ý tích hợp:** repository GitHub được kiểm tra hiện mới có `README.md`, chưa có schema hay mã nguồn để đối chiếu. Vì vậy `database/schema.sql` là schema tham chiếu độc lập, có kèm các bảng nền `User`, `Role`, `Book`, `BookCopy` để file chạy được. Trước khi merge, nhóm cần thống nhất tên bảng/cột với ERD và code của Thông/Huy; không chạy trực tiếp trên database đang có dữ liệu nếu chưa backup.

## Nội dung
- `docs/ERD_BorrowRecord_Fine.md`: ERD Mermaid, thuộc tính, quan hệ và quy tắc dữ liệu.
- `docs/StateMachine_BorrowRecord.md`: state machine Mermaid, chuyển trạng thái và điều kiện.
- `database/schema.sql`: DDL MySQL 8.0+.
- `database/README.md`: cách tạo database và kiểm tra.

## Quy ước nghiệp vụ trong bản tham chiếu
- Một `BorrowRecord` đại diện cho **một bản sao sách** được yêu cầu mượn. Nếu nhóm muốn một phiếu chứa nhiều sách, nên tách `BorrowRequest` và `BorrowRecordItem`/`BorrowDetail` thay vì ép nhiều bản sao vào một record.
- Chỉ tạo `Fine` khi phát sinh tiền phạt; một record có tối đa một khoản phạt trong mô hình hiện tại.
- `OVERDUE` được xác định khi chưa trả và `due_at < thời điểm hiện tại`. Vì trạng thái quá hạn phụ thuộc thời gian, ứng dụng cần cập nhật định kỳ hoặc tính động khi truy vấn.
- Tiền phạt là số tiền được tính lúc trả sách, không tự động cập nhật theo thời gian sau khi chốt.
- `APPROVED` là đã duyệt, `BORROWING` là đã giao sách cho độc giả; không đồng nhất hai trạng thái này.

## Công nghệ
- MySQL 8.0+
- Dùng `InnoDB`, `utf8mb4`, khóa ngoại.
- Java web/Eclipse: dùng JDBC hoặc DAO/Service của dự án để truy cập schema này.

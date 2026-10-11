package com.ptit.library.service;

import com.ptit.library.model.*;
import com.ptit.library.repository.BookCopyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class BookCopyService {
    private final BookCopyRepository copyRepo;
    private final BookService bookService;

    private BookCopy find(Long id) {
        return copyRepo.findById(id).orElseThrow(() -> new IllegalArgumentException("Không tìm thấy bản sách #" + id));
    }

    @Transactional
    public void add(Long bookId, String barcode) {
        String code = barcode == null ? "" : barcode.trim();
        if (code.isEmpty()) throw new IllegalArgumentException("Mã vạch không được để trống");
        if (copyRepo.findByBarcode(code).isPresent()) throw new IllegalArgumentException("Mã vạch đã tồn tại");
        BookCopy c = new BookCopy();
        c.setBook(bookService.findById(bookId));
        c.setBarcode(code);
        copyRepo.save(c);
    }

    /** Trả về id sách để controller redirect lại trang chi tiết */
    @Transactional
    public Long updateStatus(Long copyId, CopyStatus status) {
        BookCopy c = find(copyId);
        c.setStatus(status);
        return c.getBook().getId();
    }

    @Transactional
    public Long delete(Long copyId) {
        BookCopy c = find(copyId);
        if (c.getStatus() == CopyStatus.BORROWED) throw new IllegalStateException("Bản sách đang được mượn, không thể xoá");
        Long bookId = c.getBook().getId();
        copyRepo.delete(c);
        return bookId;
    }
}

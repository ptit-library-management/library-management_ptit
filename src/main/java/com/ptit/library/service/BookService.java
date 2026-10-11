package com.ptit.library.service;

import com.ptit.library.dto.BookForm;
import com.ptit.library.model.*;
import com.ptit.library.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.HashSet;
import java.util.List;

@Service
@RequiredArgsConstructor
public class BookService {
    private final BookRepository bookRepo;
    private final CategoryRepository categoryRepo;
    private final PublisherRepository publisherRepo;
    private final AuthorRepository authorRepo;

    public List<Book> findAll() { return bookRepo.findAll(); }

    public Book findById(Long id) {
        return bookRepo.findById(id).orElseThrow(() -> new IllegalArgumentException("Không tìm thấy sách #" + id));
    }

    public BookForm toForm(Book b) {
        BookForm f = new BookForm();
        f.setId(b.getId());
        f.setTitle(b.getTitle());
        f.setIsbn(b.getIsbn());
        f.setPublishYear(b.getPublishYear());
        f.setDescription(b.getDescription());
        f.setCategoryId(b.getCategory().getId());
        f.setPublisherId(b.getPublisher().getId());
        b.getAuthors().forEach(a -> f.getAuthorIds().add(a.getId()));
        return f;
    }

    @Transactional
    public Book save(BookForm f) {
        bookRepo.findByIsbn(f.getIsbn().trim()).ifPresent(dup -> {
            if (!dup.getId().equals(f.getId())) throw new IllegalArgumentException("ISBN đã tồn tại");
        });
        Book b = f.getId() == null ? new Book() : findById(f.getId());
        b.setTitle(f.getTitle().trim());
        b.setIsbn(f.getIsbn().trim());
        b.setPublishYear(f.getPublishYear());
        b.setDescription(f.getDescription());
        b.setCategory(categoryRepo.findById(f.getCategoryId())
                .orElseThrow(() -> new IllegalArgumentException("Thể loại không tồn tại")));
        b.setPublisher(publisherRepo.findById(f.getPublisherId())
                .orElseThrow(() -> new IllegalArgumentException("Nhà xuất bản không tồn tại")));
        b.setAuthors(new HashSet<>(authorRepo.findAllById(f.getAuthorIds())));
        return bookRepo.save(b);
    }

    @Transactional
    public void delete(Long id) {
        Book b = findById(id);
        boolean borrowing = b.getCopies().stream().anyMatch(c -> c.getStatus() == CopyStatus.BORROWED);
        if (borrowing) throw new IllegalStateException("Không thể xoá: sách đang có bản được mượn");
        bookRepo.delete(b);
    }
}

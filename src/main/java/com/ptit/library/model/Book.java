package com.ptit.library.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.util.*;

@Entity
@Table(name = "books")
@Getter @Setter
public class Book {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false, unique = true, length = 20)
    private String isbn;

    private Integer publishYear;

    @Column(columnDefinition = "TEXT")
    private String description;

    private String coverImage;

    @ManyToOne(optional = false)
    @JoinColumn(name = "category_id")
    private Category category;

    @ManyToOne(optional = false)
    @JoinColumn(name = "publisher_id")
    private Publisher publisher;

    @ManyToMany
    @JoinTable(name = "book_authors",
            joinColumns = @JoinColumn(name = "book_id"),
            inverseJoinColumns = @JoinColumn(name = "author_id"))
    private Set<Author> authors = new LinkedHashSet<>();

    @OneToMany(mappedBy = "book", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<BookCopy> copies = new ArrayList<>();

    public long getTotalCopies() {
        return copies.size();
    }

    /** Số lượng còn lại = số bản đang AVAILABLE */
    public long getAvailableCopies() {
        return copies.stream().filter(c -> c.getStatus() == CopyStatus.AVAILABLE).count();
    }
}

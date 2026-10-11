package com.ptit.library.controller;

import com.ptit.library.dto.BookForm;
import com.ptit.library.model.CopyStatus;
import com.ptit.library.repository.*;
import com.ptit.library.service.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/librarian/books")
@RequiredArgsConstructor
public class BookController {
    private final BookService bookService;
    private final BookCopyService copyService;
    private final CategoryRepository categoryRepo;
    private final PublisherRepository publisherRepo;
    private final AuthorRepository authorRepo;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("books", bookService.findAll());
        return "books/list";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model) {
        model.addAttribute("book", bookService.findById(id));
        model.addAttribute("statuses", CopyStatus.values());
        return "books/detail";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("bookForm", new BookForm());
        loadOptions(model);
        return "books/form";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model) {
        model.addAttribute("bookForm", bookService.toForm(bookService.findById(id)));
        loadOptions(model);
        return "books/form";
    }

    @PostMapping("/save")
    public String save(@Valid @ModelAttribute("bookForm") BookForm form, BindingResult result,
                       Model model, RedirectAttributes ra) {
        if (!result.hasErrors()) {
            try {
                bookService.save(form);
                ra.addFlashAttribute("message", "Đã lưu sách thành công");
                return "redirect:/librarian/books";
            } catch (IllegalArgumentException e) {
                result.rejectValue("isbn", "duplicate", e.getMessage());
            }
        }
        loadOptions(model);
        return "books/form";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id, RedirectAttributes ra) {
        try {
            bookService.delete(id);
            ra.addFlashAttribute("message", "Đã xoá sách");
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/librarian/books";
    }

    // ----- BookCopy -----
    @PostMapping("/{id}/copies")
    public String addCopy(@PathVariable Long id, @RequestParam String barcode, RedirectAttributes ra) {
        try {
            copyService.add(id, barcode);
            ra.addFlashAttribute("message", "Đã thêm bản sách");
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/librarian/books/" + id;
    }

    @PostMapping("/copies/{copyId}/status")
    public String updateStatus(@PathVariable Long copyId, @RequestParam CopyStatus status, RedirectAttributes ra) {
        Long bookId = copyService.updateStatus(copyId, status);
        ra.addFlashAttribute("message", "Đã cập nhật trạng thái");
        return "redirect:/librarian/books/" + bookId;
    }

    @PostMapping("/copies/{copyId}/delete")
    public String deleteCopy(@PathVariable Long copyId, RedirectAttributes ra) {
        try {
            Long bookId = copyService.delete(copyId);
            ra.addFlashAttribute("message", "Đã xoá bản sách");
            return "redirect:/librarian/books/" + bookId;
        } catch (RuntimeException e) {
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/librarian/books";
        }
    }

    private void loadOptions(Model model) {
        model.addAttribute("categories", categoryRepo.findAll());
        model.addAttribute("publishers", publisherRepo.findAll());
        model.addAttribute("authors", authorRepo.findAll());
    }
}

package com.ptit.library.dto;

import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.Setter;
import java.util.ArrayList;
import java.util.List;

@Getter @Setter
public class BookForm {
    private Long id;

    @NotBlank(message = "Tên sách không được để trống")
    @Size(max = 255, message = "Tên sách tối đa 255 ký tự")
    private String title;

    @NotBlank(message = "ISBN không được để trống")
    @Size(max = 20, message = "ISBN tối đa 20 ký tự")
    private String isbn;

    @Min(value = 1000, message = "Năm xuất bản không hợp lệ")
    @Max(value = 2100, message = "Năm xuất bản không hợp lệ")
    private Integer publishYear;

    private String description;

    @NotNull(message = "Vui lòng chọn thể loại")
    private Long categoryId;

    @NotNull(message = "Vui lòng chọn nhà xuất bản")
    private Long publisherId;

    @NotEmpty(message = "Chọn ít nhất 1 tác giả")
    private List<Long> authorIds = new ArrayList<>();
}

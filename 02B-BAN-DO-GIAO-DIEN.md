# Tìm file giao diện ARTIO

PHP tạo nội dung trang. CSS quy định cách hiển thị. JavaScript xử lý các thao tác và chuyển động. Giữ các nhóm này riêng, không cần nhúng tất cả vào PHP.

| Phần cần sửa | File chính |
| --- | --- |
| Thứ tự tải file, đầu trang, menu và cuối trang | `01-Source-code/includes/layout.php` |
| Giao diện nền tảng và nút dùng chung | `01-Source-code/assets/style.css` |
| Giao diện thư viện, ảnh, thẻ và các hiệu ứng chung | `01-Source-code/assets/gallery.css` |
| Các điều chỉnh giao diện bổ sung đã có | `01-Source-code/assets/site-refinements.css` — tên cũ là `feedback.css` |
| Màu nền, tiêu đề, bộ lọc và thẻ ở thư viện/bộ sưu tập | `01-Source-code/assets/resource-cards.css` |
| Giao diện trang chủ | `01-Source-code/assets/landing.css` |
| Chuyển động riêng của trang chủ | `01-Source-code/assets/landing.js` |
| Hiệu ứng xuất hiện chung và New Share | `01-Source-code/assets/gallery.js` |
| Nội dung, tên và nút trong bình luận | `01-Source-code/includes/comments.php` |
| Giao diện bình luận | `01-Source-code/assets/comments.css` |
| Gửi bình luận, đăng nhập, lưu tài nguyên | `01-Source-code/assets/app.js`, kết hợp `01-Source-code/api.php` |
| Giao diện và thao tác admin | `01-Source-code/assets/admin.css`, `admin.js` và `includes/admin-ui.php` |

## Thứ tự tải CSS

Font → `style.css` → `gallery.css` → `site-refinements.css` → `admin.css` nếu là admin, hoặc `resource-cards.css` nếu là trang người dùng → `comments.css` khi trang chi tiết yêu cầu bình luận → `landing.css` nếu là trang chủ.

Giữ thứ tự này khi sửa. File tải sau có thể thay đổi quy tắc trong file tải trước. Một số quy tắc cũ của bình luận vẫn nằm trong các file chung; đợt dọn này chưa xóa chúng để giữ nguyên cách hiển thị. Muốn chỉnh giao diện bình luận hiện tại, bắt đầu từ `comments.css`.

`artio_head()` có lựa chọn `comments: true` để tải giao diện bình luận. Trang chi tiết khóa học đã bật; trang brush bật cho tài nguyên đã xuất bản. Các trang khác không tải file này.

## Bản sao lưu trước lần dọn này

`01-Source-code/storage/backups/before-file-cleanup-20261015-193307/`

Đã sao lưu 49 file mã nguồn, kèm trang hướng dẫn cấu trúc. `backup-manifest.json` chứa danh sách và dấu kiểm tra từng file mã nguồn. Database và ảnh tải lên không nằm trong bản sao lưu này; lần dọn này không sửa chúng.

Để hoàn tác riêng lần dọn này, sao chép lại bốn file `includes/layout.php`, `course.php`, `brush-detail.php`, `assets/feedback.css` từ bản sao lưu về đúng chỗ trong `01-Source-code`. Khôi phục bản `02-CAU-TRUC-CODE.html` trong bản sao lưu về thư mục `02-Huong-dan`. Sau đó bỏ hai file mới `assets/site-refinements.css` và tài liệu `02B-BAN-DO-GIAO-DIEN.md` nếu muốn trở về nguyên trạng. Tải lại trang bằng Ctrl + F5.

Chỉ hoàn tác các file của lần dọn này. Nếu đã sửa thêm về sau, đối chiếu trước khi chép đè để tránh mất những sửa đổi mới.

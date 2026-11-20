# hopdong – STATUS (cập nhật 20/11/2026)

Web quản lý hợp đồng & nhà thầu (một file `index.html`), chạy ở https://dungnt12384-ntd.github.io/hopdong/. Dữ liệu mã hóa AES-GCM, lưu ở Google Drive người dùng. Chi tiết kiến trúc xem `CLAUDE.md`.
Repo công khai: không ghi mật khẩu, khóa, dữ liệu hợp đồng thật vào đây.

## Đang ở đâu
- Bản `main` đang chạy thật: commit 9003dca (nhập liệu đơn giản hóa).
- Đã soát xét code (20/11/2026) và **đã sửa trong thư mục làm việc, CHƯA commit, CHƯA push** (chờ chủ repo test trên `http://localhost:8765`):
  1. **SRI cho `exceljs`** (`integrity` sha384 + `crossorigin`). Mã hash tính từ chính file cdnjs 4.4.0 tại thời điểm sửa; nếu đổi phiên bản thư viện phải tính lại.
  2. **Ghi có điều kiện lên Drive**: trước khi ghi `du-lieu-hop-dong.json`, kiểm tra md5 trên Drive còn đúng bản vừa đọc (`GFile.changed`); nếu máy khác vừa ghi thì đọc lại, gộp lại rồi mới ghi. Còn khe hở rất nhỏ giữa lúc kiểm tra và lúc ghi (Drive không có ghi-có-điều-kiện thật sự cho trường hợp này).
  3. **Dọn tombstone** quá 180 ngày (`TOMB_TTL`, trong `mergeData`). Chọn 180 thay vì 90 để máy offline lâu không làm bản ghi đã xóa hiện lại.
  4. **PBKDF2 600000 vòng** cho file ghi mới; file cũ (310000 hoặc không có trường `kdf`) vẫn đọc được vì số vòng đọc theo trường `kdf` trong file. Nâng cấp tự động khi nhập mật khẩu (không áp dụng khi dùng khóa "Ghi nhớ"): lần mở khóa đầu tiên bằng mật khẩu sẽ ghi lại file với số vòng mới.
  5. **Trang kiểm thử** `test-logic.html` (gộp dữ liệu, tombstone, stamp, mã hóa, tương thích file cũ). Mở `http://localhost:8765/test-logic.html`.
- Sao lưu trước khi sửa: `D:\github\hopdong-backup\20261120-235543_sri-etag-tomb-pbkdf2-test.zip`.

## Lưu ý khi triển khai thay đổi mã hóa (mục 4)
- Sau khi bản mới được push và một máy mở khóa bằng mật khẩu, file trên Drive chuyển sang 600000 vòng. **Máy đang chạy bản web cũ (còn cache) sẽ không giải mã được** file mới và báo "Sai mật khẩu" → tải lại cứng (Ctrl+Shift+R) để lấy bản mới. `sw.js` ưu tiên mạng nên thường tự cập nhật.
- Máy đã "Ghi nhớ" khóa sẽ bị hỏi lại mật khẩu một lần sau khi file được nâng cấp.
- Các bản sao lưu cũ trong `SaoLuu/` vẫn đọc được bằng mật khẩu cũ (310000 vòng).
- Nên thử trên `localhost` (thư mục `QuanLyHopDong-Test`) trước: tạo dữ liệu thử bằng bản cũ (`git stash` hoặc checkout 9003dca), rồi mở bằng bản mới để kiểm tra nâng cấp; tuyệt đối không thử trên dữ liệu thật khi chưa có bản sao lưu.

## Việc tồn
- Chủ repo test thủ công: đăng nhập, mở khóa, sửa/xóa một bản ghi, đồng bộ giữa 2 thiết bị, đổi mật khẩu, khôi phục từ sao lưu cũ. Xem Console có lỗi không.
- Rủi ro đã biết, chưa xử lý:
  - Bản ghi gộp theo `Date.now()` của từng thiết bị: đồng hồ lệch thì "bản sửa sau thắng" có thể sai.
  - `SaoLuu/` giữ vô hạn khi `keep=0` (cân nhắc đặt mặc định giữ N bản).
  - `decText` vẫn nhận file không mã hóa (tương thích ngược); cần chắc `CR.on` luôn bật ở bản thật.
  - Token Google nằm trong `sessionStorage` (tối đa 1 giờ); CSP còn `'unsafe-inline'` cho script.
  - Không có kiểm thử cho phần giao diện/báo cáo; chỉ kiểm thử phần dữ liệu & mã hóa bằng `test-logic.html`.

## Bước tiếp
1. Chủ repo chạy `test-logic.html` và test thủ công trên `localhost:8765`.
2. Khi chủ repo báo OK: commit và hỏi lại trước khi push (`main` là bản chạy thật).
3. Sau khi push: kiểm tra trên web thật bằng máy đã có sao lưu; ghi sự cố vào file này nếu có.

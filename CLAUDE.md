# Quản lý Hợp đồng & Nhà thầu — ghi chú cho Claude

> Repo này **công khai** (GitHub Pages). Không bao giờ ghi vào đây mật khẩu, khóa bí mật, client secret hay dữ liệu hợp đồng thật.

## Đây là gì
Web app cá nhân, **một file `index.html`** (HTML + CSS + JS thuần, không build), do vợ của chủ repo dùng để quản lý hợp đồng, nhà thầu, thanh toán.
- Chạy trên GitHub Pages: `https://dungnt12384-ntd.github.io/hopdong/` (nhánh `main`, tự cập nhật 1–2 phút sau khi push).
- Dùng trên máy tính (Chrome/Edge) và điện thoại (cài PWA: `manifest.webmanifest`, `sw.js`, `icon-*.png`).
- `huong-dan-quy-trinh.html`: tài liệu hướng dẫn quy trình cho người dùng (tiếng Việt).

## Dữ liệu nằm ở đâu
- Không có máy chủ. Trình duyệt gọi thẳng Google Drive API bằng Google Identity Services (quyền `drive.file`, chỉ thấy file do chính app tạo).
- Dữ liệu ở thư mục **`QuanLyHopDong`** (gốc My Drive của tài khoản đăng nhập): `du-lieu-hop-dong.json` + thư mục `SaoLuu/` (sao lưu tự động theo lịch trong Cài đặt).
- File được **mã hóa AES-GCM 256** (khóa PBKDF2-SHA256, 310000 vòng) bằng mật khẩu người dùng đặt; quên mật khẩu = mất dữ liệu. Tuyệt đối không phá định dạng `{enc:'aes-gcm-v1',kdf,salt,iv,data}`.
- Mỗi thay đổi gọi `save()` → `syncNow()` ghi ngay lên Drive; đồng bộ lại mỗi ~20 giây và khi trang lấy lại focus.
- Khi chạy ở `localhost`/`127.0.0.1`, app tự dùng thư mục **`QuanLyHopDong-Test`** (xem `GCFG.folder`) để không đụng dữ liệu thật.
- Phiên Google giữ trong `sessionStorage` (`hd_tok`, tối đa 1 giờ) để F5 không phải đăng nhập lại; khóa mã hóa có thể "Ghi nhớ" trong IndexedDB (khóa không xuất được).
- Client ID OAuth nằm trong `GCFG` (công khai theo thiết kế). **Không dùng client secret.** Các origin được phép: `https://dungnt12384-ntd.github.io` và `http://localhost:8765`. Ứng dụng Google ở chế độ Testing, chỉ tài khoản trong danh sách Test users đăng nhập được.

## Cấu trúc code chính trong `index.html`
- Trạng thái `S` gồm `vendors, contracts, payments, log, settings, tomb`; gộp theo từng bản ghi (`mergeData`, `stamp`, `snap`, `canon`).
- Lớp `GDir`/`GFile` giả lập giao diện File System Access API bằng Drive REST, nên phần còn lại (`syncNow`, `bkWrite`, …) dùng như thư mục thường.
- Khối đăng nhập/mã hóa: `GD` (Google), `CR` (crypto), `gStart/gAfterAuth/gUnlock/gFinish/lockApp/gSignOut`, `encText/decText`.
- Có CSP trong thẻ `<meta>` ở đầu file; thêm nguồn ngoài thì phải cập nhật CSP.
- Tự khóa sau 15 phút không thao tác (trừ máy đã chọn "Ghi nhớ").

## Cách chạy thử (bắt buộc trước khi push)
Chạy trong thư mục repo, rồi mở `http://localhost:8765`:
- Windows: `powershell -ExecutionPolicy Bypass -File chay-thu.ps1` (dừng bằng Ctrl+C hoặc đóng cửa sổ)
- Mac: `python3 -m http.server 8765 --bind 127.0.0.1`

Phải chạy lệnh **trong thư mục repo**, nếu không server sẽ phục vụ nhầm thư mục khác. Sau khi sửa, nhấn Ctrl+Shift+R để tránh bản cache cũ. Không có Node, không có bộ test tự động: kiểm tra bằng trình duyệt và xem Console có lỗi không.

## Quy trình làm việc
1. Pull trước khi sửa (mỗi máy có một bản clone riêng: máy bàn `D:\github\hopdong`, MacBook `~/Documents/GitHub/hopdong`; **không** đặt repo trong Google Drive/OneDrive).
2. Sửa code web → chủ repo **tự test trên `http://localhost:8765`** → khi chủ repo báo OK thì mới commit/push. Claude không tự push khi chưa được nói.
3. **Luôn hỏi chủ repo trước khi push** (kể cả khi chạy `sync-git`), vì `main` là bản chạy thật của người dùng. Với thay đổi lớn nên dùng nhánh riêng + Pull Request. Không `push --force`, không xóa nhánh.
4. **Bản git chính thức duy nhất trên máy bàn công ty: `D:\github\hopdong`.** Mọi sửa đổi/commit/push làm ở đây. Không dùng `.git` trong `G:\My Drive\QuanLyHopDong`. Đồng bộ với MacBook (push lên/pull xuống) chỉ khi chủ repo nói.
5. Windows: git của GitHub Desktop nằm ở `%LOCALAPPDATA%\GitHubDesktop\app-*\resources\app\git\cmd\git.exe` (git chưa có trong PATH).

## Quy ước
- Giao tiếp và giao diện bằng **tiếng Việt**. Giữ nguyên phong cách code gọn, một file.
- Không đưa vào repo: `client_secret*`, `*.key`, `*.pem`, `.env`, `du-lieu-hop-dong*.json`, `SaoLuu/` (đã có trong `.gitignore`).
- Không thay đổi định dạng dữ liệu hay mã hóa theo cách làm hỏng khả năng đọc dữ liệu hiện có; nếu cần đổi, phải có đường nâng cấp và sao lưu trước.
- **MỌI lệnh shell phải chạy trong cửa sổ Terminal của app** (`run_in_terminal`) để chủ repo nhìn thấy và kiểm soát: git (kể cả `status`, `log`, `stash`), xóa/di chuyển file, chạy script, test. **CẤM tự chạy ngầm bất kỳ lệnh nào bằng công cụ Bash/PowerShell, không có ngoại lệ** (kể cả lệnh "ngắn" hay chỉ để đọc); mọi lệnh phải hiện trên Terminal để chủ repo kiểm soát. Sau khi chạy phải mở/chỉ cho chủ repo thấy tab Terminal (panel không tự mở). Lệnh xóa hoặc phá hủy thì còn phải hỏi trước. Lệnh phải 1 dòng; việc phức tạp thì viết vào file script rồi chạy file đó. Dùng lại cùng một tab, đọc kết quả bằng `read_terminal` rồi báo cáo. Không cần chủ repo nhắc lại.
- **Backup trước mỗi việc sửa đổi** để rollback khi lỗi: trước khi sửa bất kỳ file nào, chạy trong Terminal `powershell -ExecutionPolicy Bypass -File .\backup-truoc-sua.ps1 -Note "mo-ta-ngan"` → tạo zip ở `D:\github\hopdong-backup\` (ngoài repo, không bị push, giữ 30 bản mới nhất). Khi lỗi: giải nén zip đè lại repo hoặc dùng `git checkout`/`git restore`. Không cần chủ repo nhắc lại.
- Đồng bộ git: `sync-git.bat` (hoặc `powershell -ExecutionPolicy Bypass -File .\sync-git.ps1 [-Message "..."]`) = commit → pull --rebase → push. Vì script có push nên vẫn phải được chủ repo đồng ý trước khi chạy (xem Quy trình mục 3).
- Hạn chế đã biết: đính kèm tài liệu/xuất Excel vào thư mục máy chỉ có trên Chrome/Edge máy tính; không dùng offline cho dữ liệu; mỗi phiên mới cần một lần bấm đăng nhập Google sau khi hết 1 giờ hoặc đóng tab.

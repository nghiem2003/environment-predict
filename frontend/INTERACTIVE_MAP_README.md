# Interactive Map Component - Bản đồ dự báo

## Tổng quan
Component `InteractiveMap` là một bản đồ dự báo tương tác hiển thị dự báo mới nhất của các khu vực. Component này cung cấp giao diện bản đồ với sidebar để chọn vùng, hiển thị vòng tròn khoanh vùng theo kết quả dự báo, và các tính năng tương tác đầy đủ.

## Tính năng chính

### 1. Bản đồ dự báo tương tác
- **Bản đồ Leaflet**: Sử dụng React Leaflet để hiển thị bản đồ OpenStreetMap
- **Zoom in/out**: Có thể phóng to/thu nhỏ bản đồ bằng chuột hoặc nút điều khiển
- **Di chuyển bản đồ**: Có thể kéo thả để di chuyển bản đồ
- **Vòng tròn dự báo**: Hiển thị vòng tròn khoanh vùng với màu sắc theo kết quả dự báo:
  - 🟢 Xanh lá: Dự báo tốt (result = 1)
  - 🟡 Vàng: Dự báo trung bình (result = 0)
  - 🔴 Đỏ: Dự báo kém (result = -1)
  - 🔵 Xanh dương: Chưa có dự báo (result = -2)
- **Markers tùy chỉnh**: Hiển thị các vùng với markers có màu sắc khác nhau theo loại (Oyster: xanh dương, Cobia: xanh lá)

### 2. Thanh tìm kiếm nổi
- **Giao diện nổi**: Thanh tìm kiếm nổi bên trên bản đồ với hiệu ứng trong suốt
- **Tìm kiếm**: Tìm kiếm vùng theo tên
- **Lọc theo loại**: Lọc vùng theo loại (Oyster/Cobia)
- **Lọc theo địa điểm**: Lọc theo tỉnh/thành phố và quận/huyện
- **Hiển thị số lượng**: Hiển thị số lượng khu vực được lọc
- **Responsive**: Tự động điều chỉnh layout trên mobile

### 3. Markers và vòng tròn trên bản đồ
- **Vòng tròn dự báo**: Mỗi vùng được khoanh tròn với màu sắc theo kết quả dự báo
- **Markers tương tác**: Click vào marker hoặc vòng tròn để xem thông tin chi tiết vùng
- **Popup thông tin**: Hiển thị thông tin vùng và dự báo khi click vào marker
- **Tự động zoom**: Tự động phóng to khi chọn vùng từ sidebar hoặc click marker
- **Màu sắc phân biệt**: Markers có màu khác nhau cho từng loại vùng

### 4. Giao diện fullscreen
- **Bản đồ toàn màn hình**: Bản đồ chiếm toàn bộ màn hình để tối ưu trải nghiệm
- **Không sidebar**: Loại bỏ sidebar để tập trung vào bản đồ
- **Thanh tìm kiếm nổi**: Thanh tìm kiếm nổi bên trên với hiệu ứng trong suốt
- **Responsive design**: Tự động điều chỉnh trên các thiết bị khác nhau

## Cách sử dụng

### 1. Truy cập component
- **Truy cập công khai**: Không cần đăng nhập, bất kỳ ai cũng có thể xem
- **Từ trang chủ**: Tự động chuyển hướng đến bản đồ dự báo khi chưa đăng nhập
- **Từ menu**: Chọn "Bản đồ dự báo" từ menu sidebar (hiển thị cho tất cả người dùng)
- **Truy cập trực tiếp**: Vào `/interactive-map`

### 2. Điều hướng bản đồ
- **Chọn vùng từ bản đồ**: Click vào marker hoặc vòng tròn trên bản đồ
- **Zoom**: Sử dụng chuột giữa hoặc nút +/- trên bản đồ
- **Di chuyển**: Kéo thả bản đồ để di chuyển
- **Xem dự báo**: Vòng tròn màu sắc cho biết kết quả dự báo của vùng
- **Tìm kiếm**: Sử dụng thanh tìm kiếm nổi bên trên để lọc vùng

### 3. Tìm kiếm và lọc
- **Tìm kiếm**: Nhập tên vùng vào ô tìm kiếm
- **Lọc loại**: Chọn "Oyster" hoặc "Cobia" từ dropdown
- **Lọc địa điểm**: Chọn tỉnh/thành phố và quận/huyện

## Cấu trúc file

```
frontend/src/components/
├── InteractiveMap.jsx      # Component chính
├── InteractiveMap.css      # Styles cho component
└── MapView.jsx            # Component cũ (được giữ lại)
```

## Dependencies

Component sử dụng các thư viện sau:
- `react-leaflet`: Bản đồ Leaflet cho React
- `leaflet`: Thư viện bản đồ chính
- `antd`: UI components
- `axios`: HTTP client
- `react-redux`: State management
- `react-i18next`: Internationalization

## API Integration

Component tích hợp với các API sau:
- `GET /api/express/areas`: Lấy danh sách vùng
- `GET /api/express/areas/provinces`: Lấy danh sách tỉnh/thành phố
- `GET /api/express/areas/districts`: Lấy danh sách quận/huyện

## Responsive Design

Component được thiết kế responsive:
- **Desktop**: Sidebar bên trái, bản đồ bên phải
- **Tablet**: Layout tương tự desktop nhưng sidebar nhỏ hơn
- **Mobile**: Sidebar ở trên, bản đồ ở dưới

## Customization

### Thay đổi màu markers
```css
.area-marker-icon.oyster {
  background-color: #1890ff; /* Màu cho Oyster */
}

.area-marker-icon.cobia {
  background-color: #52c41a; /* Màu cho Cobia */
}
```

### Thay đổi kích thước sidebar
```css
.map-sidebar {
  width: 350px; /* Điều chỉnh độ rộng sidebar */
}
```

## Troubleshooting

### Lỗi markers không hiển thị
- Kiểm tra xem đã import CSS của Leaflet chưa
- Kiểm tra logger để xem có lỗi JavaScript nào không

### Lỗi không load được dữ liệu vùng
- Kiểm tra kết nối API
- Kiểm tra quyền truy cập của user
- Kiểm tra token authentication

### Lỗi bản đồ không hiển thị
- Kiểm tra kết nối internet
- Kiểm tra xem có bị chặn bởi firewall không
- Thử refresh trang

## Future Enhancements

Các tính năng có thể được thêm vào trong tương lai:
- Cluster markers khi zoom out
- Heatmap overlay
- Drawing tools để vẽ vùng mới
- Export bản đồ thành hình ảnh
- Tích hợp với dữ liệu thời tiết
- Animation khi di chuyển giữa các vùng

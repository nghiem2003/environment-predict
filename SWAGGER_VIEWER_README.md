# Swagger API Documentation Viewer

## Tổng quan

Dự án này đã được tích hợp với một hệ thống xem tài liệu API Swagger hoàn chỉnh, bao gồm:

1. **Backend API Endpoint**: `/api/express/swagger` - Trả về dữ liệu Swagger JSON
2. **Frontend Component**: SwaggerViewer - Hiển thị tài liệu API với giao diện đẹp mắt

## Tính năng

### Backend (Express.js)
- **Endpoint**: `GET /api/express/swagger`
- **Response**: JSON chứa toàn bộ thông tin Swagger API specification
- **Authentication**: Không yêu cầu (public endpoint)
- **Error Handling**: Xử lý lỗi và trả về response phù hợp

### Frontend (React + Ant Design)
- **Route**: `/swagger`
- **Design**: Tông màu xanh dương (#007bff) và trắng, không gradient
- **Responsive**: Tương thích với mọi kích thước màn hình
- **Tabs**: 
  - Tổng quan: Thông tin API, servers, security schemes, tags
  - Data Schemas: Bảng hiển thị các schema với chi tiết properties
  - Raw JSON: Hiển thị dữ liệu JSON gốc

## Cách sử dụng

### 1. Chạy Backend
```bash
cd backend-express
npm start
```

### 2. Chạy Frontend
```bash
cd frontend
npm run dev
```

### 3. Truy cập Swagger Viewer
- Mở trình duyệt và truy cập: `http://localhost:3000/swagger`
- Hoặc click vào menu "API Documentation" trong sidebar

## Cấu trúc API Response

```json
{
  "success": true,
  "data": {
    "openapi": "3.0.0",
    "info": {
      "title": "Aquaculture Prediction System API",
      "version": "1.0.0",
      "description": "API documentation for the Aquaculture Prediction System"
    },
    "servers": [...],
    "components": {
      "schemas": {...},
      "securitySchemes": {...}
    },
    "tags": [...]
  },
  "message": "Swagger API documentation retrieved successfully"
}
```

## Tính năng UI

### 1. Tổng quan
- **Header Card**: Hiển thị thông tin API với gradient xanh dương
- **Statistics**: Số lượng servers, tags, schemas
- **Server List**: Danh sách các server có sẵn
- **Security Schemes**: Các phương thức bảo mật
- **Tags**: Các nhóm API endpoints

### 2. Data Schemas
- **Table View**: Hiển thị danh sách schemas
- **Expandable Rows**: Chi tiết properties của từng schema
- **Property Details**: Type, description, required fields, enum values
- **Pagination**: Phân trang cho danh sách dài

### 3. Raw JSON
- **Code View**: Hiển thị JSON với syntax highlighting
- **Scrollable**: Có thể cuộn để xem toàn bộ dữ liệu
- **Copy-friendly**: Dễ dàng copy dữ liệu

## Customization

### Thay đổi màu sắc
Trong file `SwaggerViewer.jsx`, bạn có thể thay đổi màu sắc:

```jsx
// Màu chính
const primaryColor = '#007bff';

// Màu nền
const backgroundColor = '#f5f5f5';

// Màu card
const cardBackground = '#fff';
```

### Thay đổi API endpoint
Trong file `SwaggerViewer.jsx`:

```jsx
const response = await axios.get('http://localhost:5000/api/express/swagger');
```

## Lỗi thường gặp

### 1. CORS Error
- Đảm bảo backend đã cấu hình CORS
- Kiểm tra URL API endpoint

### 2. Network Error
- Kiểm tra backend có đang chạy không
- Kiểm tra port 5000 có bị chiếm dụng không

### 3. Data không hiển thị
- Kiểm tra response từ API
- Kiểm tra logger để xem lỗi

## Dependencies

### Backend
- `express`
- `swagger-jsdoc`
- `swagger-ui-express`

### Frontend
- `react`
- `antd`
- `axios`
- `@ant-design/icons`

## Tác giả

Hệ thống Swagger Viewer được phát triển cho dự án Aquaculture Prediction System.

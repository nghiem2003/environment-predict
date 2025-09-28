# Natural Elements Management

## Tổng quan
Hệ thống quản lý Natural Elements đã được cập nhật để bao gồm thông tin chi tiết về mô tả, đơn vị đo và phân loại cho từng chỉ số môi trường.

## Các Natural Elements được hỗ trợ

### 1. Nutrients (Dinh dưỡng)
- **R_PO4**: Reactive Phosphorus - Phospho phản ứng (mg/L)

### 2. Water Quality (Chất lượng nước)
- **O2Sat**: Oxygen Saturation - Độ bão hòa oxy (%)
- **O2ml_L**: Oxygen Concentration - Nồng độ oxy hòa tan (ml/L)

### 3. Physical Properties (Tính chất vật lý)
- **STheta**: Potential Temperature - Nhiệt độ tiềm năng (°C)
- **Salnty**: Salinity - Độ mặn (PSU)
- **R_DYNHT**: Dynamic Height - Chiều cao động lực (m)
- **T_degC**: Temperature - Nhiệt độ nước (°C)
- **R_Depth**: Depth - Độ sâu (m)

### 4. Location (Vị trí)
- **Distance**: Distance from Shore - Khoảng cách từ bờ biển (km)

### 5. Atmospheric (Khí quyển)
- **Wind_Spd**: Wind Speed - Tốc độ gió (m/s)
- **Wave_Ht**: Wave Height - Chiều cao sóng (m)
- **Wave_Prd**: Wave Period - Chu kỳ sóng (s)
- **Dry_T**: Dry Temperature - Nhiệt độ khô (°C)

### 6. Biological (Sinh học)
- **IntChl**: Integrated Chlorophyll - Chlorophyll tích hợp (mg/m²)

## Cài đặt và Chạy

### 1. Chạy Migration và Cập nhật dữ liệu
```bash
cd backend-express
node scripts/run_migration_and_update.js
```

### 2. Chạy Migration riêng lẻ
```bash
npx sequelize-cli db:migrate
```

### 3. Chạy Script cập nhật dữ liệu riêng lẻ
```bash
node scripts/update_natural_elements.js
```

## API Endpoints

### 1. Lấy danh sách Natural Elements
**GET** `/api/express/nature-elements`

**Query Parameters:**
- `category`: Lọc theo category
- `search`: Tìm kiếm theo tên hoặc mô tả
- `limit`: Giới hạn số lượng
- `offset`: Bỏ qua số lượng

**Ví dụ:**
```bash
GET /api/express/nature-elements?category=Water Quality&search=oxygen
```

**Response:**
```json
{
  "success": true,
  "data": {
    "elements": [
      {
        "id": 9,
        "name": "O2Sat",
        "description": "Oxygen Saturation - Độ bão hòa oxy trong nước",
        "unit": "%",
        "category": "Water Quality"
      }
    ],
    "total": 1,
    "categories": ["Water Quality", "Physical Properties", "Nutrients"]
  }
}
```

### 2. Lấy Natural Element theo ID
**GET** `/api/express/nature-elements/:id`

### 3. Lấy danh sách Categories
**GET** `/api/express/nature-elements/categories`

### 4. Lấy Natural Elements theo Category
**GET** `/api/express/nature-elements/category/:category`

### 5. Tạo Natural Element mới (Admin only)
**POST** `/api/express/nature-elements`

**Body:**
```json
{
  "name": "NewElement",
  "description": "Mô tả element mới",
  "unit": "unit",
  "category": "Category"
}
```

### 6. Cập nhật Natural Element (Admin only)
**PUT** `/api/express/nature-elements/:id`

### 7. Xóa Natural Element (Admin only)
**DELETE** `/api/express/nature-elements/:id`

### 8. Bulk Update (Admin only)
**POST** `/api/express/nature-elements/bulk-update`

**Body:**
```json
{
  "elements": [
    {
      "name": "Element1",
      "description": "Description 1",
      "unit": "unit1",
      "category": "Category1"
    }
  ]
}
```

## Chart API đã được cập nhật

Chart API hiện đã bao gồm thông tin description, unit và category:

### GET `/api/express/predictions/chart/data`
**Response mẫu:**
```json
{
  "success": true,
  "data": {
    "predictions": [...],
    "summary": {
      "indicators": [
        {
          "id": 9,
          "name": "O2Sat",
          "description": "Oxygen Saturation - Độ bão hòa oxy trong nước",
          "unit": "%",
          "category": "Water Quality"
        }
      ]
    }
  }
}
```

## Cấu trúc Database

### Bảng `diagnose_naturalelements`
```sql
CREATE TABLE diagnose_naturalelements (
    id INTEGER PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    unit VARCHAR(255),
    category VARCHAR(255)
);
```

## Sử dụng trong Frontend

### 1. Hiển thị danh sách Natural Elements
```javascript
const response = await fetch('/api/express/nature-elements');
const data = await response.json();

data.data.elements.forEach(element => {
  console.log(`${element.name}: ${element.description} (${element.unit})`);
});
```

### 2. Lọc theo category
```javascript
const response = await fetch('/api/express/nature-elements?category=Water Quality');
const data = await response.json();
```

### 3. Sử dụng trong Chart
```javascript
const response = await fetch('/api/express/predictions/chart/data?areaId=1');
const data = await response.json();

// Hiển thị thông tin chi tiết cho mỗi indicator
data.data.summary.indicators.forEach(indicator => {
  console.log(`${indicator.name}: ${indicator.description} (${indicator.unit})`);
});
```

## Lưu ý

1. **Migration**: Chạy migration trước khi cập nhật dữ liệu
2. **Permissions**: Một số API endpoints yêu cầu authentication và admin role
3. **Data Integrity**: Script cập nhật sẽ không ghi đè dữ liệu hiện có, chỉ thêm thông tin mới
4. **Categories**: Các categories được định nghĩa sẵn: Nutrients, Water Quality, Physical Properties, Location, Atmospheric, Biological

## Troubleshooting

### Lỗi Migration
```bash
# Reset migration nếu cần
npx sequelize-cli db:migrate:undo
npx sequelize-cli db:migrate
```

### Lỗi Script
```bash
# Kiểm tra kết nối database
node testConnection.js
```

### Lỗi API
- Kiểm tra server đang chạy
- Kiểm tra authentication token
- Kiểm tra permissions (admin role cho các API chỉnh sửa)

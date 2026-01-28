# Setup Dual Flask Services

## Tổng quan

Hệ thống có 2 Flask services:
- **Flask Primary (port 5001)**: Python 3.10, XGBoost 1.7.6, load models từ `model/` và `shared_models/`
- **Flask Secondary (port 5002)**: Python 3.12, XGBoost >= 2.0.0, load models từ `model_v2/` và `shared_models_v2/`

Khi Flask Primary không tìm thấy model → tự động forward request sang Flask Secondary.

## Cấu trúc thư mục

```
backend-flask/
├── model/              # Models cũ (Python 3.10, XGBoost 1.7.6)
├── shared_models/      # Models cũ từ Express upload
├── model_v2/           # Models mới (Python 3.12, XGBoost >= 2.0.0)
├── shared_models_v2/   # Models mới từ Express upload
├── config.py           # Config cho Flask Primary
├── config_v2.py        # Config cho Flask Secondary
├── run.py              # Flask Primary
├── run_v2.py           # Flask Secondary
├── requirements.txt    # Dependencies cho Primary (Python 3.10)
├── requirements_v2.txt # Dependencies cho Secondary (Python 3.12)
├── Dockerfile          # Docker cho Primary
└── Dockerfile.v2       # Docker cho Secondary
```

## Setup Local Development

### 1. Tạo thư mục cho models mới

```bash
cd backend-flask
mkdir -p model_v2
mkdir -p shared_models_v2
```

### 2. Setup Flask Secondary (Python 3.12)

```bash
# Tạo virtual environment với Python 3.12
python3.12 -m venv venv_v2
source venv_v2/bin/activate  # Linux/Mac
# hoặc
venv_v2\Scripts\activate  # Windows

# Install dependencies với Python 3.12
pip install --upgrade pip
pip install -r requirements_v2.txt
```

### 3. Chạy Flask Secondary

```bash
# Trong venv_v2
python run_v2.py
```

Service sẽ chạy trên port 5002 và load models từ `model_v2/` và `shared_models_v2/`.

### 4. Chạy Flask Primary (như bình thường)

```bash
# Trong venv gốc (Python 3.10)
python run.py
```

Service sẽ chạy trên port 5001 và load models từ `model/` và `shared_models/`.

## Setup với Docker

### 1. Build và chạy Flask Secondary

```bash
cd backend-flask

# Build image
docker build -f Dockerfile.v2 -t flask-backend-v2 .

# Chạy container
docker run -d \
  --name flask_backend_v2 \
  -p 5002:5002 \
  -v $(pwd)/shared_models_v2:/app/shared_models_v2 \
  -v $(pwd)/model_v2:/app/model_v2 \
  -v $(pwd)/data:/app/data \
  flask-backend-v2
```

### 2. Hoặc dùng docker-compose

```bash
# Chạy cả 2 services
docker-compose -f docker-compose.v2.yml up -d

# Xem logs
docker-compose -f docker-compose.v2.yml logs -f flask_backend_v2
```

### 3. Chạy cả 2 services cùng lúc

Tạo file `docker-compose.dual.yml`:

```yaml
version: '3.8'

services:
  flask_backend:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "5001:5001"
    volumes:
      - ./shared_models:/app/shared_models
      - ./model:/app/model
      - ./data:/app/data
    networks:
      - app_network

  flask_backend_v2:
    build:
      context: .
      dockerfile: Dockerfile.v2
    ports:
      - "5002:5002"
    volumes:
      - ./shared_models_v2:/app/shared_models_v2
      - ./model_v2:/app/model_v2
      - ./data:/app/data
    networks:
      - app_network

networks:
  app_network:
    driver: bridge
```

Chạy:
```bash
docker-compose -f docker-compose.dual.yml up -d
```

## Cấu hình Forwarding

File `service_config.json`:

```json
{
  "secondary_service": {
    "port": 5002,
    "url": "http://localhost:5002",
    "enabled": true
  }
}
```

Trong Docker, nếu cả 2 services cùng network, dùng service name:
```json
{
  "secondary_service": {
    "port": 5002,
    "url": "http://flask_backend_v2:5002",
    "enabled": true
  }
}
```

## Flow hoạt động

1. **Express** gọi Flask Primary (port 5001)
2. **Flask Primary** tìm model trong `model/` và `shared_models/`
3. Nếu **tìm thấy** → xử lý bình thường
4. Nếu **không tìm thấy** → forward request sang Flask Secondary (port 5002)
5. **Flask Secondary** tìm model trong `model_v2/` và `shared_models_v2/`
6. Trả về kết quả

## Upload models mới

Khi upload model mới qua Express:
- Model cũ (Python 3.10, XGBoost 1.7.6) → lưu vào `shared_models/` → Flask Primary load
- Model mới (Python 3.12, XGBoost >= 2.0.0) → lưu vào `shared_models_v2/` → Flask Secondary load

## Testing

1. Test Flask Primary:
```bash
curl -X POST http://localhost:5001/predict/cobia \
  -H "Content-Type: application/json" \
  -d '{"model": "cobia_ridge", ...}'
```

2. Test Flask Secondary:
```bash
curl -X POST http://localhost:5002/predict/cobia \
  -H "Content-Type: application/json" \
  -d '{"model": "cobia_xgboost_v2", ...}'
```

3. Test forwarding:
- Gọi model không có trong Primary → sẽ tự động forward sang Secondary

## Kiểm tra Python version

```bash
# Flask Primary
docker exec flask_backend python --version  # Python 3.10.x

# Flask Secondary
docker exec flask_backend_v2 python --version  # Python 3.12.x
```

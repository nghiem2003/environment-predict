# CI/CD Pipeline Documentation

Hệ thống CI/CD được tách riêng cho Frontend và Backend, tự động deploy khi có thay đổi code.

## Cấu trúc

### GitHub Actions
- `.github/workflows/backend-cicd.yml` - Pipeline cho Backend (Express + Flask)
- `.github/workflows/frontend-cicd.yml` - Pipeline cho Frontend (React)

### GitLab CI
- `.gitlab-ci.yml` - Pipeline cho cả Frontend và Backend (tự động chạy dựa trên thay đổi)

## Cách hoạt động

### Backend CI/CD
**Trigger khi:**
- Push code vào `backend-express/` hoặc `backend-flask/`
- Thay đổi `docker-compose.yaml`
- Push vào branch `main` hoặc `develop`

**Quy trình:**
1. Checkout code
2. Setup Docker Buildx
3. Configure SSH
4. Sync files lên server (rsync)
5. Clean old containers và images
6. Deploy với Docker Compose (chỉ rebuild express_backend, flask_backend, postgres_db)
7. Health check

### Frontend CI/CD
**Trigger khi:**
- Push code vào `frontend/`
- Thay đổi `docker-compose.yaml`
- Push vào branch `main` hoặc `develop`

**Quy trình:**
1. Checkout code
2. Setup Docker Buildx
3. Configure SSH
4. Sync files lên server (rsync)
5. Clean old containers và images
6. Deploy với Docker Compose (chỉ rebuild frontend)
7. Health check

## Cấu hình Secrets

### GitHub Actions
Cần cấu hình các secrets sau trong GitHub repository settings:

1. **SSH_PRIVATE_KEY**: Private key SSH để kết nối server
2. **SERVER_HOST**: Địa chỉ IP hoặc domain của server (ví dụ: `14.253.124.159`)
3. **SERVER_USER**: Username SSH (ví dụ: `tbu`)
4. **SERVER_PATH**: Đường dẫn trên server (ví dụ: `/home/tbu/complete`)

**Cách thêm secrets:**
1. Vào repository → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Thêm từng secret như trên

### GitLab CI
Cần cấu hình các variables sau trong GitLab project settings:

1. **SSH_PRIVATE_KEY**: Private key SSH để kết nối server
2. **SERVER_HOST**: Địa chỉ IP hoặc domain của server
3. **SERVER_USER**: Username SSH
4. **SERVER_PATH**: Đường dẫn trên server

**Cách thêm variables:**
1. Vào project → Settings → CI/CD → Variables
2. Click "Add variable"
3. Thêm từng variable như trên (đánh dấu "Masked" cho SSH_PRIVATE_KEY)

## Tạo SSH Key

Nếu chưa có SSH key:

```bash
# Tạo SSH key pair
ssh-keygen -t rsa -b 4096 -C "ci-cd@yourproject"

# Copy public key lên server
ssh-copy-id -i ~/.ssh/id_rsa.pub user@server

# Copy private key để thêm vào secrets/variables
cat ~/.ssh/id_rsa
```

## Test CI/CD

### Test Backend
```bash
# Tạo một thay đổi nhỏ trong backend
echo "# Test" >> backend-express/README.md
git add backend-express/README.md
git commit -m "test: trigger backend CI/CD"
git push origin main
```

### Test Frontend
```bash
# Tạo một thay đổi nhỏ trong frontend
echo "# Test" >> frontend/README.md
git add frontend/README.md
git commit -m "test: trigger frontend CI/CD"
git push origin main
```

## Lưu ý

1. **Database**: Pipeline backend sẽ không xóa volume `postgres_db` để tránh mất dữ liệu
2. **Environment variables**: Đảm bảo file `.env` hoặc environment variables đã được cấu hình trên server
3. **Docker Compose**: Pipeline sẽ chỉ rebuild các service liên quan, không rebuild toàn bộ
4. **Health check**: Sau khi deploy, pipeline sẽ đợi 10 giây rồi kiểm tra trạng thái containers

## Troubleshooting

### Lỗi SSH connection
- Kiểm tra SSH_PRIVATE_KEY đã được thêm đúng chưa
- Kiểm tra server có cho phép SSH connection không
- Kiểm tra SERVER_HOST, SERVER_USER, SERVER_PATH đã đúng chưa

### Lỗi Docker
- Kiểm tra Docker đã được cài đặt trên server chưa
- Kiểm tra user có quyền chạy `sudo docker` không
- Kiểm tra docker-compose.yaml có đúng cấu trúc không

### Lỗi rsync
- Kiểm tra đường dẫn SERVER_PATH có tồn tại không
- Kiểm tra quyền ghi vào SERVER_PATH
- Kiểm tra disk space trên server

## Manual Deployment

Nếu cần deploy thủ công, có thể chạy script gốc:

```bash
# Bước 1: Sync files
rsync -avz --progress \
  --exclude='node_modules/' \
  --exclude='.vscode/' \
  --exclude='.git/' \
  --exclude='.gitignore' \
  --exclude='backend-flask/data/' \
  --exclude='backend-flask/venv/' \
  --exclude='backend-flask/model/' \
  --exclude='backend-flask/copernicus_temp_data/' \
  --exclude='backend-flask/export_full_raw.csv' \
  --exclude='backend-flask/notebook.ipynb' \
  --exclude='backend-flask/prediction_module/__pycache__/' \
  --exclude='backend-flask/__pycache__/' \
  --exclude='*.log' \
  --exclude='.env*' \
  --exclude='dist/' \
  --exclude='build/' \
  ./ user@server:/path/to/complete/

# Bước 2: Clean old containers
ssh user@server
sudo docker ps -a --filter "name=express_backend" --format "{{.Names}}" | xargs -r sudo docker stop
sudo docker ps -a --filter "name=express_backend" --format "{{.Names}}" | xargs -r sudo docker rm
# Tương tự cho flask_backend và frontend

# Bước 3: Deploy
cd /path/to/complete/
sudo docker compose up -d --build
```


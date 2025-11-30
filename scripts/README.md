# Deployment Scripts

Các script deployment được tách riêng cho từng service để dễ quản lý và deploy độc lập.

## Cấu trúc Scripts

- `deploy-backend.sh` - Deploy Backend (Express + Flask)
- `deploy-frontend.sh` - Deploy Frontend (React)
- `deploy-all.sh` - Deploy tất cả services
- `clean-docker.sh` - Cleanup Docker containers và images

## Cấu hình

Các script sử dụng environment variables để cấu hình:

```bash
export SERVER_USER=tbu
export SERVER_HOST=14.253.124.159
export SERVER_PATH=/home/tbu/complete
```

Hoặc có thể set trực tiếp khi chạy:

```bash
SERVER_USER=tbu SERVER_HOST=14.253.124.159 ./scripts/deploy-backend.sh
```

## Sử dụng

### 1. Deploy Backend (Express + Flask)

```bash
# Cấp quyền thực thi
chmod +x scripts/deploy-backend.sh

# Chạy script
./scripts/deploy-backend.sh
```

**Quy trình:**
1. Sync files lên server (exclude frontend)
2. Clean old backend containers và images
3. Deploy với Docker Compose (express_backend, flask_backend, postgres_db)
4. Health check

### 2. Deploy Frontend (React)

```bash
# Cấp quyền thực thi
chmod +x scripts/deploy-frontend.sh

# Chạy script
./scripts/deploy-frontend.sh
```

**Quy trình:**
1. Sync files lên server (exclude backend-express, backend-flask)
2. Clean old frontend containers và images
3. Deploy với Docker Compose (frontend)
4. Health check

### 3. Deploy Tất cả Services

```bash
# Cấp quyền thực thi
chmod +x scripts/deploy-all.sh

# Chạy script
./scripts/deploy-all.sh
```

**Quy trình:**
1. Sync tất cả files lên server
2. Clean tất cả old containers và images
3. Deploy tất cả services với Docker Compose
4. Health check

### 4. Clean Docker

```bash
# Cấp quyền thực thi
chmod +x scripts/clean-docker.sh

# Clean tất cả
./scripts/clean-docker.sh

# Clean chỉ backend
./scripts/clean-docker.sh backend

# Clean chỉ frontend
./scripts/clean-docker.sh frontend
```

## Ví dụ sử dụng

### Deploy chỉ backend khi có thay đổi backend code

```bash
# Chỉnh sửa code trong backend-express hoặc backend-flask
# ...

# Deploy
./scripts/deploy-backend.sh
```

### Deploy chỉ frontend khi có thay đổi frontend code

```bash
# Chỉnh sửa code trong frontend
# ...

# Deploy
./scripts/deploy-frontend.sh
```

### Clean và deploy lại từ đầu

```bash
# Clean tất cả
./scripts/clean-docker.sh

# Deploy lại
./scripts/deploy-all.sh
```

## Lưu ý

1. **SSH Key**: Đảm bảo đã setup SSH key để kết nối server không cần password
2. **Docker**: Server phải có Docker và Docker Compose đã được cài đặt
3. **Permissions**: User trên server phải có quyền chạy `sudo docker`
4. **Database**: Script không xóa volume `postgres_db` để tránh mất dữ liệu
5. **Environment Variables**: Đảm bảo file `.env` hoặc environment variables đã được cấu hình trên server

## Troubleshooting

### Lỗi SSH connection
```bash
# Test SSH connection
ssh ${SERVER_USER}@${SERVER_HOST}

# Kiểm tra SSH key
ssh-add -l
```

### Lỗi Docker permission
```bash
# Thêm user vào docker group (trên server)
sudo usermod -aG docker ${SERVER_USER}
```

### Lỗi rsync
```bash
# Test rsync connection
rsync -avz --dry-run ./ ${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}/
```

## Tích hợp với CI/CD

Các script này có thể được sử dụng trong CI/CD pipeline (GitHub Actions, GitLab CI) như đã được cấu hình trong:
- `.github/workflows/backend-cicd.yml`
- `.github/workflows/frontend-cicd.yml`
- `.gitlab-ci.yml`


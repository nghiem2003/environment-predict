# /project_flask_api/config.py

# Paths to the saved models
MODEL_PATHS = {
    'cobia_ridge': 'model/cobia/ridge_model.pkl',
    'cobia_gbr': 'model/cobia/gbr_model.pkl',
    'cobia_xgboost': 'model/cobia/xgboost_model.pkl',
    'cobia_svr': 'model/cobia/svr_model.pkl',
    'cobia_rf': 'model/cobia/rf_model.pkl',
    'cobia_lightgbm': 'model/cobia/lightgbm_model.pkl',
    'cobia_stack': 'model/cobia/stack_gen_model.pkl',
    'oyster_ridge': 'model/oyster/ridge_model.pkl',
    'oyster_gbr': 'model/oyster/gbr_model.pkl',
    'oyster_xgboost': 'model/oyster/xgboost_model.pkl',
    'oyster_svr': 'model/oyster/svr_model.pkl',
    'oyster_rf': 'model/oyster/rf_model.pkl',
    'oyster_lightgbm': 'model/oyster/lightgbm_model.pkl',
    'oyster_stack': 'model/oyster/stack_gen_model.pkl',
}

DATA_CACHE_PATH = 'data/latest_grid.nc'
# List of required fields for prediction
REQUIRED_FIELDS = [
    'R_PO4','O2Sat','O2ml_L','STheta','Salnty','R_DYNHT','T_degC','R_Depth','Distance',
    'Wind_Spd','Wave_Ht','Wave_Prd','IntChl','Dry_T'
]


DEFAULT_FALLBACK_VALUES = {
    'T_degC': 29.0,       # Nhiệt độ lý tưởng
    'Salnty': 30.0,       # Độ mặn lý tưởng
    'O2ml_L': 5.0,        # Oxy hòa tan
    'R_PO4': 0.5,         # Phosphate
    'IntChl': 0.2,        # Chlorophyll
    'Wave_Ht': 0.8,       # Chiều cao sóng thấp
    'Wave_Prd': 7.0,      # Chu kỳ sóng trung bình
    'Wind_Spd': 5.0,      # Tốc độ gió nhẹ (m/s)
    'O2Sat': 95.0,        # Độ bão hòa Oxy
    'STheta': 22.0,       # Mật độ nước biển
    'R_DYNHT': 0,         # Các giá trị này thường là 0 hoặc giá trị mặc định
    'R_Depth': 10,
    'Distance': -50,
    'Dry_T': 28,
}

FETCH_SECRET_KEY = 'your-very-secret-and-random-string-12345'

# === COPERNICUS API CREDENTIALS ===
# Thay thế bằng thông tin đăng nhập Copernicus của bạn
COPERNICUS_USERNAME = 'nghiem.eo.bua.18@gmail.com'
COPERNICUS_PASSWORD = 'Quenmatroi1!'
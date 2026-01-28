import os
import sys
from flask import Flask
from . import services

# Add parent directory to path to import config_v2
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Import các cấu hình cho Service B (dùng config_v2)
import config_v2
MODEL_PATHS = config_v2.MODEL_PATHS
DATA_CACHE_PATH = config_v2.DATA_CACHE_PATH

# Import hàm lấy dữ liệu
from .data_fetcher import run_daily_grid_retrieval

def create_app():
    """
    Hàm khởi tạo và cấu hình ứng dụng Flask Secondary (Application Factory).
    Sử dụng config_v2 để load models từ folder khác.
    """
    app = Flask(__name__)
    
    # Load config from config_v2
    app.config['MODEL_PATHS'] = MODEL_PATHS
    app.config['DATA_CACHE_PATH'] = DATA_CACHE_PATH
    app.config['REQUIRED_FIELDS'] = config_v2.REQUIRED_FIELDS
    app.config['DEFAULT_FALLBACK_VALUES'] = config_v2.DEFAULT_FALLBACK_VALUES
    app.config['FETCH_SECRET_KEY'] = config_v2.FETCH_SECRET_KEY
    app.config['COPERNICUS_USERNAME'] = config_v2.COPERNICUS_USERNAME
    app.config['COPERNICUS_PASSWORD'] = config_v2.COPERNICUS_PASSWORD
    
    with app.app_context():
        # Kiểm tra file cache khi khởi động
        if not os.path.exists(DATA_CACHE_PATH):
            print(f"Cache file not found at '{DATA_CACHE_PATH}'.")
            print("Starting initial data retrieval... This may take several minutes.")
            try:
                run_daily_grid_retrieval()
            except Exception as e:
                print(f"FATAL: Initial data retrieval failed: {e}")
                print("Please run 'python fetch_grid_cron.py' manually to create the cache file.")
        else:
            print(f"Found existing cache file at '{DATA_CACHE_PATH}'.")

        print("Loading machine learning models from model_v2/ and shared_models_v2/...")
        services.load_all_models(app.config['MODEL_PATHS'])
        print("All models loaded.")

        from .routes import prediction_api
        app.register_blueprint(prediction_api)

    return app

# /project_flask_api/run_v2.py
# Flask Secondary Service for new XGBoost models (>= 2.0.0)

import os
import sys

# Add current directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Import create_app from __init__v2
# Note: Python doesn't allow import from files starting with __
# So we need to import the module differently
import importlib.util
spec = importlib.util.spec_from_file_location(
    "prediction_module_init_v2",
    os.path.join(os.path.dirname(__file__), "prediction_module", "__init__v2.py")
)
init_v2 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(init_v2)
create_app = init_v2.create_app

# Set different port for secondary service
SECONDARY_PORT = int(os.getenv('FLASK_PORT', 5002))

# Tạo instance của ứng dụng bằng factory
app = create_app()

if __name__ == '__main__':
    # Chạy ứng dụng trên port khác
    print(f"Starting Flask Secondary Service on port {SECONDARY_PORT}")
    print("Python version:", sys.version)
    print("This service uses Python 3.12 and XGBoost >= 2.0.0 for new models")
    print("Loading models from: model_v2/ and shared_models_v2/")
    
    # Use production server in Docker, debug in development
    debug_mode = os.getenv('FLASK_ENV', 'development') == 'development'
    app.run(debug=debug_mode, host='0.0.0.0', port=SECONDARY_PORT)

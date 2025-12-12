# /project_flask_api/prediction_module/routes.py

from flask import Blueprint, request, jsonify, current_app
from . import services

prediction_api = Blueprint('prediction_api', __name__)

def handle_prediction(species):
    """Hàm xử lý chung cho cả cobia và oyster."""
    try:
        user_data = request.get_json()
        if not user_data:
            return jsonify({"error": "Invalid JSON input"}), 400
        
        # Lấy credentials từ config
        credentials = {
            'username': current_app.config['COPERNICUS_USERNAME'],
            'password': current_app.config['COPERNICUS_PASSWORD']
        }

        # Gọi service chính để xử lý
        prediction_result, status_code, final_features = services.process_prediction_request(
            user_data, species, credentials
        )

        # Tạo response hoàn chỉnh
        response_data = {
            "prediction_result": prediction_result,
            "final_features_used": {k: round(v, 2) if isinstance(v, float) else v for k, v in final_features.items() if k in services.REQUIRED_FIELDS}
        }
        
        return jsonify(response_data), status_code

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@prediction_api.route('/trigger_fetch', methods=['POST'])
def trigger_fetch_data():
    # Lấy secret key từ header của request
    incoming_secret = request.headers.get('X-FETCH-SECRET')
    
    # So sánh với secret key trong config
    if incoming_secret != current_app.config['FETCH_SECRET_KEY']:
        return jsonify({"error": "Unauthorized"}), 403 # Từ chối truy cập

    # Nếu key hợp lệ, chạy tác vụ trong một luồng riêng (chạy nền)
    # để không làm block server
    thread = threading.Thread(target=run_daily_grid_retrieval)
    thread.start()
    
    # Trả về response ngay lập tức
    return jsonify({"message": "Accepted. Data retrieval process started in the background."}), 202

@prediction_api.route('/status', methods=['GET'])
def home():
    from .model_manager import get_model_info
    model_info = get_model_info()
    return jsonify({
        'message': 'Prediction module is running!',
        'available_models': services.get_available_models(),
        'model_details': model_info
    })

@prediction_api.route('/reload_models', methods=['POST'])
def reload_models_endpoint():
    """
    Endpoint to reload all ML models without restarting Flask.
    Protected by secret key.
    """
    from .model_manager import reload_models
    
    # Check authorization
    incoming_secret = request.headers.get('X-RELOAD-SECRET')
    if incoming_secret != current_app.config.get('FETCH_SECRET_KEY'):
        return jsonify({"error": "Unauthorized"}), 403
    
    success, message, count = reload_models()
    
    if success:
        return jsonify({
            "success": True,
            "message": message,
            "total_models": count,
            "available_models": services.get_available_models()
        }), 200
    else:
        return jsonify({
            "success": False,
            "error": message
        }), 500

@prediction_api.route('/sync_models', methods=['POST'])
def sync_models_endpoint():
    """
    Endpoint to download a model from Google Drive and reload all models.
    Protected by secret key.
    """
    from .model_manager import reload_models
    from google_drive_downloader import sync_model_from_google_drive
    
    # Check authorization
    incoming_secret = request.headers.get('X-RELOAD-SECRET')
    if incoming_secret != current_app.config.get('FETCH_SECRET_KEY'):
        return jsonify({"error": "Unauthorized"}), 403
    
    try:
        data = request.get_json()
        file_id = data.get('file_id')
        file_name = data.get('file_name')
        download_link = data.get('download_link')
        
        if not file_id or not file_name:
            return jsonify({
                "success": False,
                "error": "file_id and file_name are required"
            }), 400
        
        # Download model from Google Drive
        print(f"Syncing model from Google Drive: {file_name}")
        success, local_path, message = sync_model_from_google_drive(
            file_id, file_name, download_link
        )
        
        if not success:
            return jsonify({
                "success": False,
                "error": message
            }), 500
        
        # Reload all models
        reload_success, reload_message, count = reload_models()
        
        if reload_success:
            return jsonify({
                "success": True,
                "message": f"Model synced and loaded successfully: {local_path}",
                "total_models": count,
                "available_models": services.get_available_models()
            }), 200
        else:
            return jsonify({
                "success": False,
                "error": f"Model downloaded but failed to reload: {reload_message}"
            }), 500
            
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

@prediction_api.route('/predict/cobia', methods=['POST'])
def predict_cobia():
    return handle_prediction('cobia')

@prediction_api.route('/predict/oyster', methods=['POST'])
def predict_oyster():
    return handle_prediction('oyster')


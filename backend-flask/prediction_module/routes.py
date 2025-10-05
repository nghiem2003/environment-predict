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
    return jsonify({
        'message': 'Prediction module is running!',
        'available_models': services.get_available_models()
    })

@prediction_api.route('/predict/cobia', methods=['POST'])
def predict_cobia():
    return handle_prediction('cobia')

@prediction_api.route('/predict/oyster', methods=['POST'])
def predict_oyster():
    return handle_prediction('oyster')


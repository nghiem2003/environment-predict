"""
Model Manager Module
Handles dynamic model loading and reloading
"""

import os
from . import services
from config import discover_model_paths

def reload_models():
    """
    Reload all models from the model directory.
    This allows hot-reloading of models without restarting Flask.
    
    Returns:
        tuple: (success: bool, message: str, model_count: int)
    """
    try:
        print("Reloading models...")
        
        # Clear existing models
        services.models.clear()
        
        # Rediscover models
        new_model_paths = discover_model_paths()
        
        if not new_model_paths:
            return False, "No models found in model directory", 0
        
        # Load all models
        services.load_all_models(new_model_paths)
        
        model_count = len(services.models)
        message = f"Successfully reloaded {model_count} model(s)"
        print(message)
        
        return True, message, model_count
        
    except Exception as e:
        error_msg = f"Error reloading models: {str(e)}"
        print(error_msg)
        return False, error_msg, 0

def get_model_info():
    """
    Get information about currently loaded models.
    
    Returns:
        dict: Model information including paths and status
    """
    from config import MODEL_PATHS
    
    loaded_models = services.get_available_models()
    
    model_info = []
    for model_name in loaded_models:
        path = MODEL_PATHS.get(model_name, 'Unknown')
        file_exists = os.path.exists(path) if path != 'Unknown' else False
        
        model_info.append({
            'name': model_name,
            'path': path,
            'loaded': True,
            'file_exists': file_exists,
        })
    
    return {
        'total_models': len(loaded_models),
        'models': model_info,
    }



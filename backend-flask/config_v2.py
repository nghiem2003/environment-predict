# /project_flask_api/config_v2.py
# Config for Flask Secondary Service (XGBoost >= 2.0.0)

import os
import glob

# AUTO-DISCOVER MODEL PATHS - Use different folders for new models
def discover_model_paths(base_dirs=['model_v2', 'shared_models_v2']):
    """
    Automatically discover all .pkl model files in multiple model directories.
    This is for Flask Secondary Service - uses different folders for new models.
    
    Searches in:
    - 'model_v2/' - New models for XGBoost >= 2.0.0
    - 'shared_models_v2/' - New models uploaded via Express (shared volume)
    """
    model_paths = {}
    
    # Support both string and list input
    if isinstance(base_dirs, str):
        base_dirs = [base_dirs]
    
    for base_dir in base_dirs:
        if not os.path.exists(base_dir):
            print(f"INFO: Model directory '{base_dir}' not found, skipping.")
            continue
        
        discover_in_directory(base_dir, model_paths)
    
    if not model_paths:
        print(f"WARNING: No .pkl files found in any model directories.")
    else:
        print(f"Total models discovered: {len(model_paths)}")
    
    return model_paths

def discover_in_directory(base_dir, model_paths):
    """
    Helper function to discover models in a specific directory.
    Updates model_paths dict in place.
    
    Supports 2 naming conventions:
    1. Folder structure: model_v2/cobia/ridge_model.pkl -> 'cobia_ridge'
    2. Flat structure: model_v2/cobia__ridge_regression_model.pkl -> 'cobia_ridge_regression'
    """
    if not os.path.exists(base_dir):
        return model_paths
    
    # Search for all .pkl files in subdirectories
    pattern = os.path.join(base_dir, '**', '*.pkl')
    pkl_files = glob.glob(pattern, recursive=True)
    
    for pkl_file in pkl_files:
        # Extract species and algorithm from path
        rel_path = os.path.relpath(pkl_file, base_dir)
        parts = rel_path.split(os.sep)
        filename = parts[-1]
        
        # Check if filename uses flat naming: species__algorithm_model.pkl
        if '__' in filename:
            # FLAT STRUCTURE (from Google Drive uploads)
            parts_name = filename.replace('_model.pkl', '').replace('.pkl', '').split('__')
            
            if len(parts_name) >= 2:
                species = parts_name[0]
                algorithm = parts_name[1]
                
                if algorithm == 'stack_gen':
                    algorithm = 'stack'
                
                model_key = f"{species}_{algorithm}"
                
                if model_key not in model_paths:
                    model_paths[model_key] = pkl_file
                    print(f"Discovered (flat): {model_key} -> {pkl_file}")
        
        elif len(parts) >= 2:
            # FOLDER STRUCTURE
            species = parts[0]
            algorithm = filename.replace('_model.pkl', '').replace('.pkl', '')
            if algorithm == 'stack_gen':
                algorithm = 'stack'
            
            species_prefix = species + '_'
            if algorithm.startswith(species_prefix):
                algorithm = algorithm[len(species_prefix):]
            
            model_key = f"{species}_{algorithm}"
            
            if model_key not in model_paths:
                model_paths[model_key] = pkl_file
                print(f"Discovered model: {model_key} -> {pkl_file}")

# Generate MODEL_PATHS dynamically for new models
MODEL_PATHS = discover_model_paths()

DATA_CACHE_PATH = 'data/latest_grid.nc'
# List of required fields for prediction
REQUIRED_FIELDS = [
    'R_PO4','O2Sat','O2ml_L','STheta','Salnty','R_DYNHT','T_degC','R_Depth','Distance',
    'Wind_Spd','Wave_Ht','Wave_Prd','IntChl','Dry_T'
]

DEFAULT_FALLBACK_VALUES = {
    'T_degC': 29.0,
    'Salnty': 30.0,
    'O2ml_L': 5.0,
    'R_PO4': 0.5,
    'IntChl': 0.2,
    'Wave_Ht': 0.8,
    'Wave_Prd': 7.0,
    'Wind_Spd': 5.0,
    'O2Sat': 95.0,
    'STheta': 22.0,
    'R_DYNHT': 0,
    'R_Depth': 10,
    'Distance': -50,
    'Dry_T': 28,
}

FETCH_SECRET_KEY = 'your-very-secret-and-random-string-12345'

# === COPERNICUS API CREDENTIALS ===
COPERNICUS_USERNAME = 'nghiem.eo.bua.18@gmail.com'
COPERNICUS_PASSWORD = 'Quenmatroi1!'

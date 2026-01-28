#!/bin/bash
# Initialize models for Flask Secondary Service
# Copies models from model_v2/ to shared_models_v2/ if shared_models_v2 is empty

if [ ! -d "shared_models_v2" ]; then
    mkdir -p shared_models_v2
fi

# Check if shared_models_v2 is empty
if [ -z "$(ls -A shared_models_v2)" ]; then
    echo "shared_models_v2 is empty, copying from model_v2/ if exists..."
    if [ -d "model_v2" ] && [ "$(ls -A model_v2)" ]; then
        cp -r model_v2/* shared_models_v2/ 2>/dev/null || true
        echo "Models copied to shared_models_v2/"
    else
        echo "No models found in model_v2/"
    fi
else
    echo "shared_models_v2 already contains models, skipping copy"
fi

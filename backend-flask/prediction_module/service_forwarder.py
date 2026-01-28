"""
Service Forwarder - Forwards requests to Flask Secondary when model not found in Primary
"""

import os
import json
import requests
from typing import Dict, Optional, Tuple

class ServiceForwarder:
    """
    Handles forwarding prediction requests to Flask Secondary service
    when model is not found in Flask Primary
    """
    
    def __init__(self, config_path: str = 'service_config.json'):
        self.config_path = config_path
        self.config: Dict = {}
        self.secondary_service_url: Optional[str] = None
        self.forward_enabled: bool = False
        self._load_config()
    
    def _load_config(self):
        """Load service configuration"""
        default_config = {
            "secondary_service": {
                "port": 5002,
                "url": "http://localhost:5002",
                "enabled": True
            }
        }
        
        if os.path.exists(self.config_path):
            try:
                with open(self.config_path, 'r') as f:
                    self.config = json.load(f)
            except Exception as e:
                print(f"Error loading service config: {e}, using defaults")
                self.config = default_config
        else:
            # Create default config
            self.config = default_config
            try:
                with open(self.config_path, 'w') as f:
                    json.dump(default_config, f, indent=2)
                print(f"Created default service config: {self.config_path}")
            except Exception as e:
                print(f"Error creating config: {e}")
        
        secondary = self.config.get('secondary_service', {})
        # In Docker, use service name; in local dev, use localhost
        default_url = os.getenv('FLASK_SECONDARY_URL', 'http://localhost:5002')
        self.secondary_service_url = secondary.get('url', default_url)
        self.forward_enabled = secondary.get('enabled', True)
        
        if self.forward_enabled:
            print(f"Service forwarder enabled. Secondary service: {self.secondary_service_url}")
        else:
            print("Service forwarder disabled")
    
    def forward_prediction_request(
        self, 
        species: str, 
        user_data: Dict,
        timeout: int = 30
    ) -> Tuple[Dict, int]:
        """
        Forward prediction request to secondary service
        
        Args:
            species: Species type ('cobia', 'oyster', 'mangrove')
            user_data: Request data
            timeout: Request timeout in seconds
        
        Returns:
            tuple: (response_data: dict, status_code: int)
        """
        if not self.forward_enabled or not self.secondary_service_url:
            return {
                "error": "Secondary service not configured or disabled"
            }, 503
        
        try:
            # Forward to secondary service
            url = f"{self.secondary_service_url}/predict/{species}"
            
            print(f"Forwarding prediction request to secondary service: {url}")
            print(f"  Model: {user_data.get('model', 'default')}")
            
            response = requests.post(
                url,
                json=user_data,
                timeout=timeout,
                headers={'Content-Type': 'application/json'}
            )
            
            # Return response from secondary service
            if response.status_code == 200:
                print(f"✓ Successfully forwarded to secondary service")
                return response.json(), 200
            else:
                print(f"✗ Secondary service returned error: {response.status_code}")
                try:
                    error_data = response.json()
                    return error_data, response.status_code
                except:
                    return {
                        "error": f"Secondary service error: {response.status_code}",
                        "details": response.text
                    }, response.status_code
                
        except requests.exceptions.Timeout:
            return {
                "error": "Secondary service timeout",
                "message": f"Request to secondary service timed out after {timeout}s"
            }, 504
        except requests.exceptions.ConnectionError:
            return {
                "error": "Secondary service unavailable",
                "message": f"Cannot connect to secondary service at {self.secondary_service_url}. Make sure it's running."
            }, 503
        except Exception as e:
            return {
                "error": "Forwarding failed",
                "message": str(e)
            }, 500


# Global instance
service_forwarder = ServiceForwarder()

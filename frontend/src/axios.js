import axios from 'axios';

// Function to get the token from storage (e.g., localStorage)
const getToken = () => {
  return localStorage.getItem('token'); // Adjust the key name based on your token storage
};

// Create an Axios instance with default headers
const axiosInstance = axios.create({
  baseURL: 'http://localhost:8082', // Replace with your API base URL
});

// Add a request interceptor to add the token to headers before each request
axiosInstance.interceptors.request.use(
  (config) => {
    const token = getToken(); // Retrieve the token from storage

    // If a token is available, attach it to the Authorization header
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }

    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

export default axiosInstance;

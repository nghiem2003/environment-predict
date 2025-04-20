import React, { useState, useEffect } from 'react';
import { jwtDecode } from 'jwt-decode';
import { login, logout } from '../redux/authSlice';
import { useNavigate } from 'react-router-dom';
import { useSelector, useDispatch } from 'react-redux';
import axios from '../axios';
import './Login.css';

const Login = () => {
   const { token } = useSelector((state) => state.auth);
  console.log('The token',token);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const dispatch = useDispatch();
  const navigate = useNavigate();

   useEffect(() => {
      if (token) {
        try {
          const decodedToken = jwtDecode(token); // Decode the JWT token
          const exp = decodedToken.exp * 1000
          const now = Date.now()
          if(now > exp ) {
            dispatch(logout())
            navigate('/')
          }
          navigate('/dashboard');
          
        } catch (error) {
          console.error('Error decoding token:', error);
          alert('Invalid token. Please log in again.');
        }
      }
    }, [token]);

  const handleLogin = async () => {
    try {
      const response = await axios.post('/api/express/auth/login', {
        email,
        password,
      });

      const { token, role } = response.data;
      localStorage.setItem('token', token);
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
      // Dispatch login action with token and role
      dispatch(
        login({
          user: email,
          token,
          role,
        })
      );

      // Navigate to the dashboard after successful login
      navigate('/dashboard');
    } catch (error) {
      setError('Invalid username or password. Please try again.');
    }
  };

  return (
    <div className="login-container">
      <h1>Login</h1>
      <input
        className="input"
        type="text"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />
      <input
        className="input"
        type="password"
        placeholder="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />
      <button onClick={handleLogin}>Login</button>
      {error && <p style={{ color: 'red' }}>{error}</p>}
    </div>
  );
};

export default Login;

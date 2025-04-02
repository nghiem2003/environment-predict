import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import { login } from '../redux/authSlice';
import { useNavigate } from 'react-router-dom';
import axios from '../axios';
import './Login.css';

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const dispatch = useDispatch();
  const navigate = useNavigate();

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

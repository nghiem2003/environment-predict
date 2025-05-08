import React, { useEffect, useState } from 'react';
import { Form, Input, Button, Typography, message } from 'antd';
import { UserOutlined, LockOutlined } from '@ant-design/icons';
import { useTranslation } from 'react-i18next';
import { useDispatch, useSelector } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import { login, logout } from '../redux/authSlice';
import axios from '../axios';
import { jwtDecode } from 'jwt-decode';
import { toast } from 'react-toastify';

const { Title } = Typography;

const Login = () => {
  const { t } = useTranslation();
  const { token } = useSelector((state) => state.auth);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const [form] = Form.useForm();

  useEffect(() => {
    if (token) {
      try {
        const decodedToken = jwtDecode(token); // Decode the JWT token
        const exp = decodedToken.exp * 1000;
        const now = Date.now();
        if (now > exp) {
          dispatch(logout());
          navigate('/');
        }
        navigate('/dashboard');
      } catch (error) {
        console.error('Error decoding token:', error);
        toast.error(t('login.invalidToken'));
      }
    }
  }, [token, dispatch, navigate, t]);

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
      message.error(error.response?.data?.message || t('login.error'));
    }
  };

  return (
    <div
      style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        minHeight: '100vh',
        background: '#f0f2f5',
      }}
    >
      <div
        style={{
          width: 350,
          padding: 32,
          background: '#fff',
          borderRadius: 8,
          boxShadow: '0 2px 8px rgba(0, 0, 0, 0.15)',
        }}
      >
        <Title level={2} style={{ textAlign: 'center', marginBottom: 24 }}>
          {t('login.title')}
        </Title>
        <Form
          form={form}
          name="login"
          onFinish={handleLogin}
          layout="vertical"
          size="large"
        >
          <Form.Item
            name="email"
            rules={[
              { required: true, message: t('login.emailRequired') },
              { type: 'email', message: t('login.invalidEmail') },
            ]}
          >
            <Input
              prefix={<UserOutlined />}
              placeholder={t('login.email')}
              autoComplete="username"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </Form.Item>
          <Form.Item
            name="password"
            rules={[{ required: true, message: t('login.passwordRequired') }]}
          >
            <Input.Password
              prefix={<LockOutlined />}
              placeholder={t('login.password')}
              autoComplete="current-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </Form.Item>
          <Form.Item>
            <Button
              type="primary"
              htmlType="submit"
              onClick={handleLogin}
              block
            >
              {t('login.button')}
            </Button>
          </Form.Item>
        </Form>
      </div>
    </div>
  );
};

export default Login;

import React, { useEffect, useState } from 'react';
import {
  Form,
  Input,
  Button,
  Typography,
  message,
  Card,
  Alert,
  Space,
  Divider,
  Row,
  Col,
  Spin
} from 'antd';
import {
  UserOutlined,
  LockOutlined,
  ArrowLeftOutlined,
  LoginOutlined,
  EyeInvisibleOutlined,
  EyeTwoTone,
  MailOutlined,
  KeyOutlined
} from '@ant-design/icons';
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
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [errorType, setErrorType] = useState(''); // 'network', 'auth', 'validation', 'server'
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

  const handleLogin = async (values) => {
    setLoading(true);
    setError('');
    setErrorType('');

    try {
      console.log('Login attempt:', { email: values.email, password: '***' });

      const response = await axios.post('/api/express/auth/login', {
        email: values.email,
        password: values.password,
      });

      const { token, role } = response.data;
      localStorage.setItem('token', token);
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;

      // Dispatch login action with token and role
      dispatch(
        login({
          user: values.email,
          token,
          role,
        })
      );

      message.success(t('login.success') || 'Đăng nhập thành công!');

      // Navigate to the dashboard after successful login
      navigate('/dashboard');
    } catch (error) {
      console.error('Login error:', error);

      let errorMessage = '';
      let errorType = 'server';

      if (!error.response) {
        // Network error
        errorMessage = t('login.networkError') || 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
        errorType = 'network';
      } else {
        const status = error.response.status;
        const data = error.response.data;

        switch (status) {
          case 401:
            errorMessage = data?.error || t('login.invalidCredentials') || 'Email hoặc mật khẩu không đúng.';
            errorType = 'auth';
            break;
          case 403:
            errorMessage = data?.error || t('login.accountDeactivated') || 'Tài khoản đã bị vô hiệu hóa.';
            errorType = 'auth';
            break;
          case 400:
            errorMessage = data?.error || t('login.invalidInput') || 'Thông tin đăng nhập không hợp lệ.';
            errorType = 'validation';
            break;
          case 500:
            errorMessage = t('login.serverError') || 'Lỗi server. Vui lòng thử lại sau.';
            errorType = 'server';
            break;
          default:
            errorMessage = data?.error || t('login.unknownError') || 'Có lỗi xảy ra. Vui lòng thử lại.';
            errorType = 'server';
        }
      }

      setError(errorMessage);
      setErrorType(errorType);
      message.error(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  const getErrorIcon = () => {
    switch (errorType) {
      case 'network':
        return <UserOutlined />;
      case 'auth':
        return <LockOutlined />;
      case 'validation':
        return <MailOutlined />;
      case 'server':
        return <KeyOutlined />;
      default:
        return <UserOutlined />;
    }
  };

  return (
    <div
      style={{
        minHeight: '100vh',
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '20px',
      }}
    >
      <Row justify="center" style={{ width: '100%', maxWidth: '1200px' }}>
        <Col xs={24} sm={20} md={16} lg={12} xl={10}>
          <Card
            style={{
              borderRadius: '16px',
              boxShadow: '0 20px 40px rgba(0, 0, 0, 0.1)',
              border: 'none',
              overflow: 'hidden',
            }}
            bodyStyle={{ padding: 0 }}
          >
            <div
              style={{
                background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                padding: '40px 40px 20px 40px',
                textAlign: 'center',
                color: 'white',
              }}
            >
              <Space direction="vertical" size="large" style={{ width: '100%' }}>
                <div>
                  <LoginOutlined style={{ fontSize: '48px', marginBottom: '16px' }} />
                  <Title level={2} style={{ color: 'white', margin: 0 }}>
                    {t('login.title') || 'Đăng nhập'}
                  </Title>
                  <p style={{ color: 'rgba(255, 255, 255, 0.8)', margin: '8px 0 0 0' }}>
                    {t('login.subtitle') || 'Chào mừng bạn quay trở lại'}
                  </p>
                </div>
              </Space>
            </div>

            <div style={{ padding: '40px' }}>
              <Space direction="vertical" size="large" style={{ width: '100%' }}>
                {/* Back Button */}
                <Button
                  type="text"
                  icon={<ArrowLeftOutlined />}
                  onClick={() => navigate('/interactive-map')}
                  style={{
                    paddingLeft: 0,
                    color: '#666',
                    marginBottom: '8px'
                  }}
                >
                  {t('common.back') || 'Trở về trang chủ'}
                </Button>

                {/* Error Alert */}
                {error && (
                  <Alert
                    message={error}
                    type={errorType === 'network' ? 'warning' : 'error'}
                    icon={getErrorIcon()}
                    showIcon
                    style={{ marginBottom: '16px' }}
                    action={
                      <Button
                        size="small"
                        type="text"
                        onClick={() => setError('')}
                      >
                        Đóng
                      </Button>
                    }
                  />
                )}

                {/* Login Form */}
                <Form
                  form={form}
                  name="login"
                  onFinish={handleLogin}
                  layout="vertical"
                  size="large"
                  initialValues={{}}
                >
                  <Form.Item
                    name="email"
                    label={<span style={{ fontWeight: 500 }}>Email</span>}
                    rules={[
                      {
                        required: true,
                        message: t('login.emailRequired') || 'Vui lòng nhập email'
                      },
                      {
                        type: 'email',
                        message: t('login.invalidEmail') || 'Email không hợp lệ'
                      },
                    ]}
                  >
                    <Input
                      prefix={<MailOutlined style={{ color: '#667eea' }} />}
                      placeholder={t('login.email') || 'Nhập email của bạn'}
                      autoComplete="username"
                      style={{
                        borderRadius: '8px',
                        padding: '12px 16px',
                        fontSize: '16px'
                      }}
                    />
                  </Form.Item>

                  <Form.Item
                    name="password"
                    label={<span style={{ fontWeight: 500 }}>Mật khẩu</span>}
                    rules={[
                      {
                        required: true,
                        message: t('login.passwordRequired') || 'Vui lòng nhập mật khẩu'
                      },
                      {
                        min: 6,
                        message: 'Mật khẩu phải có ít nhất 6 ký tự'
                      }
                    ]}
                  >
                    <Input.Password
                      prefix={<LockOutlined style={{ color: '#667eea' }} />}
                      placeholder={t('login.password') || 'Nhập mật khẩu của bạn'}
                      autoComplete="current-password"
                      iconRender={(visible) => (visible ? <EyeTwoTone /> : <EyeInvisibleOutlined />)}
                      style={{
                        borderRadius: '8px',
                        padding: '12px 16px',
                        fontSize: '16px'
                      }}
                    />
                  </Form.Item>

                  <Form.Item style={{ marginBottom: '24px' }}>
                    <Button
                      type="primary"
                      htmlType="submit"
                      loading={loading}
                      block
                      size="large"
                      icon={<LoginOutlined />}
                      style={{
                        height: '48px',
                        borderRadius: '8px',
                        fontSize: '16px',
                        fontWeight: 500,
                        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                        border: 'none',
                        boxShadow: '0 4px 12px rgba(102, 126, 234, 0.4)',
                      }}
                    >
                      {loading ? (
                        <Space>
                          <Spin size="small" />
                          <span>Đang đăng nhập...</span>
                        </Space>
                      ) : (
                        t('login.button') || 'Đăng nhập'
                      )}
                    </Button>
                  </Form.Item>
                </Form>

                <Divider style={{ margin: '24px 0' }}>
                  <span style={{ color: '#999', fontSize: '14px' }}>
                    Hệ thống Dự đoán Nuôi trồng Thủy sản
                  </span>
                </Divider>

                <div style={{ textAlign: 'center', color: '#666', fontSize: '14px' }}>
                  <p style={{ margin: 0 }}>
                    Nếu bạn gặp vấn đề khi đăng nhập, vui lòng liên hệ quản trị viên.
                  </p>
                </div>
              </Space>
            </div>
          </Card>
        </Col>
      </Row>
    </div>
  );
};

export default Login;

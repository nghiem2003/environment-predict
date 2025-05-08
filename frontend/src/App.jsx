import React, { useState, useEffect } from 'react';
import {
  Routes,
  Route,
  useNavigate,
  useLocation,
  Navigate,
} from 'react-router-dom';
import { useSelector, useDispatch } from 'react-redux';
import { logout } from './redux/authSlice';
import Login from './components/Login';
import 'react-toastify/dist/ReactToastify.css';
import { ToastContainer } from 'react-toastify';
import Dashboard from './components/Dashboard';
import WelcomePage from './components/WelcomePage';
import Prediction from './components/Prediction';
import PredictionDetails from './components/PredictionDetails';
import CreatePrediction from './components/CreateNewPrediction';
import ProtectedRoute from './components/ProtectedRoute';
import 'leaflet/dist/leaflet.css';
import './App.css'; // Import CSS for header and footer
import AreaList from './components/AreaList';
import UserList from './components/UserList';
import { useTranslation } from 'react-i18next';
import LanguageSwitch from './components/LanguageSwitch';
import {
  Layout,
  Menu,
  Button,
  theme,
  Typography,
  Space,
  message,
  Row,
  Col,
  Grid,
} from 'antd';
import {
  ArrowLeftOutlined,
  MenuFoldOutlined,
  MenuUnfoldOutlined,
  ArrowRightOutlined,
  DashboardOutlined,
  AreaChartOutlined,
  UserOutlined,
  PlusCircleOutlined,
  LogoutOutlined,
  GlobalOutlined,
} from '@ant-design/icons';

const { Header, Sider, Content } = Layout;
const { Title } = Typography;
const { useBreakpoint } = Grid;

const App = () => {
  const { t, i18n } = useTranslation();
  const [collapsed, setCollapsed] = useState(false);
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const location = useLocation();
  const { user, token, role } = useSelector((state) => state.auth);
  const screens = useBreakpoint();
  const {
    token: { colorBgContainer, borderRadiusLG },
  } = theme.useToken();

  const switchLanguage = (lng) => {
    i18n.changeLanguage(lng);
  };

  const handleLogout = () => {
    dispatch(logout());
    message.success(t('logout.success'));
    navigate('/');
  };

  const isSidebarVisible = role === 'admin' || role === 'expert';

  const getMenuItems = () => {
    if (role === 'admin') {
      return [
        {
          key: '/areas',
          icon: <AreaChartOutlined />,
          label: t('sidebar.area_list'),
        },
        {
          key: '/dashboard',
          icon: <DashboardOutlined />,
          label: t('sidebar.prediction_list'),
        },
        {
          key: '/user-list',
          icon: <UserOutlined />,
          label: t('sidebar.user_list'),
        },
      ];
    } else if (role === 'expert') {
      return [
        {
          key: '/dashboard',
          icon: <DashboardOutlined />,
          label: t('sidebar.prediction_list'),
        },
        {
          key: '/create-prediction',
          icon: <PlusCircleOutlined />,
          label: t('sidebar.create_prediction'),
        },
      ];
    }
    return [];
  };

  const renderHeader = () => (
    <Header
      style={{
        background: '#007bff',
        color: '#fff',
        padding: screens.xs ? '0 12px' : '0 24px',
        position: 'sticky',
        top: 0,
        zIndex: 1,
        width: '100%',
      }}
    >
      <Row align="middle" justify="start" style={{ height: '100%' }}>
        <Col
          style={{
            display: 'flex',
            alignItems: 'center',
            width: 'max-content',
          }}
        >
          {isSidebarVisible && screens.xs && (
            <Button
              type="text"
              icon={<MenuUnfoldOutlined style={{ fontSize: 24 }} />}
              onClick={() => setCollapsed(false)}
              style={{
                color: '#fff',
                width: 40,
                height: 40,
                marginRight: 8,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            />
          )}
        </Col>
        <Col xs={12} sm={16} md={18}>
          <Title
            level={4}
            style={{
              color: '#fff',
              margin: 0,
              cursor: 'pointer',
              lineHeight: '64px',
              fontSize: screens.xs ? '18px' : '24px',
            }}
          >
            Prediction System
          </Title>
        </Col>
        <Col xs={12} sm={8} md={6}>
          <Space
            size={screens.xs ? 'small' : 'middle'}
            style={{ justifyContent: 'flex-end' }}
          >
            <Button.Group size={screens.xs ? 'small' : 'middle'}>
              <Button
                type={i18n.language === 'en' ? 'primary' : 'default'}
                style={{
                  background: i18n.language === 'en' ? '#fff' : '#007bff',
                  color: i18n.language === 'en' ? '#007bff' : '#fff',
                  border: '1px solid #007bff',
                }}
                onClick={() => switchLanguage('en')}
              >
                EN
              </Button>
              <Button
                type={i18n.language === 'vn' ? 'primary' : 'default'}
                style={{
                  background: i18n.language === 'vn' ? '#fff' : '#007bff',
                  color: i18n.language === 'vn' ? '#007bff' : '#fff',
                  border: '1px solid #007bff',
                }}
                onClick={() => switchLanguage('vn')}
              >
                VN
              </Button>
            </Button.Group>
            {token ? (
              <Button
                type="default"
                size={screens.xs ? 'small' : 'middle'}
                icon={<LogoutOutlined />}
                onClick={handleLogout}
                style={{
                  background: '#007bff',
                  borderColor: '#007bff',
                  color: '#fff',
                  fontWeight: 'bold',
                }}
              >
                {screens.xs || screens.sm ? '' : t('logout.button')}
              </Button>
            ) : (
              <Button
                type="primary"
                size={screens.xs ? 'small' : 'middle'}
                style={{
                  background: '#007bff',
                  borderColor: '#007bff',
                  color: '#fff',
                  fontWeight: 'bold',
                }}
                onClick={() => navigate('/Login')}
              >
                {t('login.button')}
              </Button>
            )}
          </Space>
        </Col>
      </Row>
    </Header>
  );

  useEffect(() => {
    // Auto-collapse sidebar on mobile
    if (screens.xs) {
      setCollapsed(true);
    }
  }, [screens.xs]);

  return (
    <Layout style={{ minHeight: '100vh' }}>
      {isSidebarVisible && (
        <Sider
          trigger={null}
          collapsible
          collapsed={collapsed}
          breakpoint="lg"
          collapsedWidth={screens.xs ? 0 : 80}
          width="15vw"
          minWidth={180}
          style={{
            overflow: 'auto',
            height: '100vh',
            position: 'fixed',
            left: 0,
            top: 0,
            bottom: 0,
            zIndex: 2,
            background: '#fff',
            boxShadow: '2px 0 8px rgba(0,0,0,0.08)',
            scrollbarWidth: 'thin',
            scrollbarColor: '#e0e0e0 #fff',
          }}
          className="custom-sider"
        >
          <div
            style={{
              height: 32,
              margin: 16,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#222',
              fontWeight: 600,
              borderRadius: 4,
            }}
          >
            {screens.xs ? (
              <Button
                type="text"
                icon={<ArrowLeftOutlined style={{ fontSize: 24 }} />}
                onClick={() => setCollapsed(true)}
                style={{
                  width: 40,
                  height: 40,
                  marginRight: 8,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              />
            ) : (
              t('sidebar.title')
            )}
          </div>
          <Menu
            theme="light"
            mode="inline"
            selectedKeys={[location.pathname]}
            items={getMenuItems()}
            onClick={({ key }) => navigate(key)}
            style={{ background: '#fff', border: 'none' }}
          />
        </Sider>
      )}
      <Layout
        style={{
          marginLeft: isSidebarVisible
            ? screens.xs
              ? 0
              : collapsed
              ? 80
              : '15vw'
            : 0,
          transition: 'all 0.2s',
        }}
      >
        {location.pathname !== '/Login' && renderHeader()}
        <Content
          style={{
            margin: screens.xs ? '12px 8px' : '24px 16px',
            padding: screens.xs ? 16 : 24,
            background: colorBgContainer,
            borderRadius: borderRadiusLG,
            minHeight: 280,
          }}
        >
          <Routes>
            <Route
              path="/"
              element={
                token ? <Navigate to="/dashboard" replace /> : <WelcomePage />
              }
            />
            <Route path="/Login" element={<Login />} />
            <Route
              path="/dashboard"
              element={
                <ProtectedRoute roles={['expert', 'admin']}>
                  <Dashboard />
                </ProtectedRoute>
              }
            />
            <Route
              path="/areas"
              element={
                <ProtectedRoute roles={['admin']}>
                  <AreaList />
                </ProtectedRoute>
              }
            />
            <Route
              path="/user-list"
              element={
                <ProtectedRoute roles={['admin']}>
                  <UserList />
                </ProtectedRoute>
              }
            />
            <Route path="/predictions/:areaId" element={<Prediction />} />
            <Route
              path="/predictions/details/:predictionId"
              element={
                <ProtectedRoute roles={['expert', 'admin']}>
                  <PredictionDetails />
                </ProtectedRoute>
              }
            />
            <Route
              path="/create-prediction"
              element={
                <ProtectedRoute roles={['expert', 'admin']}>
                  <CreatePrediction />
                </ProtectedRoute>
              }
            />
          </Routes>
        </Content>
      </Layout>
    </Layout>
  );
};

export default App;

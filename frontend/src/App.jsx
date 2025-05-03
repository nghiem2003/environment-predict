import React from 'react';
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

const App = () => {
  const { t,i18n } = useTranslation()

  const switchLanguage = (lng) => {
    i18n.changeLanguage(lng)
  }
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const location = useLocation();
  // Get authentication state from Redux
  const { user, token, role } = useSelector((state) => state.auth);

  const handleLogout = () => {
    dispatch(logout());
    navigate('/'); // Redirect to the WelcomePage after logout
  };

  // Determine if the sidebar should be visible
  const isSidebarVisible = role === 'admin' || role === 'expert';

  const Sidebar = () => {
    const menuItems =
      role === 'admin'
        ? [
            { label: t('sidebar.area_list'), path: '/areas' },
            { label: t('sidebar.prediction_list'), path: '/dashboard' },
            { label: t('sidebar.user_list'), path: '/user-list' },
          ]
        : role === 'expert'
        ? [
            { label: t('sidebar.prediction_list'), path: '/dashboard' },
            { label: t('sidebar.create_prediction'), path: '/create-prediction' },
          ]
        : [];

    return (
      <aside className="sidebar">
        <div className="sidebar-header">{t('sidebar.title')}</div>
        <ul>
          {menuItems.map((item) => (
            <li
              key={item.path}
              className={location.pathname === item.path ? 'active' : ''}
              onClick={() => navigate(item.path)}
            >
              {item.label}
            </li>
          ))}
        </ul>
        <LanguageSwitch />
        <button className="logout-button" onClick={handleLogout}>
          {t('sidebar.logout')}
        </button>
      </aside>
    );
  };

  const Header = () => {
    if (isSidebarVisible) return null; // Hide header when sidebar is visible

    return (
      <header className="app-header">
        <h1 className="app-title" onClick={() => navigate('/')}>
          Prediction System
        </h1>
        <div className='group'>
        <LanguageSwitch />
        {!token && (
          <button className="login-button" onClick={() => navigate('/Login')}>
            Login
          </button>
        )}
        </div>
      </header>
    );
  };

  const Footer = () => (
    <footer className="app-footer">
      <p>&copy; 2024 Prediction System. All Rights Reserved.</p>
    </footer>
  );

  return (
    <div className="app-container">
      <ToastContainer />
      <Header />
      <div className="app-body">
        {isSidebarVisible && <Sidebar />}
        <div className={<Sidebar /> ? 'content' : 'content-sidebar'}>
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
        </div>
      </div>
     {/* <Footer /> */}
      
    </div>
  );
};

export default App;

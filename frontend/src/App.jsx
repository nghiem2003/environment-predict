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
import Dashboard from './components/Dashboard';
import WelcomePage from './components/WelcomePage';
import Prediction from './components/Prediction';
import PredictionDetails from './components/PredictionDetails';
import CreatePrediction from './components/CreateNewPrediction';
import ProtectedRoute from './components/ProtectedRoute';
import 'leaflet/dist/leaflet.css';
import './App.css'; // Import CSS for header and footer

const App = () => {
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
            { label: 'View Area List', path: '/areas' },
            { label: 'View Prediction List', path: '/dashboard' },
            { label: 'View Users List', path: '/user-list' },
          ]
        : role === 'expert'
        ? [
            { label: 'View Prediction List', path: '/dashboard' },
            { label: 'Create Prediction', path: '/create-prediction' },
          ]
        : [];

    return (
      <aside className="sidebar">
        <div className="sidebar-header">Prediction System</div>
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
        <button className="logout-button" onClick={handleLogout}>
          Logout
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
        {!token && (
          <button className="login-button" onClick={() => navigate('/Login')}>
            Login
          </button>
        )}
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
      <Footer />
    </div>
  );
};

export default App;

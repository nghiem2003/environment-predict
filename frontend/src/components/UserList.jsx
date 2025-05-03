import React, { useState, useEffect } from 'react';
import axios from '../axios';
import './UserList.css';
import { useTranslation } from 'react-i18next';

const UserList = () => {
  const { t } = useTranslation()
  const [users, setUsers] = useState([]);
  const [isRegionPopup,setIsRegionPopup] = useState(false)
  const [searchTerm, setSearchTerm] = useState('');
  const [regionList, setRegionList] = useState([]);
  const [isUserPopupOpen, setIsUserPopupOpen] = useState(false);
  const [isConfirmPopupOpen, setIsConfirmPopupOpen] = useState(false);
  const [isShowPasswordPopupOpen, setIsShowPasswordPopupOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);
  const [adminPassword, setAdminPassword] = useState('');
  const [userPopupData, setUserPopupData] = useState({
    id: null,
    name: '',
    email: '',
    address: '',
    phone: '',
    password: '',
    region:''
  });

  // Fetch users from the API
  const fetchUsers = async () => {
    try {
      const response = await axios.get('/api/express/auth/', {
        params: { search: searchTerm },
      });
      console.log(response.data.data);
      
      setUsers(response.data.data || []);
      const regionResponse = await axios.get('/api/express/areas/regions');
      setRegionList(regionResponse.data); 
    } catch (error) {
      console.error('Error fetching users:', error);
    }
    
  };

  useEffect(() => {
    fetchUsers();
  }, [searchTerm]);

  const getRegionNameFromId = (id) => {
  const region = regionList.find((r) => r.id === id);
  return region ? region.name : '';
};


  // Input change for popup form
  const handlePopupInputChange = (e) => {
    console.log(e.target.value,'and',e.target.name,'and',e.target.key);
    
    const { name, value } = e.target;
    console.log(name,value);
    
    setUserPopupData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  // Submit handler for creating/updating a user
  const handleUserPopupSubmit = async (e) => {
    e.preventDefault();
    try {
      if (userPopupData.id) {
        // Update existing user
        await axios.post(`/api/express/auth/update/${userPopupData.id}`, userPopupData);
      } else {
        // Create new user
        await axios.post('/api/express/auth/create-user', userPopupData);
      }
      setIsUserPopupOpen(false);
      fetchUsers();
      setUserPopupData({
        id: null,
        name: '',
        email: '',
        address: '',
        phone: '',
        password: '',
      });
    } catch (error) {
      console.error('Error saving user:', error);
    }
  };

  // Modify user popup
  const handleModifyUser = (user) => {
    setUserPopupData({
      id: user.id,
      name: user.username,
      email: user.email,
      address: user.address,
      phone: user.phone,
      password: '', // leave password empty when updating
      region:user.region,
    });
    setIsUserPopupOpen(true);
  };

  // Deactivate user confirmation popup
  const handleDeactivateUser = async (id) => {
    try {

      
      console.log('trying to deactive');
      
      await axios.patch(`/api/express/auth/deactivate/${id}`);
      setIsConfirmPopupOpen(false);
      fetchUsers();
    } catch (error) {
      console.error('Error deactivating user:', error);
    }
  };

  // Activate user without confirmation (or add one if needed)
  const handleActivateUser = async (id) => {
    try {
      await axios.patch(`/api/express/auth/activate/${id}`);
      fetchUsers();
    } catch (error) {
      console.error('Error activating user:', error);
    }
  };

  // Show password popup handler (simulate verification)
  const handleShowPassword = (user) => {
    setSelectedUser(user);
    setRevealedPassword(user.password);
  };

  const handleVerifyAdminPassword = () => {
    // For demo, assume admin password is 'adminpassword'
    setRevealedPassword('dummy_password');
  };

  return (
    <div className="user-management">
      <div className="header">
        <input
          type="text"
          placeholder={t('userList.searchPlaceholder')}
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="search-input"
        />
        <button
          className="add-btn"
          onClick={() => {
            setUserPopupData({
              id: null,
              name: '',
              email: '',
              address: '',
              phone: '',
              password: '',
            });
            setIsUserPopupOpen(true);
          }}
        >
          {t('userList.addUser')}
        </button>
      </div>

      <table className="user-table">
        <thead>
          <tr>
            <th>{t('userList.fullName')}</th>
            <th>{t('userList.email')}</th>
            <th>{t('userList.address')}</th>
            <th>{t('userList.phone')}</th>
            <th>{t('userList.role')}</th>
            <th>{t('userList.status')}</th>
            <th>{t('userList.actions')}</th>
          </tr>
        </thead>
        <tbody>
          {users.length ? (
            users.map((user) => (
              <tr key={user.id}>
                <td>{user.username}</td>
                <td>{user.email}</td>
                <td>{user.address}</td>
                <td>{user.phone}</td>
                <td>{user.role === 'admin' ? t('userList.admin') : t('userList.expert')}</td>
                <td>{user.status === 'active' ? t('userList.activeAccount') : t('userList.inactiveAccount') }</td>
                <td>
                  <button style={{'background-color': "#007bff"}} onClick={() => handleModifyUser(user)}>{t('userList.editUser')}</button>
                  { user.role !== 'admin' ? user.status === 'active'? (
                    <button
                      onClick={() => {
                        setSelectedUser(user);
                        setIsConfirmPopupOpen(true);
                      }}
                    >
                      {t('userList.deactivate')}
                    </button>
                  ) : (
                    <button onClick={() => handleActivateUser(user.id)}>
                      {t('userList.activate')}
                    </button>
                  ) :<></>}
                  
                </td>
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan="8">{t('userList.noUsers')}</td>
            </tr>
          )}
        </tbody>
      </table>

      {/* Add/Modify User Popup */}
      {isUserPopupOpen && (
        <div className="popup">
          <div className="popup-content">
            <h3>{userPopupData.id ? t('userList.editUser') : t('userList.addUser')}</h3>
            <form onSubmit={handleUserPopupSubmit}>
              <input
                type="text"
                name="name"
                placeholder={t('userList.fullName')}
                value={userPopupData.name}
                onChange={handlePopupInputChange}
                required
              />
              <input
                type="email"
                name="email"
                placeholder={t('userList.email')}
                value={userPopupData.email}
                onChange={handlePopupInputChange}
                required
              />
              <input
                type="text"
                name="address"
                placeholder={t('userList.address')}
                value={userPopupData.address}
                onChange={handlePopupInputChange}
                required
              />
              <input
                type="text"
                name="phone"
                placeholder={t('userList.phone')}
                value={userPopupData.phone}
                onChange={handlePopupInputChange}
                required
              />
              <input
              placeholder={t('userList.region')}
              type='text'
        name="region"
        value={getRegionNameFromId(userPopupData.region)}
        onFocus={() => setIsRegionPopup(true)}
        required
        id="region"/>
        <ul>
        {isRegionPopup ? regionList.map((region) => (
          <li key={region.id} value={region.name} 
          onClick={() => 
          {handlePopupInputChange({target:{name:'region',value:region.id}})
          setIsRegionPopup(false)
          }}>
            {region.province},{region.name} 
          </li>
        )) : null }
        </ul>
              {userPopupData.id ? <></> : <input
                type="password"
                name="password"
                placeholder={t('userList.password')}
                value={userPopupData.password}
                onChange={handlePopupInputChange}
              />}
              <div className="popup-actions">
                <button type="submit">{t('userList.save')}</button>
                <button type="button" onClick={() => setIsUserPopupOpen(false)}>
                   {t('userList.cancel')}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Deactivate Confirmation Popup */}
      {isConfirmPopupOpen && (
        <div className="popup">
          <div className="popup-content">
            <h3>{t('userList.deactivateConfirm')}</h3>
            <div className="popup-actions">
              <button onClick={() => handleDeactivateUser(selectedUser.id)}>{t('userList.yes')}</button>
              <button onClick={() => setIsConfirmPopupOpen(false)}>{t('userList.no')}</button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
};

export default UserList;

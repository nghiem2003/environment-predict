import React, { useState, useEffect } from 'react';
import axios from '../axios';
import './UserList.css';

const UserList = () => {
  const [users, setUsers] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
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
  });
  const [revealedPassword, setRevealedPassword] = useState(null);

  // Fetch users from the API
  const fetchUsers = async () => {
    try {
      const response = await axios.get('/api/express/auth/', {
        params: { search: searchTerm },
      });
      console.log(response.data.data);
      
      setUsers(response.data.data || []);
    } catch (error) {
      console.error('Error fetching users:', error);
    }
    
  };

  useEffect(() => {
    fetchUsers();
  }, [searchTerm]);

  // Input change for popup form
  const handlePopupInputChange = (e) => {
    const { name, value } = e.target;
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
    });
    setIsUserPopupOpen(true);
  };

  // Deactivate user confirmation popup
  const handleDeactivateUser = async (id) => {
    try {
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
          placeholder="Search by name or email"
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
          Add New User
        </button>
      </div>

      <table className="user-table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Address</th>
            <th>Phone</th>
            <th>Role</th>
            <th>Status</th>
            <th>Password</th>
            <th>Actions</th>
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
                <td>{user.role}</td>
                <td>{user.status}</td>
                <td>
                  <button style={{'background-color': "#007bff"}} onClick={() => handleModifyUser(user)}>Edit</button>
                  { user.role !== 'admin' ? user.status === 'active'? (
                    <button
                      onClick={() => {
                        setSelectedUser(user);
                        setIsConfirmPopupOpen(true);
                      }}
                    >
                      Deactivate
                    </button>
                  ) : (
                    <button onClick={() => handleActivateUser(user.id)}>
                      Activate
                    </button>
                  ) :<></>}
                  
                </td>
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan="8">No users found</td>
            </tr>
          )}
        </tbody>
      </table>

      {/* Add/Modify User Popup */}
      {isUserPopupOpen && (
        <div className="popup">
          <div className="popup-content">
            <h3>{userPopupData.id ? 'Modify User' : 'Add New User'}</h3>
            <form onSubmit={handleUserPopupSubmit}>
              <input
                type="text"
                name="name"
                placeholder="Name"
                value={userPopupData.name}
                onChange={handlePopupInputChange}
              />
              <input
                type="email"
                name="email"
                placeholder="Email"
                value={userPopupData.email}
                onChange={handlePopupInputChange}
              />
              <input
                type="text"
                name="address"
                placeholder="Address"
                value={userPopupData.address}
                onChange={handlePopupInputChange}
              />
              <input
                type="text"
                name="phone"
                placeholder="Phone"
                value={userPopupData.phone}
                onChange={handlePopupInputChange}
              />
              {userPopupData.id ? <></> : <input
                type="password"
                name="password"
                placeholder="Password"
                value={userPopupData.password}
                onChange={handlePopupInputChange}
              />}
              <div className="popup-actions">
                <button type="submit">Save</button>
                <button type="button" onClick={() => setIsUserPopupOpen(false)}>
                  Cancel
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
            <h3>Are you sure you want to deactivate this user?</h3>
            <div className="popup-actions">
              <button onClick={() => handleDeactivateUser(selectedUser.id)}>Yes</button>
              <button onClick={() => setIsConfirmPopupOpen(false)}>No</button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
};

export default UserList;

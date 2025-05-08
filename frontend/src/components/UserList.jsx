import React, { useState, useEffect } from 'react';
import axios from '../axios';
import './UserList.css';
import { useTranslation } from 'react-i18next';
import {
  Card,
  Table,
  Typography,
  Row,
  Col,
  Button,
  Space,
  Pagination,
  Modal,
  Input,
} from 'antd';

const { Title } = Typography;

const UserList = () => {
  const { t } = useTranslation();
  const [users, setUsers] = useState([]);
  const [isRegionPopup, setIsRegionPopup] = useState(false);
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
    region: '',
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
    console.log(e.target.value, 'and', e.target.name, 'and', e.target.key);

    const { name, value } = e.target;
    console.log(name, value);

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
        await axios.post(
          `/api/express/auth/update/${userPopupData.id}`,
          userPopupData
        );
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
      region: user.region,
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
    <div style={{ width: '100%', padding: 0, margin: 0 }}>
      <Card
        style={{
          width: '100%',
          boxShadow: '0 2px 8px rgba(0,0,0,0.06)',
          borderRadius: 12,
        }}
        bodyStyle={{ padding: 24 }}
      >
        <Title level={3} style={{ marginBottom: 24 }}>
          {t('userList.title') || 'Danh sách người dùng'}
        </Title>
        <Row gutter={[16, 16]} style={{ marginBottom: 16 }}>
          <Col xs={24} sm={16} md={8}>
            <Input
              placeholder={t('userList.searchPlaceholder')}
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              allowClear
            />
          </Col>
          <Col xs={24} sm={8} md={4}>
            <Button
              type="primary"
              block
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
            </Button>
          </Col>
        </Row>
        <Table
          columns={[
            {
              title: t('userList.fullName'),
              dataIndex: 'username',
              key: 'username',
            },
            { title: t('userList.email'), dataIndex: 'email', key: 'email' },
            {
              title: t('userList.address'),
              dataIndex: 'address',
              key: 'address',
            },
            { title: t('userList.phone'), dataIndex: 'phone', key: 'phone' },
            {
              title: t('userList.role'),
              dataIndex: 'role',
              key: 'role',
              render: (role) =>
                role === 'admin' ? t('userList.admin') : t('userList.expert'),
            },
            {
              title: t('userList.status'),
              dataIndex: 'status',
              key: 'status',
              render: (status) =>
                status === 'active'
                  ? t('userList.activeAccount')
                  : t('userList.inactiveAccount'),
            },
            {
              title: t('userList.actions'),
              key: 'actions',
              render: (_, user) => (
                <Space>
                  <Button type="link" onClick={() => handleModifyUser(user)}>
                    {t('userList.editUser')}
                  </Button>
                  {user.role !== 'admin' ? (
                    user.status === 'active' ? (
                      <Button
                        danger
                        type="link"
                        onClick={() => {
                          setSelectedUser(user);
                          setIsConfirmPopupOpen(true);
                        }}
                      >
                        {t('userList.deactivateUser')}
                      </Button>
                    ) : (
                      <Button
                        type="link"
                        onClick={() => handleActivateUser(user.id)}
                      >
                        {t('userList.activateUser')}
                      </Button>
                    )
                  ) : null}
                </Space>
              ),
            },
          ]}
          dataSource={users}
          rowKey="id"
          pagination={false}
          style={{ width: '100%' }}
          locale={{ emptyText: t('userList.noData') }}
        />
        <div style={{ margin: '16px 0', textAlign: 'center' }}>
          <Pagination
            current={1}
            total={users.length}
            pageSize={10}
            showSizeChanger={false}
            // onChange={...} // Add pagination logic if needed
          />
        </div>
        {/* Modals for add/edit, confirm, etc. can be refactored similarly if needed */}
      </Card>
    </div>
  );
};

export default UserList;

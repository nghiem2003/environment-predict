import React, { useState, useEffect } from 'react';
import axios from '../axios';
import { useSelector } from 'react-redux';
import './UserList.css';
import { jwtDecode } from 'jwt-decode';
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
  Form,
  Select,
  message,
} from 'antd';
import {
  EditOutlined,
  DeleteOutlined,
  StopOutlined,
  CheckOutlined,
  UserAddOutlined,
} from '@ant-design/icons';
const { Title } = Typography;

const UserList = () => {
  const { t } = useTranslation();
  const [form] = Form.useForm();
  const { token } = useSelector((state) => state.auth);
  const [authData, setAuthData] = useState(null);
  const [users, setUsers] = useState([]);
  const [isRegionPopup, setIsRegionPopup] = useState(false);
  const [isDeleteConfirmOpen, setIsDeleteConfirmOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [regionList, setRegionList] = useState([]);
  const [districtList, setDistrictList] = useState([]);
  const [filteredDistrictList, setFilteredDistrictList] = useState([]);
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
  const [selectedRegionName, setSelectedRegionName] = useState('');

  // Fetch users from the API
  const fetchUsers = async () => {
    try {
      const { role, province } = authData || {};

      const response = await axios.get('/api/express/auth/', {
        params: { search: searchTerm, role, province },
      });
      console.log(response.data.data);
      setUsers(response.data.data || []);
      const regionResponse = await axios.get('/api/express/areas/provinces');
      setRegionList(regionResponse.data);
      const districtResponse = await axios.get('/api/express/areas/districts');
      setDistrictList(districtResponse.data);
      setFilteredDistrictList(districtResponse.data);
    } catch (error) {
      console.error('Error fetching users:', error);
    }
  };

  useEffect(() => {
    if (token) {
      try {
        console.log('token1', token);
        const decodedToken = jwtDecode(token); // Decode the JWT token
        setAuthData(decodedToken);
        console.log('haha', authData);
      } catch (error) {
        console.error('Error decoding token:', error);
      }
    }
  }, [token]);

  useEffect(() => {
    if (authData) {
      fetchUsers();
    }
  }, [authData, searchTerm]);

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
  const handleUserPopupSubmit = async (values) => {
    // Convert role for backend if needed
    let submitValues = { ...values };
    if (
      values.role === 'province_manager' ||
      values.role === 'district_manager'
    ) {
      submitValues = { ...values, role: 'manager' };
    }
    try {
      if (userPopupData.id) {
        // Update existing user
        const result = await axios.post(
          `/api/express/auth/update/${userPopupData.id}`,
          {
            id: userPopupData.id,
            ...submitValues,
          }
        );
        if (result.status === 200) {
          message.success(
            t('userList.updateSuccess') || 'User updated successfully'
          );
        } else {
          message.error(t('userList.updateFailed') || 'User update failed');
        }
      } else {
        // Create new user
        const result = await axios.post(
          '/api/express/auth/create-user',
          submitValues
        );
        console.log(result);
        if (result.status === 200) {
          message.success(
            t('userList.createSuccess') || 'User created successfully'
          );
        } else {
          message.error(t('userList.createFailed') || 'User creation failed');
        }
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
    const regionName = getRegionNameFromId(user.region);
    console.log(user);

    setFilteredDistrictList(
      districtList.filter((district) => district.province_id === user.province)
    );
    setSelectedRegionName(regionName);
    setUserPopupData({
      id: user.id,
      name: user.username,
      email: user.email,
      address: user.address,
      phone: user.phone,
      password: '', // leave password empty when updating
      province: user.province,
      district: user.district,
    });
    form.setFieldsValue({
      name: user.username,
      email: user.email,
      address: user.address,
      phone: user.phone,
      region: user.region,
    });
    setIsUserPopupOpen(true);
  };

  const handleDeleteUser = async (id) => {
    try {
      // Giả sử endpoint để xoá user là DELETE /api/express/auth/delete/:id
      await axios.delete(`/api/express/auth/delete/${id}`);
      message.success(
        t('userList.deleteSuccess') || 'User deleted successfully'
      );
      setIsDeleteConfirmOpen(false);
      fetchUsers();
    } catch (error) {
      console.error('Error deleting user:', error);
      message.error(t('userList.deleteFailed') || 'Failed to delete user');
    }
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

  // Update the modal open handler to reset region name
  const handleAddUser = () => {
    setSelectedRegionName('');
    setUserPopupData({
      id: null,
      name: '',
      email: '',
      address: '',
      phone: '',
      password: '',
      province: '',
      district: '',
    });
    form.resetFields();
    setIsUserPopupOpen(true);
  };

  // Add this function to handle form values change
  const handleFormValuesChange = (changedValues) => {
    if (changedValues.region) {
      const region = regionList.find((r) => r.id === changedValues.region);
      if (region) {
        setSelectedRegionName(`${region.province}, ${region.name}`);
      }
    }
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
              icon={<UserAddOutlined />}
              block
              onClick={handleAddUser}
            >
              {t('userList.addUser')}
            </Button>
          </Col>
        </Row>
        <div style={{ overflowX: 'auto', width: '100%' }}>
          <Table
            columns={[
              {
                title: t('userList.fullName'),
                dataIndex: 'username',
                key: 'username',
                width: 50,
              },
              {
                title: t('userList.email'),
                dataIndex: 'email',
                key: 'email',
                width: 200,
              },
              {
                title: t('userList.address'),
                dataIndex: 'address',
                key: 'address',
                width: 200,
              },
              {
                title: t('userList.phone'),
                dataIndex: 'phone',
                key: 'phone',
                width: 150,
              },
              {
                title: t('userList.role'),
                dataIndex: 'role',
                key: 'role',
                width: 120,
                render: (role, record) => {
                  if (
                    role === 'manager' ||
                    role === 'province_manager' ||
                    role === 'district_manager'
                  ) {
                    // Use district/province to determine label
                    if (record.district) {
                      return t('userList.districtManager');
                    }
                    if (record.province) {
                      return t('userList.provinceManager');
                    }
                  }
                  return t(`userList.${role}`);
                },
              },
              {
                title: t('userList.status'),
                dataIndex: 'status',
                key: 'status',
                width: 120,
                render: (status) =>
                  status === 'active'
                    ? t('userList.activeAccount')
                    : t('userList.inactiveAccount'),
              },
              {
                title: t('userList.actions'),
                key: 'actions',
                width: 200,
                fixed: 'right',
                render: (_, user) => (
                  <Space size="middle">
                    <Button
                      type="primary"
                      size="small"
                      icon={<EditOutlined />}
                      onClick={() => handleModifyUser(user)}
                    >
                      {t('userList.editUser')}
                    </Button>
                    {user.role !== 'admin' ? (
                      user.status === 'active' ? (
                        <Button
                          danger
                          type="primary"
                          size="small"
                          icon={<StopOutlined />}
                          onClick={() => {
                            setSelectedUser(user);

                            setIsConfirmPopupOpen(true);
                          }}
                        >
                          {t('userList.deactivateUser')}
                        </Button>
                      ) : (
                        <Button
                          type="primary"
                          size="small"
                          icon={<CheckOutlined />}
                          onClick={() => handleActivateUser(user.id)}
                        >
                          {t('userList.activateUser')}
                        </Button>
                      )
                    ) : null}
                    {jwtDecode(token).role === 'admin' &&
                      user.role !== 'admin' && (
                        <Button
                          danger
                          type="default"
                          size="middle"
                          icon={<DeleteOutlined />}
                          onClick={() => {
                            setSelectedUser(user);
                            setIsDeleteConfirmOpen(true);
                          }}
                        >
                          {t('userList.deleteUser') || 'Xoá'}
                        </Button>
                      )}
                  </Space>
                ),
              },
            ]}
            dataSource={users}
            rowKey="id"
            pagination={false}
            scroll={{ x: 1200 }}
            style={{ width: '100%' }}
            locale={{ emptyText: t('userList.noData') }}
          />
        </div>
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

      {/* Add/Modify User Modal */}
      <Modal
        title={
          userPopupData.id ? t('userList.editUser') : t('userList.addUser')
        }
        open={isUserPopupOpen}
        onCancel={() => {
          setIsUserPopupOpen(false);
          form.resetFields();
          setSelectedRegionName('');
        }}
        footer={null}
      >
        <Form
          form={form}
          layout="vertical"
          initialValues={userPopupData}
          onFinish={handleUserPopupSubmit}
          onValuesChange={handleFormValuesChange}
        >
          <Form.Item
            name="name"
            label={t('userList.fullName')}
            rules={[{ required: true, message: t('userList.required') }]}
          >
            <Input />
          </Form.Item>

          <Form.Item
            name="email"
            label={t('userList.email')}
            rules={[
              { required: true, message: t('userList.required') },
              { type: 'email', message: t('userList.invalidEmail') },
            ]}
          >
            <Input />
          </Form.Item>

          <Form.Item
            name="address"
            label={t('userList.address')}
            rules={[{ required: true, message: t('userList.required') }]}
          >
            <Input />
          </Form.Item>

          <Form.Item
            name="phone"
            label={t('userList.phone')}
            rules={[{ required: true, message: t('userList.required') }]}
          >
            <Input />
          </Form.Item>

          {/* Show role select for admin when editing or always when creating */}
          {(!userPopupData.id || jwtDecode(token).role === 'admin') && (
            <Form.Item
              name="role"
              label={t('userList.role')}
              rules={[{ required: true, message: t('userList.required') }]}
            >
              <Select
                placeholder={t('userList.selectRole')}
                options={[
                  {
                    value: 'expert',
                    label: t('userList.expert'),
                  },
                  {
                    value: 'province_manager',
                    label: t('userList.provinceManager'),
                  },
                  {
                    value: 'district_manager',
                    label: t('userList.districtManager'),
                  },
                ]}
                onChange={(value) => {
                  // Province and district logic when changing role
                  if (value === 'province_manager') {
                    // Must have province, reset district
                    if (!form.getFieldValue('province')) {
                      form.setFieldsValue({ province: undefined });
                    }
                    form.setFieldsValue({
                      district: undefined,
                      role: 'province_manager',
                    });
                  } else if (value === 'district_manager') {
                    // Must have province, district
                    if (!form.getFieldValue('province')) {
                      form.setFieldsValue({
                        province: undefined,
                        district: undefined,
                      });
                    } else if (!form.getFieldValue('district')) {
                      form.setFieldsValue({ district: undefined });
                    }
                    form.setFieldsValue({
                      role: 'district_manager',
                    });
                  } else {
                    // expert: must have province, district
                    if (!form.getFieldValue('province')) {
                      form.setFieldsValue({
                        province: undefined,
                        district: undefined,
                      });
                    } else if (!form.getFieldValue('district')) {
                      form.setFieldsValue({ district: undefined });
                    }
                    form.setFieldsValue({
                      role: 'expert',
                    });
                  }
                  form.validateFields(['province', 'district']);
                  const currentProvince = form.getFieldValue('province');
                  if (currentProvince) {
                    setFilteredDistrictList(
                      districtList.filter(
                        (district) => district.province_id === currentProvince
                      )
                    );
                  }
                }}
              />
            </Form.Item>
          )}

          <Form.Item
            name="province"
            label={t('userList.region')}
            rules={[{ required: true, message: t('userList.required') }]}
          >
            <Select
              disabled={jwtDecode(token).role === 'manager'}
              showSearch
              placeholder={t('userList.selectProvince')}
              optionFilterProp="children"
              filterOption={(input, option) =>
                (option?.label ?? '')
                  .toLowerCase()
                  .includes(input.toLowerCase())
              }
              options={regionList.map((region) => ({
                value: region.id,
                label: `${region.name}`,
              }))}
              onChange={(value) => {
                setFilteredDistrictList(
                  districtList.filter(
                    (district) => district.province_id === value
                  )
                );
                form.setFieldsValue({ district: '' });
              }}
            />
          </Form.Item>

          <Form.Item
            name="district"
            label={t('userList.region')}
            rules={[
              {
                required:
                  form.getFieldValue('role') === 'expert' ||
                  form.getFieldValue('role') === 'district_manager',
                message: t('userList.required'),
              },
            ]}
            dependencies={['role', 'province']}
          >
            <Select
              showSearch
              placeholder={t('userList.selectDistrict')}
              optionFilterProp="children"
              disabled={
                !form.getFieldValue('province') ||
                form.getFieldValue('role') === 'province_manager'
              }
              filterOption={(input, option) =>
                (option?.label ?? '')
                  .toLowerCase()
                  .includes(input.toLowerCase())
              }
              options={filteredDistrictList.map((region) => ({
                value: region.id,
                label: `${region.name}`,
              }))}
            />
          </Form.Item>

          {!userPopupData.id && (
            <Form.Item
              name="password"
              label={t('userList.password')}
              rules={[{ required: true, message: t('userList.required') }]}
            >
              <Input.Password />
            </Form.Item>
          )}

          <Form.Item>
            <Space style={{ width: '100%', justifyContent: 'flex-end' }}>
              <Button
                onClick={() => {
                  setIsUserPopupOpen(false);
                  form.resetFields();
                }}
              >
                {t('userList.cancel')}
              </Button>
              <Button type="primary" htmlType="submit">
                {t('userList.save')}
              </Button>
            </Space>
          </Form.Item>
        </Form>
      </Modal>

      {/* Deactivate Confirmation Modal */}
      <Modal
        title={t('userList.deactivateConfirm')}
        open={isConfirmPopupOpen}
        onOk={() => handleDeactivateUser(selectedUser?.id)}
        onCancel={() => setIsConfirmPopupOpen(false)}
        okText={t('userList.yes')}
        cancelText={t('userList.no')}
      >
        <p>{t('userList.deactivateConfirmMessage')}</p>
      </Modal>
      <Modal
        title={t('userList.deleteConfirm') || 'Xác nhận xoá'}
        open={isDeleteConfirmOpen}
        onOk={() => handleDeleteUser(selectedUser?.id)}
        onCancel={() => setIsDeleteConfirmOpen(false)}
        okText={t('userList.yes') || 'Có'}
        cancelText={t('userList.no') || 'Không'}
      >
        <p>
          {t('userList.deleteConfirmMessage') ||
            'Bạn có chắc chắn muốn xóa người dùng này? Hành động này không thể hoàn tác.'}
        </p>
      </Modal>
    </div>
  );
};

export default UserList;

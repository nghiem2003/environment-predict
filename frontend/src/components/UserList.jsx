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
    role: '',
  });
  const [selectedRegionName, setSelectedRegionName] = useState('');
  const [pagination, setPagination] = useState({
    current: 1,
    pageSize: 10,
    total: 0,
  });

  // Fetch users from the API
  const fetchUsers = async (page = 1, pageSize = 10) => {
    try {
      const { role, province } = authData || {};

      const response = await axios.get('/api/express/auth/paginated', {
        params: {
          search: searchTerm,
          role,
          province,
          limit: pageSize,
          offset: (page - 1) * pageSize
        },
      });
      console.log(response.data.users);
      setUsers(response.data.users || []);
      setPagination({
        current: page,
        pageSize: pageSize,
        total: response.data.total || 0,
      });
    } catch (error) {
      console.error('Error fetching users:', error);
    }
  };

  // Fetch provinces and districts independently so selects are always available
  const fetchRegions = async () => {
    try {
      const regionResponse = await axios.get('/api/express/areas/provinces');
      setRegionList(regionResponse.data);
    } catch (error) {
      console.error('Error fetching provinces:', error);
    }
  };

  const fetchDistricts = async () => {
    try {
      const districtResponse = await axios.get('/api/express/areas/districts');
      setDistrictList(districtResponse.data);
      setFilteredDistrictList(districtResponse.data);
    } catch (error) {
      console.error('Error fetching districts:', error);
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

  // Always load provinces/districts once token is available
  useEffect(() => {
    if (token) {
      fetchRegions();
      fetchDistricts();
    }
  }, [token]);

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
    try {
      // Validate required fields
      if (!values.name || !values.email || !values.address || !values.phone || !values.province) {
        message.error('Vui lòng điền đầy đủ thông tin bắt buộc');
        return;
      }

      // Validate role-specific requirements
      if (values.role === 'expert' && !values.district) {
        message.error('Expert role requires district selection');
        return;
      }

      // Validate district belongs to province
      if (values.district) {
        const selectedDistrict = districtList.find(d => d.id === values.district);
        if (selectedDistrict && selectedDistrict.province_id !== values.province) {
          message.error('District does not belong to selected province');
          return;
        }
      }

      // Convert role for backend - keep original role names for clarity
      let submitValues = { ...values };

      // For new users, ensure password is provided
      if (!userPopupData.id && !values.password) {
        message.error('Password is required for new users');
        return;
      }

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
        role: '',
      });
    } catch (error) {
      console.error('Error saving user:', error);
      message.error('Có lỗi xảy ra khi lưu thông tin người dùng');
    }
  };

  // Modify user popup
  const handleModifyUser = (user) => {
    const regionName = getRegionNameFromId(user.province);
    console.log(user);

    // Filter districts based on user's province
    setFilteredDistrictList(
      districtList.filter((district) => district.province_id === user.province)
    );
    setSelectedRegionName(regionName);

    // Convert role for display
    let displayRole = user.role;
    if (user.role === 'manager') {
      displayRole = user.district ? 'district_manager' : 'province_manager';
    }

    setUserPopupData({
      id: user.id,
      name: user.username,
      email: user.email,
      address: user.address,
      phone: user.phone,
      password: '', // leave password empty when updating
      province: user.province,
      district: user.district,
      role: displayRole,
    });

    // Reset form and set values
    form.resetFields();
    form.setFieldsValue({
      name: user.username,
      email: user.email,
      address: user.address,
      phone: user.phone,
      province: user.province,
      district: user.district,
      role: displayRole,
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
      role: '',
    });

    // Reset form completely
    form.resetFields();

    // Pre-fill province/district for managers (especially district managers)
    try {
      if (token) {
        const decoded = jwtDecode(token);
        if (decoded.role === 'manager') {
          if (decoded.province) {
            form.setFieldsValue({ province: decoded.province });
            // Filter district options to selected province
            setFilteredDistrictList(
              districtList.filter((d) => d.province_id === decoded.province)
            );
          }
          if (decoded.district) {
            form.setFieldsValue({ district: decoded.district });
          }
        }
      }
    } catch (e) {
      // ignore decode issues
    }

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
              size='large'
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
              size='large'
              block
              onClick={handleAddUser}
            >
              {t('userList.addUser')}
            </Button>
          </Col>
        </Row>
        <div style={{ overflowX: 'auto', width: '100%', position: 'relative' }}>
          <Table
            className="user-actions-table"
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
                width: 300,
                align: 'center',
                onCell: () => ({
                  style: { whiteSpace: 'nowrap' },
                }),
                render: (_, user) => (
                  <div style={{ display: 'flex', gap: 8, flexWrap: 'nowrap', alignItems: 'center', justifyContent: 'center' }}>
                    <Button
                      type="primary"
                      size="small"
                      icon={<EditOutlined />}
                      onClick={() => handleModifyUser(user)}
                      style={{ whiteSpace: 'nowrap' }}
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
                          style={{ whiteSpace: 'nowrap' }}
                        >
                          {t('userList.deactivateUser')}
                        </Button>
                      ) : (
                        <Button
                          type="primary"
                          size="small"
                          icon={<CheckOutlined />}
                          onClick={() => handleActivateUser(user.id)}
                          style={{ whiteSpace: 'nowrap' }}
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
                          size="small"
                          icon={<DeleteOutlined />}
                          onClick={() => {
                            setSelectedUser(user);
                            setIsDeleteConfirmOpen(true);
                          }}
                          style={{ whiteSpace: 'nowrap' }}
                        >
                          {t('userList.deleteUser') || 'Xoá'}
                        </Button>
                      )}
                  </div>
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
            current={pagination.current}
            total={pagination.total}
            pageSize={pagination.pageSize}
            showSizeChanger={false}
            onChange={(page, pageSize) => fetchUsers(page, pageSize)}
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
        styles={{ body: { maxHeight: '70vh', overflowY: 'auto' } }}
        width={700}
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
            <Input size='large' />
          </Form.Item>

          <Form.Item
            name="email"
            label={t('userList.email')}
            rules={[
              { required: true, message: t('userList.required') },
              { type: 'email', message: t('userList.invalidEmail') },
            ]}
          >
            <Input size='large' />
          </Form.Item>

          <Form.Item
            name="address"
            label={t('userList.address')}
            rules={[{ required: true, message: t('userList.required') }]}
          >
            <Input size='large' />
          </Form.Item>

          <Form.Item
            name="phone"
            label={t('userList.phone')}
            rules={[{ required: true, message: t('userList.required') }]}
          >
            <Input width={50} size='large' />
          </Form.Item>

          {/* Show role select for admin or manager when editing or always when creating */}
          {(!userPopupData.id || ['admin', 'manager'].includes(jwtDecode(token).role)) && (
            <Form.Item
              name="role"
              label={t('userList.role')}
              rules={[{ required: true, message: t('userList.required') }]}
            >
              <Select
                disabled={jwtDecode(token).role === 'manager'}
                size='large'
                placeholder={t('userList.selectRole')}
                options={
                  jwtDecode(token).role === 'manager'
                    ? [
                      {
                        value: 'district_manager',
                        label: t('userList.districtManager'),
                      },
                    ]
                    : [
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
                    ]
                }
                onChange={(value) => {
                  // Simplified role handling
                  form.setFieldsValue({ role: value });

                  // Reset district when role changes
                  form.setFieldsValue({ district: undefined });

                  // If current user is manager, lock province to their own
                  try {
                    const decoded = jwtDecode(token);
                    if (decoded.role === 'manager' && decoded.province) {
                      form.setFieldsValue({ province: decoded.province });
                    }
                  } catch (e) {
                    // ignore decode issues
                  }

                  // Filter districts based on current province
                  const currentProvince = form.getFieldValue('province');
                  if (currentProvince) {
                    setFilteredDistrictList(
                      districtList.filter(
                        (district) => district.province_id === currentProvince
                      )
                    );
                  }

                  // Validate required fields based on role
                  form.validateFields(['province', 'district']);
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
              size='large'
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
              size='large'
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
              <Input.Password size='large' />
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

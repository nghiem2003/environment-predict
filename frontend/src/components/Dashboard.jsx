import React, { useEffect, useState } from 'react';
import { useSelector } from 'react-redux';
import PredictionDetails from './PredictionDetails';
import { jwtDecode } from 'jwt-decode';
import axios from '../axios';
import './Dashboard.css';
import { useTranslation } from 'react-i18next';
import { toast } from 'react-toastify';
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
  Checkbox,
  List,
  Spin,
  message,
} from 'antd';
import { MailOutlined } from '@ant-design/icons';

const { Title } = Typography;

const Dashboard = () => {
  const { t } = useTranslation();
  const { token } = useSelector((state) => state.auth);
  console.log('The token', token);
  const [currentPage, setCurrentPage] = useState(0);
  const [totalPredictions, setTotalPredictions] = useState(0);
  const predictionsPerPage = 10;
  const [showModal, setShowModal] = useState(false);
  const [selectedPredictionId, setSelectedPredictionId] = useState(null);
  const [userId, setUserId] = useState(null);
  const [userRole, setUserRole] = useState(null);
  const [predictionList, setPredictionList] = useState([]);
  const [isManualModalVisible, setIsManualModalVisible] = useState(false);
  const [subscribers, setSubscribers] = useState([]);
  const [selectedEmails, setSelectedEmails] = useState([]);
  const [isLoadingSubscribers, setIsLoadingSubscribers] = useState(false);
  const [isSendingManual, setIsSendingManual] = useState(false);
  const [selectedPrediction, setSelectedPrediction] = useState(null);

  useEffect(() => {
    if (token) {
      try {
        const decodedToken = jwtDecode(token); // Decode the JWT token
        console.log(decodedToken);
        setUserId(decodedToken.id); // Assuming `id` is the field for userId in the token
        setUserRole(decodedToken.role);
        setTimeout(100);
        console.log(userId);
        if (decodedToken.role === 'admin' || decodedToken.role === 'manager') {
          console.log('start fetching');

          axios
            .get(`/api/express/predictions/admin`, {
              params: {
                limit: 10, // Limit number of results per page
                offset: currentPage * 10,
              },
            })
            .then((response) => {
              setPredictionList(response.data.rows);
              console.log(response.data);
              setTotalPredictions(response.data.count); // Set total areas for pagination
            })
            .catch((error) => {
              console.error('Error fetching prediction details:', error);
            });
        } else {
          axios
            .get(`/api/express/predictions/user/${decodedToken.id}`, {
              params: {
                limit: 10, // Limit number of results per page
                offset: currentPage * 10,
              },
            })
            .then((response) => {
              setPredictionList(response.data);
              setTotalPredictions(response.data.length);
              console.log(response.data);
            })
            .catch((error) => {
              console.error('Error fetching prediction details:', error);
            });
        }
      } catch (error) {
        console.error('Error decoding token:', error);
        toast.error(t('dashboard.invalidToken'));
      }
    }
  }, [currentPage]);

  useEffect(() => { }, [predictionList]);

  const handleViewDetails = (predictionId) => {
    setSelectedPredictionId(predictionId);
    setShowModal(true);
  };

  const closeModal = () => {
    setShowModal(false);
    setSelectedPredictionId(null);
  };

  const totalPages = Math.ceil(totalPredictions / predictionsPerPage);
  const handleNextPage = () => {
    if (currentPage < totalPages - 1) {
      setCurrentPage(currentPage + 1);
    }
  };

  const handlePrevPage = () => {
    if (currentPage > 0) {
      setCurrentPage(currentPage - 1);
    }
  };

  // Load subscribers for an area
  const loadSubscribers = async (areaId) => {
    if (!areaId) return;

    setIsLoadingSubscribers(true);
    try {
      const response = await axios.get(`api/express/emails/area/${areaId}/subscribers`);
      setSubscribers(response.data.data.subscribers);
    } catch (error) {
      message.error('Không thể tải danh sách người đăng ký email');
      console.error('Load subscribers error:', error);
    } finally {
      setIsLoadingSubscribers(false);
    }
  };

  // Show manual notification modal
  const showManualNotificationModal = (prediction) => {
    setSelectedPrediction(prediction);
    setIsManualModalVisible(true);
    if (prediction.Area?.id) {
      loadSubscribers(prediction.Area.id);
    }
  };

  // Send manual notification
  const sendManualNotification = async (sendToAll = false) => {
    if (!selectedPrediction || !selectedPrediction.Area?.id) {
      message.error('Thiếu thông tin để gửi thông báo');
      return;
    }

    setIsSendingManual(true);
    try {
      const predictionData = {
        result: `Dự đoán #${selectedPrediction.id}`,
        model: 'Hệ thống dự đoán',
        predictionCount: 1,
        batchPrediction: false
      };

      const payload = {
        areaId: selectedPrediction.Area.id,
        predictionData: predictionData,
        sendToAll: sendToAll,
        ...(sendToAll ? {} : { selectedEmails: selectedEmails })
      };

      const response = await axios.post('api/express/emails/send-manual', payload);

      message.success(response.data.message);
      setIsManualModalVisible(false);
      setSelectedEmails([]);
    } catch (error) {
      message.error('Gửi thông báo thất bại: ' + (error.response?.data?.error || error.message));
    } finally {
      setIsSendingManual(false);
    }
  };

  // Handle email selection
  const handleEmailSelection = (email, checked) => {
    if (checked) {
      setSelectedEmails([...selectedEmails, email]);
    } else {
      setSelectedEmails(selectedEmails.filter(e => e !== email));
    }
  };

  // Select all emails
  const selectAllEmails = () => {
    setSelectedEmails(subscribers.map(sub => sub.email));
  };

  // Deselect all emails
  const deselectAllEmails = () => {
    setSelectedEmails([]);
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
        <Title level={3} style={{ marginBottom: 24, zIndex: 1000 }}>
          {t('dashboard.title')}
        </Title>
        <Table
          columns={[
            {
              title: t('dashboard.id'),
              dataIndex: 'id',
              key: 'id',
              render: (id) => `${t('dashboard.prediction')}#${id}`,
            },
            ...(userRole === 'admin' || userRole === 'manager'
              ? [
                {
                  title: t('dashboard.creator'),
                  dataIndex: ['User', 'username'],
                  key: 'creator',
                },
              ]
              : []),
            {
              title: t('dashboard.area'),
              dataIndex: ['Area', 'name'],
              key: 'area',
            },
            {
              title: 'Ngày tạo',
              dataIndex: 'createdAt',
              key: 'createdAt',
              render: (date) => {
                if (!date) return '-';
                return new Date(date).toLocaleString('vi-VN', {
                  year: 'numeric',
                  month: '2-digit',
                  day: '2-digit',
                  hour: '2-digit',
                  minute: '2-digit'
                });
              },
            },
            ...(userRole === 'admin' || userRole === 'manager'
              ? [
                {
                  title: t('dashboard.province'),
                  dataIndex: ['Area', 'Province', 'name'],
                  key: 'province',
                  render: (text) => text || '-',
                },
                {
                  title: t('dashboard.district'),
                  dataIndex: ['Area', 'District', 'name'],
                  key: 'district',
                  render: (text) => text || '-',
                },
              ]
              : []),
            {
              title: t('dashboard.actions'),
              key: 'actions',
              render: (_, item) => (
                <Space>
                  <Button
                    type="link"
                    onClick={() => handleViewDetails(item.id)}
                  >
                    {t('dashboard.viewDetails')}
                  </Button>
                  {(userRole === 'admin' || userRole === 'manager') && (
                    <Button
                      type="link"
                      icon={<MailOutlined />}
                      onClick={() => showManualNotificationModal(item)}
                    >
                      Gửi thông báo
                    </Button>
                  )}
                </Space>
              ),
            },
          ]}
          dataSource={predictionList}
          rowKey="id"
          pagination={false}
          style={{ width: '100%', overflowX: 'scroll' }}
          scroll={{ x: 'max-content' }}
          locale={{ emptyText: t('dashboard.noData') }}
        />
        <div style={{ margin: '16px 0', textAlign: 'center' }}>
          <Pagination
            current={currentPage + 1}
            total={totalPredictions}
            pageSize={predictionsPerPage}
            onChange={(page) => setCurrentPage(page - 1)}
            showSizeChanger={false}
          />
        </div>
        <Modal
          open={showModal}
          onCancel={closeModal}
          footer={null}
          width={800}
          style={{ maxWidth: '100vw' }}
          styles={{ body: { maxHeight: '70vh', overflowY: 'auto', overflowX: 'auto' } }}
        >
          <div style={{ minWidth: '750px' }}>
            <PredictionDetails predictionId={selectedPredictionId} />
          </div>
        </Modal>

        {/* Manual Notification Modal */}
        <Modal
          title={
            <div style={{ fontSize: '18px', fontWeight: '600', color: '#1890ff' }}>
              📧 Gửi thông báo thủ công
            </div>
          }
          open={isManualModalVisible}
          onCancel={() => {
            setIsManualModalVisible(false);
            setSelectedEmails([]);
          }}
          width={700}
          style={{ top: 20 }}
          footer={[
            <Button
              key="cancel"
              onClick={() => {
                setIsManualModalVisible(false);
                setSelectedEmails([]);
              }}
              size="large"
            >
              Hủy
            </Button>,
            <Button
              key="send-all"
              type="primary"
              loading={isSendingManual}
              onClick={() => sendManualNotification(true)}
              disabled={subscribers.length === 0}
              size="large"
              style={{ marginLeft: '8px' }}
            >
              Gửi cho tất cả ({subscribers.length})
            </Button>,
            <Button
              key="send-selected"
              type="primary"
              loading={isSendingManual}
              onClick={() => sendManualNotification(false)}
              disabled={selectedEmails.length === 0}
              size="large"
              style={{ marginLeft: '8px' }}
            >
              Gửi cho đã chọn ({selectedEmails.length})
            </Button>
          ]}
        >
          <div style={{ padding: '8px 0' }}>
            {selectedPrediction && (
              <div style={{
                marginBottom: '20px',
                padding: '16px',
                backgroundColor: '#f0f8ff',
                borderRadius: '8px',
                border: '1px solid #d6e4ff'
              }}>
                <div style={{ display: 'flex', alignItems: 'center', marginBottom: '8px' }}>
                  <span style={{ fontSize: '16px', marginRight: '8px' }}>📊</span>
                  <strong style={{ fontSize: '16px', color: '#1890ff' }}>Thông tin dự đoán</strong>
                </div>
                <div style={{ marginLeft: '24px' }}>
                  <p style={{ margin: '4px 0', fontSize: '14px' }}>
                    <strong>Dự đoán:</strong> <span style={{ color: '#1890ff' }}>#{selectedPrediction.id}</span>
                  </p>
                  <p style={{ margin: '4px 0', fontSize: '14px' }}>
                    <strong>Khu vực:</strong> {selectedPrediction.Area?.name}
                  </p>
                  <p style={{ margin: '4px 0', fontSize: '14px' }}>
                    <strong>Loại khu vực:</strong> {selectedPrediction.Area?.area_type}
                  </p>
                  {selectedPrediction.createdAt && (
                    <p style={{ margin: '4px 0', fontSize: '14px' }}>
                      <strong>Ngày tạo:</strong> {new Date(selectedPrediction.createdAt).toLocaleString('vi-VN', {
                        year: 'numeric',
                        month: '2-digit',
                        day: '2-digit',
                        hour: '2-digit',
                        minute: '2-digit'
                      })}
                    </p>
                  )}
                </div>
              </div>
            )}

            <div style={{ marginBottom: '16px' }}>
              <div style={{ display: 'flex', alignItems: 'center', marginBottom: '12px' }}>
                <span style={{ fontSize: '16px', marginRight: '8px' }}>👥</span>
                <strong style={{ fontSize: '16px', color: '#52c41a' }}>Chọn người nhận thông báo</strong>
              </div>
              <p style={{ color: '#666', fontSize: '14px', margin: '0 0 16px 24px' }}>
                Click vào dòng để chọn/bỏ chọn người dùng
              </p>
            </div>

            {isLoadingSubscribers ? (
              <div style={{ textAlign: 'center', padding: '40px 20px' }}>
                <Spin size="large" tip="Đang tải danh sách người đăng ký..." />
              </div>
            ) : subscribers.length > 0 ? (
              <div>
                <div style={{
                  marginBottom: '16px',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  padding: '0 4px'
                }}>
                  <Space>
                    <Button
                      size="middle"
                      onClick={selectAllEmails}
                      style={{ borderRadius: '6px' }}
                    >
                      ✅ Chọn tất cả
                    </Button>
                    <Button
                      size="middle"
                      onClick={deselectAllEmails}
                      style={{ borderRadius: '6px' }}
                    >
                      ❌ Bỏ chọn tất cả
                    </Button>
                  </Space>
                  <span style={{
                    fontSize: '14px',
                    color: '#1890ff',
                    fontWeight: '500'
                  }}>
                    Đã chọn: {selectedEmails.length}/{subscribers.length}
                  </span>
                </div>

                <List
                  dataSource={subscribers}
                  renderItem={(subscriber) => (
                    <List.Item
                      style={{
                        padding: '8px 0',
                        cursor: 'pointer',
                        borderRadius: '4px',
                        margin: '2px 0',
                        transition: 'background-color 0.2s',
                      }}
                      onClick={() => handleEmailSelection(subscriber.email, !selectedEmails.includes(subscriber.email))}
                      onMouseEnter={(e) => {
                        e.currentTarget.style.backgroundColor = '#f5f5f5';
                      }}
                      onMouseLeave={(e) => {
                        e.currentTarget.style.backgroundColor = 'transparent';
                      }}
                    >
                      <div style={{ display: 'flex', alignItems: 'center', width: '100%' }}>
                        <Checkbox
                          checked={selectedEmails.includes(subscriber.email)}
                          onChange={(e) => {
                            e.stopPropagation();
                            handleEmailSelection(subscriber.email, e.target.checked);
                          }}
                          style={{ marginRight: '12px' }}
                        />
                        <span style={{ flex: 1, fontSize: '14px' }}>
                          {subscriber.email}
                        </span>
                      </div>
                    </List.Item>
                  )}
                  style={{
                    maxHeight: '300px',
                    overflowY: 'auto',
                    border: '1px solid #d9d9d9',
                    borderRadius: '6px',
                    padding: '8px 0'
                  }}
                />
              </div>
            ) : (
              <div style={{
                textAlign: 'center',
                padding: '40px 20px',
                color: '#999',
                backgroundColor: '#fafafa',
                borderRadius: '8px',
                border: '1px dashed #d9d9d9'
              }}>
                <div style={{ fontSize: '48px', marginBottom: '16px' }}>📭</div>
                <p style={{ fontSize: '16px', margin: '0 0 8px 0', fontWeight: '500' }}>
                  Không có người đăng ký email
                </p>
                <p style={{ fontSize: '14px', margin: '0' }}>
                  Chưa có ai đăng ký nhận thông báo cho khu vực này
                </p>
              </div>
            )}
          </div>
        </Modal>
      </Card>
    </div>
  );
};

export default Dashboard;

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
} from 'antd';

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

  useEffect(() => {
    if (token) {
      try {
        const decodedToken = jwtDecode(token); // Decode the JWT token
        console.log(decodedToken);
        setUserId(decodedToken.id); // Assuming `id` is the field for userId in the token
        setUserRole(decodedToken.role);
        setTimeout(100);
        console.log(userId);
        if (decodedToken.role === 'admin') {
          console.log('start ftching');

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

  useEffect(() => {}, [predictionList]);

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
            ...(userRole === 'admin'
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
                </Space>
              ),
            },
          ]}
          dataSource={predictionList}
          rowKey="id"
          pagination={false}
          style={{ width: '100%' }}
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
        <Modal open={showModal} onCancel={closeModal} footer={null} width={800}>
          <PredictionDetails predictionId={selectedPredictionId} />
        </Modal>
      </Card>
    </div>
  );
};

export default Dashboard;

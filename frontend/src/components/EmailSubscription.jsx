import React, { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { useParams } from 'react-router-dom';
import {
  Card,
  Form,
  Input,
  Button,
  Alert,
  Typography,
  Space,
  Spin,
} from 'antd';
import {
  MailOutlined,
  CheckCircleOutlined,
  ExclamationCircleOutlined,
} from '@ant-design/icons';
import axios from '../axios';

const { Title, Text } = Typography;

const EmailSubscription = () => {
  const { t } = useTranslation();
  const { areaId } = useParams();
  const [form] = Form.useForm();
  const [isSubscribed, setIsSubscribed] = useState(false);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');
  const [area, setArea] = useState(null);
  const [areaLoading, setAreaLoading] = useState(true);

  // Fetch area information
  useEffect(() => {
    const fetchArea = async () => {
      try {
        const response = await axios.get(`/api/express/areas/area/${areaId}`);
        setArea(response.data);
      } catch (error) {
        setError('Không thể tải thông tin khu vực');
      } finally {
        setAreaLoading(false);
      }
    };

    if (areaId) {
      fetchArea();
    }
  }, [areaId]);

  const handleSubscribe = async (values) => {
    setLoading(true);
    setError('');
    setMessage('');

    try {
      const response = await axios.post('/api/express/emails/subscribe', {
        email: values.email,
        area_id: areaId,
      });

      setMessage(response.data.message);
      setIsSubscribed(true);
      form.resetFields();
    } catch (err) {
      if (err.response?.data?.error) {
        setError(err.response.data.error);
      } else {
        setError(t('email.createFailed'));
      }
    } finally {
      setLoading(false);
    }
  };

  const handleSubscribeAnother = () => {
    setIsSubscribed(false);
    setMessage('');
    setError('');
    form.resetFields();
  };

  if (areaLoading) {
    return (
      <div style={{ textAlign: 'center', padding: '50px' }}>
        <Spin size="large" />
        <div style={{ marginTop: 16 }}>Đang tải thông tin khu vực...</div>
      </div>
    );
  }

  if (!area) {
    return (
      <Alert
        message="Lỗi"
        description="Không tìm thấy thông tin khu vực"
        type="error"
        showIcon
      />
    );
  }

  return (
    <div
      style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        minHeight: '50vh',
        padding: '20px',
      }}
    >
      <Card
        title={
          <Space>
            <MailOutlined />
            <span>{t('email.subscriptions')}</span>
          </Space>
        }
        style={{ maxWidth: 500, width: '100%' }}
      >
        <Text type="secondary">
          Đăng ký nhận thông báo cho khu vực <Text strong>{area.name}</Text>
        </Text>

        {!isSubscribed ? (
          <Form
            form={form}
            layout="vertical"
            onFinish={handleSubscribe}
            style={{ marginTop: 16 }}
          >
            <Form.Item
              name="email"
              label={t('email.email')}
              rules={[
                { required: true, message: t('email.required') },
                { type: 'email', message: t('email.invalidEmail') },
              ]}
            >
              <Input
                placeholder="your-email@example.com"
                disabled={loading}
                prefix={<MailOutlined />}
              />
            </Form.Item>

            <Form.Item>
              <Button
                type="primary"
                htmlType="submit"
                loading={loading}
                icon={<MailOutlined />}
                block
              >
                Đăng ký nhận thông báo
              </Button>
            </Form.Item>
          </Form>
        ) : (
          <div style={{ textAlign: 'center', marginTop: 16 }}>
            <Alert
              message="Đăng ký thành công"
              description={message}
              type="success"
              showIcon
              icon={<CheckCircleOutlined />}
              style={{ marginBottom: 16 }}
            />
            <Button onClick={handleSubscribeAnother} type="default">
              Đăng ký email khác
            </Button>
          </div>
        )}

        {error && (
          <Alert
            message="Lỗi"
            description={error}
            type="error"
            showIcon
            icon={<ExclamationCircleOutlined />}
            style={{ marginTop: 16 }}
          />
        )}

        {message && !isSubscribed && (
          <Alert
            message="Thành công"
            description={message}
            type="success"
            showIcon
            icon={<CheckCircleOutlined />}
            style={{ marginTop: 16 }}
          />
        )}
      </Card>
    </div>
  );
};

export default EmailSubscription;

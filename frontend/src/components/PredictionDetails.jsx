import React, { useState, useEffect } from 'react';
import axios from '../axios';
import { useTranslation } from 'react-i18next';
import { Typography, Descriptions, Table, Spin } from 'antd';

const { Title, Text } = Typography;

const PredictionDetails = ({ predictionId }) => {
  const [prediction, setPrediction] = useState(null);
  const { t } = useTranslation();
  useEffect(() => {
    axios
      .get(`/api/express/predictions/${predictionId}`)
      .then((response) => {
        setPrediction(response.data);
      })
      .catch((error) => {
        console.error('Error fetching prediction details:', error);
      });
  }, [predictionId]);

  if (!prediction)
    return (
      <Spin
        tip={t('predictionDetails.loading')}
        style={{ width: '100%', margin: '32px 0' }}
      />
    );

  const getPredictionText = (prediction) => {
    if (prediction.prediction_text == -1) {
      return (
        t('predictionDetails.unsuitable') ||
        'The environment is unsuitable or dangerous for growth'
      );
    } else if (prediction.prediction_text == 1) {
      return (
        t('predictionDetails.excellent') ||
        'The environment is excellent for oyster growth'
      );
    } else {
      return (
        t('predictionDetails.suitable') ||
        'The environment is suitable for growth'
      );
    }
  };

  const columns = [
    {
      title: t('predictionDetails.element'),
      dataIndex: 'name',
      key: 'name',
    },
    {
      title: t('predictionDetails.value'),
      dataIndex: ['PredictionNatureElement', 'value'],
      key: 'value',
      render: (_, record) => record.PredictionNatureElement.value,
    },
  ];

  return (
    <div style={{ width: '100%' }}>
      <Title level={3} style={{ marginBottom: 16 }}>
        {t('predictionDetails.title')}
      </Title>
      <Descriptions
        bordered
        column={1}
        size="large"
        style={{ marginBottom: 24 }}
      >
        <Descriptions.Item label={t('predictionDetails.id')}>
          {prediction.id}
        </Descriptions.Item>
        <Descriptions.Item label={t('predictionDetails.area')}>
          {prediction.Area.name}, {prediction.Area.address}
        </Descriptions.Item>
        <Descriptions.Item label={t('predictionDetails.areaType')}>
          {prediction.Area.area_type}
        </Descriptions.Item>
        <Descriptions.Item label={t('predictionDetails.predictionText')}>
          {getPredictionText(prediction)}
        </Descriptions.Item>
        <Descriptions.Item label={t('predictionDetails.expertId')}>
          {prediction.user_id}
        </Descriptions.Item>
      </Descriptions>
      <Title level={4} style={{ marginBottom: 12 }}>
        {t('predictionDetails.naturalElements')}
      </Title>
      <Table
        columns={columns}
        dataSource={prediction.NaturalElements}
        rowKey="id"
        pagination={false}
        size="large"
        bordered
      />
    </div>
  );
};

export default PredictionDetails;

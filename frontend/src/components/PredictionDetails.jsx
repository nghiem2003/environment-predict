import React, { useState, useEffect } from 'react';
import axios from '../axios';
import './PredictionDetails.css';
import { useTranslation } from 'react-i18next';

const PredictionDetails = ({ predictionId }) => {
  const [prediction, setPrediction] = useState(null);
  const { t } = useTranslation()
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
    return <div className="loading">{t('predictionDetails.loading')}</div>;

  const getPredictionText = (prediction) => {
    if (prediction.prediction_text == -1) {
      return 'The environment is unsuitable or dangerous for growth';
    } else if (prediction.prediction_text == 1) {
      return 'The environment is excellent for oyster growth';
    } else {
      return 'The environment is suitable for growth';
    }
  };
  return (
    <div className="prediction-details-container">
      <h1 className="title">{t('predictionDetails.title')}</h1>
      <h2>{t('predictionDetails.id')}: {prediction.id}</h2>
      <p>
        <strong>{t('predictionDetails.area')}:</strong> {prediction.Area.name}, {prediction.Area.address}
      </p>
      <p>
        <strong>{t('predictionDetails.areaType')}:</strong> {prediction.Area.area_type}
      </p>
      <p>
        <strong>{t('predictionDetails.predictionText')}:</strong> {getPredictionText(prediction)}
      </p>
      <p>
        <strong>{t('predictionDetails.expertId')}:</strong> {prediction.user_id}
      </p>
      <h3>{t('predictionDetails.naturalElements')}</h3>
      <table className="elements-table">
        <thead>
          <tr>
            <th>{t('predictionDetails.element')}</th>
            <th>{t('predictionDetails.value')}</th>
          </tr>
        </thead>
        <tbody>
          {prediction.NaturalElements.map((element) => (
            <tr key={element.id}>
              <td>{element.name}</td>
              <td>{element.PredictionNatureElement.value}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default PredictionDetails;

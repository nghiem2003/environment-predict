import React, { useState, useEffect } from 'react';
import axios from '../axios';
import MapView from './MapView'; // Ensure the MapView component is imported correctly
import { useNavigate, useParams } from 'react-router-dom';
import './Prediction.css';
import { useTranslation } from 'react-i18next';

const Prediction = () => {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const isLoading = false;
  const { areaId } = useParams();
  console.log('areaId:', areaId);
  const [area, setArea] = useState(null);
  const [prediction, setPrediction] = useState(null);

  // Helper function to format prediction text
  const getPredictionText = (prediction) => {
    if (prediction.prediction_text == -1) {
      return t('prediction.unsuitable');
    } else if (prediction.prediction_text == 1) {
      return t('prediction.excellent');
    } else {
      return t('prediction.suitable');
    }
  };

  const fetchArea = async () => {
      
      
      try {
        // Fetch area details
        console.log('hello');
        
        const areaResponse = await axios.get(
          `/api/express/areas/area/${areaId}`
        );
        setArea(areaResponse.data);
        console.log('area:',areaResponse.data);
        // Fetch the latest prediction for the area
        
        
      } catch (error) {
        console.error('Error fetching data:', error);
      }
    };

    const fetchPrediction = async () => {
      try {
        const predictionResponse = await axios.get(
          `/api/express/predictions/${areaId}/latest`
        );
        if(predictionResponse.data) setPrediction(predictionResponse.data);
        console.log(predictionResponse.data);
      }
      catch(err) {
        console.log(err);
      }  
    }

  useEffect(() => {
    fetchArea();
    fetchPrediction();
  }, [areaId]);
  return (
    <>
      {
        !area ? (
      <div className="prediction-container">
        <a href='/' >{t('prediction.return')}</a>
        {t('prediction.loadingArea')}
      </div>
    ) :
      prediction ? 
      <div className="prediction-container">
        <a href='/' >{t('prediction.return')}</a>
      <h1>{t('prediction.title', { area: area.name })}</h1>
      <p>{getPredictionText(prediction)}</p>
      <MapView
        latitude={area?.latitude}
        longitude={area?.longitude}
        result={prediction?.prediction_text}
        area={area?.area}
      />
    </div>: <div className="prediction-container">
      <a href='/' >{t('prediction.return')}</a>
       <h1>{t('prediction.title', { area: area.name })}</h1>
      <div> {t('prediction.noPrediction')}{' '}<a href='/'>{t('prediction.goBack')}</a></div>
  <MapView
        latitude={area?.latitude}
        longitude={area?.longitude}
        result={-2}
        area={area?.area}
      />
  </div>
      }
    
    </>
  );
};

export default Prediction;

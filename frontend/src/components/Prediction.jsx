import React, { useState, useEffect } from 'react';
import axios from '../axios';
import MapView from './MapView'; // Ensure the MapView component is imported correctly
import { useParams } from 'react-router-dom';
import './Prediction.css';

const Prediction = () => {
  const { areaId } = useParams();
  const [area, setArea] = useState(null);
  const [prediction, setPrediction] = useState(null);

  // Helper function to format prediction text
  const getPredictionText = (prediction) => {
    if (prediction.prediction_text == -1) {
      return 'The environment is unsuitable or dangerous for growth';
    } else if (prediction.prediction_text == 1) {
      return 'The environment is excellent for oyster growth';
    } else {
      return 'The environment is suitable for growth';
    }
  };

  useEffect(() => {
    const fetchAreaAndPrediction = async () => {
      try {
        // Fetch area details
        const areaResponse = await axios.get(
          `/api/express/areas/${areaId}`
        );
        setArea(areaResponse.data);

        // Fetch the latest prediction for the area
        const predictionResponse = await axios.get(
          `/api/express/predictions/${areaId}/latest`
        );
        setPrediction(predictionResponse.data);
      } catch (error) {
        console.error('Error fetching data:', error);
      }
    };

    fetchAreaAndPrediction();
  }, [areaId]);

  if (!area || !prediction) return <div>Loading prediction...</div>;

  return (
    <div className="prediction-container">
      <h1>Prediction for {area.name}</h1>
      <p>{getPredictionText(prediction)}</p>
      <MapView
        latitude={area.latitude}
        longitude={area.longitude}
        result={prediction.prediction_text}
      />
    </div>
  );
};

export default Prediction;

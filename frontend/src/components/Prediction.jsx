import React, { useState, useEffect } from 'react';
import axios from '../axios';
import MapView from './MapView'; // Ensure the MapView component is imported correctly
import { useParams,useNavigate } from 'react-router-dom';
import './Prediction.css';

const Prediction = () => {
  const isLoading = false;
  const navigate = useNavigate();
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
        console.log(areaResponse.data);
        // Fetch the latest prediction for the area
        const predictionResponse = await axios.get(
          `/api/express/predictions/${areaId}/latest`
        );
        setPrediction(predictionResponse.data);
        console.log(predictionResponse.data);
        
      } catch (error) {
        console.error('Error fetching data:', error);
      }
    };

    fetchAreaAndPrediction();
  }, [areaId]);

  if (!area || !prediction) return <><div className="prediction-container">No prediction has been made.Click <a href='/'>here</a> to come back to welcome page</div></>

  return (
    <div className="prediction-tab">
    <div className="prediction-container">
      <h1>Prediction in {area.name}</h1>
      <p>{getPredictionText(prediction)}</p>
      <MapView
        latitude={area.latitude}
        longitude={area.longitude}
        result={prediction.prediction_text}
        area={area.area}
      />
    </div>
    </div>
  );
};

export default Prediction;

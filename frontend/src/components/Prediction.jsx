import React, { useState, useEffect } from 'react';
import axios from '../axios';
import MapView from './MapView'; // Ensure the MapView component is imported correctly
import { useParams } from 'react-router-dom';
import './Prediction.css';

const Prediction = () => {
  const isLoading = false;
  const { areaId } = useParams();
  console.log('areaId:', areaId);
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
    <div className="prediction-tab">
      {
        !area ? (
      <div className="prediction-container">
        Loading area data...
      </div>
    ) :
      prediction ? 
      <div className="prediction-container">
      <h1>Prediction in {area.name}</h1>
      <p>{getPredictionText(prediction)}</p>
      <MapView
        latitude={area?.latitude}
        longitude={area?.longitude}
        result={prediction?.prediction_text}
        area={area?.area}
      />
    </div>: <div className="prediction-container">
       <h1>Prediction in {area.name}</h1>
      <div>No prediction has been made.Click <a href='/'>here</a> to come back to welcome page</div>
  <MapView
        latitude={area?.latitude}
        longitude={area?.longitude}
        result={-2}
        area={area?.area}
      />
  </div>
      }
    
    </div>
  );
};

export default Prediction;

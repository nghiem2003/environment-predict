import React, { useState, useEffect } from 'react';
import axios from '../axios';
import './PredictionDetails.css';

const PredictionDetails = ({ predictionId }) => {
  const [prediction, setPrediction] = useState(null);

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
    return <div className="loading">Loading prediction details...</div>;

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
      <h1 className="title">Prediction Details</h1>
      <h2>Prediction ID: {prediction.id}</h2>
      <p>
        <strong>Area:</strong> {prediction.Area.name}, {prediction.Area.address}
      </p>
      <p>
        <strong>Area Type:</strong> {prediction.Area.area_type}
      </p>
      <p>
        <strong>Prediction Text:</strong> {getPredictionText(prediction)}
      </p>
      <p>
        <strong>Expert ID:</strong> {prediction.user_id}
      </p>
      <h3>Natural Elements</h3>
      <table className="elements-table">
        <thead>
          <tr>
            <th>Element</th>
            <th>Value</th>
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

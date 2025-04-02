import React, { useState } from 'react';
import './CSVBatchPredictionPopup.css';

const CSVBatchPredictionPopup = ({ onClose }) => {
  const [area, setArea] = useState('');
  const [model, setModel] = useState('');
  const [csvElements, setCsvElements] = useState([]);

  const handleCSVUpload = (e) => {
    const file = e.target.files[0];

    const reader = new FileReader();
    reader.onload = (event) => {
      const text = event.target.result;
      const elements = text.split(/\r?\n/).filter((line) => line);
      setCsvElements(elements);
    };
    reader.readAsText(file);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log({ area, model, csvElements });

    // API call here...

    onClose();
  };

  return (
    <div className="popup-overlay">
      <div className="popup-container">
        <button className="close-btn" onClick={onClose}>
          &times;
        </button>
        <h2>CSV Batch Prediction</h2>
        <form onSubmit={handleSubmit}>
          <label>Area:</label>
          <input
            type="text"
            value={area}
            onChange={(e) => setArea(e.target.value)}
            required
          />

          <label>Model:</label>
          <input
            type="text"
            value={model}
            onChange={(e) => setModel(e.target.value)}
            required
          />

          <label>Upload CSV File:</label>
          <input
            type="file"
            accept=".csv"
            onChange={handleCSVUpload}
            required
          />

          {csvElements.length > 0 && (
            <div className="csv-elements">
              <strong>CSV Elements:</strong>
              <ul>
                {csvElements.map((el, idx) => (
                  <li key={idx}>{el}</li>
                ))}
              </ul>
            </div>
          )}

          <button type="submit" className="submit-btn">
            Predict
          </button>
        </form>
      </div>
    </div>
  );
};

export default CSVBatchPredictionPopup;

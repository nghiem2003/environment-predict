import React, { useEffect, useState } from 'react';
import { useSelector } from 'react-redux';
import PredictionDetails from './PredictionDetails';
import { jwtDecode } from 'jwt-decode';
import axios from '../axios';
import './Dashboard.css';

const Dashboard = () => {
  const { token } = useSelector((state) => state.auth);
  console.log('The token',token);

  const [showModal, setShowModal] = useState(false);
  const [selectedPredictionId, setSelectedPredictionId] = useState(null);
  const [userId, setUserId] = useState(null);
  const [predictionList, setPredictionList] = useState([]);

  useEffect(() => {
    if (token) {
      try {
        const decodedToken = jwtDecode(token); // Decode the JWT token
        console.log(decodedToken);
        setUserId(decodedToken.id); // Assuming `id` is the field for userId in the token
        setTimeout(100);
        console.log(userId);
        if(decodedToken.role === 'admin') {
          console.log('start ftching');
          
          axios
          .get(`/api/express/predictions/admin`).then((response) => {
            setPredictionList(response.data);
          })
          .catch((error) => {
            console.error('Error fetching prediction details:', error);
          });
        }else{
        axios
          .get(`/api/express/predictions/user/${decodedToken.id}`)
          .then((response) => {
            setPredictionList(response.data);
          })
          .catch((error) => {
            console.error('Error fetching prediction details:', error);
          });
        }
      } catch (error) {
        console.error('Error decoding token:', error);
        alert('Invalid token. Please log in again.');
      }
    }
  }, []);

  useEffect(() => {}, [predictionList]);

  const handleViewDetails = (predictionId) => {
    setSelectedPredictionId(predictionId);
    setShowModal(true);
  };

  const closeModal = () => {
    setShowModal(false);
    setSelectedPredictionId(null);
  };

  return (
    <div className={`dashboard-container ${showModal ? 'blurred' : ''}`}>
      <div className="dashboard-card">
        <h1>Dashboard</h1>
        <h2>All Predictions</h2>
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {predictionList.length > 0 ? (
              predictionList.map((item) => (
                <tr>
                  <td className='predict-id'>Prediction#{item.id}</td>
                  <td className='action'>
                    <button
                      className="view-details-btn"
                      onClick={() => handleViewDetails(item.id)}
                    >
                      View Details
                    </button>
                  </td>
                </tr>
              ))
            ) : (
              <tr><td className='predict-id'></td><td className='action'></td></tr>
            )}
          </tbody>
        </table>
      </div>

      {showModal && (
        <div className="modal-overlay">
          <div className="modal-content">
            <button className="close-btn" onClick={closeModal}>
              &times;
            </button>
            <PredictionDetails predictionId={selectedPredictionId} />
          </div>
        </div>
      )}
    </div>
  );
};

export default Dashboard;

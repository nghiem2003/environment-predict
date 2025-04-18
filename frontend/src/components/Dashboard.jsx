import React, { useEffect, useState } from 'react';
import { useSelector } from 'react-redux';
import PredictionDetails from './PredictionDetails';
import { jwtDecode } from 'jwt-decode';
import axios from '../axios';
import './Dashboard.css';

const Dashboard = () => {
  const { token } = useSelector((state) => state.auth);
  console.log('The token',token);
  const [currentPage, setCurrentPage] = useState(0);
  const [totalPredictions, setTotalPredictions] = useState(0);
  const predictionsPerPage = 10;
  const [showModal, setShowModal] = useState(false);
  const [selectedPredictionId, setSelectedPredictionId] = useState(null);
  const [userId, setUserId] = useState(null);
  const [userRole,setUserRole] = useState(null)
  const [predictionList, setPredictionList] = useState([]);

  useEffect(() => {
    if (token) {
      try {
        const decodedToken = jwtDecode(token); // Decode the JWT token
        console.log(decodedToken);
        setUserId(decodedToken.id); // Assuming `id` is the field for userId in the token
        setUserRole(decodedToken.role)
        setTimeout(100);
        console.log(userId);
        if(decodedToken.role === 'admin') {
          console.log('start ftching');
          
          axios
          .get(`/api/express/predictions/admin`,{
            params: {
              limit: 10, // Limit number of results per page
              offset: currentPage * 10,
            }
          }
          ).then((response) => {
            setPredictionList(response.data.rows);
            console.log(response.data);
            setTotalPredictions(response.data.count); // Set total areas for pagination
          })
          .catch((error) => {
            console.error('Error fetching prediction details:', error);
          });
        }else{
        axios
          .get(`/api/express/predictions/user/${decodedToken.id}`,{
            params: {
              limit: 10, // Limit number of results per page
              offset: currentPage * 10,
            }
          })
          .then((response) => {
            setPredictionList(response.data);
             setTotalPredictions(response.data.length);
             console.log(response.data);

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
  }, [currentPage]);

  useEffect(() => {}, [predictionList]);

  const handleViewDetails = (predictionId) => {
    setSelectedPredictionId(predictionId);
    setShowModal(true);
  };

  const closeModal = () => {
    setShowModal(false);
    setSelectedPredictionId(null);
  };

    const totalPages = Math.ceil(totalPredictions / predictionsPerPage);
  const handleNextPage = () => {
    if (currentPage < totalPages - 1) {
      setCurrentPage(currentPage + 1);
    }
  };

  const handlePrevPage = () => {
    if (currentPage > 0) {
      setCurrentPage(currentPage - 1);
    }
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
              {userRole === 'admin' ?<th>Creator</th> : <></>}
              <th>Area</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {predictionList.length > 0 ? (
              predictionList.map((item) => (
                <tr>
                  <td className='predict-id'>Prediction#{item.id}</td>
                  {userRole === 'admin' ?<td>{item.User.username}</td> : <></>}
                  <td>{item.Area.name}</td>
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
        <div className="pagination">
        <button onClick={handlePrevPage} disabled={currentPage === 0}>
          Previous
        </button>
        <span>Page {currentPage + 1} of {totalPages}</span>
        <button onClick={handleNextPage} disabled={currentPage === totalPages - 1}>
          Next
        </button>
      </div>
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

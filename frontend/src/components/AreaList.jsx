import React, { useState, useEffect } from 'react';
import axios from '../axios';
import './AreaList.css';

const AreaList = () => {
  const [areas, setAreas] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [areaType, setAreaType] = useState('');
  const [latRange, setLatRange] = useState({ min: '', max: '' });
  const [longRange, setLongRange] = useState({ min: '', max: '' });
  const [isPopupOpen, setIsPopupOpen] = useState(false);
  const [isDeleteConfirmOpen, setIsDeleteConfirmOpen] = useState(false);
  const [selectedArea, setSelectedArea] = useState(null);
  const [newArea, setNewArea] = useState({
    areaName: '',
    lat: '',
    long: '',
    address: '',
    area_type: 'oyster',
  });

  // Fetch areas from the API
  const fetchAreas = async () => {
    try {
      const response = await axios.get('/api/express/areas', {
        params: {
          search: searchTerm,
          area_type: areaType,
          lat_min: latRange.min,
          lat_max: latRange.max,
          long_min: longRange.min,
          long_max: longRange.max,
        },
      });
      setAreas(response.data);
      console.log(response.data);
      
    } catch (error) {
      console.error('Error fetching areas:', error);
    }
  };

  // Fetch areas when dependencies change
  useEffect(() => {
    fetchAreas();
  }, [searchTerm, areaType, latRange, longRange]);

  const handleAddArea = async (e) => {
    e.preventDefault();
    try {
      if (newArea.id) {
        // Update existing area
        await axios.put(`/api/express/areas/${newArea.id}`, newArea);
      } else {
        // Create new area
        await axios.post('/api/express/areas', newArea);
      }
      setIsPopupOpen(false); // Close the popup after successful creation
      fetchAreas(); // Refresh the area list
      setNewArea({ areaName: '', lat: '', long: '', address: '', area_type: 'oyster' });
    } catch (error) {
      console.error('Error saving area:', error);
    }
  };

  const handleDelete = async (id) => {
    try {
      await axios.delete(`/api/express/areas/${id}`);
      setIsDeleteConfirmOpen(false); // Close delete confirmation
      fetchAreas(); // Refresh the area list after deletion
    } catch (error) {
      console.error('Error deleting area:', error);
    }
  };

  const handleUpdate = (id) => {
    const areaToUpdate = areas.find((area) => area.id === id);
    console.log(areaToUpdate);
    
    setNewArea(areaToUpdate); // Pre-fill the form with the existing area data
    setIsPopupOpen(true); // Open the popup to edit
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;    
    setNewArea((prevState) => {
        const updatedState = {
      ...prevState,
      [name]: value
    }; 
    return updatedState;
    });
    console.log(newArea);
  };

  const handleSearch = (e) => {
    setSearchTerm(e.target.value);
  };

  return (
    <div className="app">
      <div className="header">
        <input
          type="text"
          placeholder="Search by area name"
          value={searchTerm}
          onChange={handleSearch}
          className="search-input"
        />
        <select
          onChange={(e) => setAreaType(e.target.value)}
          value={areaType}
          className="filter-select"
          
        >
          <option value="" disabled>Select Area Type</option>
          <option value="">All</option>
          <option value="oyster">Oyster</option>
          <option value="cobia">Cobia</option>
        </select>
        <div className="latlong-filter">
          <input
            type="number"
            placeholder="Min Lat"
            value={latRange.min}
            onChange={(e) => setLatRange({ ...latRange, min: e.target.value })}
            className="filter-input"
          />
          <input
            type="number"
            placeholder="Max Lat"
            value={latRange.max}
            onChange={(e) => setLatRange({ ...latRange, max: e.target.value })}
            className="filter-input"
          />
          <input
            type="number"
            placeholder="Min Long"
            value={longRange.min}
            onChange={(e) => setLongRange({ ...longRange, min: e.target.value })}
            className="filter-input"
          />
          <input
            type="number"
            placeholder="Max Long"
            value={longRange.max}
            onChange={(e) => setLongRange({ ...longRange, max: e.target.value })}
            className="filter-input"
          />
        </div>
        <button className="add-btn" onClick={() => setIsPopupOpen(true)}>
          Add New Area
        </button>
      </div>

      <table className="area-table">
        <thead>
          <tr>
            <th>Area Name</th>
            <th>Area Type</th>
            <th>Latitude</th>
            <th>Longitude</th>
            <th>Address</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {areas.length > 0 ? (
            areas.map((area) => (
              <tr key={area.id}>
                <td>{area.name}</td>
                <td>{area.area_type}</td>
                <td>{area.latitude}</td>
                <td>{area.longitude}</td>
                <td>{area.address}</td>
                <td>
                  <button onClick={() => handleUpdate(area.id)}>Update</button>
                  <button onClick={() => setIsDeleteConfirmOpen(true) && setSelectedArea(area)}>
                    Delete
                  </button>
                </td>
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan="6">No areas found</td>
            </tr>
          )}
        </tbody>
      </table>

      {/* Add/Update Area Popup */}
      {isPopupOpen && (
        <div className="popup">
          <div className="popup-content">
            <h3>{newArea.id ? 'Update Area' : 'Add New Area'}</h3>
            <form onSubmit={handleAddArea}>
              <input
                type="text"
                name="name"
                placeholder="Area Name"
                value={newArea.name}
                onChange={(e) =>handleInputChange(e)}
              />
              <input
                type="number"
                name="latitude"
                placeholder="Latitude"
                value={newArea.latitude}
                onChange={(e)=> handleInputChange(e)}
              />
              <input
                type="number"
                name="longitude"
                placeholder="Longitude"
                value={newArea.longitude}
                onChange={(e)=> handleInputChange(e)}
              />
              <input
                type="text"
                name="address"
                placeholder="Address"
                value={newArea.address}
                onChange={(e)=> handleInputChange(e)}
              />
              <select
                name="area_type"
                value={newArea.area_type}
                onChange={(e)=>handleInputChange(e)}
                disabled={newArea.id? true: false }
              >
                <option value="oyster">Oyster</option>
                <option value="cobia">Cobia</option>
              </select>
              <button type="submit">Save</button>
              <button type="button" onClick={() =>{ 
                setIsPopupOpen(false)
                setNewArea({ areaName: '', lat: '', long: '', address: '', area_type: 'oyster' });
                }}>
                Cancel
              </button>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation Popup */}
      {isDeleteConfirmOpen && (
        <div className="popup">
          <div className="popup-content">
            <h3>Are you sure you want to delete this area?</h3>
            <button onClick={() => handleDelete(selectedArea.id)}>Yes</button>
            <button onClick={() => setIsDeleteConfirmOpen(false)}>No</button>
          </div>
        </div>
      )}
    </div>
  );
};

export default AreaList;

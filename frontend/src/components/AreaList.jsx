import React, { useState, useEffect } from 'react';
import axios from '../axios';
import './AreaList.css';
import { useTranslation } from 'react-i18next';

const AreaList = () => {
  const { t } = useTranslation();
  const [currentPage, setCurrentPage] = useState(0);
  const [totalAreas, setTotalAreas] = useState(0);
  const areasPerPage = 10;  // Number of areas per page
  const [areas, setAreas] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [areaType, setAreaType] = useState('');
  const [latRange, setLatRange] = useState({ min: '', max: '' });
  const [longRange, setLongRange] = useState({ min: '', max: '' });
  const [isPopupOpen, setIsPopupOpen] = useState(false);
  const [isDeleteConfirmOpen, setIsDeleteConfirmOpen] = useState(false);
  const [selectedArea, setSelectedArea] = useState(null);
  const [regionList, setRegionList] = useState([]);
  const [newArea, setNewArea] = useState({
    areaName: '',
    lat: '',
    long: '',
    region: '',
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
          limit: 10, // Limit number of results per page
          offset: currentPage * 10,
        },
      });
      setAreas(response.data.areas);
      setTotalAreas(response.data.total); // Set total areas for pagination
      console.log(response.data.areas);
      console.log(response.data.total);
      const regionResponse = await axios.get('/api/express/areas/regions');
      setRegionList(regionResponse.data); // Set regions for the dropdown
      console.log(regionResponse.data);
    } catch (error) {
      console.error('Error fetching areas:', error);
    }
  };

  // Fetch areas when dependencies change
  useEffect(() => {
    fetchAreas();
  }, [searchTerm, areaType, latRange, longRange, currentPage]);

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
      setNewArea({ areaName: '', lat: '', long: '', region: '', area_type: 'oyster' });
    } catch (error) {
      console.error('Error saving area:', error);
    }
  };

  const handleDelete = async (id) => {
    try {
      console.log('trying to delete');
      
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
    console.log(name,',',value);
      
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

  const totalPages = Math.ceil(totalAreas / areasPerPage);
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
    <div className="app">
      <div className="header">
        <input
          type="text"
          placeholder={t('area_list.search_placeholder')}
          value={searchTerm}
          onChange={handleSearch}
          className="search-input"
        />
        <select
          onChange={(e) => setAreaType(e.target.value)}
          value={areaType}
          className="filter-select"
          
        >
          <option value="" disabled>{t('area_list.filter.select_type')}</option>
          <option value="">{t('area_list.filter.all')}</option>
          <option value="oyster">{t('area_list.filter.oyster')}</option>
          <option value="cobia">{t('area_list.filter.cobia')}</option>
        </select>
        <div className="latlong-filter">
          <input
            type="number"
            placeholder={t('area_list.filter.min_lat')}
            value={latRange.min}
            onChange={(e) => setLatRange({ ...latRange, min: e.target.value })}
            className="filter-input"
          />
          <input
            type="number"
            placeholder={t('area_list.filter.max_lat')}
            value={latRange.max}
            onChange={(e) => setLatRange({ ...latRange, max: e.target.value })}
            className="filter-input"
          />
          <input
            type="number"
            placeholder={t('area_list.filter.min_long')}
            value={longRange.min}
            onChange={(e) => setLongRange({ ...longRange, min: e.target.value })}
            className="filter-input"
          />
          <input
            type="number"
            placeholder={t('area_list.filter.max_long')}
            value={longRange.max}
            onChange={(e) => setLongRange({ ...longRange, max: e.target.value })}
            className="filter-input"
          />
        </div>
        <button className="add-btn" onClick={() => setIsPopupOpen(true)}>
          {t('area_list.add_button')}
        </button>
      </div>

      <table className="area-table">
        <thead>
          <tr>
            <th>{t('area_list.table.name')}</th>
            <th>{t('area_list.table.type')}</th>
            <th>{t('area_list.table.lat')}</th>
            <th>{t('area_list.table.long')}</th>
            <th>{t('area_list.table.address')}</th>
            <th>{t('area_list.table.actions')}</th>
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
                <td>{area.Region?.province},{area.Region?.name}</td>
                <td>
                  <button onClick={() => handleUpdate(area.id)}>{t('area_list.popup.update')}</button>
                  <button onClick={() => {
                    setIsDeleteConfirmOpen(true)
                    setSelectedArea(area)
                    console.log(area);
                    
                    }}>
                      {t('area_list.popup.delete')}
                  </button>
                </td>
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan="6">{t('area_list.table.no_data')}</td>
            </tr>
          )}
        </tbody>
      </table>
          <div className="pagination">
        <button onClick={handlePrevPage} disabled={currentPage === 0}>
          {t('area_list.pagination.previous')}
        </button>
        <span>{t('area_list.pagination.page_info', { current: currentPage + 1, total: totalPages })}</span>
        <button onClick={handleNextPage} disabled={currentPage === totalPages - 1}>
          {t('area_list.pagination.next')}
        </button>
      </div>
      {/* Add/Update Area Popup */}
      {isPopupOpen && (
        <div className="popup">
          <div className="popup-content">
            <h3>{newArea.id ? t('area_list.popup.update') : t('area_list.popup.add')}</h3>
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
              <select
        name="region"
        value={regionList.find((region) => region.id === newArea.region)?.id || ''}
        onChange={(e) =>handleInputChange(e)}
        id="region"
      >
        <option value="" disabled>{t('area_list.popup.select_region')}</option>
        {regionList.map((region) => (
          <option key={region.id} value={region.id}>
            {region.province},{region.name} 
          </option>
        ))}
      </select>
              <select
                name="area_type"
                value={newArea.area_type}
                onChange={(e)=>handleInputChange(e)}
                disabled={newArea.id? true: false }
              >
                <option value="oyster">{t('area_list.filter.oyster')}</option>
                <option value="cobia">{t('area_list.filter.cobia')}</option>
              </select>
              <button type="submit">{t('area_list.popup.save')}</button>
              <button type="button" onClick={() =>{ 
                setIsPopupOpen(false)
                setNewArea({ areaName: '', lat: '', long: '', region: '', area_type: 'oyster' });
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
            <h3>{t('area_list.confirm_delete.title')} {selectedArea?.name}?</h3>
            <button className='delete-confirm-button' onClick={() => handleDelete(selectedArea.id)}>{t('area_list.confirm_delete.yes')}</button>
            <button className='delete-deny-button' onClick={() => setIsDeleteConfirmOpen(false)}>{t('area_list.confirm_delete.no')}</button>
          </div>
        </div>
      )}
    </div>
  );
};

export default AreaList;

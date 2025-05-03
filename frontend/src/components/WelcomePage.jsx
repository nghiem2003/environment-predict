import React, { useState, useEffect } from 'react';
import './WelcomePage.css';
import { useNavigate } from 'react-router-dom';
import axios from '../axios';
import { useTranslation } from 'react-i18next';

const WelcomePage = () => {
  const { t } = useTranslation()
  const [areas, setAreas] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [filteredAreas, setFilteredAreas] = useState([]);
  const navigate = useNavigate();

  useEffect(() => {
    axios
      .get('/api/express/areas') // Replace with your backend API
      .then((response) => {
        console.log(response);

        setAreas(response.data.areas);

        setFilteredAreas(response.data.areas);
      })
      .catch((error) => console.error('Error fetching areas:', error));
  }, []);

  useEffect(() => {
    setFilteredAreas(
      areas.filter((area) =>
        area.name.toLowerCase().includes(searchTerm.toLowerCase())
      )
    );
  }, [searchTerm, areas]);

  const handleAreaSelect = (areaId) => {
    navigate(`/predictions/${areaId}`);
  };

  return (
    <div>
      <h1>{t('welcomePage.title')}</h1>
      <input
        type="text"
        placeholder={t('welcomePage.searchPlaceholder')}
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
      />
      {filteredAreas ? (
        <ul>
          {filteredAreas.map((area) => (
            <li key={area.id} onClick={() => handleAreaSelect(area.id)}>
              {area.Region?.province},{area.Region?.name},{area.name}
            </li>
          ))}
        </ul>
      ) : (
        <></>
      )}
    </div>
  );
};

export default WelcomePage;

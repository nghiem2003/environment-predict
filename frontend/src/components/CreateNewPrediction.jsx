import React, { useState, useEffect } from 'react';
import { jwtDecode } from 'jwt-decode'; // Import without braces
import axios from '../axios';
import { useSelector } from 'react-redux';
import './CreateNewPrediction.css';
import { toast } from 'react-toastify'
import { useTranslation } from 'react-i18next';


const CreateNewPrediction = () => {
  const { t } = useTranslation();
  const { token } = useSelector((state) => state.auth);
  const [userId, setUserId] = useState(null);
  const [areas, setAreas] = useState([]);
  const [region, setRegion] = useState('');
  const [selectedAreaId, setSelectedAreaId] = useState('');
  const [areaType, setAreaType] = useState('');
  const [modelName, setModelName] = useState('');
  const [inputs, setInputs] = useState({
    R_PO4: 0,
    O2Sat: 0,
    O2ml_L: 0,
    STheta: 0,
    Salnty: 0,
    R_DYNHT: 0,
    T_degC: 0,
    R_Depth: 0,
    Distance: 0,
    Wind_Spd: 0,
    Wave_Ht: 0,
    Wave_Prd: 0,
    IntChl: 0,
    Dry_T: 0,
  });
  const [csvElements, setCsvElements] = useState([]);
  const [activeTab, setActiveTab] = useState('single');

  // Predefined list of models
  const allModels = [
    { value: 'cobia_ridge', label: 'Cobia Ridge', type: 'cobia' },
    { value: 'cobia_gbr', label: 'Cobia GBR', type: 'cobia' },
    { value: 'cobia_xgboost', label: 'Cobia XGBoost', type: 'cobia' },
    { value: 'cobia_svr', label: 'Cobia SVR', type: 'cobia' },
    { value: 'cobia_rf', label: 'Cobia Random Forest', type: 'cobia' },
    { value: 'cobia_lightgbm', label: 'Cobia LightGBM', type: 'cobia' },
    { value: 'cobia_stack', label: 'Cobia Stacked Model', type: 'cobia' },
    { value: 'oyster_ridge', label: 'Oyster Ridge', type: 'oyster' },
    { value: 'oyster_gbr', label: 'Oyster GBR', type: 'oyster' },
    { value: 'oyster_xgboost', label: 'Oyster XGBoost', type: 'oyster' },
    { value: 'oyster_svr', label: 'Oyster SVR', type: 'oyster' },
    { value: 'oyster_rf', label: 'Oyster Random Forest', type: 'oyster' },
    { value: 'oyster_lightgbm', label: 'Oyster LightGBM', type: 'oyster' },
    { value: 'oyster_stack', label: 'Oyster Stacked Model', type: 'oyster' },
  ];

  // Decode token to get userId
  useEffect(() => {
    if (token) {
      try {
        const decodedToken = jwtDecode(token); // Decode the JWT token
        setUserId(decodedToken.id); // Assuming `id` is the field for userId in the token
        setRegion(decodedToken.region); // Assuming `region` is the field for region in the token
        console.log(decodedToken);
        
      } catch (error) {
        console.error('Error decoding token:', error);
        alert('Invalid token. Please log in again.');
      }
    }
  }, [token]);

  // Fetch areas on component mount
  useEffect(() => {
    const fetchAreas = async () => {
      try {
        const response = await axios.get('api/express/areas');
        console.log(response.data);
        //console.log(response.data.areas[0].region);
        const decodedToken = jwtDecode(token); 
        console.log(decodedToken.region);
        const areaList = response.data.areas.filter((area) => area.region === decodedToken.region);
        console.log('arealist:',areaList);
        setAreas(areaList);
      } catch (error) {
        console.error('Error fetching areas:', error);
        //alert('Failed to fetch areas. Please try again.');
      }
    };

    fetchAreas();
  }, []);

  const handleCSVUpload = (e) => {
  const file = e.target.files[0];
  const reader = new FileReader();

  reader.onload = (event) => {
    const text = event.target.result;
    // Split the CSV content into lines, remove any empty lines
    const csvElements = text.split(/\r?\n/).filter(Boolean);

    // Store the lines in state (first line is the header, the rest are data rows)
    setCsvElements(csvElements);
  };

  reader.readAsText(file);
};

const handleSubmitBatch = async (e) => {
  e.preventDefault();
  try {
  if(!selectedAreaId || !modelName) throw new Error('You need to select area and model')
  
  // Get the header (keys)
  const headers = csvElements[0].split(',');  // Split the first line into headers

  // Process the remaining lines (data rows)
  const data = csvElements.slice(1).map((line) => {
    const parts = line.split(',');  // Split each data line into parts
    const obj = {};

    // Map each header to the corresponding value in the row
    for (let i = 0; i < headers.length; i++) {
      obj[headers[i]] = parseFloat(parts[i]);  // Key: header[i], Value: parts[i]
    }

    return obj;  // Return the object for the current row
  });

  // Log the processed data
  console.log('Processed data:', data);
  
  // Send the data to your backend API
  
    await axios.post('api/express/predictions/batch', {
      userId,
      areaId: selectedAreaId,
      modelName,
      data,
    });
    toast.success('Created predictions from file successful!')
  } catch (error) {
    console.log('error',error);
     toast.error(`${error}`)
    //alert('Batch prediction failed!\nError:',error);
  }
};


  const handleInputChange = (event) => {
    const { name, value } = event.target;
    setInputs({
      ...inputs,
      [name]: parseFloat(value),
    });
  };

  const handleSubmitSingle = async (e) => {
    e.preventDefault();

    try {
      await axios.post('api/express/predictions', {
        userId,
        areaId: selectedAreaId,
        modelName,
        inputs,
      });
      toast.success('Created single prediction successful!')
    } catch(e) {
      toast.error(`${e}`)
    }
  };
  const filteredModels = areaType
  ? allModels.filter((m) => m.type === areaType)
  : [];

  return (
    <div className="prediction-container">
      <h1>{t('prediction_form.title')}</h1>
      <div className="tabs">
        <button
          className={activeTab === 'single' ? 'active' : ''}
          onClick={() => setActiveTab('single')}
        >
          {t('prediction_form.tabs.single')}
        </button>
        <button
          className={activeTab === 'batch' ? 'active' : ''}
          onClick={() => setActiveTab('batch')}
        >
          {t('prediction_form.tabs.batch')}
        </button>
      </div>

      {activeTab === 'single' && (
        <form className="prediction-form">
          <input type="number" value={userId || ''} readOnly required />

          <select
            value={selectedAreaId}
            onChange={(e) => {
              const area = areas.find((a) => a.id === +e.target.value);
              setSelectedAreaId(e.target.value);
              setAreaType(area?.area_type);
            }}
          >
            <option value="">Select Area</option>
            {areas.length > 0 ? areas.map((area) => (
              <option key={area.id} value={area.id}>
                {area.name}
              </option>
            )) : (
              <option value="">{t('prediction_form.loading_areas')}</option>
            )}
          </select>

          <select
            value={modelName}
            onChange={(e) => setModelName(e.target.value)}
            disabled={!areaType}
          >
            <option value="">{t('prediction_form.select_model')}</option>
            {filteredModels.map((model) => (
              <option key={model.value} value={model.value}>
                {model.label}
              </option>
            ))}
          </select>

          {areaType &&
            Object.keys(inputs).map((key) => (
              <input
                key={key}
                type="number"
                placeholder={key}
                onChange={(e) =>
                  setInputs({ ...inputs, [key]: +e.target.value })
                }
              />
            ))}

          <button onClick={handleSubmitSingle}>{t('prediction_form.submit_single')}</button>
        </form>
      )}

      {activeTab === 'batch' && (
        <form className="prediction-form">
          <input type="number" value={userId || ''} readOnly required />

          <select
            value={selectedAreaId}
            onChange={(e) => {
              const area = areas.find((a) => a.id === +e.target.value);
              setSelectedAreaId(e.target.value);
              setAreaType(area?.area_type);
            }}
            required
          >
            <option value="" required>{t('prediction_form.select_area')}</option>
            {areas.map((area) => (
              <option key={area.id} value={area.id}>
                {area.name}
              </option>
            ))}
          </select>

          <select
            value={modelName}
            onChange={(e) => setModelName(e.target.value)}
            disabled={!areaType}
            required
          >
            <option value="" required>{t('prediction_form.select_model')}</option>
            {filteredModels.map((model) => (
              <option key={model.value} value={model.value}>
                {model.label}
              </option>
            ))}
          </select>
          <input
            type="file"
            accept=".csv"
            onChange={handleCSVUpload}
            required
          />
          <button onClick={handleSubmitBatch} disabled={!selectedAreaId || !modelName}>{t('prediction_form.submit_batch')}</button>
        </form>
      )}
    </div>
  );
};

export default CreateNewPrediction;

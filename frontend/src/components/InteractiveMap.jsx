import React, { useState, useEffect, useRef } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap, Circle } from 'react-leaflet';
import { LatLng } from 'leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import './InteractiveMap.css';
import axios from '../axios';
import { useSelector } from 'react-redux';
import { jwtDecode } from 'jwt-decode';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import {
    Card,
    List,
    Typography,
    Button,
    Space,
    Input,
    Select,
    Row,
    Col,
    Tag,
    Spin,
    message,
    Tooltip,
    Collapse,
} from 'antd';
import { LineChart, Line, XAxis, YAxis, Tooltip as RTooltip, ResponsiveContainer, CartesianGrid } from 'recharts';
import {
    EnvironmentOutlined,
    SearchOutlined,
    FilterOutlined,
    InfoCircleOutlined,
    ArrowRightOutlined,
    ArrowLeftOutlined,
} from '@ant-design/icons';

const { Title, Text } = Typography;
const { Option } = Select;

// Fix for default markers in react-leaflet
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png',
    iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png',
});

// Compact tooltip for Recharts
function SmallTooltip({ active, payload, label, unit }) {
    if (active && payload && payload.length) {
        const value = payload[0]?.value;
        return (
            <div style={{
                background: '#fff',
                border: '1px solid #d9d9d9',
                borderRadius: 4,
                padding: '4px 6px',
                fontSize: 10,
                lineHeight: 1.2,
                maxWidth: 120
            }}>
                <div style={{ marginBottom: 2 }}>{label}</div>
                <div style={{ fontWeight: 600 }}>{`${value ?? 0} ${unit || ''}`}</div>
            </div>
        );
    }
    return null;
}

// Custom marker icons for different area types
const createCustomIcon = (color) => {
    return L.divIcon({
        className: 'custom-div-icon',
        html: `<div style="
      background-color: ${color};
      width: 20px;
      height: 20px;
      border-radius: 50%;
      border: 3px solid white;
      box-shadow: 0 2px 4px rgba(0,0,0,0.3);
    "></div>`,
        iconSize: [20, 20],
        iconAnchor: [10, 10],
    });
};

const oysterIcon = createCustomIcon('#1890ff');
const cobiaIcon = createCustomIcon('#52c41a');

// Component to update map view when area is selected
function MapUpdater({ center, zoom }) {
    const map = useMap();

    useEffect(() => {
        if (center) {
            map.setView(center, zoom || 15);
        }
    }, [center, zoom, map]);

    return null;
}

// Component for prediction circles (only shown in detail view)
function PredictionCircle({ area, prediction }) {
    // Convert prediction_text (categorical: -1, 0, 1) to label/color
    const getPredictionInfo = () => {
        if (!prediction) {
            return { result: -2, color: '#1890ff', label: 'Chưa có dự báo' };
        }
        const value = Number.parseInt(prediction.prediction_text, 10);
        if (Number.isNaN(value)) {
            return { result: -2, color: '#1890ff', label: 'Chưa có dự báo' };
        }
        if (value === 1) return { result: 1, color: '#52c41a', label: 'Tốt' };
        if (value === 0) return { result: 0, color: '#faad14', label: 'Trung bình' };
        if (value === -1) return { result: -1, color: '#ff4d4f', label: 'Kém' };
        return { result: -2, color: '#1890ff', label: 'Chưa có dự báo' };
    };

    const predictionInfo = getPredictionInfo();
    // area.area is already in hectares, convert to radius (m) for circle display
    // 1 hectare = 10,000 m²
    const areaInHectares = area.area || 0;
    const circleRadius = areaInHectares > 0 ? Math.sqrt(areaInHectares * 10000 / Math.PI) * 0.1 : 50;

    return (
        <Circle
            center={[area.latitude, area.longitude]}
            radius={circleRadius}
            pathOptions={{
                fillColor: predictionInfo.color,
                fillOpacity: 0.3,
                color: predictionInfo.color,
                opacity: 0.8,
                weight: 2,
            }}
        />
    );
}

// Component for individual area markers with prediction circles
function AreaMarker({ area, prediction, onAreaClick, onViewDetails }) {
    const icon = area.area_type === 'oyster' ? oysterIcon : cobiaIcon;

    // Get prediction result and color from prediction_text (categorical)
    const getPredictionInfo = () => {
        if (!prediction) {
            return { result: -2, color: '#1890ff', label: 'Chưa có dự báo' };
        }

        const value = Number.parseInt(prediction.prediction_text, 10);
        if (Number.isNaN(value)) {
            return { result: -2, color: '#1890ff', label: 'Chưa có dự báo' };
        }
        if (value === 1) return { result: 1, color: '#52c41a', label: 'Tốt' };
        if (value === 0) return { result: 0, color: '#faad14', label: 'Trung bình' };
        if (value === -1) return { result: -1, color: '#ff4d4f', label: 'Kém' };
        return { result: -2, color: '#1890ff', label: 'Chưa có dự báo' };
    };

    const predictionInfo = getPredictionInfo();
    // area.area is already in hectares, convert to radius (m) for circle display
    // 1 hectare = 10,000 m²
    const areaInHectares = area.area || 0;

    return (
        <>
            {/* Marker */}
            <Marker
                position={[area.latitude, area.longitude]}
                icon={icon}
                eventHandlers={{
                    click: () => onAreaClick(area),
                }}
            >
                <Popup>
                    <div className="area-popup">
                        <Title level={5} style={{ margin: '0 0 8px 0' }}>
                            {area.name}
                        </Title>
                        <Space direction="vertical" size="small" style={{ width: '100%' }}>
                            <div>
                                <Text strong>Loại: </Text>
                                <Tag color={area.area_type === 'oyster' ? 'blue' : 'green'}>
                                    {area.area_type === 'oyster' ? 'Oyster' : 'Cobia'}
                                </Tag>
                            </div>
                            <div>
                                <Text strong>Dự báo: </Text>
                                <Space direction="vertical" size="small">
                                    <Tag color={predictionInfo.color}>
                                        {predictionInfo.label}
                                    </Tag>
                                    {/* No score display since prediction_text is categorical */}
                                </Space>
                            </div>
                            {prediction && (
                                <div>
                                    <Text strong>Ngày dự báo: </Text>
                                    <Text>{new Date(prediction.createdAt).toLocaleDateString('vi-VN')}</Text>
                                </div>
                            )}
                            <div>
                                <Text strong>Vị trí: </Text>
                                <Text>{area.latitude}, {area.longitude}</Text>
                            </div>
                            {area.area && (
                                <div>
                                    <Text strong>Diện tích: </Text>
                                    <Text>{area.area} ha</Text>
                                </div>
                            )}
                            {area.Province && (
                                <div>
                                    <Text strong>Địa chỉ: </Text>
                                    <Text>{area.Province.name}, {area.District?.name}</Text>
                                </div>
                            )}
                            <Space direction="vertical" style={{ width: '100%' }}>
                                {prediction && prediction.id && (
                                    <Button
                                        type="primary"
                                        size="small"
                                        onClick={() => onViewDetails(area)}
                                        style={{ width: '100%' }}
                                    >
                                        Xem chi tiết
                                    </Button>
                                )}
                                <Button
                                    type="default"
                                    size="small"
                                    onClick={() => navigate(`/email-subscription/${area.id}`)}
                                    style={{ width: '100%' }}
                                >
                                    Đăng ký email thông báo
                                </Button>
                            </Space>
                        </Space>
                    </div>
                </Popup>
            </Marker>
        </>
    );
}

const InteractiveMap = () => {
    const { t } = useTranslation();
    const { token } = useSelector((state) => state.auth);
    const navigate = useNavigate();
    const mapRef = useRef(null);

    // State management
    const [areas, setAreas] = useState([]);
    const [filteredAreas, setFilteredAreas] = useState([]);
    const [predictions, setPredictions] = useState({}); // Store predictions by area ID
    const [loading, setLoading] = useState(true);
    const [selectedArea, setSelectedArea] = useState(null);
    const [historyByElement, setHistoryByElement] = useState({}); // key: element name/id -> [{date,value}]
    const [mapCenter, setMapCenter] = useState([10.762622, 106.660172]); // Vietnam center
    const [mapZoom, setMapZoom] = useState(6);

    // Filter states
    const [searchTerm, setSearchTerm] = useState('');
    const [areaType, setAreaType] = useState('');
    const [provinceFilter, setProvinceFilter] = useState('');
    const [districtFilter, setDistrictFilter] = useState('');
    const [filtersCollapsed, setFiltersCollapsed] = useState(false);
    const [isDetailView, setIsDetailView] = useState(false);
    const [isFilterCardVisible, setIsFilterCardVisible] = useState(false);
    const [isDetailCardVisible, setIsDetailCardVisible] = useState(true);

    // Data for filters
    const [provinces, setProvinces] = useState([]);
    const [districts, setDistricts] = useState([]);
    const [filteredDistricts, setFilteredDistricts] = useState([]);

    // Fetch areas data
    const fetchAreas = async () => {
        try {
            setLoading(true);
            const response = await axios.get('/api/express/areas', {
                params: {
                    search: searchTerm,
                    area_type: areaType,
                    province: provinceFilter,
                    district: districtFilter,
                    limit: 1000, // Get all areas for map display
                },
            });

            const areasData = response.data.areas || [];
            setAreas(areasData);
            setFilteredAreas(areasData);

            // Fetch predictions for all areas
            await fetchPredictionsForAreas(areasData);

            // Set map center to first area if available
            if (areasData.length > 0) {
                const firstArea = areasData[0];
                setMapCenter([firstArea.latitude, firstArea.longitude]);
                setMapZoom(10);
            }
        } catch (error) {
            console.error('Error fetching areas:', error);
            message.error('Không thể tải dữ liệu khu vực');
        } finally {
            setLoading(false);
        }
    };

    // Fetch predictions for areas
    const fetchPredictionsForAreas = async (areasData) => {
        try {
            const predictionPromises = areasData.map(async (area) => {
                try {
                    const response = await axios.get(`/api/express/predictions/${area.id}/latest`);
                    return { areaId: area.id, prediction: response.data };
                } catch (error) {
                    console.error(`Error fetching prediction for area ${area.id}:`, error);
                    return { areaId: area.id, prediction: null };
                }
            });

            const results = await Promise.all(predictionPromises);
            const predictionsMap = {};
            results.forEach(({ areaId, prediction }) => {
                predictionsMap[areaId] = prediction;
            });
            setPredictions(predictionsMap);
        } catch (error) {
            console.error('Error fetching predictions:', error);
        }
    };

    // Debug function to check data
    const debugData = () => {
        console.log('Areas:', areas);
        console.log('Filtered Areas:', filteredAreas);
        console.log('Predictions:', predictions);
        console.log('Loading:', loading);
    };

    // Fetch provinces and districts
    const fetchLocationData = async () => {
        try {
            const [provincesRes, districtsRes] = await Promise.all([
                axios.get('/api/express/areas/provinces'),
                axios.get('/api/express/areas/districts'),
            ]);

            setProvinces(provincesRes.data || []);
            setDistricts(districtsRes.data || []);
            setFilteredDistricts(districtsRes.data || []);
        } catch (error) {
            console.error('Error fetching location data:', error);
        }
    };

    // Filter areas based on search and filters
    const filterAreas = () => {
        let filtered = areas;

        if (searchTerm) {
            filtered = filtered.filter(area =>
                area.name.toLowerCase().includes(searchTerm.toLowerCase())
            );
        }

        if (areaType) {
            filtered = filtered.filter(area => area.area_type === areaType);
        }

        if (provinceFilter) {
            filtered = filtered.filter(area => area.province === provinceFilter);
        }

        if (districtFilter) {
            filtered = filtered.filter(area => area.district === districtFilter);
        }

        setFilteredAreas(filtered);
    };

    // Handle area selection from sidebar
    const handleAreaSelect = (area) => {
        console.log('handleAreaSelect called with area:', area);
        setSelectedArea(area);
        setMapCenter([area.latitude, area.longitude]);
        setMapZoom(15);
        setIsDetailView(true);
        setIsFilterCardVisible(false);
        // fetch 2-week history for charts
        fetchHistory(area.id);
    };

    // Handle area click from map marker - only move map, don't change selected area
    const handleAreaClick = (area) => {
        setMapCenter([area.latitude, area.longitude]);
        setMapZoom(15);
    };

    // Handle area click from "Xem chi tiết" button - change selected area and switch to detail view
    const handleViewDetails = (area) => {
        console.log('handleViewDetails called with area:', area);
        setSelectedArea(area);
        setMapCenter([area.latitude, area.longitude]);
        setMapZoom(15);
        setIsDetailView(true);
        setIsFilterCardVisible(false);
        // fetch 2-week history for charts
        fetchHistory(area.id);
    };
    const fetchHistory = async (areaId) => {
        try {
            console.log('Fetching history for area:', areaId);
            const res = await axios.get(`/api/express/predictions/${areaId}/history`, { params: { days: 14 } });
            console.log('Full API response:', res);
            console.log('History API response data:', res.data);

            // Check if response has predictions array or is direct array
            let predictions = [];
            if (Array.isArray(res.data)) {
                predictions = res.data;
            } else if (res.data && Array.isArray(res.data.predictions)) {
                predictions = res.data.predictions;
            } else if (res.data && res.data.data && Array.isArray(res.data.data)) {
                predictions = res.data.data;
            }

            console.log('Parsed predictions array:', predictions);
            console.log('Number of predictions:', predictions.length);

            if (predictions.length === 0) {
                console.log('No predictions found, creating empty series');
                setHistoryByElement({});
                return;
            }

            // Create date range for last 14 days
            const dateRange = [];
            for (let i = 13; i >= 0; i--) {
                const date = new Date();
                date.setDate(date.getDate() - i);
                dateRange.push(date.toISOString().split('T')[0]); // YYYY-MM-DD format
            }
            console.log('Date range:', dateRange);

            // Transform: for each element, build time series with full 14 days
            const elementSeries = {};

            // First, collect all unique elements from predictions
            const allElements = new Set();
            predictions.forEach((p, index) => {
                console.log(`Processing prediction ${index}:`, p);
                if (p && p.NaturalElements && Array.isArray(p.NaturalElements)) {
                    p.NaturalElements.forEach((el) => {
                        if (el && el.name) {
                            allElements.add(el.name);
                            console.log(`Found element: ${el.name}, value: ${el.PredictionNatureElement?.value}`);
                        }
                    });
                }
            });

            console.log('All unique elements:', Array.from(allElements));

            // For each element, create 14-day series
            allElements.forEach(elementName => {
                elementSeries[elementName] = [];
                dateRange.forEach(dateStr => {
                    // Find prediction for this date
                    const predictionForDate = predictions.find(p => {
                        if (!p || !p.createdAt) return false;
                        const predictionDate = p.createdAt.split('T')[0];
                        return predictionDate === dateStr;
                    });

                    if (predictionForDate && predictionForDate.NaturalElements) {
                        const element = predictionForDate.NaturalElements.find(el => el && el.name === elementName);
                        if (element) {
                            const value = element.PredictionNatureElement?.value;
                            const unit = element.unit;
                            elementSeries[elementName].push({
                                date: dateStr,
                                value: parseFloat(value) || 0,
                                unit: unit || ''
                            });
                        } else {
                            elementSeries[elementName].push({
                                date: dateStr,
                                value: 0,
                                unit: ''
                            });
                        }
                    } else {
                        // No data for this date, use 0
                        elementSeries[elementName].push({
                            date: dateStr,
                            value: 0,
                            unit: ''
                        });
                    }
                });
            });

            console.log('Processed element series with 14 days:', elementSeries);
            setHistoryByElement(elementSeries);
        } catch (e) {
            console.error('Failed to fetch history', e);
            console.error('Error details:', e.response?.data || e.message);
        }
    };

    // Handle back button - return to search/list view
    const handleBackToList = () => {
        setIsDetailView(false);
        setSelectedArea(null);
        setIsDetailCardVisible(true); // Reset detail card visibility
    };

    // Handle province change
    const handleProvinceChange = (provinceId) => {
        setProvinceFilter(provinceId);
        setDistrictFilter('');

        if (provinceId) {
            const filtered = districts.filter(district => district.province_id === provinceId);
            setFilteredDistricts(filtered);
        } else {
            setFilteredDistricts(districts);
        }
    };

    // Initialize data
    useEffect(() => {
        fetchAreas();
        fetchLocationData();
    }, []);

    // Apply filters when they change
    useEffect(() => {
        filterAreas();
    }, [searchTerm, areaType, provinceFilter, districtFilter, areas]);

    // Apply user role-based filtering (only if logged in)
    useEffect(() => {
        if (token) {
            try {
                const decodedToken = jwtDecode(token);
                if (decodedToken.role === 'manager') {
                    const newProvince = decodedToken.province || '';
                    const newDistrict = decodedToken.district || '';
                    setProvinceFilter(newProvince);
                    // Recompute districts list to ensure correct options
                    if (newProvince) {
                        const filtered = districts.filter(d => d.province_id === newProvince);
                        setFilteredDistricts(filtered);
                        // Only keep district if it belongs to the selected province
                        if (newDistrict && !filtered.some(d => d.id === newDistrict)) {
                            setDistrictFilter('');
                        } else {
                            setDistrictFilter(newDistrict);
                        }
                    } else {
                        setFilteredDistricts(districts);
                        setDistrictFilter(newDistrict);
                    }
                }
            } catch (error) {
                console.error('Error decoding token:', error);
            }
        }
    }, [token]);

    return (
        <div className="map-with-sidebar-container">
            {/* Left Sidebar */}
            <div className="left-sidebar">
                <Card className="sidebar-card">
                    {!isDetailView ? (
                        // Search and List View
                        <>
                            <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: '8px' }}>
                                <Button
                                    size="small"
                                    onClick={() => setIsFilterCardVisible(!isFilterCardVisible)}
                                    className="filter-button"
                                    icon={<FilterOutlined />}
                                >
                                    {t('common.filter')}
                                </Button>
                            </div>

                            {/* Search */}
                            <Space direction="vertical" style={{ width: '100%', marginBottom: '16px' }}>
                                <Input
                                    placeholder={t('welcomePage.searchPlaceholder')}
                                    prefix={<SearchOutlined />}
                                    value={searchTerm}
                                    onChange={(e) => setSearchTerm(e.target.value)}
                                    allowClear
                                    size="large"
                                />

                                {/* Filters moved to right floating card */}

                                <div style={{ textAlign: 'center', marginTop: '8px' }}>
                                    <Text strong style={{ color: '#1890ff' }}>
                                        {filteredAreas.length} {t('area_list.title').toLowerCase()}
                                    </Text>
                                    {loading && <Spin size="small" style={{ marginLeft: '8px' }} />}
                                    {window.location.hostname === 'localhost' && (
                                        <Button
                                            size="small"
                                            onClick={debugData}
                                            style={{ marginLeft: '8px' }}
                                        >
                                            Debug
                                        </Button>
                                    )}
                                </div>
                            </Space>

                            {/* Areas List */}
                            <div className="areas-list">
                                {loading ? (
                                    <div style={{ textAlign: 'center', padding: '20px' }}>
                                        <Spin size="large" />
                                    </div>
                                ) : (
                                    <List
                                        dataSource={filteredAreas}
                                        renderItem={(area) => (
                                            <List.Item
                                                className={`area-list-item ${selectedArea?.id === area.id ? 'selected' : ''}`}
                                                onClick={() => handleAreaSelect(area)}
                                            >
                                                <List.Item.Meta
                                                    avatar={
                                                        <div
                                                            className={`area-marker-icon ${area.area_type}`}
                                                        />
                                                    }
                                                    title={
                                                        <Space>
                                                            <Text strong style={{ fontSize: '14px' }}>
                                                                {area.name}
                                                            </Text>
                                                            {predictions[area.id] && (() => {
                                                                const value = Number.parseInt(predictions[area.id].prediction_text, 10);
                                                                let color = 'blue';
                                                                let label = t('detail.noPrediction');
                                                                if (value === 1) { color = 'green'; label = t('detail.good'); }
                                                                else if (value === 0) { color = 'orange'; label = t('detail.average'); }
                                                                else if (value === -1) { color = 'red'; label = t('detail.poor'); }

                                                                return (
                                                                    <Space direction="vertical" size="small">
                                                                        <Tag color={color} size="small">
                                                                            {label}
                                                                        </Tag>
                                                                    </Space>
                                                                );
                                                            })()}
                                                        </Space>
                                                    }
                                                    description={
                                                        <Space direction="vertical" size="small" style={{ width: '100%' }}>
                                                            <Text type="secondary" style={{ fontSize: '12px' }}>
                                                                {area.Province?.name}, {area.District?.name}
                                                            </Text>
                                                            <Space>
                                                                <Tag color={area.area_type === 'oyster' ? 'blue' : 'green'} size="small">
                                                                    {area.area_type === 'oyster' ? t('common.oyster') : t('common.cobia')}
                                                                </Tag>
                                                                {area.area && (
                                                                    <Text type="secondary" style={{ fontSize: '11px' }}>
                                                                        {area.area} ha
                                                                    </Text>
                                                                )}
                                                            </Space>
                                                            {predictions[area.id] && (
                                                                <Text type="secondary" style={{ fontSize: '11px' }}>
                                                                    {t('detail.predictionLabel')}: {new Date(predictions[area.id].createdAt).toLocaleDateString('vi-VN')}
                                                                </Text>
                                                            )}
                                                        </Space>
                                                    }
                                                />
                                            </List.Item>
                                        )}
                                        locale={{ emptyText: t('area_list.noAreas') }}
                                    />
                                )}
                            </div>
                        </>
                    ) : (
                        // Detail View
                        <>
                            <div style={{ display: 'flex', alignItems: 'center', marginBottom: '16px' }}>
                                <Button
                                    type="text"
                                    icon={<ArrowLeftOutlined />}
                                    onClick={handleBackToList}
                                    style={{ marginRight: '8px' }}
                                >
                                    {t('common.back')}
                                </Button>
                                <Title level={4} style={{ margin: 0, flex: 1, textAlign: 'center' }}>
                                    {t('detail.infoTitle')}
                                </Title>
                            </div>

                            {selectedArea && (
                                <Card
                                    size="small"
                                    style={{ marginBottom: '16px' }}
                                    title={
                                        <Space>
                                            <InfoCircleOutlined />
                                            <Text strong>{selectedArea.name}</Text>
                                        </Space>
                                    }
                                >
                                    <Space direction="vertical" style={{ width: '100%' }}>
                                        <div>
                                            <Text strong>{t('detail.typeLabel')}: </Text>
                                            <Tag color={selectedArea.area_type === 'oyster' ? 'blue' : 'green'}>
                                                {selectedArea.area_type === 'oyster' ? t('common.oyster') : t('common.cobia')}
                                            </Tag>
                                        </div>
                                        <div>
                                            <Text strong>{t('detail.predictionLabel')}: </Text>
                                            {predictions[selectedArea.id] ? (() => {
                                                const score = parseFloat(predictions[selectedArea.id].prediction_text);
                                                const isScoreValid = !isNaN(score);

                                                let result, color, label;
                                                if (!isScoreValid) {
                                                    result = -2;
                                                    color = 'blue';
                                                    label = t('detail.noPrediction');
                                                } else if (score >= 0.7) {
                                                    result = 1;
                                                    color = 'green';
                                                    label = t('detail.good');
                                                } else if (score >= 0.4) {
                                                    result = 0;
                                                    color = 'orange';
                                                    label = t('detail.average');
                                                } else {
                                                    result = -1;
                                                    color = 'red';
                                                    label = t('detail.poor');
                                                }

                                                return (
                                                    <Space direction="vertical" size="small">
                                                        <Tag color={color}>
                                                            {label}
                                                        </Tag>
                                                    </Space>
                                                );
                                            })() : (
                                                <Tag color="blue">{t('detail.noPrediction')}</Tag>
                                            )}
                                        </div>
                                        {predictions[selectedArea.id] && (
                                            <div>
                                                <Text strong>{t('detail.predictionDate')}: </Text>
                                                <Text>{new Date(predictions[selectedArea.id].createdAt).toLocaleDateString('vi-VN')}</Text>
                                            </div>
                                        )}
                                        <div>
                                            <Text strong>{t('detail.location')}: </Text>
                                            <Text>{selectedArea.latitude}, {selectedArea.longitude}</Text>
                                        </div>
                                        {selectedArea.area && (
                                            <div>
                                                <Text strong>{t('detail.area')}: </Text>
                                                <Text>{selectedArea.area} ha</Text>
                                            </div>
                                        )}
                                        <div>
                                            <Text strong>{t('detail.address')}: </Text>
                                            <Text>{selectedArea.Province?.name}, {selectedArea.District?.name}</Text>
                                        </div>
                                        <div style={{ marginTop: '12px' }}>
                                            <Space direction="vertical" style={{ width: '100%' }}>
                                                {predictions[selectedArea.id] && (
                                                    <Button
                                                        size="large"
                                                        onClick={() => setIsDetailCardVisible(!isDetailCardVisible)}
                                                        type={isDetailCardVisible ? "default" : "primary"}
                                                        block
                                                    >
                                                        {isDetailCardVisible ? t('common.hideDetails') : t('common.showDetails')}
                                                    </Button>
                                                )}
                                                <Button
                                                    size="large"
                                                    onClick={() => navigate(`/email-subscription/${selectedArea.id}`)}
                                                    type="default"
                                                    block
                                                >
                                                    {t('common.subscribeEmail')}
                                                </Button>
                                            </Space>
                                        </div>
                                    </Space>
                                </Card>
                            )}
                        </>
                    )}
                </Card>
            </div>

            {/* Right Detail Card - only in detail view and when visible */}
            {isDetailView && isDetailCardVisible && selectedArea && predictions[selectedArea.id]?.NaturalElements && predictions[selectedArea.id].NaturalElements.length > 0 && (
                <div className="right-detail">
                    <Card size="small" title="Chi tiết yếu tố môi trường">
                        <Space direction="vertical" style={{ width: '100%' }}>
                            {window.location.hostname === 'localhost' && (
                                <Button onClick={() => fetchHistory(selectedArea?.id)} type="dashed" size="small">
                                    Test History API
                                </Button>
                            )}
                            {predictions[selectedArea.id].NaturalElements.map((el) => (
                                <div key={el.id} style={{ marginBottom: '12px', padding: '8px', border: '1px solid #f0f0f0', borderRadius: '4px' }}>
                                    <Space style={{ width: '100%', justifyContent: 'space-between', marginBottom: '4px' }}>
                                        <Text strong>{el.name}</Text>
                                        <Text>{el.PredictionNatureElement?.value} {el.unit || ''}</Text>
                                    </Space>
                                    {el.description && (
                                        <Text type="secondary" style={{ fontSize: '12px', display: 'block', marginBottom: '8px' }}>{el.description}</Text>
                                    )}
                                    {/* Chart */}
                                    <div style={{ height: 140 }}>
                                        {(() => {
                                            const elementData = historyByElement[el.name] || [];
                                            const chartData = elementData.map(d => ({
                                                ...d,
                                                dateLabel: new Date(d.date).toLocaleDateString('vi-VN'),
                                                value: parseFloat(d.value) || 0
                                            }));
                                            console.log(`Chart data for ${el.name}:`, chartData);
                                            console.log('Raw historyByElement:', historyByElement[el.name]);

                                            return chartData.length > 0 ? (
                                                <ResponsiveContainer width="100%" height="100%">
                                                    <LineChart data={chartData} margin={{ top: 8, right: 8, left: 8, bottom: 8 }}>
                                                        <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                                                        <XAxis
                                                            dataKey="dateLabel"
                                                            tick={{ fontSize: 10 }}
                                                            interval="preserveStartEnd"
                                                            angle={-45}
                                                            textAnchor="end"
                                                            height={60}
                                                        />
                                                        <YAxis
                                                            tick={{ fontSize: 10 }}
                                                            width={50}
                                                            domain={['dataMin - 0.1', 'dataMax + 0.1']}
                                                        />
                                                        <RTooltip content={<SmallTooltip unit={el.unit} />} />
                                                        <Line
                                                            type="monotone"
                                                            dataKey="value"
                                                            stroke="#1890ff"
                                                            strokeWidth={2}
                                                            dot={false}
                                                            activeDot={{ r: 4, stroke: '#1890ff', strokeWidth: 2 }}
                                                        />
                                                    </LineChart>
                                                </ResponsiveContainer>
                                            ) : (
                                                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100%', background: '#f9f9f9', borderRadius: '4px' }}>
                                                    <Text type="secondary" style={{ fontSize: '11px' }}>Chưa có dữ liệu lịch sử</Text>
                                                </div>
                                            );
                                        })()}
                                    </div>
                                </div>
                            ))}
                        </Space>
                    </Card>
                </div>
            )
            }

            {/* Map */}
            <div className="map-container">
                <MapContainer
                    center={mapCenter}
                    zoom={mapZoom}
                    style={{ height: '100%', width: '100%' }}
                    ref={mapRef}
                >
                    <TileLayer
                        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                    />

                    <MapUpdater center={mapCenter} zoom={mapZoom} />

                    {filteredAreas.map((area) => (
                        <AreaMarker
                            key={area.id}
                            area={area}
                            prediction={predictions[area.id]}
                            onAreaClick={handleAreaClick}
                            onViewDetails={handleViewDetails}
                        />
                    ))}

                    {/* Prediction Circles - only show in detail view */}
                    {isDetailView && selectedArea && (
                        <PredictionCircle
                            area={selectedArea}
                            prediction={predictions[selectedArea.id]}
                        />
                    )}
                </MapContainer>
            </div>

            {/* Right Floating Filter Card */}
            {!isDetailView && isFilterCardVisible && (
                <div className="right-filter">
                    <Card size="small" title={t('common.filter')}>
                        <Space direction="vertical" style={{ width: '100%' }}>
                            <div>
                                <Text strong style={{ fontSize: '12px', color: '#666' }}>{t('filter.areaType')}</Text>
                                <Select
                                    placeholder={t('filter.areaTypePlaceholder')}
                                    value={areaType}
                                    onChange={setAreaType}
                                    style={{ width: '100%', marginTop: '4px' }}
                                    allowClear
                                    size="small"
                                >
                                    <Option value="oyster">{t('common.oyster')}</Option>
                                    <Option value="cobia">{t('common.cobia')}</Option>
                                </Select>
                            </div>

                            <div>
                                <Text strong style={{ fontSize: '12px', color: '#666' }}>{t('filter.province')}</Text>
                                <Select
                                    placeholder={t('filter.provincePlaceholder')}
                                    value={provinceFilter}
                                    onChange={handleProvinceChange}
                                    style={{ width: '100%', marginTop: '4px' }}
                                    allowClear
                                    size="small"
                                    disabled={token && jwtDecode(token)?.role === 'manager'}
                                >
                                    {provinces.map(province => (
                                        <Option key={province.id} value={province.id}>
                                            {province.name}
                                        </Option>
                                    ))}
                                </Select>
                            </div>

                            <div>
                                <Text strong style={{ fontSize: '12px', color: '#666' }}>{t('filter.district')}</Text>
                                <Select
                                    placeholder={t('filter.districtPlaceholder')}
                                    value={districtFilter}
                                    onChange={setDistrictFilter}
                                    style={{ width: '100%', marginTop: '4px' }}
                                    allowClear
                                    size="small"
                                    disabled={token && jwtDecode(token)?.role === 'manager' && jwtDecode(token)?.district}
                                >
                                    {filteredDistricts.map(district => (
                                        <Option key={district.id} value={district.id}>
                                            {district.name}
                                        </Option>
                                    ))}
                                </Select>
                            </div>

                            <Button
                                size="small"
                                onClick={() => setIsFilterCardVisible(false)}
                                style={{ width: '100%', marginTop: '8px' }}
                            >
                                {t('common.close')}
                            </Button>
                        </Space>
                    </Card>
                </div>
            )}
        </div>
    );
};

export default InteractiveMap;

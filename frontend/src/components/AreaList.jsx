import React, { useState, useEffect } from 'react';
import axios from '../axios';
import './AreaList.css';
import { useTranslation } from 'react-i18next';
import {
  MapContainer,
  TileLayer,
  Marker,
  useMapEvents,
  useMap,
} from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import {
  Input,
  Select,
  Button,
  Space,
  Table,
  Pagination,
  Modal,
  Form,
  Typography,
  Card,
  Row,
  Col,
} from 'antd';

const { Option } = Select;
const { Title } = Typography;

// delete L.Icon.Default.prototype._getIconUrl;
// L.Icon.Default.mergeOptions({
//   iconRetinaUrl: require('leaflet/dist/images/marker-icon-2x.png'),
//   iconUrl: require('leaflet/dist/images/marker-icon.png'),
//   shadowUrl: require('leaflet/dist/images/marker-shadow.png'),
// });

const AreaList = () => {
  const [form] = Form.useForm();
  const { t } = useTranslation();
  const [map, setMap] = useState(null);
  const [position, setPosition] = useState(null);
  const [currentPage, setCurrentPage] = useState(0);
  const [totalAreas, setTotalAreas] = useState(0);
  const areasPerPage = 10; // Number of areas per page
  const [areas, setAreas] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [areaType, setAreaType] = useState('');
  const [latRange, setLatRange] = useState({ min: '', max: '' });
  const [longRange, setLongRange] = useState({ min: '', max: '' });
  const [isPopupOpen, setIsPopupOpen] = useState(false);
  const [isDeleteConfirmOpen, setIsDeleteConfirmOpen] = useState(false);
  const [selectedArea, setSelectedArea] = useState(null);
  const [mapCenter, setMapCenter] = useState([10.762622, 106.660172]); // Default center (Vietnam)
  const [regionList, setRegionList] = useState([]);
  const [newArea, setNewArea] = useState({
    id: '',
    name: '',
    latitude: '',
    longitude: '',
    area: '',
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
      console.log('total', response.data.areas.length);
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

  const handleAddArea = async (values) => {
    console.log('id', form.getFieldValue('id'));

    try {
      if (form.getFieldValue('id')) {
        await axios.put(
          `/api/express/areas/${form.getFieldValue('id')}`,
          values
        );
      } else {
        await axios.post('/api/express/areas', values);
      }
      setIsPopupOpen(false);
      fetchAreas();
      form.resetFields();
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

    form.setFieldsValue({
      id: areaToUpdate.id || '',
      name: areaToUpdate.name || '',
      latitude: areaToUpdate.latitude || '',
      longitude: areaToUpdate.longitude || '',
      area: areaToUpdate.area || '',
      region: areaToUpdate.region || '',
      area_type: areaToUpdate.area_type || 'oyster',
    });

    // Update map center and position when editing an area
    if (areaToUpdate.latitude && areaToUpdate.longitude) {
      const newPos = [
        Number(areaToUpdate.latitude),
        Number(areaToUpdate.longitude),
      ];
      setMapCenter(newPos);
      setPosition(newPos);
    }

    setIsPopupOpen(true);
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setNewArea((prevState) => ({
      ...prevState,
      [name]: value,
    }));
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

  useEffect(() => {
    if (map) {
      const interval = setInterval(() => {
        map.invalidateSize(true);
      }, 400);

      return () => clearInterval(interval);
    }
  }, [map]);

  function MapUpdater({ center }) {
    const map = useMap();
    useEffect(() => {
      map.setView(center);
    }, [center, map]);
    return null;
  }

  function LocationMarker({ setCoordinates }) {
    useMapEvents({
      click(e) {
        setPosition([e.latlng.lat, e.latlng.lng]);
        setCoordinates(e.latlng);
      },
    });

    return position ? <Marker position={position} /> : null;
  }

  // Table columns for Ant Design Table
  const columns = [
    { title: t('area_list.table.name'), dataIndex: 'name', key: 'name' },
    {
      title: t('area_list.table.type'),
      dataIndex: 'area_type',
      key: 'area_type',
    },
    { title: t('area_list.table.lat'), dataIndex: 'latitude', key: 'latitude' },
    {
      title: t('area_list.table.long'),
      dataIndex: 'longitude',
      key: 'longitude',
    },
    {
      title: t('area_list.table.address'),
      key: 'address',
      render: (_, area) => `${area.Region?.province},${area.Region?.name}`,
    },
    {
      title: t('area_list.table.actions'),
      key: 'actions',
      render: (_, area) => (
        <Space>
          <Button size="small" onClick={() => handleUpdate(area.id)}>
            {t('area_list.popup.update')}
          </Button>
          <Button
            size="small"
            danger
            onClick={() => {
              setIsDeleteConfirmOpen(true);
              console.log(area);
              setSelectedArea(area);
            }}
          >
            {t('area_list.popup.delete')}
          </Button>
        </Space>
      ),
    },
  ];

  return (
    <div style={{ width: '100%', padding: 0, margin: 0 }}>
      <Card
        style={{
          width: '100%',
          boxShadow: '0 2px 8px rgba(0,0,0,0.06)',
          borderRadius: 12,
        }}
        bodyStyle={{ padding: 24 }}
      >
        <Title level={3} style={{ marginBottom: 24 }}>
          {t('area_list.title') || 'Danh sách khu vực'}
        </Title>
        <Row gutter={[16, 16]} style={{ marginBottom: 16 }}>
          <Col xs={24} sm={12} md={6}>
            <Input
              placeholder={
                t('area_list.search_placeholder') || 'Tìm kiếm theo tên khu vực'
              }
              value={searchTerm}
              onChange={handleSearch}
              allowClear
            />
          </Col>
          <Col xs={24} sm={12} md={3}>
            <Select
              value={areaType}
              onChange={setAreaType}
              style={{ width: '100%' }}
              allowClear
              placeholder={t('area_list.type_placeholder') || 'Tất cả'}
            >
              <Option value="">{t('area_list.type_all') || 'Tất cả'}</Option>
              <Option value="oyster">Oyster</Option>
              <Option value="cobia">Cobia</Option>
            </Select>
          </Col>
          <Col xs={24} sm={12} md={3}>
            <Input
              placeholder={t('area_list.filter.min_lat') || 'Vĩ độ tối thiểu'}
              value={latRange.min}
              onChange={(e) =>
                setLatRange({ ...latRange, min: e.target.value })
              }
              type="number"
            />
          </Col>
          <Col xs={24} sm={12} md={3}>
            <Input
              placeholder={t('area_list.filter.max_lat') || 'Vĩ độ tối đa'}
              value={latRange.max}
              onChange={(e) =>
                setLatRange({ ...latRange, max: e.target.value })
              }
              type="number"
            />
          </Col>
          <Col xs={24} sm={12} md={3}>
            <Input
              placeholder={
                t('area_list.filter.min_long') || 'Kinh độ tối thiểu'
              }
              value={longRange.min}
              onChange={(e) =>
                setLongRange({ ...longRange, min: e.target.value })
              }
              type="number"
            />
          </Col>
          <Col xs={24} sm={12} md={3}>
            <Input
              placeholder={t('area_list.filter.max_long') || 'Kinh độ tối đa'}
              value={longRange.max}
              onChange={(e) =>
                setLongRange({ ...longRange, max: e.target.value })
              }
              type="number"
            />
          </Col>
          <Col xs={24} sm={12} md={3}>
            <Button type="primary" block onClick={() => setIsPopupOpen(true)}>
              {t('area_list.add_button') || 'Thêm khu vực mới'}
            </Button>
          </Col>
        </Row>
        <Table
          columns={columns}
          dataSource={areas}
          rowKey="id"
          pagination={false}
          style={{ width: '100%' }}
          scroll={{ x: 'max-content' }}
        />
        <div style={{ margin: '16px 0', textAlign: 'center' }}>
          <Pagination
            current={currentPage + 1}
            total={totalAreas}
            pageSize={areasPerPage}
            onChange={(page) => setCurrentPage(page - 1)}
            showSizeChanger={false}
          />
        </div>

        {/* Add/Update Area Modal */}
        <Modal
          open={isPopupOpen}
          title={
            form.getFieldValue('id')
              ? t('area_list.popup.update')
              : t('area_list.popup.add')
          }
          onCancel={() => {
            setIsPopupOpen(false);
            form.resetFields();
          }}
          footer={null}
          width={700}
        >
          <div style={{ display: 'flex', gap: 24, height: '500px' }}>
            <Form
              form={form}
              layout="vertical"
              style={{ flex: 1, overflowY: 'auto' }}
              onFinish={handleAddArea}
            >
              <Form.Item
                label="Area Name"
                name="name"
                rules={[{ required: true }]}
              >
                <Input />
              </Form.Item>
              <Form.Item
                label="Latitude"
                name="latitude"
                rules={[{ required: true }]}
              >
                <Input type="number" />
              </Form.Item>
              <Form.Item
                label="Longitude"
                name="longitude"
                rules={[{ required: true }]}
              >
                <Input type="number" />
              </Form.Item>
              <Form.Item label="Area's area" name="area">
                <Input type="number" />
              </Form.Item>
              <Form.Item
                label={t('area_list.popup.select_region')}
                name="region"
              >
                <Select>
                  {regionList.map((region) => (
                    <Option key={region.id} value={region.id}>
                      {region.province},{region.name}
                    </Option>
                  ))}
                </Select>
              </Form.Item>
              <Form.Item label={t('area_list.filter.type')} name="area_type">
                <Select disabled={!!form.getFieldValue('id')}>
                  <Option value="oyster">{t('area_list.filter.oyster')}</Option>
                  <Option value="cobia">{t('area_list.filter.cobia')}</Option>
                </Select>
              </Form.Item>
              <Form.Item>
                <Space>
                  <Button type="primary" htmlType="submit">
                    {t('area_list.popup.save')}
                  </Button>
                  <Button
                    onClick={() => {
                      setIsPopupOpen(false);
                      form.resetFields();
                    }}
                  >
                    Cancel
                  </Button>
                </Space>
              </Form.Item>
            </Form>
            <div style={{ flex: 1, minWidth: '300px' }}>
              <MapContainer
                center={mapCenter}
                zoom={30}
                style={{ height: '100%', width: '100%' }}
                ref={setMap}
              >
                <TileLayer
                  url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                  attribution="&copy; OpenStreetMap contributors"
                />
                <MapUpdater center={mapCenter} />
                <Marker position={mapCenter} />
                <LocationMarker
                  setCoordinates={(latlng) => {
                    form.setFieldsValue({
                      latitude: latlng.lat,
                      longitude: latlng.lng,
                    });
                    setMapCenter([latlng.lat, latlng.lng]);
                    setPosition(latlng);
                  }}
                />
              </MapContainer>
            </div>
          </div>
        </Modal>

        {/* Delete Confirmation Modal */}
        <Modal
          open={isDeleteConfirmOpen}
          title={t('area_list.confirm_delete.title')}
          onCancel={() => setIsDeleteConfirmOpen(false)}
          onOk={() => handleDelete(selectedArea.id)}
          okText={t('area_list.confirm_delete.yes')}
          cancelText={t('area_list.confirm_delete.no')}
        >
          <p>
            {t('area_list.confirm_delete.title')} {selectedArea?.name}?
          </p>
        </Modal>
      </Card>
    </div>
  );
};

export default AreaList;

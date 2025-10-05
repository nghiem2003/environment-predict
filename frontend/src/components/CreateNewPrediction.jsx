import React, { useState, useEffect } from 'react';
import { jwtDecode } from 'jwt-decode';
import axios from '../axios';
import { useSelector } from 'react-redux';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import {
  Form,
  Input,
  Button,
  Select,
  Tabs,
  Upload,
  Card,
  Typography,
  message,
  Spin,
} from 'antd';
import { UploadOutlined } from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';
const { Option } = Select;
const { Title } = Typography;

const CreateNewPrediction = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();
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
  const [excelFile, setExcelFile] = useState(null);
  const [activeTab, setActiveTab] = useState('single');
  const [singleForm] = Form.useForm();
  const [batchForm] = Form.useForm();
  const [isBatchLoading, setIsBatchLoading] = useState(false);
  const [isSingleLoading, setIsSingleLoading] = useState(false);
  const [batchProgress, setBatchProgress] = useState(0);

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

  useEffect(() => {
    if (token) {
      try {
        const decodedToken = jwtDecode(token);
        setUserId(decodedToken.id);
        setRegion(decodedToken.region);
      } catch (error) {
        console.error('Error decoding token:', error);
        message.error('Invalid token. Please log in again.');
      }
    }
  }, [token]);

  useEffect(() => {
    const fetchAreas = async () => {
      try {
        const response = await axios.get('api/express/areas');
        const decodedToken = jwtDecode(token);
        const areaList = response.data.areas.filter(
          (area) => area.region === decodedToken.region
        );
        setAreas(areaList);
      } catch (error) {
        message.error('Error fetching areas:', error);
      }
    };
    fetchAreas();
  }, [token]);

  const handleCSVUpload = ({ file }) => {
    if (file.status === 'removed') {
      setCsvElements([]);
      return;
    }

    const reader = new FileReader();
    reader.onload = (event) => {
      const text = event.target.result;
      const csvElements = text.split(/\r?\n/).filter(Boolean);
      setCsvElements(csvElements);
      console.log(csvElements);
    };
    reader.readAsText(file);
  };

  const handleExcelUpload = ({ file }) => {
    if (file.status === 'removed') {
      setExcelFile(null);
      return;
    }
    // antd Upload wraps the native File in file.originFileObj when beforeUpload returns false
    setExcelFile(file.originFileObj || file);
  };

  const handleSubmitBatch = async (values) => {
    setIsBatchLoading(true);
    setBatchProgress(0);
    try {
      const { userIdForm, areaId, modelName } = values;
      if (!areaId || !modelName)
        throw new Error('You need to select area and model');

      setBatchProgress(20);
      const headers = csvElements[0].split(',');
      const data = csvElements.slice(1).map((line) => {
        const parts = line.split(',');
        const obj = {};
        for (let i = 0; i < headers.length; i++) {
          obj[headers[i]] = parseFloat(parts[i]);
        }
        console.log('data', obj);

        return obj;
      });
      console.log('data', data);

      setBatchProgress(50);
      await axios.post('api/express/predictions/batch', {
        userId,
        areaId,
        modelName,
        data,
      });

      setBatchProgress(100);
      message.success(`Đã tạo thành công ${data.length} dự đoán từ file CSV!`);
      batchForm.resetFields();
      setCsvElements([]);
      navigate('/dashboard');
    } catch (error) {
      message.error(`${error}`);
    } finally {
      setIsBatchLoading(false);
      setBatchProgress(0);
    }
  };

  const handleSubmitExcel = async (values) => {
    console.log('values', values);

    setIsBatchLoading(true);
    setBatchProgress(0);
    try {
      const { areaId, modelName } = values;
      if (!areaId || !modelName) throw new Error('You need to select area and model');
      if (!excelFile) throw new Error('You need to upload an Excel file');

      const formData = new FormData();
      formData.append('userId', userId);
      formData.append('areaId', areaId);
      formData.append('modelName', modelName);
      formData.append('file', excelFile);

      setBatchProgress(30);
      await axios.post('api/express/predictions/excel', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });

      setBatchProgress(100);
      message.success('Đã tạo dự đoán từ Excel!');
      batchForm.resetFields();
      setExcelFile(null);
      navigate('/dashboard');
    } catch (error) {
      message.error(`${error}`);
    } finally {
      setIsBatchLoading(false);
      setBatchProgress(0);
    }
  };

  const handleSubmitSingle = async (values) => {
    setIsSingleLoading(true);
    try {
      const { userIdForm, areaId, modelName, ...inputValues } = values;
      await axios.post('api/express/predictions', {
        userId,
        areaId,
        modelName,
        inputs: inputValues,
      });
      message.success('Created single prediction successful!');
      singleForm.resetFields();
      navigate('/dashboard');
    } catch (e) {
      message.error(`${e}`);
    } finally {
      setIsSingleLoading(false);
    }
  };

  const filteredModels = areaType
    ? allModels.filter((m) => m.type === areaType)
    : [];

  return (
    <Card style={{ maxWidth: 700, margin: '0 auto', marginTop: 32 }}>
      <Title level={3} style={{ textAlign: 'center', marginBottom: 24 }}>
        {t('prediction_form.title')}
      </Title>
      <Spin
        spinning={isBatchLoading || isSingleLoading}
        tip={
          isBatchLoading
            ? `Đang xử lý dự đoán hàng loạt... ${batchProgress}%`
            : 'Đang tạo dự đoán...'
        }
      >
        <Tabs
          activeKey={activeTab}
          onChange={setActiveTab}
          disabled={isBatchLoading || isSingleLoading}
          items={[
            {
              key: 'single',
              label: t('prediction_form.tabs.single'),
              children: (
                <Form
                  form={singleForm}
                  layout="vertical"
                  onFinish={handleSubmitSingle}
                  initialValues={{ userId }}
                  disabled={isSingleLoading}
                >
                  <Form.Item name="userIdForm" style={{ display: 'none' }}>
                    <Input type="hidden" value={userId} />
                  </Form.Item>
                  <Form.Item
                    label={t('prediction_form.select_area')}
                    name="areaId"
                    rules={[
                      {
                        required: true,
                        message: t('prediction_form.select_area'),
                      },
                    ]}
                  >
                    <Select
                      placeholder={t('prediction_form.select_area')}
                      onChange={(val) => {
                        setSelectedAreaId(val);
                        const area = areas.find((a) => a.id === +val);
                        setAreaType(area?.area_type);
                        singleForm.setFieldsValue({ modelName: undefined });
                      }}
                    >
                      {areas.map((area) => (
                        <Option key={area.id} value={area.id}>
                          {area.name}
                        </Option>
                      ))}
                    </Select>
                  </Form.Item>
                  <Form.Item
                    label={t('prediction_form.select_model')}
                    name="modelName"
                    rules={[
                      {
                        required: true,
                        message: t('prediction_form.select_model'),
                      },
                    ]}
                  >
                    <Select
                      placeholder={t('prediction_form.select_model')}
                      disabled={!areaType}
                    >
                      {filteredModels.map((model) => (
                        <Option key={model.value} value={model.value}>
                          {model.label}
                        </Option>
                      ))}
                    </Select>
                  </Form.Item>
                  {areaType &&
                    Object.keys(inputs).map((key) => (
                      <Form.Item
                        key={key}
                        label={key}
                        name={key}
                        rules={[
                          { required: true, message: `${key} is required` },
                        ]}
                      >
                        <Input type="number" />
                      </Form.Item>
                    ))}
                  <Form.Item>
                    <Button
                      type="primary"
                      htmlType="submit"
                      block
                      loading={isSingleLoading}
                      disabled={isSingleLoading}
                    >
                      {isSingleLoading ? 'Đang tạo dự đoán...' : t('prediction_form.submit_single')}
                    </Button>
                  </Form.Item>
                </Form>
              ),
            },
            {
              key: 'batch',
              label: t('prediction_form.tabs.batch'),
              children: (
                <Form
                  form={batchForm}
                  layout="vertical"
                  onFinish={activeTab === 'batch' ? handleSubmitBatch : undefined}
                  initialValues={{ userId }}
                  disabled={isBatchLoading}
                >
                  <Form.Item name="userIdForm" style={{ display: 'none' }}>
                    <Input type="hidden" value={userId} />
                  </Form.Item>
                  <Form.Item
                    label={t('prediction_form.select_area')}
                    name="areaId"
                    rules={[
                      {
                        required: true,
                        message: t('prediction_form.select_area'),
                      },
                    ]}
                  >
                    <Select
                      placeholder={t('prediction_form.select_area')}
                      onChange={(val) => {
                        setSelectedAreaId(val);
                        const area = areas.find((a) => a.id === +val);
                        setAreaType(area?.area_type);
                        batchForm.setFieldsValue({ modelName: undefined });
                      }}
                    >
                      {areas.map((area) => (
                        <Option key={area.id} value={area.id}>
                          {area.name}
                        </Option>
                      ))}
                    </Select>
                  </Form.Item>
                  <Form.Item
                    label={t('prediction_form.select_model')}
                    name="modelName"
                    rules={[
                      {
                        required: true,
                        message: t('prediction_form.select_model'),
                      },
                    ]}
                  >
                    <Select
                      placeholder={t('prediction_form.select_model')}
                      disabled={!areaType}
                    >
                      {filteredModels.map((model) => (
                        <Option key={model.value} value={model.value}>
                          {model.label}
                        </Option>
                      ))}
                    </Select>
                  </Form.Item>
                  <Form.Item
                    label={t('prediction_form.upload_csv') || 'Upload CSV'}
                    name="csv"
                    rules={[
                      {
                        required: true,
                        message: t('prediction_form.upload_csv') || 'Upload CSV',
                      },
                    ]}
                  >
                    <Upload
                      accept=".csv"
                      beforeUpload={() => false}
                      onChange={handleCSVUpload}
                      maxCount={1}
                      fileList={
                        csvElements.length > 0
                          ? [{ name: 'data.csv', status: 'done' }]
                          : []
                      }
                    >
                      <Button icon={<UploadOutlined />}>
                        {t('prediction_form.upload_csv') || 'Upload CSV'}
                      </Button>
                    </Upload>
                  </Form.Item>
                  <Form.Item>
                    <Button
                      type="primary"
                      htmlType="submit"
                      block
                      loading={isBatchLoading}
                      disabled={isBatchLoading}
                    >
                      {isBatchLoading ? 'Đang tạo dự đoán hàng loạt...' : t('prediction_form.submit_batch')}
                    </Button>
                  </Form.Item>
                </Form>
              ),
            },
            {
              key: 'excel',
              label: 'Batch Excel',
              children: (
                <Form
                  form={batchForm}
                  layout="vertical"
                  onFinish={handleSubmitExcel}
                  initialValues={{ userId }}
                  disabled={isBatchLoading}
                >
                  <Form.Item name="userIdForm" style={{ display: 'none' }}>
                    <Input type="hidden" value={userId} />
                  </Form.Item>
                  <Form.Item
                    label={t('prediction_form.select_area')}
                    name="areaId"
                    rules={[
                      { required: true, message: t('prediction_form.select_area') },
                    ]}
                  >
                    <Select
                      placeholder={t('prediction_form.select_area')}
                      onChange={(val) => {
                        setSelectedAreaId(val);
                        const area = areas.find((a) => a.id === +val);
                        setAreaType(area?.area_type);
                        batchForm.setFieldsValue({ modelName: undefined });
                      }}
                    >
                      {areas.map((area) => (
                        <Option key={area.id} value={area.id}>
                          {area.name}
                        </Option>
                      ))}
                    </Select>
                  </Form.Item>
                  <Form.Item
                    label={t('prediction_form.select_model')}
                    name="modelName"
                    rules={[
                      { required: true, message: t('prediction_form.select_model') },
                    ]}
                  >
                    <Select
                      placeholder={t('prediction_form.select_model')}
                      disabled={!areaType}
                    >
                      {filteredModels.map((model) => (
                        <Option key={model.value} value={model.value}>
                          {model.label}
                        </Option>
                      ))}
                    </Select>
                  </Form.Item>
                  <Form.Item
                    label={'Upload Excel (.xlsx/.xls)'}
                  >
                    <Upload
                      accept=".xlsx,.xls"
                      beforeUpload={() => false}
                      onChange={handleExcelUpload}
                      maxCount={1}
                      fileList={excelFile ? [{ name: excelFile.name || 'excel.xlsx', status: 'done' }] : []}
                    >
                      <Button icon={<UploadOutlined />}>Upload Excel</Button>
                    </Upload>
                  </Form.Item>
                  <Form.Item>
                    <Button
                      type="primary"
                      htmlType="submit"
                      block
                      loading={isBatchLoading}
                      disabled={isBatchLoading}
                    >
                      {isBatchLoading ? 'Đang tạo dự đoán từ Excel...' : 'Tạo dự đoán từ Excel'}
                    </Button>
                  </Form.Item>
                </Form>
              ),
            },
          ]}
        />
      </Spin>
    </Card>
  );
};

export default CreateNewPrediction;

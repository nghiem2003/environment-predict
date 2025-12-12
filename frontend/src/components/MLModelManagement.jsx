import React, { useState, useEffect } from 'react';
import {
  Table,
  Button,
  Modal,
  Form,
  Input,
  Select,
  Switch,
  message,
  Space,
  Tag,
  Card,
  Row,
  Col,
  Popconfirm,
  Tooltip,
  Transfer,
  InputNumber,
  Upload,
  Tabs,
} from 'antd';
import {
  PlusOutlined,
  EditOutlined,
  PoweroffOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  UploadOutlined,
  InboxOutlined,
  CloseOutlined,
  InfoCircleOutlined,
  DeleteOutlined,
} from '@ant-design/icons';
import axios from '../axios';
import { useTranslation } from 'react-i18next';
import NatureElementModal from './NatureElementModal';
import NatureElementManagement from './NatureElementManagement';

const { Option } = Select;
const { TextArea } = Input;

const MLModelManagement = () => {
  const { t } = useTranslation();
  const [models, setModels] = useState([]);
  const [natureElements, setNatureElements] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [editingModel, setEditingModel] = useState(null);
  const [form] = Form.useForm();
  const [targetKeys, setTargetKeys] = useState([]);
  const [selectedKeys, setSelectedKeys] = useState([]);
  const [elementConfig, setElementConfig] = useState({}); // Store input_order and is_required

  // Nature element creation modal
  const [isAddElementModalVisible, setIsAddElementModalVisible] = useState(false);

  // Model file upload modal
  const [isUploadModalVisible, setIsUploadModalVisible] = useState(false);
  const [uploadingModel, setUploadingModel] = useState(null);
  const [fileList, setFileList] = useState([]);

  // Nature element detail modal
  const [isElementDetailModalVisible, setIsElementDetailModalVisible] = useState(false);
  const [selectedElement, setSelectedElement] = useState(null);

  // Add element to model
  const [addingElementToModel, setAddingElementToModel] = useState(null);
  const [searchElementValue, setSearchElementValue] = useState('');

  // Fetch all ML models
  const fetchModels = async () => {
    setLoading(true);
    try {
      const response = await axios.get('/api/express/ml-models');
      setModels(response.data.data || []);
    } catch (error) {
      console.error('Error fetching ML models:', error);
      message.error('Không thể tải danh sách model');
    } finally {
      setLoading(false);
    }
  };

  // Fetch all nature elements
  const fetchNatureElements = async () => {
    try {
      const response = await axios.get('/api/express/nature-elements');
      setNatureElements(response.data?.data?.elements || []);
    } catch (error) {
      console.error('Error fetching nature elements:', error);
      message.error('Không thể tải danh sách yếu tố môi trường');
    }
  };

  // Open modal to add new nature element
  const showAddElementModal = () => {
    setIsAddElementModalVisible(true);
  };

  const handleCancelAddElement = () => {
    setIsAddElementModalVisible(false);
  };

  // Handle success after adding nature element
  const handleAddElementSuccess = async (newElement) => {
    // Refresh nature elements list
    await fetchNatureElements();

    // Auto-select the newly created element
    const newElementId = newElement.id;
    if (newElementId) {
      setTargetKeys([...targetKeys, newElementId]);
      setElementConfig((prev) => ({
        ...prev,
        [newElementId]: { input_order: 0, is_required: true },
      }));
    }

    setIsAddElementModalVisible(false);
  };

  useEffect(() => {
    fetchModels();
    fetchNatureElements();
  }, []);

  // Open modal for create/edit
  const showModal = (model = null) => {
    setEditingModel(model);
    setIsModalVisible(true);

    if (model) {
      // Editing existing model
      form.setFieldsValue({
        name: model.name,
        description: model.description,
        model_file_path: model.model_file_path,
        area_type: model.area_type,
        is_active: model.is_active,
      });

      // Set transfer target keys and config
      const selectedIds = model.natureElements?.map((ne) => ne.id) || [];
      setTargetKeys(selectedIds);

      const config = {};
      model.natureElements?.forEach((ne) => {
        config[ne.id] = {
          input_order: ne.ModelNatureElement?.input_order || 0,
          is_required: ne.ModelNatureElement?.is_required !== false,
        };
      });
      setElementConfig(config);
    } else {
      // Creating new model
      form.resetFields();
      form.setFieldsValue({ is_active: true });
      setTargetKeys([]);
      setElementConfig({});
    }
  };

  const handleCancel = () => {
    setIsModalVisible(false);
    setEditingModel(null);
    form.resetFields();
    setTargetKeys([]);
    setElementConfig({});
    setSelectedKeys([]);
  };

  // Check for duplicate before save
  const checkDuplicateModel = async (name, area_type, exclude_id = null) => {
    try {
      const response = await axios.post('/api/express/ml-models/check-duplicate', {
        name,
        area_type,
        exclude_id,
      });

      const { hasDuplicate, conflicts, generatedInfo } = response.data;

      if (hasDuplicate) {
        const conflictMessages = conflicts.map(c => c.message).join('\n');
        const flaskKey = generatedInfo.flaskModelKey;
        
        Modal.warning({
          title: 'Cảnh báo trùng lặp!',
          content: (
            <div>
              <p style={{ marginBottom: 8 }}>{conflictMessages}</p>
              <div style={{ background: '#fff7e6', padding: 12, borderRadius: 4, marginTop: 12 }}>
                <p style={{ margin: 0, fontSize: 12 }}>
                  <strong>File name sẽ tạo ra:</strong> {generatedInfo.fileName}
                </p>
                <p style={{ margin: 0, fontSize: 12, marginTop: 4 }}>
                  <strong>Flask model key:</strong> {flaskKey}
                </p>
              </div>
              <p style={{ marginTop: 12, color: '#ff4d4f' }}>
                Vui lòng đổi tên model để tránh xung đột!
              </p>
            </div>
          ),
          width: 600,
        });
        return false;
      }

      return true;
    } catch (error) {
      console.error('Error checking duplicate:', error);
      message.error('Không thể kiểm tra trùng lặp');
      return false;
    }
  };

  // Handle form submit
  const handleSubmit = async () => {
    try {
      const values = await form.validateFields();

      // Check for duplicates before submitting
      const isDuplicateFree = await checkDuplicateModel(
        values.name,
        values.area_type,
        editingModel ? editingModel.id : null
      );

      if (!isDuplicateFree) {
        return; // Stop submission if duplicate found
      }

      // Prepare nature elements array with config
      const natureElementsData = targetKeys.map((id) => ({
        nature_element_id: id,
        is_required: elementConfig[id]?.is_required !== false,
        input_order: elementConfig[id]?.input_order || 0,
      }));

      const payload = {
        ...values,
        natureElements: natureElementsData,
      };

      if (editingModel) {
        // Update
        await axios.put(`/api/express/ml-models/${editingModel.id}`, payload);
        message.success('Cập nhật model thành công');
      } else {
        // Create
        await axios.post('/api/express/ml-models', payload);
        message.success('Tạo model mới thành công');
      }

      handleCancel();
      fetchModels();
    } catch (error) {
      console.error('Error saving model:', error);
      message.error(error.response?.data?.error || 'Có lỗi xảy ra khi lưu model');
    }
  };

  // Toggle model status
  const handleToggleStatus = async (id, currentStatus) => {
    try {
      await axios.patch(`/api/express/ml-models/${id}/toggle-status`, {
        is_active: !currentStatus,
      });
      message.success(`Model đã ${!currentStatus ? 'kích hoạt' : 'tắt'}`);
      fetchModels();
    } catch (error) {
      console.error('Error toggling model status:', error);
      message.error('Không thể thay đổi trạng thái model');
    }
  };

  // Delete custom model
  const handleDeleteModel = (record) => {
    // Check if model has file
    if (record.model_file_path || record.google_drive_file_id) {
      Modal.warning({
        title: 'Không thể xóa model',
        content: (
          <div>
            <p>Model <strong>{record.name}</strong> đã có file upload.</p>
            <p style={{ marginTop: 12, color: '#666' }}>
              File: <code>{record.model_file_path}</code>
            </p>
            <p style={{ marginTop: 12 }}>
              Bạn chỉ có thể <strong>Tắt (disable)</strong> model này, không thể xóa.
            </p>
          </div>
        ),
      });
      return;
    }

    Modal.confirm({
      title: 'Xác nhận xóa model',
      content: (
        <div>
          <p>Bạn có chắc chắn muốn xóa model <strong>{record.name}</strong>?</p>
          <p style={{ color: '#ff4d4f', marginTop: 8 }}>
            Hành động này không thể hoàn tác!
          </p>
        </div>
      ),
      onOk: async () => {
        try {
          await axios.delete(`/api/express/ml-models/${record.id}`);
          message.success('Xóa model thành công');
          fetchModels();
        } catch (error) {
          console.error('Error deleting model:', error);
          message.error(error.response?.data?.error || 'Không thể xóa model');
        }
      },
      okText: 'Xóa',
      cancelText: 'Hủy',
      okButtonProps: { danger: true },
    });
  };

  // Add nature element to model
  const handleAddElementToModel = async (modelId, elementId) => {
    try {
      const model = models.find(m => m.id === modelId);
      if (!model) return;

      // Check if element already exists
      const elementExists = model.natureElements?.some(ne => ne.id === elementId);
      if (elementExists) {
        message.warning('Yếu tố này đã có trong model');
        return;
      }

      // Prepare updated nature elements
      const existingElements = model.natureElements?.map((ne, index) => ({
        nature_element_id: ne.id,
        is_required: ne.ModelNatureElement?.is_required ?? true,
        input_order: ne.ModelNatureElement?.input_order ?? index,
      })) || [];

      const newElements = [
        ...existingElements,
        {
          nature_element_id: elementId,
          is_required: true,
          input_order: existingElements.length,
        }
      ];

      await axios.put(`/api/express/ml-models/${modelId}`, {
        name: model.name,
        description: model.description,
        area_type: model.area_type,
        is_active: model.is_active,
        natureElements: newElements,
      });

      message.success('Đã thêm yếu tố môi trường');
      fetchModels();
      setAddingElementToModel(null);
      setSearchElementValue('');
    } catch (error) {
      console.error('Error adding element to model:', error);
      message.error(error.response?.data?.error || 'Không thể thêm yếu tố');
    }
  };

  // Remove nature element from model
  const handleRemoveElementFromModel = async (modelId, elementId) => {
    try {
      const model = models.find(m => m.id === modelId);
      if (!model) return;

      // Filter out the element to remove and update input_order
      const updatedElements = model.natureElements
        ?.filter(ne => ne.id !== elementId)
        .map((ne, index) => ({
          nature_element_id: ne.id,
          is_required: ne.ModelNatureElement?.is_required ?? true,
          input_order: index,
        })) || [];

      await axios.put(`/api/express/ml-models/${modelId}`, {
        name: model.name,
        description: model.description,
        area_type: model.area_type,
        is_active: model.is_active,
        natureElements: updatedElements,
      });

      message.success('Đã xóa yếu tố môi trường');
      fetchModels();
    } catch (error) {
      console.error('Error removing element from model:', error);
      message.error(error.response?.data?.error || 'Không thể xóa yếu tố');
    }
  };

  // Show element detail modal
  const showElementDetail = (element) => {
    setSelectedElement(element);
    setIsElementDetailModalVisible(true);
  };

  // Get available elements for adding (exclude already added ones)
  const getAvailableElements = (model) => {
    const existingIds = model.natureElements?.map(ne => ne.id) || [];
    return natureElements.filter(ne => !existingIds.includes(ne.id));
  };

  // Show upload modal
  const showUploadModal = (model) => {
    setUploadingModel(model);
    setIsUploadModalVisible(true);
    setFileList([]);
  };

  const handleCancelUpload = () => {
    setIsUploadModalVisible(false);
    setUploadingModel(null);
    setFileList([]);
  };

  // Handle file upload
  const handleFileUpload = async (options) => {
    const { file, onSuccess, onError } = options;

    const formData = new FormData();
    formData.append('file', file);

    try {
      const response = await axios.post(
        `/api/express/ml-models/${uploadingModel.id}/upload`,
        formData,
        {
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        }
      );

      message.success('Upload file model thành công! Flask đã reload models.');
      onSuccess(response.data, file);

      // Refresh models list
      fetchModels();

      // Close modal after short delay
      setTimeout(() => {
        handleCancelUpload();
      }, 1000);
    } catch (error) {
      console.error('Error uploading model file:', error);
      message.error(error.response?.data?.error || 'Không thể upload file model');
      onError(error);
    }
  };

  const uploadProps = {
    accept: '.pkl',
    maxCount: 1,
    fileList,
    customRequest: handleFileUpload,
    onChange: ({ fileList: newFileList }) => {
      setFileList(newFileList);
    },
    beforeUpload: (file) => {
      if (!file.name.endsWith('.pkl')) {
        message.error('Chỉ cho phép upload file .pkl');
        return Upload.LIST_IGNORE;
      }
      if (file.size > 500 * 1024 * 1024) {
        message.error('File không được vượt quá 500MB');
        return Upload.LIST_IGNORE;
      }
      return true;
    },
  };

  // Transfer component handlers
  const handleTransferChange = (newTargetKeys) => {
    setTargetKeys(newTargetKeys);

    // Initialize config for newly added elements
    newTargetKeys.forEach((key) => {
      if (!elementConfig[key]) {
        setElementConfig((prev) => ({
          ...prev,
          [key]: { input_order: 0, is_required: true },
        }));
      }
    });
  };

  const handleSelectChange = (sourceSelectedKeys, targetSelectedKeys) => {
    setSelectedKeys([...sourceSelectedKeys, ...targetSelectedKeys]);
  };

  // Update element config
  const updateElementConfig = (id, field, value) => {
    setElementConfig((prev) => ({
      ...prev,
      [id]: {
        ...prev[id],
        [field]: value,
      },
    }));
  };

  // Table columns
  const columns = [
    {
      title: 'ID',
      dataIndex: 'id',
      key: 'id',
      width: 60,
    },
    {
      title: 'Tên Model',
      dataIndex: 'name',
      key: 'name',
      ellipsis: true,
    },
    {
      title: 'Mô tả',
      dataIndex: 'description',
      key: 'description',
      ellipsis: true,
      render: (text) => text || '-',
    },
    {
      title: 'Loại khu vực',
      dataIndex: 'area_type',
      key: 'area_type',
      width: 120,
      render: (type) => {
        if (!type) return '-';
        return (
          <Tag color={type === 'oyster' ? 'blue' : 'green'}>
            {type === 'oyster' ? 'Hàu' : 'Cá bớp'}
          </Tag>
        );
      },
    },
    {
      title: 'Số yếu tố',
      key: 'elementCount',
      width: 100,
      align: 'center',
      render: (_, record) => record.natureElements?.length || 0,
    },
    {
      title: 'Loại Model',
      dataIndex: 'is_default',
      key: 'is_default',
      width: 110,
      align: 'center',
      render: (isDefault) =>
        isDefault ? (
          <Tag color="gold">Mặc định</Tag>
        ) : (
          <Tag color="cyan">Tùy chỉnh</Tag>
        ),
    },
    {
      title: 'Trạng thái',
      dataIndex: 'is_active',
      key: 'is_active',
      width: 100,
      align: 'center',
      render: (isActive) =>
        isActive ? (
          <Tag icon={<CheckCircleOutlined />} color="success">
            Hoạt động
          </Tag>
        ) : (
          <Tag icon={<CloseCircleOutlined />} color="default">
            Tắt
          </Tag>
        ),
    },
    {
      title: 'Hành động',
      key: 'actions',
      width: 220,
      align: 'center',
      render: (_, record) => (
        <Space size="small">
          {!record.is_default && (
            <Tooltip title="Upload file model">
              <Button
                icon={<UploadOutlined />}
                size="small"
                onClick={() => showUploadModal(record)}
              />
            </Tooltip>
          )}
          <Tooltip title={record.is_default ? 'Model mặc định không thể chỉnh sửa' : 'Chỉnh sửa'}>
            <Button
              type="primary"
              icon={<EditOutlined />}
              size="small"
              onClick={() => showModal(record)}
              disabled={record.is_default}
            />
          </Tooltip>
          <Tooltip title={record.is_active ? 'Tắt model' : 'Kích hoạt model'}>
            <Button
              icon={<PoweroffOutlined />}
              size="small"
              onClick={() => handleToggleStatus(record.id, record.is_active)}
              style={{
                color: record.is_active ? '#ff4d4f' : '#52c41a',
                borderColor: record.is_active ? '#ff4d4f' : '#52c41a',
              }}
            />
          </Tooltip>
          {!record.is_default && !record.model_file_path && (
            <Tooltip title="Xóa model">
              <Button
                danger
                icon={<DeleteOutlined />}
                size="small"
                onClick={() => handleDeleteModel(record)}
              />
            </Tooltip>
          )}
          {!record.is_default && record.model_file_path && (
            <Tooltip title="Không thể xóa model đã có file. Chỉ có thể disable.">
              <Button
                danger
                icon={<DeleteOutlined />}
                size="small"
                disabled
                style={{ opacity: 0.3 }}
              />
            </Tooltip>
          )}
        </Space>
      ),
    },
  ];

  return (
    <div style={{ padding: '24px' }}>
      <Tabs
        defaultActiveKey="models"
        items={[
          {
            key: 'models',
            label: 'Quản lý Models',
            children: (
              <Card
                title="Quản lý Model Học Máy"
                extra={
                  <Button
                    type="primary"
                    icon={<PlusOutlined />}
                    onClick={() => showModal()}
                  >
                    Thêm Model
                  </Button>
                }
              >
                <Table
                  columns={columns}
                  dataSource={models}
                  rowKey="id"
                  loading={loading}
                  pagination={{
                    pageSize: 10,
                    showSizeChanger: true,
                    showTotal: (total) => `Tổng số ${total} model`,
                  }}
                  expandable={{
                    expandedRowRender: (record) => {
                      const availableElements = getAvailableElements(record);
                      const isAdding = addingElementToModel === record.id;

                      return (
                        <div style={{ padding: '12px 24px' }}>
                          <p style={{ marginBottom: 8 }}>
                            <strong>File model:</strong> {record.model_file_path || 'Chưa có'}
                          </p>
                          {record.google_drive_download_link && (
                            <p style={{ marginBottom: 8, fontSize: 12, color: '#666' }}>
                              <strong>Google Drive:</strong>{' '}
                              <a href={record.google_drive_download_link} target="_blank" rel="noopener noreferrer">
                                Xem file
                              </a>
                            </p>
                          )}
                          <div style={{ marginTop: 16 }}>
                            <p style={{ marginBottom: 12 }}>
                              <strong>Yếu tố môi trường ({record.natureElements?.length || 0}):</strong>
                            </p>
                            <Space size={[8, 8]} wrap>
                              {record.natureElements?.map((element) => (
                                <Tag
                                  key={element.id}
                                  color="blue"
                                  style={{
                                    cursor: 'pointer',
                                    fontSize: '13px',
                                    padding: '4px 10px',
                                    display: 'inline-flex',
                                    alignItems: 'center',
                                    gap: '6px',
                                  }}
                                  onClick={() => showElementDetail(element)}
                                >
                                  <span>
                                    {element.name}
                                    {element.ModelNatureElement?.is_required && ' *'}
                                    <span style={{ color: '#bbb', marginLeft: 4 }}>
                                      ({element.ModelNatureElement?.input_order})
                                    </span>
                                  </span>
                                  {!record.is_default && (
                                    <CloseOutlined
                                      style={{
                                        fontSize: 10,
                                        marginLeft: 4,
                                        color: '#ff4d4f',
                                      }}
                                      onClick={(e) => {
                                        e.stopPropagation();
                                        Modal.confirm({
                                          title: 'Xác nhận xóa',
                                          content: `Bạn có chắc muốn xóa "${element.name}" khỏi model này?`,
                                          onOk: () => handleRemoveElementFromModel(record.id, element.id),
                                          okText: 'Xóa',
                                          cancelText: 'Hủy',
                                          okButtonProps: { danger: true },
                                        });
                                      }}
                                    />
                                  )}
                                </Tag>
                              ))}

                              {!record.is_default && (
                                <>
                                  {isAdding ? (
                                    <Select
                                      showSearch
                                      placeholder="Chọn yếu tố"
                                      style={{ width: 250 }}
                                      value={searchElementValue}
                                      onChange={(value) => {
                                        handleAddElementToModel(record.id, value);
                                      }}
                                      onBlur={() => {
                                        setAddingElementToModel(null);
                                        setSearchElementValue('');
                                      }}
                                      filterOption={(input, option) =>
                                        option.children.toLowerCase().indexOf(input.toLowerCase()) >= 0
                                      }
                                      autoFocus
                                      open={true}
                                    >
                                      {availableElements.map((el) => (
                                        <Option key={el.id} value={el.id}>
                                          {el.name} {el.unit ? `(${el.unit})` : ''}
                                        </Option>
                                      ))}
                                    </Select>
                                  ) : (
                                    <Tooltip title="Thêm yếu tố môi trường">
                                      <Tag
                                        icon={<PlusOutlined />}
                                        color="success"
                                        style={{
                                          cursor: 'pointer',
                                          borderStyle: 'dashed',
                                          padding: '4px 10px',
                                          fontSize: '13px',
                                        }}
                                        onClick={() => setAddingElementToModel(record.id)}
                                      >
                                        Thêm yếu tố
                                      </Tag>
                                    </Tooltip>
                                  )}
                                </>
                              )}
                            </Space>
                          </div>
                        </div>
                      );
                    },
                  }}
                />
              </Card>
            ),
          },
          {
            key: 'elements',
            label: 'Quản lý Yếu tố Môi trường',
            children: <NatureElementManagement />,
          },
        ]}
      />

      {/* Modals for ML Models */}
      <Modal
        title={editingModel ? 'Chỉnh sửa Model' : 'Thêm Model Mới'}
        open={isModalVisible}
        onOk={handleSubmit}
        onCancel={handleCancel}
        width={900}
        okText={editingModel ? 'Cập nhật' : 'Tạo mới'}
        cancelText="Hủy"
      >
        <Form form={form} layout="vertical">
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                label="Tên Model"
                name="name"
                rules={[{ required: true, message: 'Vui lòng nhập tên model' }]}
              >
                <Input placeholder="VD: Oyster Prediction Model v1.0" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item label="Loại khu vực" name="area_type">
                <Select placeholder="Chọn loại khu vực" allowClear>
                  <Option value="oyster">Hàu</Option>
                  <Option value="cobia">Cá bớp</Option>
                </Select>
              </Form.Item>
            </Col>
          </Row>
          
          {/* Info box about file path */}
          <div style={{ 
            background: '#e6f7ff', 
            border: '1px solid #91d5ff',
            borderRadius: 4, 
            padding: 12, 
            marginBottom: 16 
          }}>
            <p style={{ margin: 0, fontSize: 13, color: '#0050b3' }}>
              ℹ️ <strong>Lưu ý:</strong> Đường dẫn file sẽ tự động được tạo khi bạn upload file .pkl sau khi tạo model.
            </p>
          </div>

          <Form.Item label="Mô tả" name="description">
            <TextArea rows={3} placeholder="Mô tả chi tiết về model" />
          </Form.Item>

          <Form.Item label="Đường dẫn file model" name="model_file_path">
            <Input placeholder="VD: /models/oyster_model_v1.pkl" />
          </Form.Item>

          <Form.Item label="Trạng thái" name="is_active" valuePropName="checked">
            <Switch checkedChildren="Hoạt động" unCheckedChildren="Tắt" />
          </Form.Item>

          <Form.Item
            label={
              <Space>
                <span>Chọn yếu tố môi trường</span>
                <Button
                  type="link"
                  size="small"
                  icon={<PlusOutlined />}
                  onClick={showAddElementModal}
                  style={{ padding: 0 }}
                >
                  Thêm yếu tố mới
                </Button>
              </Space>
            }
          >
            <Transfer
              dataSource={natureElements.map((ne) => ({
                key: ne.id,
                title: ne.name,
                description: ne.unit || '',
              }))}
              titles={['Có sẵn', 'Đã chọn']}
              targetKeys={targetKeys}
              selectedKeys={selectedKeys}
              onChange={handleTransferChange}
              onSelectChange={handleSelectChange}
              render={(item) => `${item.title} ${item.description ? `(${item.description})` : ''}`}
              listStyle={{
                width: 350,
                height: 300,
              }}
            />
          </Form.Item>

          {targetKeys.length > 0 && (
            <Form.Item label="Cấu hình yếu tố đã chọn">
              <div
                style={{
                  maxHeight: 200,
                  overflow: 'auto',
                  border: '1px solid #d9d9d9',
                  borderRadius: 4,
                  padding: 8,
                }}
              >
                {targetKeys.map((key) => {
                  const element = natureElements.find((ne) => ne.id === key);
                  return (
                    <Row
                      key={key}
                      gutter={16}
                      style={{ marginBottom: 8, alignItems: 'center' }}
                    >
                      <Col span={10}>
                        <strong>{element?.name}</strong>
                      </Col>
                      <Col span={7}>
                        <Space size="small">
                          <span>Thứ tự:</span>
                          <InputNumber
                            min={0}
                            max={100}
                            value={elementConfig[key]?.input_order || 0}
                            onChange={(value) =>
                              updateElementConfig(key, 'input_order', value)
                            }
                            size="small"
                            style={{ width: 60 }}
                          />
                        </Space>
                      </Col>
                      <Col span={7}>
                        <Space size="small">
                          <span>Bắt buộc:</span>
                          <Switch
                            checked={elementConfig[key]?.is_required !== false}
                            onChange={(checked) =>
                              updateElementConfig(key, 'is_required', checked)
                            }
                            size="small"
                          />
                        </Space>
                      </Col>
                    </Row>
                  );
                })}
              </div>
            </Form.Item>
          )}
        </Form>
      </Modal>

      {/* Modal to add new Nature Element */}
      <NatureElementModal
        visible={isAddElementModalVisible}
        onCancel={handleCancelAddElement}
        onSuccess={handleAddElementSuccess}
        editingElement={null}
      />

      {/* Modal to upload model file */}
      <Modal
        title={`Upload file model: ${uploadingModel?.name || ''}`}
        open={isUploadModalVisible}
        onCancel={handleCancelUpload}
        footer={null}
        width={600}
      >
        <div style={{ padding: '20px 0' }}>
          <p style={{ marginBottom: 16 }}>
            <strong>Lưu ý:</strong>
          </p>
          <ul style={{ marginBottom: 24 }}>
            <li>Chỉ chấp nhận file .pkl (Pickle format)</li>
            <li>Kích thước tối đa: 500MB</li>
            <li>File sẽ được lưu trong shared volume và Flask sẽ tự động reload</li>
            <li>Model cũ (nếu có) sẽ bị ghi đè</li>
          </ul>

          <Upload.Dragger {...uploadProps}>
            <p className="ant-upload-drag-icon">
              <InboxOutlined />
            </p>
            <p className="ant-upload-text">
              Click hoặc kéo thả file vào đây để upload
            </p>
            <p className="ant-upload-hint">
              Hỗ trợ single upload. Chỉ file .pkl
            </p>
          </Upload.Dragger>

          {uploadingModel?.model_file_path && (
            <div style={{ marginTop: 16, padding: 12, background: '#f5f5f5', borderRadius: 4 }}>
              <p style={{ margin: 0, fontSize: 12, color: '#666' }}>
                <strong>File hiện tại:</strong> {uploadingModel.model_file_path}
              </p>
            </div>
          )}
        </div>
      </Modal>

      {/* Nature Element Detail Modal */}
      <Modal
        title={
          <Space>
            <InfoCircleOutlined style={{ color: '#1890ff' }} />
            <span>Chi tiết Yếu tố Môi trường</span>
          </Space>
        }
        open={isElementDetailModalVisible}
        onCancel={() => {
          setIsElementDetailModalVisible(false);
          setSelectedElement(null);
        }}
        footer={[
          <Button
            key="close"
            type="primary"
            onClick={() => {
              setIsElementDetailModalVisible(false);
              setSelectedElement(null);
            }}
          >
            Đóng
          </Button>,
        ]}
        width={600}
      >
        {selectedElement && (
          <div style={{ padding: '20px 0' }}>
            <Row gutter={[16, 16]}>
              <Col span={24}>
                <div style={{ marginBottom: 16 }}>
                  <Tag color="blue" style={{ fontSize: 16, padding: '4px 12px' }}>
                    {selectedElement.name}
                  </Tag>
                </div>
              </Col>

              <Col span={12}>
                <div style={{ marginBottom: 8 }}>
                  <strong style={{ color: '#666' }}>ID:</strong>
                </div>
                <div>{selectedElement.id}</div>
              </Col>

              <Col span={12}>
                <div style={{ marginBottom: 8 }}>
                  <strong style={{ color: '#666' }}>Đơn vị:</strong>
                </div>
                <div>{selectedElement.unit || '-'}</div>
              </Col>

              <Col span={12}>
                <div style={{ marginBottom: 8 }}>
                  <strong style={{ color: '#666' }}>Danh mục:</strong>
                </div>
                <div>
                  <Tag color="green">{selectedElement.category || '-'}</Tag>
                </div>
              </Col>

              <Col span={24}>
                <div style={{ marginBottom: 8 }}>
                  <strong style={{ color: '#666' }}>Mô tả:</strong>
                </div>
                <div style={{
                  padding: '12px',
                  background: '#f5f5f5',
                  borderRadius: '4px',
                  minHeight: '60px',
                }}>
                  {selectedElement.description || 'Không có mô tả'}
                </div>
              </Col>

              {selectedElement.ModelNatureElement && (
                <>
                  <Col span={12}>
                    <div style={{ marginBottom: 8 }}>
                      <strong style={{ color: '#666' }}>Bắt buộc:</strong>
                    </div>
                    <div>
                      {selectedElement.ModelNatureElement.is_required ? (
                        <Tag color="red">Có</Tag>
                      ) : (
                        <Tag>Không</Tag>
                      )}
                    </div>
                  </Col>

                  <Col span={12}>
                    <div style={{ marginBottom: 8 }}>
                      <strong style={{ color: '#666' }}>Thứ tự input:</strong>
                    </div>
                    <div>
                      <Tag color="blue">{selectedElement.ModelNatureElement.input_order}</Tag>
                    </div>
                  </Col>
                </>
              )}
            </Row>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default MLModelManagement;


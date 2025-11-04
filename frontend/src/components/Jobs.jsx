import React, { useEffect, useState } from 'react';
import { Card, Table, Tag, Space, Select, Input, Button, Typography, message, Pagination } from 'antd';
import axios from '../axios';

const { Title, Text } = Typography;
const { Option } = Select;

const Jobs = () => {
    const [jobs, setJobs] = useState([]);
    const [loading, setLoading] = useState(false);
    const [name, setName] = useState('');
    const [state, setState] = useState('');
    const [pagination, setPagination] = useState({
        current: 1,
        pageSize: 10,
        total: 0,
    });

    const fetchJobs = async (page = 1, pageSize = 10) => {
        try {
            setLoading(true);
            const res = await axios.get('/api/express/jobs', {
                params: {
                    name: name || undefined,
                    state: state || undefined,
                    limit: pageSize,
                    offset: (page - 1) * pageSize
                }
            });
            const rows = res.data?.jobs || [];
            const filtered = name ? rows : rows.filter(r => r.name === 'csv-import' || r.name === 'xlsx-import');
            setJobs(filtered);
            setPagination({
                current: page,
                pageSize: pageSize,
                total: res.data?.total || filtered.length,
            });
        } catch (e) {
            message.error('Không tải được danh sách job');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => { fetchJobs(1, 10); }, []);

    const columns = [
        { title: 'ID', dataIndex: 'id', key: 'id', ellipsis: true },
        { title: 'Tên', dataIndex: 'name', key: 'name' },
        { title: 'Trạng thái', dataIndex: 'state', key: 'state', render: (s) => <Tag color={s === 'completed' ? 'green' : s === 'failed' ? 'red' : s === 'active' ? 'blue' : 'default'}>{s}</Tag> },
        { title: 'Người tạo', key: 'user', render: (_, r) => r.creator?.username || r.data?.userId || '-' },
        { title: 'Khu vực', key: 'area', render: (_, r) => r.data?.areaId || '-' },
        { title: 'Tạo lúc', dataIndex: 'createdon', key: 'createdon', render: (v) => v ? new Date(v).toLocaleString('vi-VN') : '-' },
        { title: 'Bắt đầu', dataIndex: 'startedon', key: 'startedon', render: (v) => v ? new Date(v).toLocaleString('vi-VN') : '-' },
        { title: 'Hoàn tất', dataIndex: 'completedon', key: 'completedon', render: (v) => v ? new Date(v).toLocaleString('vi-VN') : '-' },
    ];

    return (
        <Card>
            <Space direction="vertical" style={{ width: '100%' }} size="large">
                <Title level={3} style={{ margin: 0 }}>Danh sách Job</Title>
                <Space wrap>
                    <Select placeholder="Tên job" allowClear value={name} onChange={setName} style={{ width: 200 }}>
                        <Option value="csv-import">csv-import</Option>
                        <Option value="xlsx-import">xlsx-import</Option>
                    </Select>
                    <Select placeholder="Trạng thái" allowClear value={state} onChange={setState} style={{ width: 180 }}>
                        <Option value="created">created</Option>
                        <Option value="active">active</Option>
                        <Option value="completed">completed</Option>
                        <Option value="failed">failed</Option>
                    </Select>
                    <Button type="primary" onClick={() => fetchJobs(pagination.current, pagination.pageSize)}>Tải</Button>
                </Space>
                <div style={{ overflowX: 'auto', width: '100%' }}>
                    <Table
                        rowKey="id"
                        loading={loading}
                        dataSource={jobs}
                        columns={columns}
                        pagination={false}
                        scroll={{ x: 'max-content' }}
                    />
                </div>
                <div style={{ margin: '16px 0', textAlign: 'center' }}>
                    <Pagination
                        current={pagination.current}
                        total={pagination.total}
                        pageSize={pagination.pageSize}
                        showSizeChanger={false}
                        onChange={(page, pageSize) => fetchJobs(page, pageSize)}
                    />
                </div>
            </Space>
        </Card>
    );
};

export default Jobs;



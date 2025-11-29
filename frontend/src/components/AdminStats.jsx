import React, { useEffect, useState, useMemo, useRef } from 'react';
import { useSelector } from 'react-redux';
import { jwtDecode } from 'jwt-decode';
import axios from '../axios';
import { useTranslation } from 'react-i18next';
import {
    Card, Row, Col, Statistic, Typography, Space, Segmented, Spin, message, Empty, Result
} from 'antd';
import {
    EnvironmentOutlined, UserOutlined, PieChartOutlined, BarChartOutlined
} from '@ant-design/icons';
import * as am5 from '@amcharts/amcharts5';
import * as am5xy from '@amcharts/amcharts5/xy';
import * as am5percent from '@amcharts/amcharts5/percent';
import * as am5hierarchy from '@amcharts/amcharts5/hierarchy';
import am5themes_Animated from '@amcharts/amcharts5/themes/Animated';

const { Title, Text } = Typography;

const COLORS = [
    '#52c41a', '#faad14', '#ff4d4f', '#1890ff', '#722ed1',
    '#13c2c2', '#eb2f96', '#fa8c16', '#2f54eb', '#a0d911',
    '#f5222d', '#fa541c', '#faad14', '#52c41a', '#13c2c2',
    '#1890ff', '#2f54eb', '#722ed1', '#eb2f96', '#a0d911',
];

// Pie Chart Component
const PieChartComponent = ({ data, colors }) => {
    const chartRef = useRef(null);
    const chartDivRef = useRef(null);

    useEffect(() => {
        if (!data || data.length === 0) return;

        const root = am5.Root.new(chartDivRef.current);
        root.setThemes([am5themes_Animated.new(root)]);

        const chart = root.container.children.push(
            am5percent.PieChart.new(root, {
                layout: root.verticalLayout,
            })
        );

        const series = chart.series.push(
            am5percent.PieSeries.new(root, {
                valueField: 'value',
                categoryField: 'category',
            })
        );

        series.data.setAll(
            data.map((item, index) => ({
                category: item.name,
                value: item.value,
                fill: am5.color(colors[index % colors.length]),
            }))
        );

        series.slices.template.setAll({
            stroke: am5.color('#fff'),
            strokeWidth: 2,
        });

        series.labels.template.setAll({
            text: '{category}: {value}',
            fontSize: 12,
        });

        series.ticks.template.setAll({
            disabled: true,
        });

        const legend = chart.children.push(
            am5.Legend.new(root, {
                centerX: am5.percent(50),
                x: am5.percent(50),
                marginTop: 15,
                marginBottom: 15,
            })
        );

        legend.data.setAll(series.dataItems);

        chartRef.current = root;

        return () => {
            root.dispose();
        };
    }, [data, colors]);

    if (!data || data.length === 0) {
        return <Empty description="No data" />;
    }

    return <div ref={chartDivRef} style={{ width: '100%', height: '320px' }} />;
};

// Treemap Component
const TreemapComponent = ({ data }) => {
    const chartRef = useRef(null);
    const chartDivRef = useRef(null);

    useEffect(() => {
        if (!data || data.length === 0) return;
        console.log('haha', data);

        const root = am5.Root.new(chartDivRef.current);
        root.setThemes([am5themes_Animated.new(root)]);

        const container = root.container.children.push(
            am5.Container.new(root, {
                width: am5.percent(100),
                height: am5.percent(100),
                layout: root.verticalLayout,
                paddingTop: 10,
                paddingBottom: 10,
                paddingLeft: 10,
                paddingRight: 10,
            })
        );

        // Tính toán để giảm chênh lệch tỷ lệ
        const values = data.map(item => item.value).filter(v => v > 0);
        if (values.length === 0) {
            console.warn('⚠️ [Treemap] No valid values in data');
            return;
        }

        const minValue = Math.min(...values);
        const maxValue = Math.max(...values);
        const ratio = maxValue / minValue;

        const minPercent = 0.03;
        const adjustedData = ratio > 15
            ? data.map((item, index) => {

                const adjustedValue = Math.max(item.value, maxValue * minPercent);
                return {
                    name: item.name,
                    value: adjustedValue,
                    originalValue: item.value,
                    fill: am5.color(COLORS[index % COLORS.length]),
                };
            })
            : data.map((item, index) => ({
                name: item.name,
                value: item.value,
                originalValue: item.value,
                fill: am5.color(COLORS[index % COLORS.length]),
            }));

        console.log('📊 [Treemap] Adjusted data:', {
            length: adjustedData.length,
            data: adjustedData.map(item => ({
                name: item.name,
                value: item.value,
                originalValue: item.originalValue
            })),
        });

        // Wrap data trong children array cho treemap
        const treemapData = {
            name: 'root',
            children: adjustedData,
        };

        const series = container.children.push(
            am5hierarchy.Treemap.new(root, {
                singleBranchOnly: false,
                downDepth: 1,
                upDepth: 0,
                initialDepth: 1,
                valueField: 'originalValue',
                categoryField: 'name',
                childDataField: "children",
            })
        );

        series.data.setAll([treemapData])

        // Đảm bảo label hiển thị cho cả phần tử nhỏ
        // Hiển thị giá trị gốc (originalValue) nếu có, nếu không thì dùng value
        series.labels.template.setAll({
            fontSize: 12,
            fill: am5.color('#fff'),
            text: '{name}\n{value}',
            minFontSize: 10,
            maxFontSize: 16,
            oversizedBehavior: 'hide',
        });


        // Adapter để hiển thị originalValue thay vì value đã điều chỉnh
        // Chỉ áp dụng cho các node con (không phải root)

        series.rectangles.template.setAll({
            stroke: am5.color('#fff'),
            strokeWidth: 2,
            cornerRadiusTL: 10,
            cornerRadiusTR: 10,
            cornerRadiusBL: 10,
            cornerRadiusBR: 10,
        });

        series.rectangles.template.adapters.add('fill', (fill, target) => {
            return target.dataItem?.dataContext?.fill || fill;
        });

        chartRef.current = root;

        return () => {
            root.dispose();
        };
    }, [data]);

    if (!data || data.length === 0) {
        return <Empty description="No data" />;
    }

    return <div ref={chartDivRef} style={{ width: '100%', height: '320px' }} />;
};

const LineChartComponent = ({ data, granularity = 'day' }) => {
    const chartRef = useRef(null);
    const chartDivRef = useRef(null);

    useEffect(() => {
        // Chỉ dispose chart khi thực sự không có dữ liệu và đã có chart trước đó
        // Không dispose ngay khi data tạm thời empty để tránh flicker
        if (!data || !Array.isArray(data) || data.length === 0) {
            // Chỉ dispose nếu đã có chart và data thực sự không có (không phải đang loading)
            if (chartRef.current && (!data || data.length === 0)) {
                // Delay một chút để tránh dispose khi đang fetch
                const timeoutId = setTimeout(() => {
                    if (chartRef.current && (!data || !Array.isArray(data) || data.length === 0)) {
                        chartRef.current.dispose();
                        chartRef.current = null;
                    }
                }, 500);
                return () => clearTimeout(timeoutId);
            }
            return;
        }

        // Tạo root
        const root = am5.Root.new(chartDivRef.current);
        root.setThemes([am5themes_Animated.new(root)]);

        // Tạo chart với pan/zoom
        const chart = root.container.children.push(am5xy.XYChart.new(root, {
            panX: true,
            panY: true,
            wheelX: 'panX',
            wheelY: 'zoomX',
            pinchZoomX: true,
            paddingLeft: 0,
        }));

        // Tạo DateAxis - điều chỉnh theo granularity
        const xAxis = chart.xAxes.push(
            am5xy.DateAxis.new(root, {
                maxDeviation: 0.05,
                baseInterval: granularity === 'month'
                    ? { timeUnit: 'month', count: 1 }
                    : { timeUnit: 'day', count: 1 },
                renderer: am5xy.AxisRendererX.new(root, {
                    minGridDistance: 80,
                    minorGridEnabled: true,
                    pan: 'zoom',
                }),
                tooltip: am5.Tooltip.new(root, {}),
            })
        );

        // Giới hạn zoom out - tối đa 14 giá trị (12 + 1 mỗi bên)
        xAxis.events.on('selectionextremeschanged', () => {
            const selection = xAxis.get('selection');
            if (selection && chartData.length > 0) {
                const firstDate = chartData[0].date;
                const lastDate = chartData[chartData.length - 1].date;
                const totalRange = lastDate - firstDate;
                const maxRange = totalRange * (14 / 12); // Cho phép zoom out tối đa 14/12 lần

                const currentRange = selection.endDate.getTime() - selection.startDate.getTime();
                if (currentRange > maxRange) {
                    // Giới hạn zoom out
                    const center = (selection.startDate.getTime() + selection.endDate.getTime()) / 2;
                    const newStart = new Date(center - maxRange / 2);
                    const newEnd = new Date(center + maxRange / 2);
                    xAxis.zoomToDates(newStart, newEnd);
                }
            }
        });

        // Tạo ValueAxis
        const yAxis = chart.yAxes.push(
            am5xy.ValueAxis.new(root, {
                maxDeviation: 1,
                renderer: am5xy.AxisRendererY.new(root, {
                    pan: 'zoom',
                }),
            })
        );

        // Tạo SmoothedXLineSeries - tự động làm mượt đường line
        const series = chart.series.push(
            am5xy.SmoothedXLineSeries.new(root, {
                name: 'Subscriptions',
                xAxis: xAxis,
                yAxis: yAxis,
                valueYField: 'value',
                valueXField: 'date',
                stroke: am5.color('#722ed1'),
                fill: am5.color('#722ed1'),
                tooltip: am5.Tooltip.new(root, {
                    labelText: 'Số email đăng ký: {valueY}',
                }),
            })
        );

        // Cấu hình stroke
        series.strokes.template.setAll({
            strokeWidth: 2,
        });

        // Cấu hình fill
        series.fills.template.setAll({
            fillOpacity: 0.2,
            visible: true,
        });

        // Parse và set data - chỉ lấy tối đa 12 điểm cuối cùng
        const limitedData = data.length > 12 ? data.slice(-12) : data;

        const chartData = limitedData
            .map((item, index) => {
                if (!item || !item.date) {
                    console.warn(`⚠️ [LineChart] Invalid item at index ${index}:`, item);
                    return null;
                }

                // Parse date string 'YYYY-MM-DD'
                const dateStr = item.date;
                let date;

                if (typeof dateStr === 'string' && dateStr.includes('-')) {
                    const parts = dateStr.split('-');
                    if (parts.length === 3) {
                        const year = parseInt(parts[0], 10);
                        const month = parseInt(parts[1], 10) - 1; // Month is 0-indexed
                        const day = parseInt(parts[2], 10);
                        date = new Date(year, month, day);
                    } else {
                        date = new Date(dateStr);
                    }
                } else {
                    date = new Date(dateStr);
                }

                if (isNaN(date.getTime())) {
                    console.warn(`⚠️ [LineChart] Invalid date at index ${index}:`, dateStr);
                    return null;
                }

                const parsed = {
                    date: date.getTime(),
                    value: item.value,
                };

                // Log một vài item đầu và cuối để debug
                if (index < 2 || index >= limitedData.length - 2) {
                    console.log(`📅 [LineChart] Parsed item ${index}:`, {
                        originalDate: dateStr,
                        timestamp: parsed.date,
                        value: parsed.value,
                        dateObj: date.toISOString(),
                    });
                }

                return parsed;
            })
            .filter((item) => item !== null);

        console.log('📊 [LineChart] Final chart data:', {
            originalLength: data.length,
            limitedLength: limitedData.length,
            finalLength: chartData.length,
            expected: 12,
            matches: chartData.length <= 12,
            firstFew: chartData.slice(0, 3),
            lastFew: chartData.slice(-3),
        });

        if (chartData.length > 12) {
            console.warn('⚠️ [LineChart] More than 12 data points, limiting to last 12');
        }

        series.data.setAll(chartData);

        // Set zoom để chỉ hiển thị 12 điểm cuối cùng
        if (chartData.length > 0) {
            const firstDate = chartData[0].date;
            const lastDate = chartData[chartData.length - 1].date;
            const initialRange = lastDate - firstDate;

            // Tính toán phạm vi tối đa cho phép (14 điểm = 12 + 1 mỗi bên)
            // Nếu có 12 điểm, mỗi điểm chiếm 1 khoảng, 14 điểm = 13 khoảng
            const maxRange = initialRange * (14 / 12);

            // Set zoom ban đầu
            xAxis.zoomToDates(new Date(firstDate), new Date(lastDate));

            // Lắng nghe sự kiện zoom để giới hạn
            xAxis.events.on('selectionextremeschanged', () => {
                const selection = xAxis.get('selection');
                if (selection && chartData.length > 0) {
                    const currentStart = selection.startDate.getTime();
                    const currentEnd = selection.endDate.getTime();
                    const currentRange = currentEnd - currentStart;

                    // Nếu zoom out quá mức cho phép (vượt quá 14 điểm)
                    if (currentRange > maxRange) {
                        // Tính center của selection hiện tại
                        const center = (currentStart + currentEnd) / 2;

                        // Giới hạn về phạm vi tối đa, giữ nguyên center
                        const newStart = new Date(center - maxRange / 2);
                        const newEnd = new Date(center + maxRange / 2);

                        // Đảm bảo không vượt quá phạm vi dữ liệu
                        const minDate = chartData[0].date;
                        const maxDate = chartData[chartData.length - 1].date;

                        let finalStart = newStart.getTime();
                        let finalEnd = newEnd.getTime();

                        // Nếu vượt quá biên trái, điều chỉnh
                        if (finalStart < minDate) {
                            finalStart = minDate;
                            finalEnd = finalStart + maxRange;
                        }

                        // Nếu vượt quá biên phải, điều chỉnh
                        if (finalEnd > maxDate) {
                            finalEnd = maxDate;
                            finalStart = finalEnd - maxRange;
                        }

                        // Áp dụng zoom giới hạn
                        xAxis.zoomToDates(new Date(finalStart), new Date(finalEnd));
                    }
                }
            });
        }

        // Log sau khi set data để verify
        console.log('✅ [LineChart] Data set to series, series dataItems count:', series.dataItems.length);

        // Thêm cursor với cấu hình tốt hơn
        const cursor = chart.set('cursor', am5xy.XYCursor.new(root, {
            behavior: 'none',
        }));
        cursor.lineY.set('visible', false);

        chartRef.current = root;

        return () => {
            root.dispose();
        };
    }, [data, granularity]);

    if (!data || !Array.isArray(data) || data.length === 0) {
        return <Empty description="No data" />;
    }

    return <div ref={chartDivRef} style={{ width: '100%', height: '320px' }} />;
};

const AdminStats = () => {
    const { t } = useTranslation();
    const { token } = useSelector((state) => state.auth);

    const [loading, setLoading] = useState(true);
    const [stats, setStats] = useState({
        areaCount: 0,
        userCount: 0,
        predictionPieData: [],
        areaDistributionData: [],
        emailSeriesRaw: []
    });

    const [timeGranularity, setTimeGranularity] = useState('day');
    const fetchingRef = useRef(false);

    const decoded = useMemo(() => {
        if (!token) return null;
        try {
            return jwtDecode(token);
        } catch (e) {
            return null;
        }
    }, [token]);

    useEffect(() => {
        if (!decoded) {
            setLoading(false);
            return;
        }
        if (fetchingRef.current) return;

        const fetchStats = async () => {
            fetchingRef.current = true;
            setLoading(true);

            try {
                const { role, province, district } = decoded;
                const commonParams = { role, ...(province && { province }), ...(district && { district }) };

                // Fetch các stats chính (không bao gồm email stats - sẽ fetch riêng)
                const [areasRes, usersRes, predictionsRes] = await Promise.all([
                    axios.get('/api/express/areas/stats/summary', { params: commonParams }),
                    axios.get('/api/express/auth/stats/summary', { params: { role, province } }),
                    axios.get('/api/express/predictions/stats/latest-ratio', { params: commonParams }),
                ]);

                // Tính tổng số areas từ byProvince
                const sumByProvince = (areasRes.data?.byProvince || []).reduce((sum, item) => sum + (item.count || 0), 0);
                console.log('📊 [AdminStats] Sum of areas by province:', sumByProvince);

                // Nếu có sự chênh lệch, thêm "Khác" cho các area không có province
                const areaDistribution = (areasRes.data?.byProvince || []).map((item, index) => ({
                    name: item.provinceName || t('stats.unknownProvince'),
                    value: item.count || 0,
                    fill: COLORS[index % COLORS.length],
                }));

                // Nếu tổng số areas khác với sum của byProvince, thêm phần "Khác"
                if (areasRes.data?.totalAreas && sumByProvince < areasRes.data.totalAreas) {
                    const missingCount = areasRes.data.totalAreas - sumByProvince;
                    console.log('⚠️ [AdminStats] Missing areas detected:', missingCount);
                    areaDistribution.push({
                        name: t('stats.unknownProvince') || 'Khác',
                        value: missingCount,
                        fill: COLORS[areaDistribution.length % COLORS.length],
                    });
                }

                console.log('📊 [AdminStats] Final area distribution:', areaDistribution);

                const { good = 0, average = 0, poor = 0 } = predictionsRes.data || {};
                const pieData = [
                    { name: t('detail.good'), value: good },
                    { name: t('detail.average'), value: average },
                    { name: t('detail.poor'), value: poor },
                ].filter((d) => d.value > 0);

                setStats(prev => ({
                    areaCount: areasRes.data?.totalAreas || 0,
                    userCount: usersRes.data?.totalUsers || 0,
                    areaDistributionData: areaDistribution,
                    predictionPieData: pieData,
                    emailSeriesRaw: prev.emailSeriesRaw || [] // Giữ nguyên dữ liệu email đã fetch, không reset
                }));

            } catch (error) {
                console.error('Error fetching stats:', error);
                message.error(t('stats.loadError'));
            } finally {
                setLoading(false);
                fetchingRef.current = false;
            }
        };

        fetchStats();
    }, [decoded, t]);

    // Fetch email stats riêng (vì cần granularity và limit)
    // Sử dụng ref riêng để tránh conflict với fetchingRef chính
    const emailFetchingRef = useRef(false);
    const emailLastFetchRef = useRef({ granularity: null, timestamp: 0 });

    useEffect(() => {
        if (!decoded) {
            // Reset ref khi decoded chưa có để đảm bảo fetch lại khi decoded có
            emailFetchingRef.current = false;
            emailLastFetchRef.current = { granularity: null, timestamp: 0 };
            return;
        }

        // Ở lần đầu tiên (granularity chưa được fetch), luôn fetch
        const lastFetch = emailLastFetchRef.current;
        const isFirstLoad = lastFetch.granularity === null;

        // Kiểm tra xem đã fetch với granularity này chưa (trong vòng 1 giây)
        // Chỉ check nếu không phải lần đầu tiên
        if (!isFirstLoad) {
            const now = Date.now();
            if (
                lastFetch.granularity === timeGranularity &&
                now - lastFetch.timestamp < 1000 &&
                emailFetchingRef.current
            ) {
                return; // Đã fetch gần đây với cùng granularity, bỏ qua
            }
        }

        // Reset fetching ref khi granularity thay đổi (không phải lần đầu)
        if (!isFirstLoad && emailFetchingRef.current && lastFetch.granularity !== timeGranularity) {
            emailFetchingRef.current = false;
        }

        if (emailFetchingRef.current && !isFirstLoad) {
            return; // Đang fetch, bỏ qua (trừ lần đầu tiên)
        }

        const fetchEmailStats = async () => {
            emailFetchingRef.current = true;
            emailLastFetchRef.current = { granularity: timeGranularity, timestamp: Date.now() };

            try {
                const { role, province, district } = decoded;
                const emailParams = {
                    is_active: true,
                    granularity: timeGranularity,
                    limit: 12,
                    role,
                    ...(province && { province }),
                    ...(district && { district }),
                };

                const emailsRes = await axios.get('/api/express/emails/stats/subscriptions', { params: emailParams });

                if (emailsRes.data?.series && Array.isArray(emailsRes.data.series)) {
                    setStats(prev => ({
                        ...prev,
                        emailSeriesRaw: emailsRes.data.series
                    }));
                } else {
                    setStats(prev => ({
                        ...prev,
                        emailSeriesRaw: []
                    }));
                }
            } catch (error) {
                console.error('❌ [AdminStats] Error fetching email stats:', error);
                setStats(prev => ({
                    ...prev,
                    emailSeriesRaw: []
                }));
            } finally {
                emailFetchingRef.current = false;
            }
        };

        fetchEmailStats();
    }, [timeGranularity, decoded]);

    // Tính toán emailSeries trực tiếp từ state, không dùng useMemo
    // Chỉ tính toán khi có dữ liệu thực sự
    const getEmailSeries = () => {
        if (!stats.emailSeriesRaw || !Array.isArray(stats.emailSeriesRaw) || stats.emailSeriesRaw.length === 0) {
            return [];
        }

        // Backend đã xử lý và giới hạn dữ liệu, chỉ cần map lại
        return stats.emailSeriesRaw
            .filter(item => item && item.date && item.value !== undefined)
            .map(item => ({
                date: item.date,
                value: item.value,
            }));
    };

    const emailSeries = getEmailSeries();

    if (!decoded) return <Result status="403" title="Access Denied" />;

    return (
        <div style={{ width: '100%' }}>
            <Card style={{ width: '100%', borderRadius: 12 }} styles={{ body: { padding: 24 } }}>
                <Space direction="vertical" style={{ width: '100%' }} size="large">
                    <Title level={3}>{t('stats.title')}</Title>

                    <Spin spinning={loading} tip={t('common.loading')}>
                        <Space direction="vertical" style={{ width: '100%' }} size="large">
                            <Row gutter={[16, 16]}>
                                <Col xs={24} sm={12} lg={8}>
                                    <Card variant='borderless'>
                                        <Statistic
                                            title={t('stats.totalAreas')}
                                            value={stats.areaCount}
                                            prefix={<EnvironmentOutlined />}
                                        />
                                    </Card>
                                </Col>
                                <Col xs={24} sm={12} lg={8}>
                                    <Card variant='borderless'>
                                        <Statistic
                                            title={t('stats.totalUsers')}
                                            value={stats.userCount}
                                            prefix={<UserOutlined />}
                                        />
                                    </Card>
                                </Col>
                            </Row>

                            <Row gutter={[16, 16]}>
                                <Col xs={24} md={12}>
                                    <Card
                                        title={
                                            <>
                                                <PieChartOutlined /> {t('stats.latestPredictionPie')}
                                            </>
                                        }
                                        styles={{ body: { padding: 0 } }}
                                    >
                                        <PieChartComponent
                                            data={stats.predictionPieData}
                                            colors={COLORS}
                                        />
                                    </Card>
                                </Col>

                                <Col xs={24} md={12}>
                                    <Card
                                        title={
                                            <>
                                                <EnvironmentOutlined /> {t('stats.areaDistribution')}
                                            </>
                                        }
                                        styles={{ body: { padding: 0 } }}
                                    >
                                        <TreemapComponent data={stats.areaDistributionData} />
                                    </Card>
                                </Col>
                            </Row>

                            <Card
                                title={t('stats.emailCumulative')}
                                extra={
                                    <Segmented
                                        size="small"
                                        value={timeGranularity}
                                        onChange={(val) => setTimeGranularity(val)}
                                        options={[
                                            { label: t('stats.byDay'), value: 'day' },
                                            { label: t('stats.byMonth'), value: 'month' },
                                        ]}
                                    />
                                }
                                styles={{ body: { padding: 0 } }}
                            >
                                <LineChartComponent data={emailSeries} granularity={timeGranularity} />
                            </Card>
                        </Space>
                    </Spin>
                </Space>
            </Card>
        </div>
    );
};

export default AdminStats;

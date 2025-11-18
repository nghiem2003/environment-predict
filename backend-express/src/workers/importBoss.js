module.exports = (boss) => {
    const fs = require('fs');
    const path = require('path');
    const xlsx = require('xlsx');
    const predictionController = require('../controllers/predictionController');
    const logger = require('../config/logger');
    const { Area, Province } = require('../models');
    const proj4 = require('proj4');

    // Logger helper with job context
    const jobLogger = {
        info: (msg, ...args) => logger.info(`[JOB] ${msg}`, ...args),
        error: (msg, ...args) => logger.error(`[JOB] ${msg}`, ...args),
        warn: (msg, ...args) => logger.warn(`[JOB] ${msg}`, ...args),
        progress: (jobId, stage, details) => logger.info(`[JOB] PROGRESS [${jobId}] ${stage}`, details),
    };

    // Global error handlers for pg-boss
    boss.on('error', (error) => {
        jobLogger.error('PgBoss error event', { error: error.message, stack: error.stack });
    });

    boss.on('failed', ({ id, name, data, failedReason }) => {
        jobLogger.error(`Job Failed [${id}]`, {
            jobName: name,
            failedReason: failedReason,
            data: data
        });
    });

    // helper to call controller handler
    const callController = (handler, reqInit) => new Promise((resolve, reject) => {
        const req = { ...reqInit };
        const res = {
            status(code) { this.statusCode = code; return this; },
            json(data) {
                const status = this.statusCode || 200;
                // If status is error (>= 400), reject the promise to mark job as failed
                if (status >= 400) {
                    const error = new Error(data?.error || `Controller returned status ${status}`);
                    error.statusCode = status;
                    error.data = data;
                    reject(error);
                } else {
                    resolve({ status, data });
                }
            },
        };
        Promise.resolve(handler(req, res)).catch(reject);
    });

    const getVN2000Proj4 = (lon0) => `+proj=tmerc +lat_0=0 +lon_0=${lon0} +k=0.9999 +x_0=500000 +y_0=0 +ellps=WGS84 +towgs84=-191.904,-39.303,-111.450,0,0,0,0 +units=m +no_defs`;
    const isWithinVietnam = (lat, lon) => Number.isFinite(lat) && Number.isFinite(lon) && lat >= 8 && lat <= 24 && lon >= 102 && lon <= 110;

    const convertVN2000ToWGS84 = (x, y, centralMeridian = null) => {
        // Validate input
        if (!Number.isFinite(x) || !Number.isFinite(y)) {
            jobLogger.warn('Invalid VN2000 coordinates', { x, y });
            return null;
        }

        // Thử cả [x, y] và [y, x] vì có thể thứ tự bị ngược
        const tryConvert = (coords, order) => {
            const zones = centralMeridian ? [centralMeridian] : [105, 107, 109];
            for (const zone of zones) {
                try {
                    const [lon, lat] = proj4(getVN2000Proj4(zone), 'EPSG:4326', coords);
                    if (Number.isFinite(lat) && Number.isFinite(lon) && isWithinVietnam(lat, lon)) {
                        jobLogger.info(`Conversion successful with order ${order}`, { x, y, lat, lon, zone, order });
                        return { lat, lon, zone };
                    } else {
                        jobLogger.warn(`Zone ${zone} conversion out of bounds (order ${order})`, { x, y, lat, lon, zone, order });
                    }
                } catch (error) {
                    jobLogger.warn(`Zone ${zone} conversion error (order ${order})`, { x, y, zone, order, error: error.message });
                }
            }
            // Nếu có central_meridian nhưng không thành công, thử các zone khác
            if (centralMeridian) {
                const fallbackZones = [105, 107, 109].filter(z => z !== centralMeridian);
                for (const zone of fallbackZones) {
                    try {
                        const [lon, lat] = proj4(getVN2000Proj4(zone), 'EPSG:4326', coords);
                        if (Number.isFinite(lat) && Number.isFinite(lon) && isWithinVietnam(lat, lon)) {
                            jobLogger.info(`Conversion successful with fallback zone (order ${order})`, { x, y, lat, lon, zone, order });
                            return { lat, lon, zone };
                        }
                    } catch (error) {
                        // ignore
                    }
                }
            }
            return null;
        };

        // Thử [x, y] trước (thứ tự chuẩn)
        let result = tryConvert([x, y], '[x, y]');
        if (result) return result;

        // Nếu không thành công, thử [y, x] (đảo ngược)
        jobLogger.warn('Trying reversed order [y, x]', { x, y, centralMeridian });
        result = tryConvert([y, x], '[y, x]');
        if (result) return result;

        jobLogger.warn('All conversion attempts failed for both orders', { x, y, centralMeridian });
        return null;
    };

    const parseNumber = (value) => {
        if (value == null) return null;
        const raw = String(value).trim().replace(',', '.');
        if (!raw) return null;
        const num = Number(raw);
        return Number.isFinite(num) ? num : null;
    };

    // CSV import: parse CSV to JSON rows and call batch API
    boss.work('csv-import', async (job) => {
        const jobId = job.id;
        const { path: filePath, userId, areaId, modelName, originalname } = job.data || {};

        try {
            jobLogger.info(`CSV Import Job Started [${jobId}]`, { file: originalname || filePath, userId, areaId, modelName });

            if (!filePath || !fs.existsSync(filePath)) {
                const error = new Error('file_not_found');
                jobLogger.error(`CSV Import Job Failed [${jobId}]: File not found`, { filePath });
                throw error;
            }

            jobLogger.progress(jobId, 'Reading file', { filePath });
            const content = fs.readFileSync(filePath, 'utf8');
            const lines = content.split(/\r?\n/).filter(l => l.trim().length > 0);

            if (lines.length < 2) {
                jobLogger.error(`CSV Import Job Failed [${jobId}]: Empty CSV or insufficient rows`, { lines: lines.length });
                throw new Error('empty_csv');
            }

            jobLogger.progress(jobId, 'Parsing CSV', { totalRows: lines.length - 1 });
            const headers = lines[0].split(',').map(h => h.trim());
            const data = lines.slice(1).map((line, idx) => {
                const cells = line.split(',');
                const obj = {};
                headers.forEach((h, i) => { if (cells[i] != null && cells[i] !== '') obj[h] = isNaN(cells[i]) ? cells[i] : Number(cells[i]); });
                if ((idx + 1) % 100 === 0) {
                    jobLogger.progress(jobId, 'Parsing rows', { processed: idx + 1, total: lines.length - 1 });
                }
                return obj;
            });

            jobLogger.progress(jobId, 'Creating predictions', { records: data.length, userId, areaId, modelName });
            const reqInit = { body: { userId, areaId, modelName, data } };
            const result = await callController(predictionController.createBatchPrediction, reqInit);

            jobLogger.info(`CSV Import Job Completed [${jobId}]`, {
                recordsProcessed: data.length,
                result: result.data
            });

            return result.data;
        } catch (error) {
            // Log error with detailed information
            const errorDetails = {
                error: error.message,
                stack: error.stack,
                file: originalname || filePath,
                jobId: jobId,
                statusCode: error.statusCode || 'unknown',
                errorData: error.data || null
            };

            if (error.statusCode >= 400) {
                jobLogger.error(`CSV Import Job Failed [${jobId}]: Controller returned error status ${error.statusCode}`, errorDetails);
            } else {
                jobLogger.error(`CSV Import Job Failed [${jobId}]`, errorDetails);
            }

            // Re-throw to ensure pg-boss marks job as failed
            throw error;
        } finally {
            // Cleanup: delete temp file if exists (always runs, even on error)
            if (filePath && fs.existsSync(filePath)) {
                try {
                    fs.unlinkSync(filePath);
                    jobLogger.progress(jobId, 'Cleanup', { deletedFile: filePath, action: 'File deleted after error or completion' });
                } catch (e) {
                    jobLogger.warn(`CSV Import Job [${jobId}]: Failed to delete temp file`, { error: e.message, filePath });
                }
            }
        }
    });

    // XLSX import: read buffer and call existing excel controller
    boss.work('xlsx-import', async (job) => {
        const jobId = job.id;
        const { path: filePath, originalname, userId, areaId, modelName, template } = job.data || {};
        const templateType = template === 'excel2' ? 'Mẫu 2' : 'Mẫu 1';

        try {

            jobLogger.info(`XLSX Import Job Started [${jobId}]`, {
                file: originalname || filePath,
                userId,
                areaId,
                modelName,
                template: templateType
            });

            if (!filePath || !fs.existsSync(filePath)) {
                const error = new Error('file_not_found');
                jobLogger.error(`XLSX Import Job Failed [${jobId}]: File not found`, { filePath });
                throw error;
            }

            jobLogger.progress(jobId, 'Reading file', { filePath, size: fs.statSync(filePath).size });
            const buffer = fs.readFileSync(filePath);

            jobLogger.progress(jobId, 'Preparing request', { template: templateType, userId, areaId, modelName });
            const reqInit = { body: { userId, areaId, modelName }, file: { buffer, originalname } };
            const handler = template === 'excel2'
                ? predictionController.createBatchPredictionFromExcel2
                : predictionController.createBatchPredictionFromExcel;

            jobLogger.progress(jobId, 'Processing Excel', { handler: template === 'excel2' ? 'createBatchPredictionFromExcel2' : 'createBatchPredictionFromExcel' });
            const result = await callController(handler, reqInit);

            jobLogger.info(`XLSX Import Job Completed [${jobId}]`, {
                template: templateType,
                result: result.data
            });

            return result.data;
        } catch (error) {
            // Log error with detailed information
            const errorDetails = {
                error: error.message,
                stack: error.stack,
                file: originalname || filePath,
                template: templateType,
                jobId: jobId,
                statusCode: error.statusCode || 'unknown',
                errorData: error.data || null
            };

            if (error.statusCode >= 400) {
                jobLogger.error(`XLSX Import Job Failed [${jobId}]: Controller returned error status ${error.statusCode}`, errorDetails);
            } else {
                jobLogger.error(`XLSX Import Job Failed [${jobId}]`, errorDetails);
            }

            // Re-throw to ensure pg-boss marks job as failed
            throw error;
        } finally {
            // Cleanup: delete temp file if exists (always runs, even on error)
            if (filePath && fs.existsSync(filePath)) {
                try {
                    fs.unlinkSync(filePath);
                    jobLogger.progress(jobId, 'Cleanup', { deletedFile: filePath, action: 'File deleted after error or completion' });
                } catch (e) {
                    jobLogger.warn(`XLSX Import Job [${jobId}]: Failed to delete temp file`, { error: e.message, filePath });
                }
            }
        }
    });

    boss.work('area-xlsx-import', async (job) => {
        const jobId = job.id;
        const { path: filePath, originalname, provinceId, districtId, area: defaultArea, area_type: defaultAreaType, userId } = job.data || {};

        jobLogger.info(`Area XLSX Import Job Started [${jobId}]`, {
            file: originalname || filePath,
            provinceId,
            districtId,
            userId,
        });

        if (!filePath || !fs.existsSync(filePath)) {
            const error = new Error('file_not_found');
            jobLogger.error(`Area XLSX Import Job Failed [${jobId}]: File not found`, { filePath });
            throw error;
        }

        // Lấy central_meridian từ province
        let centralMeridian = null;
        if (provinceId) {
            try {
                const province = await Province.findOne({ where: { id: provinceId } });
                if (province && province.central_meridian) {
                    centralMeridian = province.central_meridian;
                    jobLogger.info(`Using central_meridian ${centralMeridian} for province ${province.name || provinceId}`);
                } else {
                    jobLogger.info(`No central_meridian found for province ${province?.name || provinceId}, will auto-detect`);
                }
            } catch (error) {
                jobLogger.warn(`Failed to get province central_meridian`, { provinceId, error: error.message });
            }
        }

        const summary = {
            totalRows: 0,
            created: 0,
            skipped: 0,
            duplicates: 0,
            notConverted: 0,
            skippedRows: [],
        };

        const transaction = await Area.sequelize.transaction();

        try {
            jobLogger.progress(jobId, 'Reading file', { filePath, size: fs.statSync(filePath).size });
            const buffer = fs.readFileSync(filePath);
            const workbook = xlsx.read(buffer, { type: 'buffer' });

            if (!workbook.SheetNames || workbook.SheetNames.length === 0) {
                throw new Error('empty_workbook');
            }

            for (const sheetName of workbook.SheetNames) {
                const worksheet = workbook.Sheets[sheetName];
                if (!worksheet) continue;

                const rows = xlsx.utils.sheet_to_json(worksheet, { header: 1, defval: null, blankrows: false });
                if (rows.length <= 1) continue; // header only

                for (let rowIndex = 1; rowIndex < rows.length; rowIndex++) {
                    summary.totalRows += 1;
                    const row = rows[rowIndex];
                    const excelRowNumber = rowIndex + 1;

                    const xValue = parseNumber(row?.[2]); // Column C (X)
                    const yValue = parseNumber(row?.[3]); // Column D (Y)
                    const nameValue = row?.[4] ? String(row[4]).trim() : '';

                    if (!nameValue) {
                        summary.skipped += 1;
                        summary.skippedRows.push({ row: excelRowNumber, reason: 'missing_name' });
                        continue;
                    }

                    if (xValue == null || yValue == null) {
                        summary.skipped += 1;
                        summary.skippedRows.push({ row: excelRowNumber, reason: 'missing_coordinates', name: nameValue });
                        continue;
                    }

                    // Sử dụng central_meridian từ province nếu có
                    jobLogger.info(`Converting VN2000 for row ${excelRowNumber}`, {
                        name: nameValue,
                        x: xValue,
                        y: yValue,
                        centralMeridian: centralMeridian || 'auto'
                    });
                    const coords = convertVN2000ToWGS84(xValue, yValue, centralMeridian);
                    if (!coords) {
                        jobLogger.warn(`Conversion failed for row ${excelRowNumber}`, {
                            name: nameValue,
                            x: xValue,
                            y: yValue,
                            centralMeridian: centralMeridian || 'auto'
                        });
                        summary.notConverted += 1;
                        summary.skippedRows.push({ row: excelRowNumber, reason: 'conversion_failed', name: nameValue, x: xValue, y: yValue });
                        continue;
                    }
                    jobLogger.info(`Conversion successful for row ${excelRowNumber}`, {
                        name: nameValue,
                        lat: coords.lat,
                        lon: coords.lon,
                        zone: coords.zone
                    });

                    const existingArea = await Area.findOne({
                        where: {
                            name: nameValue,
                            district: districtId,
                        },
                        transaction,
                    });

                    if (existingArea) {
                        summary.duplicates += 1;
                        summary.skippedRows.push({ row: excelRowNumber, reason: 'duplicate_name', name: nameValue });
                        continue;
                    }

                    // Sử dụng area và area_type từ form (không đọc từ Excel)
                    await Area.create({
                        name: nameValue,
                        latitude: coords.lat,
                        longitude: coords.lon,
                        province: provinceId,
                        district: districtId,
                        area: defaultArea || 0,
                        area_type: defaultAreaType || 'oyster',
                    }, { transaction });

                    summary.created += 1;

                    if (summary.created % 50 === 0) {
                        jobLogger.progress(jobId, 'Imported rows', { created: summary.created, processed: summary.totalRows });
                    }
                }
            }

            await transaction.commit();

            jobLogger.info(`Area XLSX Import Job Completed [${jobId}]`, summary);
            return summary;
        } catch (error) {
            await transaction.rollback();

            jobLogger.error(`Area XLSX Import Job Failed [${jobId}]`, {
                error: error.message,
                stack: error.stack,
                summary,
            });

            throw error;
        } finally {
            if (filePath && fs.existsSync(filePath)) {
                try {
                    fs.unlinkSync(filePath);
                    jobLogger.progress(jobId, 'Cleanup', { deletedFile: filePath });
                } catch (cleanupError) {
                    jobLogger.warn(`Area XLSX Import Job [${jobId}]: Failed to delete temp file`, { error: cleanupError.message, filePath });
                }
            }
        }
    });

    jobLogger.info('Job workers registered', { jobs: ['csv-import', 'xlsx-import', 'area-xlsx-import'] });
};



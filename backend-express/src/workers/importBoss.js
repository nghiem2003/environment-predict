module.exports = (boss) => {
    const fs = require('fs');
    const path = require('path');
    const xlsx = require('xlsx');
    const predictionController = require('../controllers/predictionController');
    const logger = require('../config/logger');

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

    jobLogger.info('Job workers registered', { jobs: ['csv-import', 'xlsx-import'] });
};



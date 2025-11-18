const express = require('express');
const router = express.Router();
const { authenticate, authorize } = require('../middlewares/authMiddleware');
const sequelize = require('../config/db');
const { User } = require('../models');
const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });
const logger = require('../config/logger');

// Enqueue CSV import job
router.post('/import/csv', upload.single('file'), async (req, res) => {
    try {
        const boss = req.app.get('boss');
        if (!boss) {
            logger.error('[API] Boss not available');
            return res.status(500).json({ error: 'job_queue_not_ready' });
        }
        if (!req.file) return res.status(400).json({ error: 'CSV file is required (field: file)' });
        const { userId, areaId, modelName } = req.body || {};
        if (!userId || !areaId || !modelName) return res.status(400).json({ error: 'userId, areaId, modelName are required' });

        const fs = require('fs');
        const path = require('path');
        const uploadsDir = path.join(process.cwd(), 'uploads');
        if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir, { recursive: true });
        const fileName = `${Date.now()}-${req.file.originalname}`;
        const filePath = path.join(uploadsDir, fileName);
        fs.writeFileSync(filePath, req.file.buffer);

        const jobId = await boss.send('csv-import', { path: filePath, originalname: req.file.originalname, userId, areaId, modelName }, { retryLimit: 0 });
        if (!jobId) {
            logger.error('[API] Failed to get jobId from boss.send()', { returned: jobId });
            return res.status(500).json({ error: 'failed_to_get_job_id' });
        }
        logger.info('[API] CSV import job enqueued', { jobId, file: req.file.originalname });
        return res.json({ jobId });
    } catch (e) {
        logger.error('[API] Failed to enqueue CSV import job', { error: e.message, stack: e.stack });
        return res.status(500).json({ error: 'failed_to_queue' });
    }
});

// Enqueue XLSX import job
router.post('/import/xlsx', upload.single('file'), async (req, res) => {
    try {
        const boss = req.app.get('boss');
        if (!boss) {
            logger.error('[API] Boss not available');
            return res.status(500).json({ error: 'job_queue_not_ready' });
        }
        if (!req.file) return res.status(400).json({ error: 'XLSX file is required (field: file)' });
        const { userId, areaId, modelName } = req.body || {};
        if (!userId || !areaId || !modelName) return res.status(400).json({ error: 'userId, areaId, modelName are required' });

        const fs = require('fs');
        const path = require('path');
        const uploadsDir = path.join(process.cwd(), 'uploads');
        if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir, { recursive: true });
        const fileName = `${Date.now()}-${req.file.originalname}`;
        const filePath = path.join(uploadsDir, fileName);
        fs.writeFileSync(filePath, req.file.buffer);

        const jobId = await boss.send('xlsx-import', { path: filePath, originalname: req.file.originalname, userId, areaId, modelName }, { retryLimit: 0 });
        if (!jobId) {
            logger.error('[API] Failed to get jobId from boss.send()', { returned: jobId });
            return res.status(500).json({ error: 'failed_to_get_job_id' });
        }
        logger.info('[API] XLSX import job enqueued', { jobId, file: req.file.originalname });
        return res.json({ jobId });
    } catch (e) {
        logger.error('[API] Failed to enqueue XLSX import job', { error: e.message, stack: e.stack });
        return res.status(500).json({ error: 'failed_to_queue' });
    }
});

router.get('/', authenticate, authorize(['admin', 'expert']), async (req, res) => {
    try {
        const { name, state, limit = 50, offset = 0 } = req.query;
        const isAdmin = req.user?.role === 'admin';
        const params = { limit: Number(limit), offset: Number(offset) };
        const where = [];
        if (name) {
            where.push(`name = :name`);
            params.name = name;
        }
        if (state) { where.push(`state = :state`); params.state = state; }
        if (!isAdmin) { where.push(`data->>'userId' = :userId`); params.userId = String(req.user?.id || ''); }
        // Exclude PgBoss internal/system jobs (maintenance, archive, etc.)
        where.push(`name NOT LIKE 'pgboss-%'`);
        where.push(`name NOT LIKE '__pgboss%'`);
        const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';
        const sql = `SELECT id, name, state, data, createdon, startedon, completedon, priority
                 FROM pgboss.job
                 ${whereSql}
                 ORDER BY createdon DESC
                 LIMIT :limit OFFSET :offset`;
        const countSql = `SELECT COUNT(*) as count
                          FROM pgboss.job
                          ${whereSql}`;
        const rows = await sequelize.query(sql, { replacements: params, type: sequelize.QueryTypes.SELECT });
        const countResult = await sequelize.query(countSql, { replacements: params, type: sequelize.QueryTypes.SELECT });
        const total = countResult[0]?.count || 0;
        // enrich with creator info
        const userIds = Array.from(new Set((rows || []).map(r => {
            try { return r.data && r.data.userId ? Number(r.data.userId) : null; } catch (_) { return null; }
        }).filter(Boolean)));
        let users = [];
        if (userIds.length) {
            users = await User.findAll({ where: { id: userIds }, attributes: ['id', 'username', 'email'] });
        }
        const idToUser = new Map(users.map(u => [Number(u.id), { id: u.id, username: u.username, email: u.email }]));
        const jobs = rows.map(r => ({ ...r, creator: idToUser.get(Number(r.data?.userId)) || null }));
        res.json({ jobs, total: Number(total) });
    } catch (e) {
        logger.error('[API] Failed to list jobs', { error: e.message, stack: e.stack });
        res.status(500).json({ error: 'failed_to_list_jobs' });
    }
});

module.exports = router;





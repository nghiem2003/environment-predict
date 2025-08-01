const { Email, Area } = require('../models');
const nodemailer = require('nodemailer');
const crypto = require('crypto');

// Email transporter configuration
const transporter = nodemailer.createTransport({
  service: 'gmail', // or your email service
  auth: {
    user: process.env.EMAIL_USER || 'your-email@gmail.com',
    pass: process.env.EMAIL_PASS || 'your-app-password',
  },
});

// Get all email subscriptions
exports.getAllEmailSubscriptions = async (req, res) => {
  try {
    const { limit, offset, area_id, email } = req.query;

    let query = {};

    if (area_id) {
      query.area_id = area_id;
    }

    if (email) {
      query.email = { [require('sequelize').Op.like]: `%${email}%` };
    }

    const options = {
      where: query,
      include: [
        {
          model: Area,
          as: 'area',
          attributes: ['id', 'name', 'area_type'],
        },
      ],
      order: [['created_at', 'DESC']],
    };

    if (limit) {
      options.limit = parseInt(limit, 10);
    }
    if (offset) {
      options.offset = parseInt(offset, 10);
    }

    const subscriptions = await Email.findAll(options);
    const total = await Email.count({ where: query });

    res.status(200).json({ subscriptions, total });
  } catch (error) {
    console.error('Get All Email Subscriptions Error:', error);
    res.status(500).json({ error: error.message });
  }
};

// Get email subscription by ID
exports.getEmailSubscriptionById = async (req, res) => {
  try {
    const { id } = req.params;

    const subscription = await Email.findOne({
      where: { id },
      include: [
        {
          model: Area,
          as: 'area',
          attributes: ['id', 'name', 'area_type'],
        },
      ],
    });

    if (!subscription) {
      return res.status(404).json({ error: 'Email subscription not found' });
    }

    res.status(200).json(subscription);
  } catch (error) {
    console.error('Get Email Subscription Error:', error);
    res.status(500).json({ error: error.message });
  }
};

// Subscribe to prediction notifications for an area
exports.subscribeToPredictions = async (req, res) => {
  try {
    const { email, area_id } = req.body;

    // Validate required fields
    if (!email || !area_id) {
      return res.status(400).json({
        error: 'Email and area_id are required',
      });
    }

    // Check if area exists
    const area = await Area.findByPk(area_id);
    if (!area) {
      return res.status(404).json({ error: 'Area not found' });
    }

    // Check if subscription already exists
    const existingSubscription = await Email.findOne({
      where: { email, area_id },
    });

    if (existingSubscription) {
      if (existingSubscription.is_active) {
        return res.status(400).json({
          error: 'You are already subscribed to predictions for this area',
        });
      } else {
        // Reactivate existing subscription
        existingSubscription.is_active = true;
        await existingSubscription.save();

        const subscriptionWithArea = await Email.findOne({
          where: { id: existingSubscription.id },
          include: [
            {
              model: Area,
              as: 'area',
              attributes: ['id', 'name', 'area_type'],
            },
          ],
        });

        return res.status(200).json({
          message: 'Subscription reactivated successfully',
          subscription: subscriptionWithArea,
        });
      }
    }

    // Generate unsubscribe token
    const unsubscribeToken = crypto.randomBytes(32).toString('hex');

    const subscription = await Email.create({
      email,
      area_id,
      is_active: true,
      unsubscribe_token: unsubscribeToken,
    });

    const subscriptionWithArea = await Email.findOne({
      where: { id: subscription.id },
      include: [
        {
          model: Area,
          as: 'area',
          attributes: ['id', 'name', 'area_type'],
        },
      ],
    });

    res.status(201).json({
      message: 'Successfully subscribed to prediction notifications',
      subscription: subscriptionWithArea,
    });
  } catch (error) {
    console.error('Subscribe to Predictions Error:', error);
    res.status(500).json({ error: error.message });
  }
};

// Update email subscription
exports.updateEmailSubscription = async (req, res) => {
  try {
    const { id } = req.params;
    const { email, area_id, is_active } = req.body;

    const subscription = await Email.findByPk(id);
    if (!subscription) {
      return res.status(404).json({ error: 'Email subscription not found' });
    }

    // Check if area exists if area_id is being updated
    if (area_id) {
      const area = await Area.findByPk(area_id);
      if (!area) {
        return res.status(404).json({ error: 'Area not found' });
      }
    }

    // Check for duplicate if email or area_id is being updated
    if (email || area_id) {
      const existingSubscription = await Email.findOne({
        where: {
          email: email || subscription.email,
          area_id: area_id || subscription.area_id,
          id: { [require('sequelize').Op.ne]: id },
        },
      });

      if (existingSubscription) {
        return res.status(400).json({
          error: 'Email subscription for this area already exists',
        });
      }
    }

    // Update fields
    if (email) subscription.email = email;
    if (area_id) subscription.area_id = area_id;
    if (typeof is_active === 'boolean') subscription.is_active = is_active;

    await subscription.save();

    const updatedSubscription = await Email.findOne({
      where: { id },
      include: [
        {
          model: Area,
          as: 'area',
          attributes: ['id', 'name', 'area_type'],
        },
      ],
    });

    res.status(200).json(updatedSubscription);
  } catch (error) {
    console.error('Update Email Subscription Error:', error);
    res.status(500).json({ error: error.message });
  }
};

// Delete email subscription
exports.deleteEmailSubscription = async (req, res) => {
  try {
    const { id } = req.params;

    const subscription = await Email.findByPk(id);
    if (!subscription) {
      return res.status(404).json({ error: 'Email subscription not found' });
    }

    await subscription.destroy();
    res
      .status(200)
      .json({ message: 'Email subscription deleted successfully' });
  } catch (error) {
    console.error('Delete Email Subscription Error:', error);
    res.status(500).json({ error: error.message });
  }
};

// Send prediction notification email
exports.sendPredictionNotification = async (areaId, predictionData) => {
  try {
    // Get all active email subscriptions for this area
    const subscriptions = await Email.findAll({
      where: {
        area_id: areaId,
        is_active: true,
      },
      include: [
        {
          model: Area,
          as: 'area',
          attributes: ['id', 'name', 'area_type'],
        },
      ],
    });

    if (subscriptions.length === 0) {
      console.log('No active email subscriptions found for area:', areaId);
      return;
    }

    const area = subscriptions[0].area;
    const baseUrl = process.env.FRONTEND_URL || 'http://localhost:3000';

    // Email content
    const subject = `Dự đoán mới cho khu vực: ${area.name}`;
    const htmlContent = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #2c3e50;">Thông báo dự đoán mới</h2>
        <p>Xin chào,</p>
        <p>Có dự đoán mới cho khu vực <strong>${area.name}</strong> (${
      area.area_type
    }).</p>
        <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
          <h3 style="margin-top: 0;">Thông tin dự đoán:</h3>
          <p><strong>Khu vực:</strong> ${area.name}</p>
          <p><strong>Loại khu vực:</strong> ${area.area_type}</p>
          <p><strong>Kết quả dự đoán:</strong> ${
            predictionData.result || 'Đang xử lý'
          }</p>
          <p><strong>Thời gian:</strong> ${new Date().toLocaleString(
            'vi-VN'
          )}</p>
        </div>
        <div style="text-align: center; margin: 30px 0;">
          <a href="${baseUrl}/prediction/${areaId}" 
             style="background-color: #3498db; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block;">
            Xem chi tiết dự đoán
          </a>
        </div>
        <hr style="margin: 30px 0; border: none; border-top: 1px solid #eee;">
        <p style="font-size: 12px; color: #666;">
          Bạn nhận được email này vì đã đăng ký nhận thông báo dự đoán cho khu vực ${
            area.name
          }.<br>
          <a href="${baseUrl}/unsubscribe?token=${
      subscription.unsubscribe_token
    }" 
             style="color: #e74c3c;">Hủy đăng ký nhận thông báo</a>
        </p>
        <p>Trân trọng,<br>Hệ thống Dự đoán Nuôi trồng Thủy sản</p>
      </div>
    `;

    // Send emails to all subscribers
    const emailPromises = subscriptions.map((subscription) => {
      const mailOptions = {
        from: process.env.EMAIL_USER || 'your-email@gmail.com',
        to: subscription.email,
        subject: subject,
        html: htmlContent.replace(
          '${subscription.unsubscribe_token}',
          subscription.unsubscribe_token
        ),
      };

      return transporter.sendMail(mailOptions);
    });

    await Promise.all(emailPromises);
    console.log(
      `Sent ${subscriptions.length} prediction notification emails for area ${areaId}`
    );
  } catch (error) {
    console.error('Send Prediction Notification Error:', error);
    throw error;
  }
};

// Unsubscribe from prediction notifications
exports.unsubscribeFromPredictions = async (req, res) => {
  try {
    const { token } = req.params;

    if (!token) {
      return res.status(400).json({ error: 'Unsubscribe token is required' });
    }

    const subscription = await Email.findOne({
      where: { unsubscribe_token: token },
      include: [
        {
          model: Area,
          as: 'area',
          attributes: ['id', 'name', 'area_type'],
        },
      ],
    });

    if (!subscription) {
      return res.status(404).json({ error: 'Invalid unsubscribe token' });
    }

    if (!subscription.is_active) {
      return res.status(400).json({
        message:
          'You are already unsubscribed from prediction notifications for this area',
        area: subscription.area,
      });
    }

    subscription.is_active = false;
    await subscription.save();

    res.status(200).json({
      message: 'Successfully unsubscribed from prediction notifications',
      area: subscription.area,
    });
  } catch (error) {
    console.error('Unsubscribe Error:', error);
    res.status(500).json({ error: error.message });
  }
};

// Test email sending
exports.testEmail = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }

    const mailOptions = {
      from: process.env.EMAIL_USER || 'your-email@gmail.com',
      to: email,
      subject: 'Test Email - Hệ thống Dự đoán Nuôi trồng Thủy sản',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #2c3e50;">Email Test</h2>
          <p>Đây là email test từ hệ thống Dự đoán Nuôi trồng Thủy sản.</p>
          <p>Nếu bạn nhận được email này, có nghĩa là cấu hình email đã hoạt động.</p>
          <p>Trân trọng,<br>Hệ thống Dự đoán Nuôi trồng Thủy sản</p>
        </div>
      `,
    };

    await transporter.sendMail(mailOptions);
    res.status(200).json({ message: 'Test email sent successfully' });
  } catch (error) {
    console.error('Test Email Error:', error);
    res.status(500).json({ error: error.message });
  }
};

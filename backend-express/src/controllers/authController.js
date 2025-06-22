const { User } = require('../models');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { Op } = require('sequelize');

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ where: { email: email } });
    const isPasswordMatch = await bcrypt.compare(password, user.password);

    if (!user && !isPasswordMatch)
      return res.status(401).json({ error: 'Invalid credentials' });

    if (user.status === 'inactivate')
      return res.status(403).json({ error: 'Your account is deactivated' });
    const token = jwt.sign(
      {
        id: user.id,
        role: user.role,
        province: user.province,
        district: user.district,
      },
      'SECRET_KEY',
      { expiresIn: '10d' }
    );

    res.status(200).json({ token, role: user.role });
  } catch (error) {
    console.error('Login Error:', {
      message: error.message,
      stack: error.stack,
      email: req.body.email,
    });
    res.status(500).json({ error: error.message });
  }
};

exports.createManagerUser = async (req, res) => {
  try {
    const {
      email,
      password,
      address = null,
      phone = null,
      province,
      district,
      role,
    } = req.body;

    // Validate required fields
    if (!email || !password || !province) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Validate district requirement for expert role
    if (role === 'expert' && !district) {
      return res
        .status(400)
        .json({ error: 'District is required for expert role' });
    }

    const isExist = await User.findOne({ where: { email } });
    if (isExist) return res.status(403).json({ error: 'User existed' });

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await User.create({
      username: email.split('@')[0],
      email: email,
      password: hashedPassword,
      address,
      phone,
      province,
      district,
      status: 'active',
      role: role || 'expert',
    });
    return res.status(200).json({ message: 'Register successful' });
  } catch (error) {
    console.error('Create Manager User Error:', {
      message: error.message,
      stack: error.stack,
    });
    return res.status(500).json({ error: 'Internal server error' });
  }
};

exports.getAllUser = async (req, res) => {
  try {
    const { role, province, search = null } = req.query;
    console.log(req.query);

    let whereCondition = {};
    if (role === 'manager') {
      whereCondition = {
        role: role,
        province: province,
        district: {
          [Op.ne]: null, // Ensure district is not null
        },
      };
    }
    if (search) {
      whereCondition.username = {
        [Op.iLike]: `%${search}%`,
      };
    }
    const userList = await User.findAll({
      where: whereCondition,
      order: [['id', 'ASC']],
    });
    return res.status(200).json({ data: userList });
  } catch (error) {
    console.error('Get All Users Error:', {
      message: error.message,
      stack: error.stack,
    });
    return res.status(500).json({ error: 'Internal server error' });
  }
};

exports.deactiveUser = async (req, res) => {
  try {
    const { id } = req.params;
    console.log('Deactivating user with ID:', id);

    const user = await User.findOne({ where: { id: id } });
    if (!user) return res.status(404).json({ error: 'User not found' });

    user.status = 'inactive';
    await user.save();
    return res
      .status(200)
      .json({ message: `User ${user.username} is deactivated` });
  } catch (error) {
    console.error('Deactivate User Error:', {
      message: error.message,
      stack: error.stack,
      userId: req.params.id,
    });
    return res.status(500).json({ error: error.message });
  }
};

exports.activateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findOne({ where: { id } });
    if (!user) return res.status(404).json({ error: 'User not found' });
    user.status = 'active';
    await user.save();
    return res
      .status(200)
      .json({ message: `User ${user.username} is activated` });
  } catch (error) {
    console.error('Activate User Error:', {
      message: error.message,
      stack: error.stack,
      userId: req.params.id,
    });
    return res.status(500).json({ error: error.message });
  }
};

exports.updateUserById = async (req, res) => {
  try {
    const { id } = req.params;
    console.log('Updating user with ID:', id, 'Data:', req.body);

    const {
      name = null,
      address = null,
      phone = null,
      province = null,
      district = null,
      email = null,
      role = null,
    } = req.body;
    const user = await User.findOne({ where: { id: id } });
    if (!user) res.status(404).json({ message: 'User not found' });

    user.username = name ? name : user.username;
    user.address = address ? address : user.address;
    user.phone = phone ? phone : user.phone;
    user.province = province ? province : user.province;
    user.district = district ? district : user.district;
    user.email = email ? email : user.email;
    user.role = role ? role : user.role;

    await user.save();
    return res.status(200).json({ message: 'Update successful' });
  } catch (error) {
    console.error('Update User Error:', {
      message: error.message,
      stack: error.stack,
      userId: req.params.id,
      updateData: req.body,
    });
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    console.log('Deleting user with ID:', id);

    // Tìm xem user có tồn tại không
    const user = await User.findOne({ where: { id } });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Xóa hẳn user. Nếu bạn chỉ muốn "soft-delete", có thể dùng user.update({ status: 'deleted' }, ...) thay thế
    await user.destroy();

    return res
      .status(200)
      .json({ message: `User ${user.username} has been deleted` });
  } catch (error) {
    console.error('Delete User Error:', {
      message: error.message,
      stack: error.stack,
      userId: req.params.id,
    });
    return res.status(500).json({ error: 'Internal server error' });
  }
};

exports.getUserById = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findOne({ where: { id } });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Remove sensitive information
    const userData = {
      id: user.id,
      username: user.username,
      email: user.email,
      role: user.role,
      status: user.status,
      address: user.address,
      phone: user.phone,
      province: user.province,
      district: user.district,
    };

    return res.status(200).json(userData);
  } catch (error) {
    console.error('Get User Error:', {
      message: error.message,
      stack: error.stack,
      userId: req.params.id,
    });
    return res.status(500).json({ error: 'Internal server error' });
  }
};

exports.changePassword = async (req, res) => {
  try {
    const { id } = req.params;
    const { oldPassword, newPassword } = req.body;

    if (!oldPassword || !newPassword) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const user = await User.findOne({ where: { id } });
    if (!user) return res.status(404).json({ error: 'User not found' });

    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Mật khẩu cũ không đúng' });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    user.password = hashedPassword;
    await user.save();

    return res.status(200).json({ message: 'Đổi mật khẩu thành công' });
  } catch (error) {
    console.error('Change Password Error:', {
      message: error.message,
      stack: error.stack,
      userId: req.params.id,
    });
    return res.status(500).json({ error: 'Internal server error' });
  }
};

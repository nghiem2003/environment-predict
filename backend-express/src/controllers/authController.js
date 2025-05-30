const { User, Region } = require('../models');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

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
      { id: user.id, role: user.role, region: user.region },
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
    const { email, password, address = null, phone = null, region } = req.body;
    const isExist = await User.findOne({ where: { email } });
    if (isExist) return res.status(403).json({ error: 'User existed' });
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await User.create({
      username: email.split('@')[0],
      email: email,
      password: hashedPassword,
      address,
      phone,
      region,
      status: 'active',
      role: 'expert',
    });
    return res.status(200).json({ message: 'Register successful' });
  } catch (error) {
    console.error('Create Manager User Error:', {
      message: error.message,
      stack: error.stack,
      email: req.body.email,
      region: req.body.region,
    });
    return res.status(500).json({ error: 'Internal server error' });
  }
};

exports.getAllUser = async (req, res) => {
  try {
    const userList = await User.findAll({
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
      region = null,
      email = null,
    } = req.body;
    const user = await User.findOne({ where: { id: id } });
    if (!user) res.status(404).json({ message: 'User not found' });

    user.username = name ? name : user.username;
    user.address = address ? address : user.address;
    user.phone = phone ? phone : user.phone;
    user.region = region ? region : user.region;
    user.email = email ? email : user.email;

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

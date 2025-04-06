const { User } = require('../models');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    
    const user = await User.findOne({ where: { email:email } });
    const isPasswordMatch = await bcrypt.compare(password,user.password)
    console.log(isPasswordMatch);
    
    if (!user && !isPasswordMatch) return res.status(401).json({ error: 'Invalid credentials' });

    if (user.status == 'inactivate')
      return res.status(403).json({ error: 'Your account is deactivated' });
    const token = jwt.sign({ id: user.id, role: user.role }, 'SECRET_KEY');

    res.status(200).json({ token, role: user.role });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.createManagerUser = async (req, res) => {
  try {
    const { email, password, address = null, phone = null } = req.body;
    const isExist = await User.findOne({ where: { email } });
    if (isExist) return res.status(403).json({ error: 'User existed' });
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await User.create({
      username: email.split('@')[0],
      email: email,
      password: hashedPassword,
      address,
      phone,
      status: 'active',
      role: 'expert',
    });
    return res.status(200).json({ message: 'Register successful' });
  } catch (e) {
    return res.status(500).json({ error: 'Internal server error' });
  }
};

exports.getAllUser = async (req, res) => {
  try {
    
    const userList = await User.findAll();
    return res.status(200).json({ data: userList });
  } catch (e) {
    return res.status(500).json({ error: 'Internal server error' });
  }
};

exports.deactiveUser = async (req, res) => {
  try {
    const { username } = req.body;
    const user = await User.findOne({ username: username });
    if (!user) return res.status(404).json({ error: 'User not found' });
    user.status = 'inactivate';
    await user.save();
    return res.status(200).json({ message: `User ${username} is deactivated` });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
};

exports.activateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findOne({ where: { id } });
    if (!user) return res.status(404).json({ error: 'User not found' });
    user.status = 'active';
    await user.save();
    return res.status(200).json({ message: `User ${user.username} is activated` });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
};


exports.updateUserById = async (req, res) => {
  try {
    const { username = null, address = null, phone = null } = req.body;
    const user = await User.findOne({ id: req.body.id });
    if (!user) res.status(404).json({ message: 'User not found' });
    user.username = username ? username.trim() : user.username;
    user.address = address ? address : user.address;
    user.phone = phone ? phone : user.phone;
    await user.save();
    return res.status(200).json({ message: 'Update successful' });
  } catch (e) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

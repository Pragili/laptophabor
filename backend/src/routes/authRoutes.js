const router = require('express').Router();
const c = require('../controllers/authController');
const auth = require('../middleware/auth');
const upload = require('../middleware/upload');

router.post('/register', upload.single('avatar'), c.register);
router.post('/login', c.login);
router.post('/forgot-password', c.forgotPassword);
router.post('/reset-password', c.resetPassword);
router.get('/me', auth, c.me);
router.put('/profile', auth, upload.single('avatar'), c.updateProfile);
module.exports = router;

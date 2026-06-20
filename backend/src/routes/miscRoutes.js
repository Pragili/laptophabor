const router = require('express').Router();
const auth = require('../middleware/auth');
const support = require('../controllers/supportController');
const notif = require('../controllers/notificationController');
const addr = require('../controllers/addressController');

router.get('/faqs', support.listFaqs);
router.post('/contact', support.sendContact);

router.get('/notifications', auth, notif.list);
router.put('/notifications/:id/read', auth, notif.markRead);
router.put('/notifications/read-all', auth, notif.markAllRead);

router.get('/addresses', auth, addr.list);
router.post('/addresses', auth, addr.create);
router.delete('/addresses/:id', auth, addr.remove);
module.exports = router;

function notFound(req, res, next) {
  res.status(404).json({ message: `Route not found: ${req.method} ${req.originalUrl}` });
}

function errorHandler(err, req, res, next) {
  console.error('[ERROR]', err.message);
  // Sequelize validation / unique constraint friendly messages
  if (err.name === 'SequelizeUniqueConstraintError') {
    return res.status(409).json({ message: 'Resource already exists', detail: err.errors?.[0]?.message });
  }
  if (err.name === 'SequelizeValidationError') {
    return res.status(400).json({ message: 'Validation failed', detail: err.errors?.map((e) => e.message) });
  }
  res.status(err.status || 500).json({ message: err.message || 'Internal server error' });
}

module.exports = { notFound, errorHandler };

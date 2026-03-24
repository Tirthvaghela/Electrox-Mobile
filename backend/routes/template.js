const express = require('express');
const router = express.Router();
const ElectionTemplate = require('../models/ElectionTemplate');
const { authenticate, authorize } = require('../middleware/auth');

// Create template
router.post('/create', authenticate, authorize('organizer', 'admin'), async (req, res) => {
  try {
    const { name, description, organizer_email, organization_id, template_data } = req.body;
    
    const template = await ElectionTemplate.create({
      name,
      description,
      organizer_email,
      organization_id,
      template_data
    });
    
    res.status(201).json({ message: 'Template created', template });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get organizer's templates
router.get('/my-templates', authenticate, async (req, res) => {
  try {
    const { email } = req.query;
    const templates = await ElectionTemplate.find({ organizer_email: email });
    res.json({ templates });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Use template
router.post('/use/:template_id', authenticate, async (req, res) => {
  try {
    const { template_id } = req.params;
    
    const template = await ElectionTemplate.findById(template_id);
    if (!template) {
      return res.status(404).json({ message: 'Template not found' });
    }
    
    template.usage_count += 1;
    await template.save();
    
    res.json({
      template_data: template.template_data,
      template_name: template.name
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;

# Electrox Election Management System - Style Guide

**Version:** 1.0.0  
**Last Updated:** March 10, 2026  
**Project:** Electrox Election Management System  
**Stack:** Flutter (Frontend) + Node.js/Express (Backend) + MongoDB (Database)

---

## Table of Contents

1. [Design System](#design-system)
2. [Color Palette](#color-palette)
3. [Typography](#typography)
4. [Spacing & Layout](#spacing--layout)
5. [Components](#components)
6. [Forms & Input](#forms--input)
7. [Frontend Conventions](#frontend-conventions)
8. [Backend Conventions](#backend-conventions)
9. [API Structure](#api-structure)
10. [Database Conventions](#database-conventions)
11. [Email Templates](#email-templates)
12. [Folder Structure](#folder-structure)

---

## Design System

### Design Philosophy

The Electrox system uses a modern, professional design system with:
- **Primary Color:** Prussian Blue (#14213D) - Trust, authority, professionalism
- **Accent Color:** Orange (#FCA311) - Energy, action, calls-to-action
- **Neutral Colors:** Black, White, Grey - Clarity and hierarchy
- **Status Colors:** Green (success), Red (error), Orange (warning)

### Design Principles

1. **Clarity:** Clear hierarchy and information architecture
2. **Accessibility:** Sufficient contrast ratios and readable text
3. **Consistency:** Uniform spacing, typography, and component usage
4. **Responsiveness:** Works on all screen sizes (mobile, tablet, desktop)
5. **Professional:** Suitable for government and institutional use

---

## Color Palette

### Primary Colors

| Color | Hex | RGB | Usage |
|-------|-----|-----|-------|
| Prussian Blue | #14213D | rgb(20, 33, 61) | Primary UI, headers, text |
| Black | #000000 | rgb(0, 0, 0) | Dark backgrounds, gradients |
| Orange | #FCA311 | rgb(252, 163, 17) | Buttons, accents, CTAs |
| Alabaster Grey | #E5E5E5 | rgb(229, 229, 229) | Backgrounds, light surfaces |
| White | #FFFFFF | rgb(255, 255, 255) | Cards, surfaces, text backgrounds |

### Status Colors

| Status | Hex | RGB | Usage |
|--------|-----|-----|-------|
| Success | #4CAF50 | rgb(76, 175, 80) | Success messages, confirmations |
| Error | #F44336 | rgb(244, 67, 54) | Error messages, validation |
| Warning | #FCA311 | rgb(252, 163, 17) | Warnings, alerts |
| Info | #14213D | rgb(20, 33, 61) | Information messages |

### Text Colors

| Element | Hex | RGB | Usage |
|---------|-----|-----|-------|
| Primary Text | #14213D | rgb(20, 33, 61) | Main content, headings |
| Secondary Text | #757575 | rgb(117, 117, 117) | Descriptions, metadata |
| Hint Text | #9E9E9E | rgb(158, 158, 158) | Placeholders, disabled text |
| Text on Dark | #FFFFFF | rgb(255, 255, 255) | Text on dark backgrounds |

### Gradients

**Primary Gradient:**
```
Direction: Top to Bottom
Start: #000000 (Black)
End: #14213D (Prussian Blue)
```

Used for: App headers, hero sections, premium elements

---

## Typography

### Font Family

**Primary Font:** Roboto (Google Fonts)
- Clean, modern, highly readable
- Excellent for UI and body text
- Available in multiple weights

### Font Sizes & Weights

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| Display Large | 32px | Bold (700) | Page titles, hero text |
| Display Medium | 28px | Bold (700) | Section titles |
| Display Small | 24px | Bold (700) | Card titles |
| Headline Medium | 20px | Semi-bold (600) | Subsection titles |
| Title Large | 18px | Semi-bold (600) | Dialog titles, form titles |
| Title Medium | 16px | Medium (500) | Button text, labels |
| Body Large | 16px | Regular (400) | Main content, descriptions |
| Body Medium | 14px | Regular (400) | Secondary content |
| Body Small | 12px | Regular (400) | Captions, metadata |

### Text Styles

**Headings:**
- Color: Prussian Blue (#14213D)
- Font Family: Roboto
- Line Height: 1.2

**Body Text:**
- Color: Prussian Blue (#14213D)
- Font Family: Roboto
- Line Height: 1.6

**Labels:**
- Color: Prussian Blue (#14213D)
- Font Weight: Medium (500)
- Font Size: 16px

**Placeholder Text:**
- Color: Hint Grey (#9E9E9E)
- Font Style: Italic (optional)

---

## Spacing & Layout

### Spacing System

The project uses an **8px base spacing system**:

| Scale | Value | Usage |
|-------|-------|-------|
| XS | 4px | Micro spacing, icon gaps |
| S | 8px | Small gaps, component padding |
| M | 16px | Standard spacing, section gaps |
| L | 24px | Large spacing, major sections |
| XL | 32px | Extra large spacing, page sections |

### Padding

| Element | Value | Usage |
|---------|-------|-------|
| Screen Padding | 20px | Page margins |
| Card Padding | 18px | Card content padding |
| Input Padding | 12px | Form field padding |

### Border Radius

| Element | Value | Usage |
|---------|-------|-------|
| Buttons | 12px | Button corners |
| Cards | 18px | Card corners |
| Input Fields | 12px | Form field corners |
| Modals | 20px | Dialog corners |

### Shadows

**Soft Shadow (Cards, Elevated Elements):**
```
Blur Radius: 16px
Offset: 0px, 6px
Color: rgba(0, 0, 0, 0.12)
```

---

## Components

### Buttons

**Primary Button (Elevated):**
- Background: Orange (#FCA311)
- Text Color: Black (#000000)
- Padding: 24px horizontal, 14px vertical
- Border Radius: 12px
- Font Size: 16px, Medium weight
- Elevation: 0 (flat design)
- State: Disabled when loading

**Secondary Button (Outlined):**
- Background: Transparent
- Border: 2px Prussian Blue (#14213D)
- Text Color: Prussian Blue (#14213D)
- Padding: 24px horizontal, 14px vertical
- Border Radius: 12px
- Font Size: 16px, Medium weight

**Button States:**
- Normal: Full opacity
- Hover: Slight shadow increase
- Pressed: Opacity 0.8
- Disabled: Opacity 0.5, no interaction
- Loading: Show spinner, disable interaction

### Cards

- Background: White (#FFFFFF)
- Border Radius: 18px
- Padding: 18px
- Shadow: Soft shadow (see Shadows section)
- Elevation: 0 (flat design with shadow)
- Margin: 8px vertical

**Card Interaction:**
- Tap: Slight scale animation (0.98)
- Hover: Shadow increase
- Ripple effect on tap

### App Bar

- Background: Prussian Blue (#14213D)
- Text Color: White (#FFFFFF)
- Height: 56px (Material standard)
- Elevation: 2px
- Title Font Size: 20px, Semi-bold
- Title Alignment: Left

### Input Fields

- Background: White (#FFFFFF)
- Border: 1px Hint Grey (#9E9E9E)
- Border Radius: 12px
- Padding: 12px horizontal, 12px vertical
- Font Size: 16px
- Placeholder Color: Hint Grey (#9E9E9E)

**Input States:**
- Normal: Grey border
- Focused: 2px Prussian Blue border
- Error: Red border (#F44336)
- Disabled: Grey background, no interaction

### Modals/Dialogs

- Background: White (#FFFFFF)
- Border Radius: 20px
- Padding: 24px
- Shadow: Soft shadow
- Overlay: Semi-transparent black (0.5 opacity)

---

## Forms & Input

### Form Layout

- **Vertical Stack:** All form fields stack vertically
- **Spacing:** 16px between fields
- **Labels:** Above input fields
- **Required Indicator:** Asterisk (*) after label text

### Label Style

- Font Size: 16px
- Font Weight: Medium (500)
- Color: Prussian Blue (#14213D)
- Margin Bottom: 8px

### Input Field Conventions

- **Placeholder:** Descriptive hint text
- **Validation:** Real-time or on blur
- **Error Message:** Below input field, red text
- **Helper Text:** Below input field, grey text

### Validation Messages

- **Error Message Color:** Red (#F44336)
- **Font Size:** 12px
- **Position:** Below input field
- **Icon:** Error icon (optional)

### Form Submission

- **Button Position:** Below all fields
- **Button Width:** Full width or fixed width
- **Loading State:** Show spinner during submission
- **Success Message:** Toast or snackbar notification
- **Error Message:** Toast or snackbar notification

---

## Frontend Conventions

### File Naming

**Dart Files:**
- Screens: `snake_case_screen.dart` (e.g., `login_screen.dart`)
- Widgets: `custom_widget_name.dart` (e.g., `custom_button.dart`)
- Models: `model_name.dart` (e.g., `user.dart`)
- Services: `service_name.dart` (e.g., `api_service.dart`)
- Config: `config_name.dart` (e.g., `theme.dart`)

**Folder Structure:**
```
lib/
├── config/              # Configuration files
│   ├── api_config.dart
│   ├── routes.dart
│   └── theme.dart
├── models/              # Data models
│   └── *.dart
├── screens/             # Screen/Page widgets
│   ├── admin/
│   ├── organiser/
│   ├── candidate/
│   ├── voter/
│   ├── login_screen.dart
│   └── splash_screen.dart
├── services/            # API and business logic
│   └── api_service.dart
├── utils/               # Utility functions
│   └── *.dart
├── widgets/             # Reusable widgets
│   ├── custom_app_bar.dart
│   ├── custom_button.dart
│   ├── custom_card.dart
│   ├── custom_drawer.dart
│   └── custom_text_field.dart
└── main.dart            # App entry point
```

### Widget Naming

- Use `Custom` prefix for reusable widgets: `CustomButton`, `CustomCard`
- Use descriptive names: `LoginScreen`, `AdminDashboard`
- Use `Screen` suffix for full-page widgets
- Use `Widget` suffix for component widgets (optional)

### State Management

- **Pattern:** Singleton pattern for services (e.g., ApiService)
- **Token Management:** Maintained in ApiService singleton
- **Data Persistence:** Token stored in ApiService instance
- **Navigation:** Named routes via AppRoutes class

### API Calling Pattern

```dart
// Singleton pattern
static final ApiService _instance = ApiService._internal();
factory ApiService() => _instance;

// Methods return Future<Map<String, dynamic>>
Future<Map<String, dynamic>> login(String email, String password) async {
  // Implementation
}

// Error handling with try-catch
try {
  final response = await apiService.login(email, password);
  if (response['success']) {
    // Handle success
  }
} catch (e) {
  // Handle error
}
```

### Screen Structure

```dart
class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Screen Title'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingScreen),
        child: Column(
          children: [
            // Content here
          ],
        ),
      ),
    );
  }
}
```

### Theme Usage

Always use `AppTheme` constants instead of hardcoded values:

```dart
// ✅ Good
Container(
  padding: const EdgeInsets.all(AppTheme.spacingM),
  decoration: BoxDecoration(
    color: AppTheme.cardColor,
    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
  ),
)

// ❌ Bad
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
  ),
)
```

---

## Backend Conventions

### File Naming

**JavaScript Files:**
- Controllers: `entity.controller.js` (e.g., `user.controller.js`)
- Routes: `entity.routes.js` (e.g., `user.routes.js`)
- Models: `Entity.model.js` (e.g., `User.model.js`)
- Middleware: `middleware_name.middleware.js` (e.g., `auth.middleware.js`)
- Utils: `utility_name.js` (e.g., `emailService.js`)

### Folder Structure

```
backend/
├── controllers/         # Business logic
│   ├── auth.controller.js
│   ├── user.controller.js
│   ├── organisation.controller.js
│   ├── election.controller.js
│   ├── election.extended.controller.js
│   ├── participant.controller.js
│   └── vote.controller.js
├── routes/              # API endpoints
│   ├── auth.routes.js
│   ├── user.routes.js
│   ├── organisation.routes.js
│   ├── election.routes.js
│   ├── election.extended.routes.js
│   ├── participant.routes.js
│   └── vote.routes.js
├── models/              # MongoDB schemas
│   ├── User.model.js
│   ├── Organisation.model.js
│   ├── Election.model.js
│   ├── Vote.model.js
│   └── Participant.model.js
├── middleware/          # Custom middleware
│   └── auth.middleware.js
├── utils/               # Utility functions
│   ├── emailService.js
│   ├── emailTemplates.js
│   ├── passwordGenerator.js
│   └── network-info.js
├── server.js            # Express app entry point
├── .env                 # Environment variables
└── package.json         # Dependencies
```

### Naming Conventions

**Controllers:**
- Export as `exports.functionName`
- Use camelCase for function names
- Example: `exports.createUser`, `exports.getUser`

**Routes:**
- Use RESTful conventions
- Example: `POST /api/users`, `GET /api/users/:id`

**Models:**
- Use PascalCase for model names
- Example: `User`, `Organisation`, `Election`

**Middleware:**
- Use camelCase for function names
- Example: `verifyToken`, `checkRole`

### Controller Pattern

```javascript
// ✅ Good pattern
exports.createUser = async (req, res) => {
  try {
    const { name, email } = req.body;
    
    // Validation
    if (!name || !email) {
      return res.status(400).json({
        success: false,
        message: 'Name and email are required'
      });
    }
    
    // Business logic
    const user = new User({ name, email });
    await user.save();
    
    // Response
    res.status(201).json({
      success: true,
      message: 'User created successfully',
      data: { user }
    });
  } catch (error) {
    console.error('Create user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create user',
      error: error.message
    });
  }
};
```

### Logging Pattern

```javascript
// Use console.log with emoji prefixes for clarity
console.log('🔄 Processing request...');
console.log('✅ Success message');
console.log('❌ Error message');
console.log('📨 Email sent');
console.log('🔐 Authentication check');
console.log('💾 Database operation');
console.log('📤 API request');
console.log('📥 API response');
```

---

## API Structure

### Base URL

- **Development:** `http://localhost:3000/api`
- **Production:** `https://api.electrox.com/api`
- **Android Emulator:** `http://10.0.2.2:3000/api`
- **iOS Simulator:** `http://localhost:3000/api`

### Request Format

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <JWT_TOKEN>
```

**Body (JSON):**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

### Response Format

**Success Response (200, 201):**
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    "user": {
      "id": "...",
      "name": "...",
      "email": "..."
    }
  }
}
```

**Error Response (400, 401, 403, 500):**
```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error message"
}
```

### HTTP Status Codes

| Code | Usage |
|------|-------|
| 200 | GET successful, data returned |
| 201 | POST/PUT successful, resource created |
| 400 | Bad request, validation error |
| 401 | Unauthorized, invalid credentials |
| 403 | Forbidden, insufficient permissions |
| 404 | Not found, resource doesn't exist |
| 500 | Server error, internal error |

### API Endpoints

**Authentication:**
- `POST /api/auth/login` - User login
- `POST /api/auth/change-password` - Change password
- `GET /api/auth/me` - Get current user

**Organisations:**
- `POST /api/organisations` - Create organisation
- `GET /api/organisations` - Get all organisations
- `GET /api/organisations/:id` - Get organisation by ID

**Users:**
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID

**Elections:**
- `POST /api/elections` - Create election
- `GET /api/elections` - Get all elections
- `GET /api/elections/:id` - Get election by ID
- `GET /api/elections/:id/results` - Get election results

**Participants:**
- `POST /api/participants/upload-csv` - Upload CSV
- `GET /api/participants/pending` - Get pending participants

**Votes:**
- `POST /api/votes` - Cast vote
- `GET /api/votes/:electionId` - Get votes for election

---

## Database Conventions

### Collection Naming

- Use **lowercase** with **underscores**: `users`, `organisations`, `elections`
- Use **plural** form: `users` not `user`
- Use **descriptive** names: `election_results` not `results`

### Field Naming

- Use **camelCase** for field names: `firstName`, `lastName`, `isActive`
- Use **descriptive** names: `createdAt` not `created`
- Use **consistent** naming across collections

### Schema Patterns

**Timestamps:**
```javascript
{
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}
```

**References:**
```javascript
{
  organisation: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Organisation',
    required: true
  }
}
```

**Enums:**
```javascript
{
  role: {
    type: String,
    enum: ['admin', 'organiser', 'candidate', 'voter'],
    required: true
  }
}
```

**Validation:**
```javascript
{
  email: {
    type: String,
    required: [true, 'Email is required'],
    lowercase: true,
    trim: true,
    validate: {
      validator: function(v) {
        return /^\S+@\S+\.\S+$/.test(v);
      },
      message: 'Please provide a valid email'
    }
  }
}
```

### Model Pattern

```javascript
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Name is required'],
    trim: true
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    lowercase: true,
    trim: true
  },
  role: {
    type: String,
    enum: ['admin', 'organiser', 'candidate', 'voter'],
    required: true
  },
  isActive: {
    type: Boolean,
    default: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('User', userSchema);
```

---

## Email Templates

### Email Structure

**Header:**
- Background: Gradient (Black to Prussian Blue)
- Logo: Electrox branding
- Tagline: "Modern Governance • Digital Trust"

**Content:**
- Greeting: "Hello [Name],"
- Body: Clear, concise message
- Credentials Box: Highlighted with orange border
- Warning Box: Important security information

**Footer:**
- Branding: "Electrox Election Management System"
- Disclaimer: "This is an automated message"

### Email Template Patterns

**Credentials Box:**
```html
<div class="credentials-box">
  <div class="credential-item">
    <span class="credential-label">Email:</span>
    <div class="credential-value">${email}</div>
  </div>
  <div class="credential-item">
    <span class="credential-label">Password:</span>
    <div class="credential-value">${password}</div>
  </div>
</div>
```

**Warning Box:**
```html
<div class="warning-box">
  <p><strong>⚠️ Important:</strong> You must change your password during your first login for security purposes.</p>
</div>
```

### Email Styling

- **Font Family:** Segoe UI, Tahoma, Geneva, Verdana, sans-serif
- **Max Width:** 600px
- **Background:** Light grey (#E5E5E5)
- **Container:** White (#FFFFFF) with rounded corners (18px)
- **Shadows:** 0 6px 16px rgba(0, 0, 0, 0.12)

### Email Templates Available

1. **Organiser Credentials** - Sent when organiser account is created
2. **Voter Credentials** - Sent when voter is added to election
3. **Candidate Credentials** - Sent when candidate is added to election
4. **Password Updated** - Sent when password is changed
5. **Election Created** - Sent when election is created
6. **CSV Upload Success** - Sent when CSV is uploaded
7. **Organisation Created** - Sent when organisation is created

---

## Folder Structure

### Root Directory

```
electrox/
├── backend/                 # Node.js/Express backend
├── lib/                     # Flutter frontend
├── android/                 # Android native code
├── ios/                     # iOS native code
├── assets/                  # App assets (icons, images)
├── test/                    # Flutter tests
├── pubspec.yaml             # Flutter dependencies
├── pubspec.lock             # Locked dependencies
├── .gitignore               # Git ignore rules
├── README.md                # Project documentation
├── SETUP_AND_RUN.md         # Setup instructions
├── STYLE_GUIDE.md           # This file
└── SYSTEM_STATUS_REPORT.md  # System status
```

### Backend Structure

```
backend/
├── controllers/             # Business logic (7 files)
├── routes/                  # API endpoints (7 files)
├── models/                  # MongoDB schemas (5 files)
├── middleware/              # Custom middleware (1 file)
├── utils/                   # Utilities (4 files)
├── server.js                # Express app
├── .env                     # Environment variables
├── package.json             # Dependencies
└── [test scripts]           # Testing scripts
```

### Frontend Structure

```
lib/
├── config/                  # Configuration (3 files)
│   ├── api_config.dart
│   ├── routes.dart
│   └── theme.dart
├── models/                  # Data models
├── screens/                 # Screen widgets (11 files)
│   ├── admin/
│   ├── organiser/
│   ├── candidate/
│   ├── voter/
│   ├── login_screen.dart
│   └── splash_screen.dart
├── services/                # API service (1 file)
├── utils/                   # Utilities
├── widgets/                 # Reusable widgets (5 files)
└── main.dart                # App entry point
```

---

## Environment Variables

### Backend (.env)

```
# MongoDB
MONGODB_URI=mongodb://localhost:27017/electrox_db
DB_URL=mongodb://localhost:27017/electrox_db

# Server
PORT=3000
NODE_ENV=development
API_BASE_URL=http://localhost:3000/api

# JWT
JWT_SECRET=your_jwt_secret_key_change_this_in_production

# SMTP Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_EMAIL=your_email@gmail.com
SMTP_PASSWORD=your_app_password

# Frontend
FRONTEND_URL=http://localhost:3000

# File Upload
MAX_FILE_SIZE=5242880
UPLOAD_PATH=./uploads
```

### Frontend (Dart)

```dart
// API Configuration
const String API_URL = 'http://localhost:3000/api';  // Custom IP
const int DEFAULT_PORT = 3000;

// Auto-detection
// Android Emulator: http://10.0.2.2:3000/api
// iOS Simulator: http://localhost:3000/api
```

---

## Best Practices

### Frontend

1. **Always use AppTheme constants** for colors, spacing, and typography
2. **Use Singleton pattern** for services to maintain state
3. **Handle errors gracefully** with try-catch blocks
4. **Show loading states** during API calls
5. **Validate input** before submission
6. **Use named routes** for navigation
7. **Keep widgets small** and focused
8. **Use const constructors** where possible

### Backend

1. **Always validate input** in controllers
2. **Use consistent error responses** with success flag
3. **Log important operations** with emoji prefixes
4. **Hash passwords** with bcrypt before saving
5. **Use JWT tokens** for authentication
6. **Implement role-based access** control
7. **Use try-catch** for error handling
8. **Return appropriate HTTP status codes**

### Database

1. **Use timestamps** for all documents
2. **Use references** for relationships
3. **Use enums** for fixed values
4. **Validate data** at schema level
5. **Use indexes** for frequently queried fields
6. **Use descriptive field names**
7. **Keep schemas normalized**

### Email

1. **Use HTML templates** for professional appearance
2. **Include branding** in all emails
3. **Use clear credentials layout** for login emails
4. **Include security warnings** where appropriate
5. **Test emails** before sending to users
6. **Use consistent styling** across all templates

---

## Code Examples

### Flutter - Login Screen

```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Login'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingScreen),
        child: Column(
          children: [
            CustomTextField(
              label: 'Email *',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppTheme.spacingM),
            CustomTextField(
              label: 'Password *',
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: AppTheme.spacingL),
            CustomButton(
              text: 'Login',
              isLoading: _isLoading,
              onPressed: _handleLogin,
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().login(
        _emailController.text,
        _passwordController.text,
      );
      // Handle success
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
```

### Node.js - Create User Controller

```javascript
exports.createUser = async (req, res) => {
  try {
    console.log('📨 Create User Request');
    const { name, email, password, role } = req.body;

    // Validation
    if (!name || !email || !password || !role) {
      return res.status(400).json({
        success: false,
        message: 'All fields are required'
      });
    }

    // Create user
    const user = new User({
      name,
      email,
      password,
      role
    });

    await user.save();
    console.log('✅ User created successfully');

    res.status(201).json({
      success: true,
      message: 'User created successfully',
      data: { user }
    });
  } catch (error) {
    console.error('❌ Create user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create user',
      error: error.message
    });
  }
};
```

---

## Maintenance & Updates

### When to Update This Guide

- When adding new components
- When changing color scheme
- When modifying folder structure
- When introducing new patterns
- When updating dependencies

### Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | Mar 10, 2026 | Initial style guide |

---

## Questions & Support

For questions about this style guide:
1. Check the relevant section
2. Review code examples
3. Check existing code in the repository
4. Ask the development team

---

**Last Updated:** March 10, 2026  
**Maintained By:** Development Team  
**Status:** Active

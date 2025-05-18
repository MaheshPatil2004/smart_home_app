# Smart Home Management System

A Flutter application for managing smart home devices, institutions, and sales representatives.

## Prerequisites

Before you begin, ensure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (Latest stable version)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/downloads)
- [Node.js](https://nodejs.org/) (for backend)
- [MongoDB](https://www.mongodb.com/try/download/community) (for database)

## Project Setup

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd <project-directory>
   ```

2. **Install Flutter Dependencies**
   ```bash
   flutter pub get
   ```

3. **Backend Setup**
   - Navigate to the backend directory
   - Install Node.js dependencies:
     ```bash
     npm install
     ```
   - Create a `.env` file in the backend directory with the following variables:
     ```
     PORT=3000
     MONGODB_URI=mongodb://localhost:27017/smart_home
     JWT_SECRET=your_jwt_secret
     ```

4. **Database Setup**
   - Start MongoDB service
   - Create a database named `smart_home`

## Running the Application

1. **Start the Backend Server**
   ```bash
   cd backend
   npm start
   ```

2. **Run the Flutter Application**
   - For Android:
     ```bash
     flutter run -d android
     ```
   - For iOS:
     ```bash
     flutter run -d ios
     ```

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── screens/                  # UI screens
│   ├── sales_rep_login.dart
│   ├── sales_dashboard.dart
│   ├── sales_customer_rooms_devices.dart
│   ├── sales_device_selection_screen.dart
│   ├── sales_generate_report.dart
│   └── ...
├── services/                 # API and business logic
│   └── api_service.dart
└── models/                   # Data models
    └── ...
```

## Features

- **Sales Representative Features**
  - Customer registration
  - Institution selection
  - Room and device management
  - Quotation generation
  - Email notifications

- **Admin Features**
  - User management
  - Institution management
  - Reports and analytics

## API Endpoints

The application communicates with the following API endpoints:

- Authentication: `/api/auth/login`
- Institutions: `/api/institutions`
- Rooms: `/api/rooms`
- Devices: `/api/devices`
- Customers: `/api/sales/customers`
- Requirements: `/api/sales/customers/:customerId/requirements`
- Quotations: `/api/sales/customers/:customerId/quotations`

## Environment Configuration

1. **Flutter Configuration**
   - Update `lib/services/api_service.dart` with your backend URL:
     ```dart
     final String baseUrl = 'http://localhost:3000/api';
     ```

2. **Backend Configuration**
   - Update MongoDB connection string in `.env`
   - Configure JWT secret for authentication

## Troubleshooting

1. **Flutter Issues**
   - Run `flutter doctor` to check for any issues
   - Ensure all dependencies are installed with `flutter pub get`
   - Clear Flutter cache if needed: `flutter clean`

2. **Backend Issues**
   - Check MongoDB connection
   - Verify environment variables
   - Check Node.js version compatibility

3. **Common Errors**
   - "Connection refused": Ensure backend server is running
   - "Invalid JWT token": Check JWT secret configuration
   - "Database connection failed": Verify MongoDB service

## Support

For any issues or questions, please contact:
- Email: [your-email@example.com]
- Phone: [your-phone-number]

## License

This project is licensed under the MIT License - see the LICENSE file for details.

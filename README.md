# Smart Home Management System

A Flutter application for managing smart home devices, institutions, and sales representatives.

## Prerequisites

Before you begin, ensure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (Latest stable version)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/downloads)
- [Node.js](https://nodejs.org/) (for backend)


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


## Running the Application



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
- Email: [patilmaheshwar2004@gmail.com]


# SideChef - Recipe Management Platform
A comprehensive recipe management platform built with Flutter, consisting of two applications:- User Application (user_recipeapp)
- Admin Dashboard (admin_recipeapp)
## Overview
SideChef is a modern recipe management platform that connects food enthusiasts with recipes while providing administrators with powerful tools to manage content and monitor platform analytics.
## Applications
### User ApplicationA feature-rich mobile application that allows users to:
- Browse and search recipes- View detailed recipe information
- Share recipes with others- Filter and search recipes using various parameters
- Customize recipe views- Image handling for recipes
- Interactive user interface with modern design
**Key Technologies:**- Flutter
- Supabase for backend- Firebase Core
- Image Picker for media handling- Search and filtering capabilities
- Share Plus for social sharing- Google Fonts for typography
- FL Chart for data visualization
### Admin DashboardA dedicated administrative interface that provides:
- Content management capabilities- Analytics and reporting
- User management- Platform monitoring
- Data visualization using charts
**Key Technologies:**- Flutter
- Supabase for backend- FL Chart for analytics visualization
- Google Fonts for consistent typography
## Technical Stack
### Frontend- Flutter SDK (^3.6.0)
- Material Design
### Backend & Services- Supabase for database and authentication
- Firebase integration (user app)
### Key Dependencies- `supabase_flutter: ^2.8.3`
- `fl_chart: ^0.70.2`- `google_fonts: ^6.2.1`
- `image_picker: ^1.1.2`- `share_plus: ^10.1.4`
- Additional utilities and helper packages
## Platform Support- Android
- iOS- Linux
- Windows- Web (potential support)
## Getting Started
1. Clone the repository
2. Set up Flutter environment (SDK ^3.6.0)3. Install dependencies:
   ```bash   cd user_recipeapp
   flutter pub get   
   cd ../admin_recipeapp   flutter pub get
   ```4. Configure Supabase:
   - Add your Supabase credentials in the respective configuration files   - Set up necessary database tables and relationships
5. Run the applications:
   ```bash   # For user app
   cd user_recipeapp   flutter run
   # For admin dashboard
   cd admin_recipeapp   flutter run
   ```
## Project Structure```
├── admin_recipeapp/     # Admin dashboard application├── user_recipeapp/      # User-facing mobile application
└── README.md           # Project documentation```
## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.
## License






















































# SideChef

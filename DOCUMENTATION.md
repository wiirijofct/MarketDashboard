# Sales Dashboard Web App Documentation

## Project Overview

This project is a Flutter web application that displays sales data visualization through an interactive dashboard. The dashboard allows users to analyze sales data across different product categories with multiple visualization options.

## Architecture

The application follows a feature-based architecture with clear separation of concerns:

```
lib/
├── core/             # Core UI components and constants
├── data/             # Data sources and repositories
├── features/         # Feature modules
│   ├── pages/        # Screen implementations
│   └── widgets/      # UI components
└── models/           # Data models
```

### Key Components

1. **Data Layer**
   - `FakeDataRepository` - Generates and provides mock sales data
   - `DailySnapshot` & `DailyCategoryData` - Models representing sales data

2. **UI Layer**
   - `SalesDashboardPage` - Main page container
   - Chart components (Line, Bar, Donut) - Visualization widgets
   - Selector widgets - UI for filtering and manipulating data view

## Features

### Data Visualization
- **Multiple Chart Types**: Line, Bar, and Donut charts to visualize sales data
- **Time Range Selection**: Filter data by last 7, 30, or 90 days
- **Category Filtering**: View data for specific product categories
- **Category Comparison**: Compare sales performance between multiple categories in line chart
- **Interactive Tooltips**: Display detailed information on hover/touch

### UI Interactions
- **Category Selection**: Select a category to focus analysis
- **Top Seller**: Quick navigation to best-selling category
- **Interactive Legends**: Visual indicators for selected categories (such as change in the bg color, unique colors and use of icons)
- **Responsive Design**: Adapts to different screen sizes (Should work well on Desktop and some Tablets)

## Implementation Details

### State Management
The application uses Flutter's built-in `StatefulWidget` for state management. Key states include:
- Selected date range
- Selected chart type
- Selected category
- Comparison categories
- UI interaction states (tooltips, hover effects)

### Data Flow
1. Data is generated in `FakeDataRepository` with predictable random patterns
2. The dashboard retrieves relevant data slices based on user selections
3. Chart widgets render visualizations based on the provided data
4. User interactions trigger state updates, causing re-renders with new data views

### Chart Implementation
Each chart type is implemented using the `fl_chart` package:

1. **Line Chart**
   - Shows trends over time
   - Supports multiple series for category comparison
   - Interactive tooltips on hover

2. **Bar Chart**
   - Shows data distribution across time periods
   - Clear value representation with consistent scaling
   - Interactive tooltips on tap/hover

3. **Donut Chart**
   - Shows category market share
   - Interactive segments with hover effects
   - Quick navigation to detailed views via tooltips

## Code Structure

### Key Files

- `sales_dashboard_page.dart` - Main dashboard implementation
- `fake_market_data.dart` - Data generation and repository
- `category.dart` - Category model with display properties
- Chart components:
  - `line_chart.dart`
  - `bar_chart.dart`
  - `pie_chart.dart`
- UI components:
  - `app_sidebar.dart`
  - `summary_card.dart`
  - `selectors/*.dart`

## Usage

### Navigation
- Use the sidebar to navigate between different dashboard views (Sales, Stock, Demand) **#TODO**
- The dashboard presents a summary of key metrics at the top
- Select different chart types and filters to analyze data

### Interactions
- Click on the "Top Seller" card to quickly filter by the best-selling category
- Use chart type selector to switch between visualization modes
- In line chart mode, use the "+" button to compare multiple categories
- In donut chart mode, click on segments to see detailed options for that category
- Use the date selector to change the time range for analysis

## Performance Considerations

- Chart rendering is optimized to handle large datasets
- UI state changes use efficient updates to minimize rebuilds
- Animations are applied selectively to enhance UX without impacting performance

## Extensibility

This dashboard is designed to be extended with:
- Additional chart types
- Real-time data integration
- Export capabilities **#TODO**
- User preference persistence **#TODO**

## Dependencies

- `flutter`: Core framework
- `fl_chart`: Chart rendering library
- Other standard Flutter libraries for UI components
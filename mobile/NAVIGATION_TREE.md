# Oasis Tracking - Navigation Tree

## Bottom Navigation (5 items)
- **Home** → Dashboard
- **Map** → MapPage
- **Animals** → AnimalsPage  
- **Alerts** → AlertsPage (or Auctions from Reports)
- **Profile** → ProfilePage

## Page Flow Diagram

```
LoginPage
    │
    └──► Dashboard (Home)
            │
            ├── [Bottom Nav] ─────────────────────────┐
            │                                          │
            ├── MapPage ◄──────────────────────────────┼── [Bottom Nav]
            │        │                                 │
            │        └── [View Full Map] ─────────────►MapPage (Full)
            │
            ├── AnimalsPage ◄─────────────────────────┼── [Bottom Nav]
            │        │                                 │
            │        └── [Animal Card Tap] ──────────► Animal Details (Modal)
            │
            ├── AlertsPage ◄───────────────────────────┼── [Bottom Nav]
            │        │                                 │
            │        └── [Alert Card] ───────────────► Alert Details + Acknowledge
            │
            └── ProfilePage ◄──────────────────────────┤── [Bottom Nav]
                    │
                    ├── [Menu: Team Members] ─────────► TeamPage
                    ├── [Menu: Animals] ─────────────► AnimalsPage
                    ├── [Menu: Geofences] ────────────► GeofencesPage
                    ├── [Menu: Devices] ─────────────► DevicesPage
                    ├── [Menu: Tasks] ────────────────► TasksPage
                    └── [Menu: Auctions] ─────────────► AuctionPage

    ReportsPage (via bottom nav on some pages)
            │
            └── [Bottom Nav: Auctions] ───────────────► AuctionPage

    TeamPage
            └── [Bottom Nav] ─────────────────────────► Back to Profile

    DevicesPage  
            └── [Bottom Nav] ─────────────────────────► Back to Profile

    GeofencesPage
            └── [Bottom Nav] ─────────────────────────► Back to Profile

    TasksPage
            └── [Bottom Nav] ─────────────────────────► Back to Profile

    AuctionPage
            └── [Bottom Nav] ─────────────────────────► Profile

    MapPage (Full)
            └── [Bottom Nav: Home] ──────────────────► Dashboard
```

## All Pages List

| Page | File | Accessible From |
|------|------|-----------------|
| LoginPage | login_page.dart | Initial entry |
| DashboardPage | dashboard_page.dart | After login |
| MapPage | map_page.dart | Bottom nav / Dashboard |
| AnimalsPage | animals_page.dart | Bottom nav / Profile |
| AlertsPage | alerts_page.dart | Bottom nav |
| ProfilePage | profile_page.dart | Bottom nav |
| TeamPage | team_page.dart | Profile menu |
| GeofencesPage | geofences_page.dart | Profile menu |
| DevicesPage | devices_page.dart | Profile menu |
| TasksPage | tasks_page.dart | Profile menu |
| AuctionPage | auction_page.dart | Profile menu / Reports |
| ReportsPage | reports_page.dart | Was in bottom nav, now removed |

## Header Component
All pages should have a consistent header with:
- Profile icon (left) - navigates to Profile
- Page title (center)
- Settings/more menu (right) - Profile, Settings, Sign Out
- Back arrow (if can pop) - goes back

## Bottom Navigation
- Fixed at bottom
- 5 items: Home, Map, Animals, Alerts, Profile
- Active item highlighted with green background
- Tap switches to page, long press not used

## Form Validation Rules
- Email: Required, valid format
- Password: Required, min 8 chars
- Name: Required, min 2 chars
- Phone: Optional, valid format if provided
- Numbers: Valid numeric input
- Required fields marked with * in label

## Color Scheme
- Primary: #06402B (Dark Green)
- Secondary: #002819 (Darker Green)
- Accent: #FBBF24 (Gold/Amber)
- Error: #BA1A1A (Red)
- Background: #FAFAF5 (Light)
- Surface: #FFFFFF (White)
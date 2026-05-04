# COMPREHENSIVE BUG REPORT - Oasis Trace

**Date:** 2026-04-15
**Reviewer:** Automated Code Review
**Status:** Ready for Developer

---

## EXECUTIVE SUMMARY

| Category | Count | Severity |
|----------|-------|----------|
| API/API Mismatch | 4 | HIGH |
| Flutter/Backend Mismatch | 3 | HIGH |
| UI Navigation Issues | 5 | MEDIUM |
| Incomplete Features | 4 | MEDIUM |
| Data Handling Issues | 3 | MEDIUM |
| **TOTAL** | **19** | |

---

## CRITICAL ISSUES (Fix First)

### BUG-001: Tasks API Returns 500 Error
| Field | Details |
|-------|---------|
| **Severity** | CRITICAL |
| **Location** | `http://localhost:8050/api/tasks` |
| **Problem** | API returns 500 Internal Server Error |
| **Impact** | Tasks page shows empty list |
| **Root Cause** | Database query issue in TaskController |
| **Fix** | Check TaskController.php line 13-26 - likely table/column mismatch |

**Error:** `500 Internal Server Error`
**Test Command:** `curl http://localhost:8050/api/tasks`

---

### BUG-002: Vaccinations API Returns 500 Error
| Field | Details |
|-------|---------|
| **Severity** | CRITICAL |
| **Location** | `http://localhost:8050/api/vaccinations` |
| **Problem** | API returns 500 Internal Server Error |
| **Impact** | Vaccinations page shows demo data only |
| **Fix** | Check VaccinationController.php - table `vaccination_schedules` may not exist |

**Error:** `500 Internal Server Error`
**Test Command:** `curl http://localhost:8050/api/vaccinations`

---

### BUG-003: Medical Records API Returns 500 Error
| Field | Details |
|-------|---------|
| **Severity** | CRITICAL |
| **Location** | `http://localhost:8050/api/medical-records` |
| **Problem** | API returns 500 Internal Server Error |
| **Impact** | Medical Records page shows demo data only |
| **Fix** | Check MedicalRecordController.php - table `medical_records` may not exist |

**Error:** `500 Internal Server Error`
**Test Command:** `curl http://localhost:8050/api/medical-records`

---

### BUG-004: Add Animal Missing Image Picker in Add Modal
| Field | Details |
|-------|---------|
| **Severity** | HIGH |
| **Location** | `lib/animals_page.dart` lines 478-698 |
| **Problem** | Add Animal modal does NOT have an image picker |
| **Expected** | User should be able to add photo when creating animal |
| **Fix** | Add image picker widget to Add modal similar to Edit modal |

---

### BUG-005: Tasks Create Doesn't Actually Create
| Field | Details |
|-------|---------|
| **Severity** | HIGH |
| **Location** | `lib/tasks_page.dart` lines 369-375 |
| **Problem** | Create task button closes modal without saving |
| **Current Code:**
```dart
onPressed: () {
  Navigator.pop(ctx);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Task created')),
  );
},
```
| **Fix** | Add actual API call to create task |

---

### BUG-006: Geofence Create Doesn't Work
| Field | Details |
|-------|---------|
| **Severity** | HIGH |
| **Location** | `lib/map_page.dart` lines 785-793 |
| **Problem** | Create Geofence button just shows error message |
| **Current Code:**
```dart
onPressed: () {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Geofence creation requires polygon drawing on map')),
  );
  Navigator.pop(ctx);
},
```
| **Fix** | Implement actual geofence creation API call |

---

## NAVIGATION ISSUES

### BUG-007: Profile Page Bottom Nav Index Mismatch
| Field | Details |
|-------|---------|
| **Severity** | MEDIUM |
| **Location** | `lib/profile_page.dart` line 25 |
| **Problem** | Profile shows index 4 but profile is actually at position 4 |
| **Issue** | Navigation works but items array expects different order |
| **Fix** | Check bottomNavItems array alignment |

---

### BUG-008: Alerts Page Uses Direct Navigator Instead of PageNavigator
| Field | Details |
|-------|---------|
| **Severity** | MEDIUM |
| **Location** | `lib/alerts_page.dart` lines 260-268 |
| **Problem** | MapPage navigation uses Navigator.push instead of PageNavigator |
| **Fix** | Use consistent navigation approach |

---

### BUG-009: Profile Page Navigation Inconsistency
| Field | Details |
|-------|---------|
| **Severity** | MEDIUM |
| **Location** | `lib/profile_page.dart` lines 116-158 |
| **Problem** | Some menus use Navigator.push, others use PageNavigator |
| **Fix** | Standardize all navigation to use PageNavigator |

---

### BUG-010: Back Button Logic Inconsistent
| Field | Details |
|-------|---------|
| **Severity** | MEDIUM |
| **Location** | Multiple pages using `Navigator.pop(context)` |
| **Problem** | Some pages use Navigator.pop, others check `Navigator.canPop` |
| **Fix** | Consistent back button implementation across all pages |

---

## DATA MISMATCH ISSUES

### BUG-011: Map API Returns `gps_lat`/`gps_lng`, App Expects `latitude`/`longitude`
| Field | Details |
|-------|---------|
| **Severity** | HIGH |
| **Location** | `lib/map_page.dart` lines 150-153 vs `MapController.php` |
| **API Response:** | `gps_lat`, `gps_lng` |
| **Flutter Expects:** | `latitude`, `longitude` |
| **Impact** | Animals don't show on map correctly |
| **Fix** | Update MapController.php to return `latitude`/`longitude` OR update map_page.dart to use `gps_lat`/`gps_lng` |

---

### BUG-012: Map API Returns `animal` Object, App Expects `animal_name`
| Field | Details |
|-------|---------|
| **Severity** | HIGH |
| **Location** | `lib/map_page.dart` line 603 vs `MapController.php` lines 27-30 |
| **API Response:** | `'animal' => ['id' => ..., 'name' => ...]` |
| **Flutter Code:** | `animal['animal_name']` |
| **Fix** | Update Flutter to use `animal['name']` or update API to return `animal_name` |

---

### BUG-013: Medical Record Update Validates `diagnosis`/`treatment` But Creates `description`
| Field | Details |
|-------|---------|
| **Severity** | MEDIUM |
| **Location** | `MedicalRecordController.php` store vs update |
| **Store Request:** | `description` |
| **Update Request:** | `diagnosis`, `treatment` |
| **Impact** | Inconsistent data handling |
| **Fix** | Align field names between store and update |

---

### BUG-014: Vaccination Create Validates `veterinarian` as ID, Flutter Sends as String
| Field | Details |
|-------|---------|
| **Severity** | MEDIUM |
| **Location** | `VaccinationController.php` line 64 vs `vaccination_page.dart` |
| **API Expects:** | Integer user ID for `veterinarian` |
| **Flutter Sends:** | Text input (not linked to users) |
| **Fix** | Add user dropdown in Flutter or change validation |

---

## UI/UX ISSUES

### BUG-015: Dashboard Shows `0` for Tasks Instead of Actual Count
| Field | Details |
|-------|---------|
| **Severity** | LOW |
| **Location** | `lib/dashboard_page.dart` line 374 |
| **Problem** | Tasks count hardcoded as `0` |
| **Code:** | `'value': '0'` |
| **Fix** | Fetch actual tasks count from API |

---

### BUG-016: Create Account Modal Doesn't Actually Create
| Field | Details |
|-------|---------|
| **Severity** | MEDIUM |
| **Location** | `lib/login_page.dart` lines 619-629 |
| **Problem** | Create account just shows snackbar, doesn't call API |
| **Fix** | Add `ApiService.register()` call |

---

### BUG-017: Settings Page Toggles Don't Persist
| Field | Details |
|-------|---------|
| **Severity** | LOW |
| **Location** | `lib/settings_page.dart` lines 12-17 |
| **Problem** | Toggle values stored in local state only |
| **Fix** | Save to SharedPreferences or API |

---

### BUG-018: Animal Details Modal Shows `image` But API Returns `identification_photo`
| Field | Details |
|-------|---------|
| **Severity** | MEDIUM |
| **Location** | `lib/dashboard_page.dart` lines 712-716 |
| **API Field:** | `identification_photo` |
| **Flutter Checks:** | `animal['image']` |
| **Fix** | Change `animal['image']` to `animal['identification_photo']` |

---

### BUG-019: Role Check Inconsistent Across Pages
| Field | Details |
|-------|---------|
| **Severity** | LOW |
| **Location** | Multiple pages check `userRole == 'Admin'` differently |
| **Problem** | Some check `'Admin'`, others use `.toLowerCase()` |
| **Fix** | Standardize to lowercase comparison everywhere |

---

## SUMMARY TABLE FOR DEVELOPER

| # | Severity | Component | Issue | File | Line |
|---|----------|-----------|-------|------|------|
| 1 | CRITICAL | Backend | Tasks API 500 error | TaskController.php | 13 |
| 2 | CRITICAL | Backend | Vaccinations API 500 error | VaccinationController.php | 13 |
| 3 | CRITICAL | Backend | Medical Records API 500 error | MedicalRecordController.php | 13 |
| 4 | HIGH | Flutter | Add modal missing image picker | animals_page.dart | 550 |
| 5 | HIGH | Flutter | Tasks create not working | tasks_page.dart | 369 |
| 6 | HIGH | Flutter | Geofence create not working | map_page.dart | 785 |
| 7 | HIGH | Data | Map lat/lng field mismatch | map_page.dart | 150 |
| 8 | HIGH | Data | Map animal object mismatch | map_page.dart | 603 |
| 9 | MEDIUM | Navigation | Profile nav index | profile_page.dart | 25 |
| 10 | MEDIUM | Navigation | Alerts nav style | alerts_page.dart | 260 |
| 11 | MEDIUM | Navigation | Profile nav style | profile_page.dart | 116 |
| 12 | MEDIUM | Navigation | Back button logic | multiple | - |
| 13 | MEDIUM | Data | Medical record fields | MedicalRecordController.php | 92 |
| 14 | MEDIUM | Data | Vaccination veterinarian | VaccinationController.php | 64 |
| 15 | LOW | UI | Dashboard tasks count | dashboard_page.dart | 374 |
| 16 | MEDIUM | UI | Create account not working | login_page.dart | 619 |
| 17 | LOW | UI | Settings not persisting | settings_page.dart | 12 |
| 18 | MEDIUM | Data | Animal image field | dashboard_page.dart | 712 |
| 19 | LOW | Auth | Role check inconsistency | multiple | - |

---

## RECOMMENDED FIX ORDER

1. **Fix Backend APIs (Bugs 1-3)** - Create tables if missing
2. **Fix Data Mismatches (Bugs 7-8, 13-14, 18)** - Align API/Flutter fields
3. **Fix Critical Features (Bugs 4-6)** - Implement missing functionality
4. **Fix Navigation (Bugs 9-12)** - Consistent navigation
5. **Fix UI Issues (Bugs 15-17, 19)** - Polish

---

## DATABASE TABLES NEEDED

```sql
-- Check if these tables exist
.tables

-- Expected tables:
-- tasks
-- vaccination_schedules  
-- medical_records
-- geofences
-- devices
-- animals
-- users
```

---

**Report Generated:** 2026-04-15
**Next Steps:** Send to Developer for fixes

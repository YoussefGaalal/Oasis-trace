# Oasis Trace - Manual Testing Checklist

## How to Use This Checklist

1. Print this document
2. For each test, mark: **PASS** | **FAIL** | **N/A**
3. Note any issues in the Notes column
4. Report bugs using the Bug Report section

---

## PREREQUISITES

- [ ] Laravel server running: `php artisan serve --port=8050`
- [ ] Flutter app installed on device/emulator
- [ ] Test user credentials available
- [ ] Test data (35 animals, 19 devices) loaded

---

## LAYER 1: AUTHENTICATION

### 1.1 Login Page
| Test | Action | Expected | PASS | FAIL | Notes |
|------|--------|----------|------|------|-------|
| 1.1.1 | Open app | Login page with logo displays | ☐ | ☐ | |
| 1.1.2 | Enter invalid email | Validation error shown | ☐ | ☐ | |
| 1.1.3 | Enter invalid password | Validation error shown | ☐ | ☐ | |
| 1.1.4 | Click Sign In (empty) | Validation error shown | ☐ | ☐ | |
| 1.1.5 | Enter valid credentials | Redirects to Dashboard | ☐ | ☐ | |
| 1.1.6 | Check "Remember me" | Credentials saved | ☐ | ☐ | |

### 1.2 Demo Mode
| Test | Action | Expected | PASS | FAIL | Notes |
|------|--------|----------|------|------|-------|
| 1.2.1 | Tap "Demo Mode" | Direct access to app | ☐ | ☐ | |

### 1.3 Forgot Password
| Test | Action | Expected | PASS | FAIL | Notes |
|------|--------|----------|------|------|-------|
| 1.3.1 | Tap "Forgot Password" | Modal opens | ☐ | ☐ | |
| 1.3.2 | Enter email + Send | Success message | ☐ | ☐ | |

### 1.4 Create Account
| Test | Action | Expected | PASS | FAIL | Notes |
|------|--------|----------|------|------|-------|
| 1.4.1 | Tap "Sign Up" | Modal opens | ☐ | ☐ | |
| 1.4.2 | Fill form + Submit | Account created | ☐ | ☐ | |

---

## LAYER 2: DASHBOARD

| Test | Action | Expected | PASS | FAIL | Notes |
|------|--------|----------|------|------|-------|
| 2.1 | View stats | Animals count visible | ☐ | ☐ | |
| 2.2 | View alerts | Alert count visible | ☐ | ☐ | |
| 2.3 | Tap quick action | Navigate to section | ☐ | ☐ | |
| 2.4 | Bottom nav works | Switch pages | ☐ | ☐ | |
| 2.5 | Back button | Returns to previous | ☐ | ☐ | |

---

## LAYER 3: ANIMALS MODULE

### 3.1 View Animals
| Test | Action | Expected | PASS | FAIL | Notes |
|------|--------|----------|------|------|-------|
| 3.1.1 | Open Animals page | List of animals shown | ☐ | ☐ | |
| 3.1.2 | Scroll list | Load more animals | ☐ | ☐ | |
| 3.1.3 | Tap animal card | Details modal opens | ☐ | ☐ | |

### 3.2 Search & Filter
| Test | Action | Expected | PASS | FAIL | Notes |
|------|--------|----------|------|------|-------|
| 3.2.1 | Search by name | Filter results | ☐ | ☐ | |
| 3.2.2 | Search by ID | Filter results | ☐ | ☐ | |
| 3.2.3 | Tap "Camel" filter | Show only camels | ☐ | ☐ | |
| 3.2.4 | Tap "Goat" filter | Show only goats | ☐ | ☐ | |
| 3.2.5 | Tap "Cow" filter | Show only cows | ☐ | ☐ | |
| 3.2.6 | Tap "All" filter | Show all animals | ☐ | ☐ | |

### 3.3 Sort
| Test | Action | Expected | PASS | FAIL | Notes |
|------|--------|----------|------|------|-------|
| 3.3.1 | Sort by Name | List sorted A-Z | ☐ | ☐ | |
| 3.3.2 | Sort by ID | List sorted by ID | ☐ | ☐ | |
| 3.3.3 | Sort by Species | Grouped by species | ☐ | ☐ | |

### 3.4 Add Animal (Owner/Admin only)
| Test | Action | Expected | PASS | FAIL | Notes |
|------|--------|----------|------|------|-------|
| 3.4.1 | Tap + button | Add modal opens | ☐ | ☐ | |
| 3.4.2 | Enter name | Name field accepts | ☐ | ☐ | |
| 3.4.3 | Select species | Dropdown works | ☐ | ☐ | |
| 3.4.4 | Select breed | Dropdown works | ☐ | ☐ | |
| 3.4.5 | Select gender | Dropdown works | ☐ | ☐ | |
| 3.4.6 | Select device | Dropdown shows devices | ☐ | ☐ | |
| 3.4.7 | Enter color | Field accepts | ☐ | ☐ | |
| 3.4.8 | Add photo | Camera/gallery opens | ☐ | ☐ | |
| 3.4.9 | Save animal | Animal created | ☐ | ☐ | |
| 3.4.10 | View in list | New animal appears | ☐ | ☐ | |

### 3.5 Edit Animal (Owner/Admin only)
| Test | Action | Expected | PASS | FAIL | Notes |
|------|--------|----------|------|------|-------|
| 3.5.1 | Tap edit button | Edit modal opens | ☐ | ☐ | |
| 3.5.2 | Change name | Name updates | ☐ | ☐ | |
| 3.5.3 | Change species | Species updates | ☐ | ☐ | |
| 3.5.4 | Change device | Device reassigned | ☐ | ☐ | |
| 3.5.5 | Add/change photo | **BUG: Photo NOT saved** | ☐ | ☐ | |
| 3.5.6 | Save changes | Changes saved | ☐ | ☐ | |

### 3.6 Delete Animal
| Test | Action | Expected | PASS | FAIL | Notes |
|------|--------|----------|------|------|-------|
| 3.6.1 | Tap delete button | Confirmation shown | ☐ | ☐ | |
| 3.6.2 | Confirm delete | Animal removed | ☐ | ☐ | |
| 3.6.3 | Cancel delete | Animal kept | ☐ | ☐ | |

---

## LAYER 4: DEVICES MODULE

| Test | Action | Expected | PASS | FAIL | Notes |
|------|--------|----------|------|------|-------|
| 4.1 | View devices list | All devices shown | ☐ | ☐ | |
| 4.2 | Add new device | Device created | ☐ | ☐ | |
| 4.3 | Edit device | Updates saved | ☐ | ☐ | |
| 4.4 | Delete device | Device removed | ☐ | ☐ | |
| 4.5 | Assign to animal | Link works | ☐ | ☐ | |

---

## LAYER 5: MAP

| Test | Action | Expected | PASS | FAIL | Notes |
|------|--------|----------|------|------|-------|
| 5.1 | Open Map page | Map loads | ☐ | ☐ | |
| 5.2 | View animal markers | Animals visible | ☐ | ☐ | |
| 5.3 | View geofences | Zones displayed | ☐ | ☐ | |
| 5.4 | Tap marker | Animal info shown | ☐ | ☐ | |

---

## LAYER 6: ALERTS

| Test | Action | Expected | PASS | FAIL | Notes |
|------|--------|----------|------|------|-------|
| 6.1 | View alerts list | Alerts displayed | ☐ | ☐ | |
| 6.2 | Acknowledge alert | Alert removed | ☐ | ☐ | |
| 6.3 | Alert types visible | Geofence, battery, temp | ☐ | ☐ | |

---

## LAYER 7: ROLE-BASED ACCESS

| Test | Login As | Action | Expected | PASS | FAIL |
|------|---------|--------|----------|------|------|
| 7.1 | Owner | View Animals | Add button visible | ☐ | ☐ |
| 7.2 | Owner | View Animals | Edit buttons visible | ☐ | ☐ |
| 7.3 | Admin | View Animals | Add button visible | ☐ | ☐ |
| 7.4 | Manager | View Animals | Add button visible | ☐ | ☐ |
| 7.5 | User | View Animals | Add button HIDDEN | ☐ | ☐ |

---

## BUG REPORTS

### Bug #1: Edit Animal Image Not Saved
**Severity:** HIGH
**Location:** Flutter `animals_page.dart:988-1006`

**Steps to Reproduce:**
1. Go to Animals
2. Tap edit on an animal
3. Tap "Add Photo"
4. Select an image
5. Tap "Save Changes"
6. Re-open edit modal

**Expected:** Photo should be saved
**Actual:** Photo is NOT saved

---

### Bug #2: Add Animal Missing Species Dropdown
**Severity:** MEDIUM
**Location:** Flutter `animals_page.dart:478-698`

**Steps to Reproduce:**
1. Go to Animals
2. Tap + to add animal

**Expected:** Species dropdown should be visible
**Actual:** Species dropdown is MISSING

---

### Bug #3: Species Validation Only Allows 3 Types
**Severity:** MEDIUM
**Location:** Laravel `StoreAnimalRequest.php:19`

**Steps to Reproduce:**
1. Try to create animal with species="Cow"

**Expected:** Cow should be accepted
**Actual:** Validation error - only Camel,Goat,Sheep allowed

---

## TEST SUMMARY

| Layer | Passed | Failed | Total |
|-------|--------|--------|-------|
| 1. Auth | 0 | 0 | 0 |
| 2. Dashboard | 0 | 0 | 0 |
| 3. Animals | 0 | 0 | 0 |
| 4. Devices | 0 | 0 | 0 |
| 5. Map | 0 | 0 | 0 |
| 6. Alerts | 0 | 0 | 0 |
| 7. Roles | 0 | 0 | 0 |
| **TOTAL** | **0** | **0** | **0** |

---

## SIGNATURES

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Tester | | | |
| Reviewer | | | |
| Developer | | | |

---

## FILES GENERATED

| File | Purpose |
|------|---------|
| `TESTING_PLAN.md` | Overall test strategy |
| `MANUAL_CHECKLIST.md` | This checklist |
| `run_tests.py` | Automated API tests |
| `test_log_*.txt` | Test results log |
| `test_results_*.json` | Machine-readable results |

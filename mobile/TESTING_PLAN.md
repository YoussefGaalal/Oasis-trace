# Oasis Trace - Testing Plan

## Overview
Automated testing plan using **CrewAI** (free) for the Life Stock Tracking app.

---

## Tools Setup

### 1. Install CrewAI
```bash
pip install crewai
pip install crewai-tools
```

### 2. Create Test Crew
```bash
mkdir test_crew
cd test_crew
```

---

## Test Execution

### Run All Tests
```bash
cd test_crew
python run_tests.py
```

### View Results
```bash
cat test_results.log
```

---

## Testing Checklist

### Layer 1: Authentication
| Step | Test Case | Expected Result | Status |
|------|-----------|----------------|--------|
| 1.1 | Open app → Login page loads | Logo, form visible | ⏳ |
| 1.2 | Enter invalid credentials | Error message shown | ⏳ |
| 1.3 | Enter valid credentials | Redirect to Dashboard | ⏳ |
| 1.4 | Demo mode login | Direct access to app | ⏳ |
| 1.5 | Forgot password flow | Reset modal opens | ⏳ |
| 1.6 | Create account modal | Registration form opens | ⏳ |
| 1.7 | Register new user | Account created | ⏳ |

### Layer 2: Dashboard
| Step | Test Case | Expected Result | Status |
|------|-----------|----------------|--------|
| 2.1 | Dashboard stats visible | Animals count, alerts shown | ⏳ |
| 2.2 | Quick actions working | Navigate to sections | ⏳ |
| 2.3 | Bottom navigation | Can switch pages | ⏳ |

### Layer 3: Animals Module
| Step | Test Case | Expected Result | Status |
|------|-----------|----------------|--------|
| 3.1 | View animals list | All animals displayed | ⏳ |
| 3.2 | Search by name/ID | Filter works | ⏳ |
| 3.3 | Filter by species | Species chips work | ⏳ |
| 3.4 | Sort animals | Sort options work | ⏳ |
| 3.5 | Add animal (basic) | Modal opens | ⏳ |
| 3.6 | Add animal with all fields | Animal created | ⏳ |
| 3.7 | Add animal with image | Photo uploads | ⏳ |
| 3.8 | Add animal with device | Device assigned | ⏳ |
| 3.9 | View animal details | Details modal shows | ⏳ |
| 3.10 | Edit animal name | Name updates | ⏳ |
| 3.11 | Edit animal species | Species updates | ⏳ |
| 3.12 | Edit animal device | Device changes | ⏳ |
| 3.13 | Edit animal image | **Image NOT saved (BUG)** | ❌ |
| 3.14 | Delete animal | Animal removed | ⏳ |
| 3.15 | Back button navigation | Returns to Dashboard | ⏳ |

### Layer 4: Devices Module
| Step | Test Case | Expected Result | Status |
|------|-----------|----------------|--------|
| 4.1 | View devices list | All devices shown | ⏳ |
| 4.2 | Add new device | Device created | ⏳ |
| 4.3 | Edit device | Updates saved | ⏳ |
| 4.4 | Delete device | Device removed | ⏳ |

### Layer 5: Alerts Module
| Step | Test Case | Expected Result | Status |
|------|-----------|----------------|--------|
| 5.1 | View alerts list | Alerts displayed | ⏳ |
| 5.2 | Acknowledge alert | Alert removed | ⏳ |

### Layer 6: Map Module
| Step | Test Case | Expected Result | Status |
|------|-----------|----------------|--------|
| 6.1 | Open map | Map loads | ⏳ |
| 6.2 | View animal markers | Animals on map | ⏳ |
| 6.3 | View geofences | Zones displayed | ⏳ |

### Layer 7: Role-Based Access
| Step | Test Case | Expected Result | Status |
|------|-----------|----------------|--------|
| 7.1 | Owner login → Add button visible | Yes | ⏳ |
| 7.2 | Owner login → Edit buttons visible | Yes | ⏳ |
| 7.3 | User login → Add button hidden | Yes | ⏳ |

---

## Test Log Format

```
========================================
TEST LOG - Oasis Trace
Date: [TIMESTAMP]
Tester: [NAME]
========================================

[TEST-001] Login with valid credentials
Status: PASS/FAIL
Expected: Redirect to Dashboard
Actual: [WHAT HAPPENED]
Screenshot: [PATH]
Notes: [ANY ISSUES]

[TEST-002] Add Animal with image
Status: PASS/FAIL
Expected: Animal created with photo
Actual: [WHAT HAPPENED]
Screenshot: [PATH]
Notes: [ANY ISSUES]
...
```

---

## Bug Report Template

```
========================================
BUG REPORT
========================================
ID: BUG-001
Date: [DATE]
Tester: [NAME]
Severity: [CRITICAL/HIGH/MEDIUM/LOW]

Test Case: [WHICH TEST FAILED]
Expected: [WHAT SHOULD HAPPEN]
Actual: [WHAT ACTUALLY HAPPENED]

Steps to Reproduce:
1. [STEP 1]
2. [STEP 2]
3. [STEP 3]

Environment:
- Device: [PHYSICAL/EMULATOR]
- OS: [ANDROID/iOS]
- API Server: [RUNNING/NOT RUNNING]

Priority Fix: [YES/NO]
Assigned To: [DEVELOPER NAME]
Status: [OPEN/FIXED/VERIFIED]
========================================
```

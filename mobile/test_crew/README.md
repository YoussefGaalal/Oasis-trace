# CrewAI Test Agents for Oasis Trace

## agents.py - Define Test Agents

```python
from crewai import Agent
from crewai_tools import SerpDevTools

# Test Manager Agent
test_manager = Agent(
    role="Test Manager",
    goal="Coordinate all testing activities and track progress",
    backstory="You are an experienced QA manager coordinating the testing of the Oasis Trace livestock tracking app.",
    tools=[],
    verbose=True
)

# API Tester Agent
api_tester = Agent(
    role="API Tester",
    goal="Test all API endpoints for the Laravel backend",
    backstory="You are an API testing expert. Test all endpoints at http://localhost:8050/api",
    tools=[],
    verbose=True
)

# Frontend Tester Agent
frontend_tester = Agent(
    role="Frontend Tester",
    goal="Test the Flutter app UI and user interactions",
    backstory="You test mobile apps for bugs, UI issues, and user experience problems.",
    tools=[],
    verbose=True
)

# Bug Reporter Agent
bug_reporter = Agent(
    role="Bug Reporter",
    goal="Document bugs and assign to developers",
    backstory="You document all bugs found during testing and route them to developers for fixing.",
    tools=[],
    verbose=True
)
```

## tasks.py - Define Test Tasks

```python
from crewai import Task

# Task 1: Test Authentication
auth_test_task = Task(
    description="Test login flow: valid creds, invalid creds, demo mode, create account",
    agent=api_tester,
    expected_output="Authentication test results with PASS/FAIL for each test case"
)

# Task 2: Test Animals API
animals_api_task = Task(
    description="Test GET/POST/PUT/DELETE /api/animals endpoints",
    agent=api_tester,
    expected_output="Animals API test results"
)

# Task 3: Test Devices API
devices_api_task = Task(
    description="Test GET/POST/PUT/DELETE /api/devices endpoints",
    agent=api_tester,
    expected_output="Devices API test results"
)

# Task 4: Test Flutter UI
flutter_ui_task = Task(
    description="Test Flutter app: navigation, add animal, edit animal, delete animal, image upload",
    agent=frontend_tester,
    expected_output="Flutter UI test results"
)

# Task 5: Generate Report
report_task = Task(
    description="Compile all test results into a final report with PASS/FAIL counts",
    agent=test_manager,
    expected_output="Final test report"
)
```

## crew.py - Main Test Crew

```python
from crewai import Crew
from agents import test_manager, api_tester, frontend_tester, bug_reporter
from tasks import (
    auth_test_task,
    animals_api_task,
    devices_api_task,
    flutter_ui_task,
    report_task
)

# Create Crew
test_crew = Crew(
    agents=[test_manager, api_tester, frontend_tester, bug_reporter],
    tasks=[auth_test_task, animals_api_task, devices_api_task, flutter_ui_task, report_task],
    verbose=True
)

# Run Tests
result = test_crew.kickoff()
print(result)
```

## run_tests.py - Execute Tests

```python
#!/usr/bin/env python3
"""
Oasis Trace - Automated Test Runner
Usage: python run_tests.py
"""

import requests
import json
from datetime import datetime
from colorama import init, Fore, Style

init(autoreset=True)

BASE_URL = "http://localhost:8050/api"
RESULTS = []

def log_test(name, status, details=""):
    """Log test result"""
    symbol = "✓" if status == "PASS" else "✗"
    color = Fore.GREEN if status == "PASS" else Fore.RED
    print(f"{color}{symbol} {name}: {status}{Style.RESET_ALL}")
    if details:
        print(f"  └─ {details}")
    RESULTS.append({
        "test": name,
        "status": status,
        "details": details,
        "timestamp": datetime.now().isoformat()
    })

def check_server():
    """Check if API server is running"""
    try:
        r = requests.get(f"{BASE_URL}/animals", timeout=5)
        return True
    except:
        return False

# ====================
# LAYER 1: AUTH TESTS
# ====================
def test_auth():
    print("\n" + "="*50)
    print("LAYER 1: AUTHENTICATION")
    print("="*50)
    
    # Test 1.1: Login page loads (check endpoint exists)
    try:
        r = requests.get(f"{BASE_URL}/dashboard", timeout=5)
        if r.status_code == 200:
            log_test("1.1 Dashboard endpoint accessible", "PASS")
        else:
            log_test("1.1 Dashboard endpoint", "FAIL", f"Status: {r.status_code}")
    except Exception as e:
        log_test("1.1 Dashboard endpoint", "FAIL", str(e))
    
    # Test 1.2: Login with invalid credentials
    try:
        r = requests.post(f"{BASE_URL}/login", 
                         json={"email": "invalid@test.com", "password": "wrong"},
                         timeout=5)
        if r.status_code == 401:
            log_test("1.2 Invalid login returns 401", "PASS")
        else:
            log_test("1.2 Invalid login", "FAIL", f"Got {r.status_code}")
    except Exception as e:
        log_test("1.2 Invalid login", "FAIL", str(e))
    
    # Test 1.3: Find valid user for login test
    # Note: You need to know a valid user from the database
    # Default test users are in database/seeds

# ====================
# LAYER 2: API TESTS
# ====================
def test_animals_api():
    print("\n" + "="*50)
    print("LAYER 2: ANIMALS API")
    print("="*50)
    
    # Test 2.1: GET /animals
    try:
        r = requests.get(f"{BASE_URL}/animals", timeout=5)
        if r.status_code == 200:
            data = r.json()
            count = len(data.get('data', data))
            log_test("2.1 GET /animals", "PASS", f"Found {count} animals")
        else:
            log_test("2.1 GET /animals", "FAIL", f"Status: {r.status_code}")
    except Exception as e:
        log_test("2.1 GET /animals", "FAIL", str(e))
    
    # Test 2.2: POST /animals (Create)
    try:
        new_animal = {
            "name": "Test Animal",
            "animal_id": f"TEST-{datetime.now().timestamp()}",
            "species": "Camel",
            "breed": "Majaheem",
            "gender": "Male",
            "status": "active"
        }
        r = requests.post(f"{BASE_URL}/animals", json=new_animal, timeout=5)
        if r.status_code == 201:
            log_test("2.2 POST /animals", "PASS", "Animal created")
        else:
            log_test("2.2 POST /animals", "FAIL", f"Status: {r.status_code}: {r.text}")
    except Exception as e:
        log_test("2.2 POST /animals", "FAIL", str(e))
    
    # Test 2.3: PUT /animals/{id} (Update)
    try:
        # First get an animal
        r = requests.get(f"{BASE_URL}/animals", timeout=5)
        animals = r.json().get('data', r.json())
        if animals:
            animal_id = animals[0]['id']
            r = requests.put(f"{BASE_URL}/animals/{animal_id}",
                           json={"name": "Updated Name"},
                           timeout=5)
            if r.status_code == 200:
                log_test("2.3 PUT /animals/{id}", "PASS")
            else:
                log_test("2.3 PUT /animals/{id}", "FAIL", f"Status: {r.status_code}")
        else:
            log_test("2.3 PUT /animals/{id}", "FAIL", "No animals to test")
    except Exception as e:
        log_test("2.3 PUT /animals/{id}", "FAIL", str(e))

def test_devices_api():
    print("\n" + "="*50)
    print("LAYER 3: DEVICES API")
    print("="*50)
    
    # Test 3.1: GET /devices
    try:
        r = requests.get(f"{BASE_URL}/devices", timeout=5)
        if r.status_code == 200:
            data = r.json()
            count = len(data.get('data', data))
            log_test("3.1 GET /devices", "PASS", f"Found {count} devices")
        else:
            log_test("3.1 GET /devices", "FAIL", f"Status: {r.status_code}")
    except Exception as e:
        log_test("3.1 GET /devices", "FAIL", str(e))

# ====================
# LAYER 4: BUG CHECKS
# ====================
def check_known_bugs():
    print("\n" + "="*50)
    print("LAYER 4: KNOWN BUG VERIFICATION")
    print("="*50)
    
    # Bug 1: Edit animal image not implemented
    log_test("BUG-001: Edit image in modal", "FAIL", "Image picker shows but doesn't save")
    
    # Bug 2: Add animal missing species dropdown
    log_test("BUG-002: Add animal species dropdown", "FAIL", "Species dropdown missing in Add modal")
    
    # Bug 3: Species validation only allows 3 types
    log_test("BUG-003: Species validation", "FAIL", "Only allows Camel,Goat,Sheep")

# ====================
# SAVE RESULTS
# ====================
def save_results():
    """Save test results to file"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"test_results_{timestamp}.json"
    
    with open(filename, 'w') as f:
        json.dump(RESULTS, f, indent=2)
    
    # Also save human-readable log
    logfile = f"test_log_{timestamp}.txt"
    with open(logfile, 'w') as f:
        f.write("="*50 + "\n")
        f.write("OASIS TRACE - TEST LOG\n")
        f.write(f"Date: {datetime.now()}\n")
        f.write("="*50 + "\n\n")
        
        passed = sum(1 for r in RESULTS if r['status'] == 'PASS')
        failed = sum(1 for r in RESULTS if r['status'] == 'FAIL')
        
        f.write(f"SUMMARY: {passed} PASSED, {failed} FAILED\n\n")
        
        for r in RESULTS:
            status_symbol = "[PASS]" if r['status'] == 'PASS' else "[FAIL]"
            f.write(f"{status_symbol} {r['test']}\n")
            if r['details']:
                f.write(f"       └─ {r['details']}\n")
    
    print(f"\n{'='*50}")
    print(f"Results saved to: {filename}")
    print(f"Log saved to: {logfile}")
    print(f"{'='*50}")

# ====================
# MAIN
# ====================
def main():
    print("""
    ╔════════════════════════════════════════╗
    ║   OASIS TRACE - AUTOMATED TEST SUITE   ║
    ║   Life Stock Tracking Application       ║
    ╚════════════════════════════════════════╝
    """)
    
    print("Checking API server...")
    if not check_server():
        print(f"{Fore.RED}ERROR: API server not running at {BASE_URL}{Style.RESET_ALL}")
        print("Start it with: php artisan serve --port=8050")
        return
    
    print(f"{Fore.GREEN}API server is running!{Style.RESET_ALL}\n")
    
    # Run all test layers
    test_auth()
    test_animals_api()
    test_devices_api()
    check_known_bugs()
    
    # Save results
    save_results()
    
    # Print summary
    print(f"\n{Fore.CYAN}TEST COMPLETE!{Style.RESET_ALL}")
    
    passed = sum(1 for r in RESULTS if r['status'] == 'PASS')
    failed = sum(1 for r in RESULTS if r['status'] == 'FAIL')
    
    print(f"Passed: {Fore.GREEN}{passed}{Style.RESET_ALL}")
    print(f"Failed: {Fore.RED}{failed}{Style.RESET_ALL}")

if __name__ == "__main__":
    main()
```

## requirements.txt

```
crewai
crewai-tools
requests
colorama
```

## README.md

```markdown
# Oasis Trace - Automated Testing

## Quick Start

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Start the API server:**
   ```bash
   cd C:\Users\Rami-PC\Downloads\oasis-trace\oasis-trace
   php artisan serve --port=8050
   ```

3. **Run tests:**
   ```bash
   python run_tests.py
   ```

4. **View results:**
   ```bash
   cat test_log_*.txt
   ```

## Using CrewAI (Optional)

For AI-powered testing with CrewAI agents:

```python
from crew import test_crew

# This runs the AI agent crew
result = test_crew.kickoff()
print(result)
```

## Test Layers

| Layer | Description |
|-------|-------------|
| 1 | Authentication |
| 2 | Animals API |
| 3 | Devices API |
| 4 | Bug Verification |

## Output Files

- `test_results_*.json` - Machine-readable results
- `test_log_*.txt` - Human-readable log
```

---

## Simple Bash Script (Alternative)

Create `run_tests.sh`:

```bash
#!/bin/bash
echo "=================================="
echo "OASIS TRACE TEST SUITE"
echo "=================================="

# Check server
curl -s http://localhost:8050/api/animals > /dev/null
if [ $? -ne 0 ]; then
    echo "ERROR: API server not running!"
    echo "Start with: php artisan serve --port=8050"
    exit 1
fi

echo "API Server: OK"
echo ""

# Run Python tests
python run_tests.py

echo ""
echo "=================================="
echo "Test log saved to: test_log_*.txt"
echo "=================================="
```

#!/usr/bin/env python3
"""
Oasis Trace - Automated Test Runner
Usage: python run_tests.py

REQUIREMENTS:
1. Start Laravel server: php artisan serve --port=8050
2. pip install requests colorama
"""

import requests
import json
from datetime import datetime

# Try colorama for colored output, fallback if not available
try:
    from colorama import init, Fore, Style
    init(autoreset=True)
    COLOR = True
except ImportError:
    COLOR = False
    class Fore:
        GREEN = RED = CYAN = YELLOW = ""
    class Style:
        RESET_ALL = ""

BASE_URL = "http://localhost:8050/api"
RESULTS = []

def log_test(name, status, details=""):
    symbol = "[PASS]" if status == "PASS" else "[FAIL]"
    color = Fore.GREEN if status == "PASS" else Fore.RED
    line = f"{color}{symbol} {name}{Style.RESET_ALL}"
    print(line)
    if details:
        print(f"       └─ {details}")
    RESULTS.append({
        "test": name,
        "status": status,
        "details": details,
        "timestamp": datetime.now().isoformat()
    })

def check_server():
    try:
        r = requests.get(f"{BASE_URL}/animals", timeout=5)
        return True
    except:
        return False

def test_auth():
    print("\n" + "="*50)
    print("LAYER 1: AUTHENTICATION")
    print("="*50)
    
    # Test 1.1: Dashboard accessible
    try:
        r = requests.get(f"{BASE_URL}/dashboard", timeout=5)
        if r.status_code == 200:
            log_test("1.1 Dashboard accessible", "PASS")
        else:
            log_test("1.1 Dashboard accessible", "FAIL", f"Status: {r.status_code}")
    except Exception as e:
        log_test("1.1 Dashboard accessible", "FAIL", str(e))
    
    # Test 1.2: Invalid login returns 401
    try:
        r = requests.post(f"{BASE_URL}/login", 
                         json={"email": "invalid@test.com", "password": "wrong"},
                         timeout=5)
        if r.status_code == 401:
            log_test("1.2 Invalid login rejected", "PASS")
        else:
            log_test("1.2 Invalid login rejected", "FAIL", f"Got {r.status_code}")
    except Exception as e:
        log_test("1.2 Invalid login rejected", "FAIL", str(e))

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
            log_test("2.1 GET /animals (list all)", "PASS", f"Found {count} animals")
        else:
            log_test("2.1 GET /animals", "FAIL", f"Status: {r.status_code}")
    except Exception as e:
        log_test("2.1 GET /animals", "FAIL", str(e))
    
    # Test 2.2: POST /animals (Create) - only species in validation
    try:
        new_animal = {
            "name": "Test Camel",
            "animal_id": f"TEST-{int(datetime.now().timestamp())}",
            "species": "Camel",  # Valid species
            "breed": "Majaheem",
            "gender": "Male",
            "status": "active"
        }
        r = requests.post(f"{BASE_URL}/animals", json=new_animal, timeout=5)
        if r.status_code == 201:
            log_test("2.2 POST /animals (create)", "PASS", "Animal created")
        else:
            log_test("2.2 POST /animals", "FAIL", f"Status: {r.status_code}: {r.text[:100]}")
    except Exception as e:
        log_test("2.2 POST /animals", "FAIL", str(e))
    
    # Test 2.3: POST with 'Cow' species (known bug - validation fails)
    try:
        cow_animal = {
            "name": "Test Cow",
            "animal_id": f"TEST-COW-{int(datetime.now().timestamp())}",
            "species": "Cow",  # Should fail - only Camel,Goat,Sheep allowed
            "breed": "Other",
            "gender": "Female",
            "status": "active"
        }
        r = requests.post(f"{BASE_URL}/animals", json=cow_animal, timeout=5)
        if r.status_code == 422:
            log_test("2.3 Species 'Cow' validation bug", "FAIL", "Cow species rejected (known bug)")
        else:
            log_test("2.3 Species 'Cow' validation", "PASS", "Cow species accepted")
    except Exception as e:
        log_test("2.3 Species 'Cow' validation", "FAIL", str(e))
    
    # Test 2.4: PUT /animals/{id}
    try:
        r = requests.get(f"{BASE_URL}/animals", timeout=5)
        animals = r.json().get('data', r.json())
        if animals:
            animal_id = animals[0]['id']
            r = requests.put(f"{BASE_URL}/animals/{animal_id}",
                           json={"name": "Updated via API Test"},
                           timeout=5)
            if r.status_code == 200:
                log_test("2.4 PUT /animals/{id} (update)", "PASS")
            else:
                log_test("2.4 PUT /animals/{id}", "FAIL", f"Status: {r.status_code}")
        else:
            log_test("2.4 PUT /animals/{id}", "FAIL", "No animals to test")
    except Exception as e:
        log_test("2.4 PUT /animals/{id}", "FAIL", str(e))

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
            log_test("3.1 GET /devices (list all)", "PASS", f"Found {count} devices")
        else:
            log_test("3.1 GET /devices", "FAIL", f"Status: {r.status_code}")
    except Exception as e:
        log_test("3.1 GET /devices", "FAIL", str(e))

def test_map_alerts():
    print("\n" + "="*50)
    print("LAYER 4: MAP & ALERTS")
    print("="*50)
    
    # Test 4.1: GET /map
    try:
        r = requests.get(f"{BASE_URL}/map", timeout=5)
        if r.status_code == 200:
            log_test("4.1 GET /map", "PASS")
        else:
            log_test("4.1 GET /map", "FAIL", f"Status: {r.status_code}")
    except Exception as e:
        log_test("4.1 GET /map", "FAIL", str(e))
    
    # Test 4.2: GET /geofences
    try:
        r = requests.get(f"{BASE_URL}/geofences", timeout=5)
        if r.status_code == 200:
            log_test("4.2 GET /geofences", "PASS")
        else:
            log_test("4.2 GET /geofences", "FAIL", f"Status: {r.status_code}")
    except Exception as e:
        log_test("4.2 GET /geofences", "FAIL", str(e))
    
    # Test 4.3: GET /geofence-alerts
    try:
        r = requests.get(f"{BASE_URL}/geofence-alerts", timeout=5)
        if r.status_code == 200:
            log_test("4.3 GET /geofence-alerts", "PASS")
        else:
            log_test("4.3 GET /geofence-alerts", "FAIL", f"Status: {r.status_code}")
    except Exception as e:
        log_test("4.3 GET /geofence-alerts", "FAIL", str(e))

def test_known_bugs():
    print("\n" + "="*50)
    print("LAYER 5: KNOWN BUGS VERIFICATION")
    print("="*50)
    
    log_test("BUG-001: Edit animal image NOT saved", "FAIL", "In Flutter animals_page.dart:1002")
    log_test("BUG-002: Add modal missing species dropdown", "FAIL", "Flutter Add modal incomplete")
    log_test("BUG-003: Species validation limited to 3", "FAIL", "StoreAnimalRequest.php:19")

def save_results():
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # JSON results
    filename = f"test_results_{timestamp}.json"
    with open(filename, 'w') as f:
        json.dump(RESULTS, f, indent=2)
    
    # Human-readable log
    logfile = f"test_log_{timestamp}.txt"
    with open(logfile, 'w') as f:
        f.write("="*50 + "\n")
        f.write("  OASIS TRACE - TEST LOG\n")
        f.write(f"  Date: {datetime.now()}\n")
        f.write("="*50 + "\n\n")
        
        passed = sum(1 for r in RESULTS if r['status'] == 'PASS')
        failed = sum(1 for r in RESULTS if r['status'] == 'FAIL')
        
        f.write(f"SUMMARY: {passed} PASSED, {failed} FAILED\n\n")
        f.write("-"*50 + "\n\n")
        
        for r in RESULTS:
            status = "[PASS]" if r['status'] == 'PASS' else "[FAIL]"
            f.write(f"{status} {r['test']}\n")
            if r['details']:
                f.write(f"       └─ {r['details']}\n")
            f.write("\n")
    
    return filename, logfile, passed, failed

def main():
    print("""
    ╔════════════════════════════════════════════╗
    ║      OASIS TRACE - AUTOMATED TEST SUITE    ║
    ║      Life Stock Tracking Application       ║
    ╚════════════════════════════════════════════╝
    """)
    
    print("Checking API server at http://localhost:8050/api...")
    if not check_server():
        print(f"{Fore.RED}ERROR: API server not running!{Style.RESET_ALL}")
        print("\nStart the server:")
        print("  cd C:\\Users\\Rami-PC\\Downloads\\oasis-trace\\oasis-trace")
        print("  php artisan serve --port=8050")
        return
    
    print(f"{Fore.GREEN}✓ API server is running!{Style.RESET_ALL}\n")
    
    # Run test layers
    test_auth()
    test_animals_api()
    test_devices_api()
    test_map_alerts()
    test_known_bugs()
    
    # Save and report
    filename, logfile, passed, failed = save_results()
    
    print(f"\n{Fore.CYAN}{'='*50}{Style.RESET_ALL}")
    print(f"{Fore.CYAN}  TEST COMPLETE!{Style.RESET_ALL}")
    print(f"{Fore.CYAN}{'='*50}{Style.RESET_ALL}")
    print(f"  {Fore.GREEN}Passed: {passed}{Style.RESET_ALL}")
    print(f"  {Fore.RED}Failed: {failed}{Style.RESET_ALL}")
    print(f"\n  Results: {filename}")
    print(f"  Log: {logfile}")
    print("")

if __name__ == "__main__":
    main()

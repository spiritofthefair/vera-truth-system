import requests

log_path = "/workspace/vera-truth-system/logs/endpoint_check.log"

# Most likely endpoint variations
endpoints = [
    "https://dashboard.aia-system.com/api/v1/gpts/invoke/",
    "https://dashboard.aia-system.com/api/v1/gpt/invoke/",
    "https://dashboard.aia-system.com/api/v1/invoke/",
    "https://dashboard.aia-system.com/v1/gpts/invoke/",
    "https://dashboard.aia-system.com/gpts/invoke/"
]

def log(msg):
    with open(log_path, "a", encoding="utf-8") as f:
        f.write(msg + "\n")

log("==== BEGIN ENDPOINT SCAN ====")

for url in endpoints:
    try:
        response = requests.get(url, timeout=8)
        log(f"[{url}] → {response.status_code}")
        if "application/json" in response.headers.get("Content-Type", ""):
            log(f"✅ JSON response confirmed at: {url}")
        elif "text/html" in response.headers.get("Content-Type", ""):
            log(f"⚠️ HTML response: likely 404 or redirect")
    except Exception as e:
        log(f"❌ {url} → ERROR: {str(e)}")

log("==== END SCAN ====")
print("✅ Endpoint scan complete. Check: /logs/endpoint_check.log")

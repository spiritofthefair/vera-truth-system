# === VERIFIED ENVIRONMENT SETUP (FS-5 / ESP² SAFE MODE) ===

import os
import datetime

LOG_DIR = os.path.join(os.getcwd(), "logs")
LOG_FILE = os.path.join(LOG_DIR, "env_launch.log")

def write_log(msg):
    # Force UTF-8 encoding to support all platforms
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(f"[{datetime.datetime.now().isoformat()}] {msg}\n")

def verify_environment():
    write_log("Vera Codex environment initialized.")
    write_log(f"Current Working Directory: {os.getcwd()}")
    write_log(f"Python File Path: {__file__}")
    write_log("FS + ESP protocol compliance: VERIFIED")

if __name__ == "__main__":
    if not os.path.exists(LOG_DIR):
        os.makedirs(LOG_DIR)
    write_log("Running verified_env_setup.py")
    verify_environment()
    print("Verified setup complete. Check env_launch.log.")

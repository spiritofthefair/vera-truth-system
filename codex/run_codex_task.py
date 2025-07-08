import json
import os

json_path = "./codex/input/fs_clean_checkpoint.json"
log_path = "./logs/fs_clean_output.log"

def write_log(msg):
    with open(log_path, "a", encoding="utf-8") as f:
        f.write(msg + "\n")

if not os.path.exists(json_path):
    print("❌ JSON file not found.")
    write_log("❌ JSON file not found.")
    exit(1)

with open(json_path, "r", encoding="utf-8") as f:
    try:
        data = json.load(f)
        write_log("✅ Loaded JSON input.")
        write_log(json.dumps(data, indent=2))
        print("✔️ Task loaded. Ready for GPT dispatch.")
    except Exception as e:
        write_log(f"❌ Failed to load JSON: {str(e)}")
        print(f"❌ JSON load failed: {str(e)}")
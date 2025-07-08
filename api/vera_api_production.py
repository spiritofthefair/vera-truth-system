from flask import Flask, request, jsonify
import os
import json
from datetime import datetime

app = Flask(__name__)

print("\n✅ Vera API starting...")
print("✅ /api/gpt-instruction route registered\n")
print("🧠 ACTIVE: canvas version running")

AUTHORIZED_KEYS = set(os.getenv("AUTHORIZED_KEYS", "VERA_GPT_KEY_9283").split(","))

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "healthy",
        "service": "vera-api",
        "version": "1.0.0",
        "timestamp": datetime.utcnow().isoformat() + "Z"
    })

@app.route('/api/gpt-instruction', methods=['POST'])
def receive_instruction():
    print("📥 Received POST request at /api/gpt-instruction")

    auth_header = request.headers.get("Authorization")
    print(f"🔐 Authorization header: {auth_header}")
    if not auth_header or not auth_header.startswith("Bearer "):
        return jsonify({"status": "unauthorized", "message": "Missing or invalid Authorization header"}), 401

    token = auth_header.split(" ")[1].strip()
    if token not in AUTHORIZED_KEYS:
        print("🚫 Invalid API token")
        return jsonify({"status": "unauthorized", "message": "Invalid API token"}), 403

    data = request.get_json()
    if not data:
        return jsonify({"status": "error", "message": "No JSON body provided"}), 400

    print(f"📦 Payload received: {json.dumps(data, indent=2)}")

    filename = f"{data.get('name', 'unnamed')}_{datetime.utcnow().strftime('%Y%m%dT%H%M%S')}.json"
    output_dir = r"E:\\LocalClone\\Vera\\vera-truth-system\\logs\\instructions"
    os.makedirs(output_dir, exist_ok=True)
    full_path = os.path.join(output_dir, filename)

    with open(full_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)

    print(f"✅ Instruction saved: {full_path}")
    return jsonify({
        "status": "success",
        "message": f"Instruction saved to {full_path}",
        "filename": filename
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

from pymongo import MongoClient
from datetime import datetime

client = MongoClient("mongodb://localhost:27017/")
db = client["swiftpay_nosql"]
logs_collection = db["user_activity_logs"]

# Log insertion snippet
new_log = {
    "customer_id": 10492,
    "device_info": {"device_id": "DEV_IOS_98234", "device_type": "Mobile", "os": "iOS 18.2"},
    "session_metadata": {"ip_address": "192.168.1.45", "login_timestamp": datetime.utcnow()},
    "activity_events": [
        {"event_id": "EVT_7723", "action": "UPDATE_PROFILE", "timestamp": datetime.utcnow()}
    ]
}

result = logs_collection.insert_one(new_log)
print(f"Inserted document ID: {result.inserted_id}")
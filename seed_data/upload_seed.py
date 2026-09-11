import json
import urllib.request
import urllib.error
import time

API_KEY = "AIzaSyCZcapZ_Ur24GWuss8BiqzWJnnp7YxMBNw"
EMAIL = "ccut5122@gmail.com"
PASSWORD = "@Abhishek0"
PROJECT = "alexa-arts-classes"
BASE = f"https://firestore.googleapis.com/v1/projects/{PROJECT}/databases/(default)/documents"


def get_token():
    req = urllib.request.Request(
        f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={API_KEY}",
        data=json.dumps({
            "email": EMAIL,
            "password": PASSWORD,
            "returnSecureToken": True,
        }).encode(),
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req) as resp:
        return json.load(resp)["idToken"]


def to_fields(value):
    if isinstance(value, bool):
        return {"booleanValue": value}
    if isinstance(value, int) and not isinstance(value, bool):
        return {"integerValue": str(value)}
    if isinstance(value, float):
        return {"doubleValue": value}
    if isinstance(value, str):
        return {"stringValue": value}
    if isinstance(value, list):
        return {"arrayValue": {"values": [to_fields(v) for v in value]}}
    if isinstance(value, dict):
        return {"mapValue": {"fields": {k: to_fields(v) for k, v in value.items()}}}
    if value is None:
        return {"nullValue": None}
    return {"stringValue": str(value)}


def load_data():
    with open("alexa_seed.json", encoding="utf-8") as f:
        return json.load(f)


def load_extra():
    with open("extra_seed.json", encoding="utf-8") as f:
        return json.load(f)


def load_extra_questions():
    with open("extra_questions.json", encoding="utf-8") as f:
        return json.load(f)


def upsert(collection, doc_id, data, token, batch_id=""):
    url = f"{BASE}/{collection}/{doc_id}"
    body = json.dumps({
        "fields": {k: to_fields(v) for k, v in data.items()}
    }).encode()
    req = urllib.request.Request(
        url,
        data=body,
        method="PATCH",
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req) as resp:
            return resp.status
    except urllib.error.HTTPError as e:
        msg = e.read().decode()[:300]
        print(f"  [{batch_id}{doc_id}] ERROR {e.code}: {msg}")
        return e.code


def main():
    token = get_token()
    data = load_data()

    print("Uploading subjects...")
    for s in data["subjects"]:
        fields = {k: v for k, v in s.items() if k != "_id"}
        status = upsert("subjects", s["_id"], fields, token)
        print(f"  {s['_id']}: {status}")

    print("Uploading chapters...")
    for c in data["chapters"]:
        fields = {k: v for k, v in c.items() if k != "_id"}
        status = upsert("chapters", c["_id"], fields, token)
        print(f"  {c['_id']}: {status}")

    print("Uploading notes...")
    for n in data["notes"]:
        fields = {k: v for k, v in n.items() if k != "_id"}
        status = upsert("notes", n["_id"], fields, token)
        print(f"  {n['_id']}: {status}")

    print("Uploading questions...")
    for q in data["questions"]:
        fields = {k: v for k, v in q.items() if k != "_id"}
        status = upsert("questions", q["_id"], fields, token)
        print(f"  {q['_id']}: {status}")

    print("Uploading extra seed (dictionary/badges/dynamicConfig)...")
    extra = load_extra()

    for entry in extra["dictionary"]:
        fields = {k: v for k, v in entry.items() if k != "_id"}
        doc_id = entry.get("_id") or entry["term"].lower().replace(" ", "_")
        status = upsert("dictionary", doc_id, fields, token)
        print(f"  dict/{doc_id}: {status}")

    for b in extra["badges"]:
        fields = {k: v for k, v in b.items() if k != "_id"}
        status = upsert("badges", b["_id"], fields, token)
        print(f"  badge/{b['_id']}: {status}")

    for c in extra["dynamicConfig"]:
        fields = {k: v for k, v in c.items() if k != "_id"}
        status = upsert("dynamicConfig", c["_id"], fields, token)
        print(f"  config/{c['_id']}: {status}")

    print("Uploading extra questions...")
    eq = load_extra_questions()
    for q in eq:
        fields = {k: v for k, v in q.items() if k != "_id"}
        status = upsert("questions", q["_id"], fields, token)
        if status != 200:
            print(f"  {q['_id']}: {status}")

    print("Done.")


if __name__ == "__main__":
    main()
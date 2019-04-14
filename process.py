import json
import pulsar

client = pulsar.Client('pulsar://localhost:6650')
consumer = client.subscribe('my-topic4',
                            subscription_name='my-sub1')

EVENT = ["INSERT", "DELETE", "UPDATE"]

def get_keys(columns):
    keys = []
    for column in columns:
        if column["isKey"] == "1":
            keys.append(column["columnName"])
    return keys

EVENT = ["INSERT", "DELETE", "UPDATE"]

def process(msg):
    message_id = msg.message_id
    messages = json.loads(msg.data())
    result = []
    for m in messages:
        if m["type"] in EVENT:
            key = get_keys(m["data"])
            print("event id: %d event type:%s execute time: %f database: %s table: %s, primary keys: %s columns: %s oldColumns: %s" %
                (message_id, m["type"], m["es"], m["database"], m["table"], str(keys), m["data"], m["old"]))
            result.append("_".join([message_id, m["type"], m["es"], m["database"], m["table"], str(keys), m["data"], m["old"]]))

    return "\n".join(result)

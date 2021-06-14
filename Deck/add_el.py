import json

def get_type(action, effect):
    type_id = 0
    if "upgrade" in effect or action == '':
        type_id = 1
    if "convert" in action:
        type_id = 2
    elif "archive" in action:
        type_id = 3
    elif "pick" in action:
        type_id = 4
    elif "build" in action:
        type_id = 5
    return type_id


def get_vp(cost):
    sum = 0
    for energy in cost:
        sum += energy
    if sum > 7:
        return 0
    return sum


with open('new_json.json') as f:
    data = json.load(f)
    for i in range(0, 108):
        card = data[str(i)]
        type_id = get_type(card['action'], card['effect'])
        card['type_id'] = type_id
        vp = get_vp(card['cost'])
        card['vp'] = vp
        print(card)
    with open('deck_json.json', 'w') as outfile:
        json.dump(data, outfile)
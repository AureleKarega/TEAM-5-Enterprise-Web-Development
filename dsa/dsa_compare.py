# dsa/dsa_compare.py
import time, random
from pathlib import Path
from dsa.parse_xml import parse_xml_to_list

def linear_search(records, target_id):
    for r in records:
        if str(r.get('id')) == str(target_id):
            return r
    return None

def dict_build(records):
    return {str(r['id']): r for r in records}

def dict_lookup(dct, target_id):
    return dct.get(str(target_id))

if __name__ == '__main__':
    xml_path = Path(__file__).parent.parent / 'modified_sms_v2.xml'
    try:
        records = parse_xml_to_list(str(xml_path))
    except Exception as e:
        print("Parser error, using synthetic:", e)
        records = [{'id': str(i+1)} for i in range(100)]
    if len(records) < 20:
        records += [{'id': str(i+1+len(records))} for i in range(20 - len(records))]

    ids = [random.choice(records)['id'] for _ in range(20)]

    t0 = time.perf_counter()
    for k in ids:
        linear_search(records, k)
    t1 = time.perf_counter()

    d = dict_build(records)
    t2 = time.perf_counter()
    for k in ids:
        dict_lookup(d, k)
    t3 = time.perf_counter()

    print(f'Linear search (20 lookups): {t1 - t0:.6f}s')
    print(f'Dict build time: {t2 - t1:.6f}s')
    print(f'Dict lookup (20 lookups): {t3 - t2:.6f}s')

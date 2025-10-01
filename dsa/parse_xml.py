# dsa/parse_xml.py
import xml.etree.ElementTree as ET
import json
import re
from typing import Dict, Any, Optional

AMT = r'([0-9][0-9,\.]*)\s*RWF'

def _to_float(text: Optional[str]) -> Optional[float]:
    if not text:
        return None
    t = text.replace(',', '').strip()
    try:
        return float(t)
    except Exception:
        return None

def _parse_body(body: str) -> Dict[str, Any]:
    d: Dict[str, Any] = {'raw_text': body}
    text = re.sub(r'\s+', ' ', body).strip()

    m_ftx = re.search(r'Financial Transaction Id:\s*([0-9]+)', text, re.I)
    if m_ftx:
        d['financial_tx_id'] = m_ftx.group(1)

    m_bal = re.search(r'new balance\s*[:]?[\s]*' + AMT, text, re.I)
    if m_bal:
        d['new_balance'] = _to_float(m_bal.group(1))

    m_dt = re.search(r'(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})', text)
    if m_dt:
        d['when_text'] = m_dt.group(1)

    m_recv = re.search(r'You have received\s*' + AMT + r'\s*from\s*([^()]+)', text, re.I)
    if m_recv:
        d['transaction_type'] = 'receive'
        d['amount'] = _to_float(m_recv.group(1))
        d['sender'] = m_recv.group(2).strip()
        return d

    m_pay = re.search(r'(?:TxId:\s*([0-9]+)\.\s*)?Your payment of\s*' + AMT + r'\s*to\s*([^.]+?)\s+(?:has been completed|at)\b', text, re.I)
    if m_pay:
        d['transaction_type'] = 'payment'
        d['amount'] = _to_float(m_pay.group(2))
        d['receiver'] = m_pay.group(3).strip()
        if m_pay.group(1):
            d['tx_id'] = m_pay.group(1)
        return d

    m_tr = re.search(AMT + r'\s*RWF\s*transferred to\s*([^()]+)\s*\((?:\+?\d+|\*+)\)\s*from\s*([0-9]+)\s*at\b', text, re.I)
    if m_tr:
        d['transaction_type'] = 'transfer'
        d['amount'] = _to_float(m_tr.group(1))
        d['receiver'] = m_tr.group(2).strip()
        d['sender_account'] = m_tr.group(3).strip()
        return d

    m_tr2 = re.search(AMT + r'\s*RWF\s*transferred to\s*([^(]+)\s*from\s*([0-9]+)\s*at\b', text, re.I)
    if m_tr2:
        d['transaction_type'] = 'transfer'
        d['amount'] = _to_float(m_tr2.group(1))
        d['receiver'] = m_tr2.group(2).strip()
        d['sender_account'] = m_tr2.group(3).strip()
        return d

    m_dep = re.search(r'bank deposit of\s*' + AMT + r'\s*has been added', text, re.I)
    if m_dep:
        d['transaction_type'] = 'deposit'
        d['amount'] = _to_float(m_dep.group(1))
        return d

    m_wd = re.search(r'withdrawn\s*' + AMT + r'\s*', text, re.I)
    if m_wd:
        d['transaction_type'] = 'withdraw'
        d['amount'] = _to_float(m_wd.group(1))
        return d

    m_any = re.search(AMT + r'\s*RWF', text)
    if m_any:
        d['transaction_type'] = 'unknown'
        d['amount'] = _to_float(m_any.group(1))
        return d

    d['transaction_type'] = 'unknown'
    return d

def parse_xml_to_list(xml_path: str) -> list:
    tree = ET.parse(xml_path)
    root = tree.getroot()
    transactions = []
    for idx, sms in enumerate(root.findall('.//sms')):
        body = sms.get('body', '') or ''
        date_ms = sms.get('date')
        address = sms.get('address') or ''
        readable_date = sms.get('readable_date') or None

        tx = {
            'id': str(idx + 1),
            'address': address,
            'date_ms': int(date_ms) if (date_ms and date_ms.isdigit()) else None,
            'readable_date': readable_date,
        }
        tx.update(_parse_body(body))
        transactions.append(tx)
    return transactions

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description='Parse modified_sms_v2.xml to transactions.json')
    parser.add_argument('xml', help='Path to modified_sms_v2.xml')
    parser.add_argument('--out', default='transactions.json', help='Output JSON file')
    args = parser.parse_args()
    data = parse_xml_to_list(args.xml)
    with open(args.out, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f'Parsed {len(data)} transactions into {args.out}')

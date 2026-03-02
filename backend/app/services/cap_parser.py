import re
import xml.etree.ElementTree as ET

def parse_cap_xml(xml_string: str) -> dict:
    """
    Parses a CAP (Common Alerting Protocol) XML string and returns a structured Python dictionary.
    Handles namespaces by stripping them dynamically.
    Raises ValueError on invalid format.
    """
    try:
        root = ET.fromstring(clean_xml_namespaces(xml_string))
    except ET.ParseError as e:
        raise ValueError(f"Invalid XML format: {str(e)}")
    
    # Check for the root tag
    if root.tag != 'alert':
        raise ValueError(f"Root element must be 'alert', found '{root.tag}'")

    cap_data = {}
    
    # Top-level alert fields
    alert_fields = ['identifier', 'sender', 'sent', 'status', 'msgType', 'scope']
    for field in alert_fields:
        elem = root.find(field)
        if elem is not None and elem.text is not None:
            cap_data[field] = elem.text.strip()
            
    # Info element fields
    info = root.find('info')
    if info is not None:
        info_fields = ['category', 'event', 'urgency', 'severity', 'certainty', 'headline', 'description']
        for field in info_fields:
            elem = info.find(field)
            if elem is not None and elem.text is not None:
                cap_data[f"info.{field}"] = elem.text.strip()
                
    return cap_data

def clean_xml_namespaces(xml_string: str) -> str:
    """
    Removes the namespace definitions uniformly and tag prefixes from XML.
    ElementTree tends to prepend {namespace} to all tags if not properly stripped.
    """
    # 1) Remove xmlns definitions from any tag
    clean_xml = re.sub(r'\sxmlns="[^"]+"', '', xml_string)
    clean_xml = re.sub(r'\sxmlns:[a-zA-Z0-9]+="[^"]+"', '', clean_xml)
    
    # 2) Strip namespace prefix from tags, like <cap:alert> to <alert>
    clean_xml = re.sub(r'<\/?([a-zA-Z0-9]+:)', lambda m: '</' if m.group(0).startswith('</') else '<', clean_xml)
    
    return clean_xml

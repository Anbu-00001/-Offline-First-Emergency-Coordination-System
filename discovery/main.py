# SPDX-License-Identifier: GPL-3.0-or-later
import os
import time
import socket
from zeroconf import ServiceInfo, Zeroconf

SERVICE_NAME = os.getenv("SERVICE_NAME", "openrescue_node")
# Default to 8000 where backend runs
DISCOVERY_PORT = int(os.getenv("DISCOVERY_PORT", 8000))

def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # doesn't even have to be reachable
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

def main():
    try:
        ip = get_local_ip()
        print(f"Starting OpenRescue mDNS discovery on {ip}:{DISCOVERY_PORT}...")
        
        info = ServiceInfo(
            "_http._tcp.local.",
            f"{SERVICE_NAME}._http._tcp.local.",
            addresses=[socket.inet_aton(ip)],
            port=DISCOVERY_PORT,
            properties={"version": "0.1.0"},
            server="openrescue.local.",
        )

        zeroconf = Zeroconf()
        zeroconf.register_service(info)
        print("mDNS Service Registered. Advertising OpenRescue presence on local network...")

        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            pass
        finally:
            print("Unregistering OpenRescue service...")
            zeroconf.unregister_service(info)
            zeroconf.close()
    except Exception as e:
        print(f"Error starting discovery service: {e}")

if __name__ == "__main__":
    main()

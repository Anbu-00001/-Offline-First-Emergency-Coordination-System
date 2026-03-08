import 'dart:io';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:flutter/foundation.dart';

class MDnsDiscovery {
  Future<String?> discoverBackendUrl() async {
    const String name = '_openrescue._tcp.local';
    final MDnsClient client = MDnsClient();

    try {
      await client.start();
      
      await for (final PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(
          ResourceRecordQuery.serverPointer(name), timeout: const Duration(seconds: 5))) {
        
        await for (final SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
            ResourceRecordQuery.service(ptr.domainName))) {
          
          final String bundleId = srv.target;
          
          await for (final IPAddressResourceRecord ip in client.lookup<IPAddressResourceRecord>(
              ResourceRecordQuery.addressIPv4(bundleId))) {
            client.stop();
            return 'http://${ip.address.address}:${srv.port}';
          }
        }
      }
    } catch (e) {
      debugPrint('mDNS discovery error: $e');
    } finally {
      client.stop();
    }
    
    return null;
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';

part 'wallet_repository.g.dart';

class WalletRepository {
  /// Launches Phantom Wallet to connect.
  Future<void> connectPhantom() async {
    // Placeholder Deep Link for Phase 1
    final Uri url = Uri.parse(
      'phantom://ul/v1/connect?app_url=https://projectcyan.app&dapp_encryption_public_key=dummy',
    );

    // Fallback to universal link if scheme fails
    final Uri universalUrl = Uri.parse(
      'https://phantom.app/ul/v1/connect?app_url=https://projectcyan.app&dapp_encryption_public_key=dummy',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(universalUrl)) {
      await launchUrl(universalUrl, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Phantom Wallet not found');
    }
  }
}

@riverpod
WalletRepository walletRepository(Ref ref) {
  return WalletRepository();
}

@riverpod
Stream<String?> deepLink(Ref ref) {
  return linkStream;
}

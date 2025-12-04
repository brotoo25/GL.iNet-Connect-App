import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

/// Requests an in-app review or shows a fallback message
/// 
/// Returns true if the review dialog was shown, false otherwise
Future<bool> requestAppReview(BuildContext context) async {
  final inAppReview = InAppReview.instance;

  // Check if the in-app review is available on this device
  if (await inAppReview.isAvailable()) {
    // Request the native in-app review dialog
    await inAppReview.requestReview();
    return true;
  } else {
    // Fallback: open the app store listing if in-app review is not available
    // Note: You'll need to replace these with your actual app store IDs
    // For now, show a message since the app is not published yet
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'In-app review is not available. The app store listing will open once the app is published.',
          ),
        ),
      );
    }
    // Once published, uncomment and update with your app store IDs:
    // await inAppReview.openStoreListing(
    //   appStoreId: 'YOUR_APP_STORE_ID', // iOS App Store ID
    //   microsoftStoreId: 'YOUR_MICROSOFT_STORE_ID', // Optional
    // );
    return false;
  }
}


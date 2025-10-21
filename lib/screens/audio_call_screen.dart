import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/app_ctrl.dart' as app_ctrl;
import '../widgets/button.dart';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({super.key});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  bool isCallActive = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation =
        Tween<double>(begin: 0.5, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showCallMeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter your phone number'),
        content: TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'Phone number',
            prefixIcon: Icon(Icons.phone),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Process phone number here
              if (_phoneController.text.isNotEmpty) {
                // Call service would be implemented here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Calling you at ${_phoneController.text}')),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _dialIn() async {
    // Replace with your actual phone number
    const phoneNumber = '+18001234567';
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch dialer')),
        );
      }
    }
  }

  void _toggleCall() {
    final appCtrl = context.read<app_ctrl.AppCtrl>();

    setState(() {
      isCallActive = !isCallActive;
    });

    if (isCallActive) {
      // Connect call
      appCtrl.connect();
      // Start animation with higher speed for active call
      _animationController.duration = const Duration(milliseconds: 800);
      _animationController.repeat(reverse: true);
    } else {
      // Disconnect call
      appCtrl.disconnect();
      // Slow down animation for inactive state
      _animationController.duration = const Duration(seconds: 2);
      _animationController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade100,
            Colors.purple.shade100,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('VOICE ADMINS'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       IconButton(
              //         icon: const Icon(Icons.menu),
              //         onPressed: () {},
              //       ),
              //       IconButton(
              //         icon: const Icon(Icons.settings),
              //         onPressed: () {},
              //       ),
              //     ],
              //   ),
              // ),
              // const Spacer(),
              const Text(
                'Hello, Asif!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const Text(
                'How can I help you today?',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 40),
              // Audio Visualizer
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.purple.shade300,
                      Colors.purple.shade500,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.shade200.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animated circles for audio visualization
                          if (isCallActive)
                            ...List.generate(3, (index) {
                              return AnimatedOpacity(
                                opacity: isCallActive ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 500),
                                child: Container(
                                  width: 120 + (index * 30 * _animation.value),
                                  height: 120 + (index * 30 * _animation.value),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white
                                        .withOpacity(0.1 - (index * 0.03)),
                                  ),
                                ),
                              );
                            }),
                          // Mic icon
                          Icon(
                            isCallActive ? Icons.mic : Icons.mic_none,
                            size: 80,
                            color: Colors.white,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Talk Now / Cancel Button
              Button(
                text: isCallActive ? 'Cancel' : 'Talk Now',
                onPressed: _toggleCall,
                isProgressing:
                    context.watch<app_ctrl.AppCtrl>().connectionState ==
                        app_ctrl.ConnectionState.connecting,
              ),
              const Spacer(),
              // Dial In and Call Me buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const FaIcon(FontAwesomeIcons.phone),
                        label: const Text('Dial In'),
                        onPressed: _dialIn,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const FaIcon(FontAwesomeIcons.phoneVolume),
                        label: const Text('Call Me'),
                        onPressed: () => _showCallMeDialog(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Terms and Privacy
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          color: Colors.indigo,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const Text('|', style: TextStyle(color: Colors.indigo)),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: Colors.indigo,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

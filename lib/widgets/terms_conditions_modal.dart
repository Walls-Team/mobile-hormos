import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsConditionsModal extends StatelessWidget {
  const TermsConditionsModal({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const TermsConditionsModal(),
    );
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse('https://app.geniushpro.com/privacy-cookies-policy');
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Error opening privacy policy: $e');
    }
  }

  Future<void> _openEmail() async {
    final uri = Uri.parse('mailto:privacidad@geniusfitwatch.com');
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error opening email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallDevice = screenWidth < 400 || screenHeight < 700;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallDevice ? 16 : 24,
        vertical: isSmallDevice ? 24 : 40,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: screenHeight * 0.9,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A3A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isSmallDevice ? 16 : 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF2D5555), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terms and Conditions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallDevice ? 20 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last updated: 12 - 10 - 2025',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: isSmallDevice ? 11 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallDevice ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // View Privacy Policy Button
                    GestureDetector(
                      onTap: _openPrivacyPolicy,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D5555),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF3D6565)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.open_in_new,
                              color: Color(0xFF7FD8BE),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'View Full Privacy Policy',
                              style: TextStyle(
                                color: const Color(0xFF7FD8BE),
                                fontSize: isSmallDevice ? 14 : 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section 1
                    _buildSection(
                      '1. Introduction and Acceptance of Terms',
                      'Welcome to the testosterone estimation platform of Genius Fit Watch LLC ("we", "our", "ours"). This document constitutes a binding legal agreement between you and Genius Fit Watch LLC.\n\n'
                      'By accessing, registering or using our website and mobile application (collectively, the "Platform"), you confirm that you have read, understood and agreed to be bound by the practices and conditions described in this document. If you do not agree with these terms, please do not use our services.',
                      isSmallDevice,
                    ),

                    // Section 2
                    _buildSection(
                      '2. Important Information: Medical Disclaimer',
                      'Our Platform offers estimates of total testosterone levels based on a proprietary algorithm and data provided by you and your wearable device. It is essential that you understand the following:',
                      isSmallDevice,
                    ),
                    
                    _buildWarningBox(
                      'Genius Fit Watch LLC does not provide medical advice or diagnoses. The services and content on our Platform are not intended, designed or implied to diagnose, prevent, monitor, treat or alleviate any disease or medical condition, nor to determine the health status of users or be a substitute for professional medical care.',
                      isSmallDevice,
                    ),

                    const SizedBox(height: 12),

                    _buildBodyText(
                      'The information available through our Platform is provided solely for the purpose of improving wellness through education. You should consult your primary care physician or other healthcare providers if you have any questions about the implications of the information or results from our Platform and before making changes to your diet or exercise routine.\n\n'
                      'Genius Fit Watch LLC is not responsible for any health decisions made based on the information provided by our Platform.',
                      isSmallDevice,
                    ),

                    // Section 3
                    _buildSection(
                      '3. User Accounts and Eligibility',
                      'To use the Platform, you must register and create an account. By doing so, you commit to providing accurate and complete information. You are responsible for maintaining the confidentiality of your account and password.\n\n'
                      'Our Platform is not directed to individuals under 18 years of age, and we do not knowingly collect personal information from minors.',
                      isSmallDevice,
                    ),

                    // Section 4
                    _buildSection(
                      '4. Privacy Policy',
                      'This section describes how we collect, use, protect and share your personal information when you use our Platform.',
                      isSmallDevice,
                    ),

                    _buildSubSection(
                      'a. Information We Collect',
                      'We collect different types of information to provide and improve our Platform:',
                      isSmallDevice,
                    ),

                    _buildBulletList([
                      'Information you provide directly: Account data (email, username, weight, height, date of birth) and voluntary contributions (hormonal test results).',
                      'Automatically collected information: Usage data and cookies/session tokens.',
                      'Third-party service information: Physiological data connected through SpikeAPI, processed in real-time and not permanently stored.',
                    ], isSmallDevice),

                    _buildSubSection(
                      'b. How We Use Your Information',
                      null,
                      isSmallDevice,
                    ),

                    _buildBulletList([
                      'Operate and maintain the Platform.',
                      'Generate hormonal estimates.',
                      'Improve our services and algorithms.',
                      'Communicate with you about updates.',
                      'Security and fraud prevention.',
                    ], isSmallDevice),

                    _buildSubSection(
                      'c. How We Share Your Information',
                      'We do not sell or rent your personal information. We only share it with service providers (such as AWS), for legal obligations or to protect our rights.',
                      isSmallDevice,
                    ),

                    _buildSubSection(
                      'd. Data Security',
                      'We implement technical and organizational security measures to protect your information. Your personal information is stored in encrypted form on our AWS infrastructure.',
                      isSmallDevice,
                    ),

                    _buildSubSection(
                      'e. Your Rights and Options',
                      null,
                      isSmallDevice,
                    ),

                    _buildBulletList([
                      'Access and update your information from the application.',
                      'Delete your account and its data.',
                      'Revoke consent for external connections (SpikeAPI).',
                    ], isSmallDevice),

                    // Section 5 - Third-Party Table
                    _buildSection(
                      '5. Third-Party Subprocessors',
                      'We use third-party subprocessors to provide our services. We conduct due diligence to assess their privacy and security practices before engaging them.',
                      isSmallDevice,
                    ),

                    const SizedBox(height: 12),

                    _buildSubprocessorsTable(isSmallDevice),

                    // Section 6
                    _buildSection(
                      '6. Intellectual Property',
                      'All rights, title and interest in the Platform, including the algorithm, software, text, graphics and logos, are the exclusive property of Genius Fit Watch LLC. You are not granted any right to use our trademark or intellectual property without our prior written consent.',
                      isSmallDevice,
                    ),

                    // Section 7
                    _buildSection(
                      '7. Changes to the Terms and Privacy Policy',
                      'We may update these terms occasionally. We will notify you of any changes by posting the new policy on this page. If the changes are significant, we will provide you with a more prominent notice, such as an email.',
                      isSmallDevice,
                    ),

                    // Section 8 - Contact
                    _buildSection(
                      '8. Contact',
                      'If you have any questions or concerns about these terms or our privacy policy, please contact us at: ',
                      isSmallDevice,
                      trailing: GestureDetector(
                        onTap: _openEmail,
                        child: Text(
                          'privacidad@geniusfitwatch.com',
                          style: TextStyle(
                            color: const Color(0xFF7FD8BE),
                            fontSize: isSmallDevice ? 13 : 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Agree Button
            Container(
              padding: EdgeInsets.all(isSmallDevice ? 16 : 20),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFF2D5555), width: 1),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: isSmallDevice ? 48 : 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8D75C),
                    foregroundColor: const Color(0xFF1E3A3A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Agree',
                    style: TextStyle(
                      fontSize: isSmallDevice ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, bool isSmall, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 15 : 16,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          if (content.isNotEmpty)
            Text(
              content,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isSmall ? 13 : 14,
                height: 1.6,
              ),
            ),
          if (trailing != null) ...[
            const SizedBox(height: 4),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, String? content, bool isSmall) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 14 : 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          if (content != null) ...[
            const SizedBox(height: 6),
            Text(
              content,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isSmall ? 13 : 14,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWarningBox(String content, bool isSmall) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D4545),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD89B5C),
          width: 2,
        ),
      ),
      child: Text(
        content,
        style: TextStyle(
          color: const Color(0xFFFFD89B),
          fontSize: isSmall ? 13 : 14,
          height: 1.6,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBodyText(String content, bool isSmall) {
    return Text(
      content,
      style: TextStyle(
        color: Colors.white70,
        fontSize: isSmall ? 13 : 14,
        height: 1.6,
      ),
    );
  }

  Widget _buildBulletList(List<String> items, bool isSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isSmall ? 13 : 14,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmall ? 13 : 14,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubprocessorsTable(bool isSmall) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D4545),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3D5555)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isSmall ? 10 : 12),
            decoration: const BoxDecoration(
              color: Color(0xFF3D5555),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Entity',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmall ? 12 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Purpose',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmall ? 12 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Country',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmall ? 12 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rows
          _buildTableRow(
            'Amazon Web Services (AWS)',
            'Hosting and infrastructure services',
            'United States',
            isSmall,
          ),
          _buildTableRow(
            'Google LLC',
            'Analytics and usage measurement services',
            'United States',
            isSmall,
            isLast: false,
          ),
          _buildTableRow(
            'SpikeAPI',
            'Integration and temporary processing of physiological metrics',
            'United States',
            isSmall,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(String entity, String purpose, String country, bool isSmall, {bool isLast = false}) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 10 : 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFF3D5555), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              entity,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isSmall ? 11 : 12,
                height: 1.4,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              purpose,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isSmall ? 11 : 12,
                height: 1.4,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              country,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isSmall ? 11 : 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

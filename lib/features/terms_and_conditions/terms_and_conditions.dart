import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: "1. Introduction and Acceptance of Terms",
              children: [
                _buildParagraph(
                  "Welcome to the testosterone estimation platform of Genius Fit Watch LLC (\"we,\" \"our,\" \"us\"). This document constitutes a binding legal agreement between you and Genius Fit Watch LLC.",
                ),
                _buildParagraph(
                  "By accessing, registering for, or using our website and mobile application (collectively, the \"Platform\"), you confirm that you have read, understood, and agreed to be bound by the practices and conditions described in this document. If you do not agree with these terms, please do not use our services.",
                ),
              ],
            ),

            _buildSection(
              title: "2. Important Information: Medical Disclaimer",
              children: [
                _buildParagraph(
                  "Our Platform offers estimations of total testosterone levels based on a proprietary algorithm and on data provided by you and your wearable device. It is fundamental that you understand the following:",
                ),
                _buildParagraph(
                  "Genius Fit Watch LLC does not provide medical advice or diagnoses. The services and content on our Platform are not intended, designed, or implied to diagnose, prevent, monitor, treat, or alleviate any disease or medical condition, nor to determine the health status of users or be a substitute for professional medical care.",
                  isImportant: true,
                ),
                _buildParagraph(
                  "The information available through our Platform is provided solely for the purpose of improving wellness through education. You must consult your primary care physician or other healthcare providers if you have any questions about the implications of the information or results from our Platform and before making changes to your diet or exercise routine.",
                ),
                _buildParagraph(
                  "Genius Fit Watch LLC is not responsible for any health decisions made based on the information provided by our Platform.",
                ),
              ],
            ),

            _buildSection(
              title: "3. User Accounts and Eligibility",
              children: [
                _buildParagraph(
                  "To use the Platform, you must register and create an account. By doing so, you commit to providing accurate and complete information. You are responsible for maintaining the confidentiality of your account and password.",
                ),
                _buildParagraph(
                  "Our Platform is not directed at individuals under 18 years of age, and we do not knowingly collect personal information from minors.",
                ),
              ],
            ),

            _buildSection(
              title: "4. Privacy Policy",
              children: [
                _buildParagraph(
                  "This section describes how we collect, use, protect, and share your personal information when you use our Platform.",
                ),

                _buildSubsection(
                  title: "a. Information We Collect",
                  children: [
                    _buildParagraph(
                      "We collect different types of information to provide and improve our Platform:",
                    ),
                    _buildBulletPoint(
                      "Information you provide directly: Account data (email, username, weight, height, date of birth) and voluntary contributions (hormone analysis results).",
                    ),
                    _buildBulletPoint(
                      "Information collected automatically: Usage data and cookies/session tokens.",
                    ),
                    _buildBulletPoint(
                      "Information from third-party services: Physiological data connected via SpikeAPI, processed in real-time and not permanently stored.",
                    ),
                  ],
                ),

                _buildSubsection(
                  title: "b. How We Use Your Information",
                  children: [
                    _buildBulletPoint("Operate and maintain the Platform"),
                    _buildBulletPoint("Generate hormonal estimations"),
                    _buildBulletPoint("Improve our services and algorithms"),
                    _buildBulletPoint("Communicate with you about updates"),
                    _buildBulletPoint("Security and fraud prevention"),
                  ],
                ),

                _buildSubsection(
                  title: "c. How We Share Your Information",
                  children: [
                    _buildParagraph(
                      "We do not sell or rent your personal information. We only share it with service providers (such as AWS), for legal obligations, or to protect our rights.",
                    ),
                  ],
                ),

                _buildSubsection(
                  title: "d. Data Security",
                  children: [
                    _buildParagraph(
                      "We implement technical and organizational security measures to protect your information. Your personal information is stored in encrypted form on our AWS infrastructure.",
                    ),
                  ],
                ),

                _buildSubsection(
                  title: "e. Your Rights and Options",
                  children: [
                    _buildBulletPoint(
                      "Access and update your information from the application",
                    ),
                    _buildBulletPoint("Delete your account and its data"),
                    _buildBulletPoint(
                      "Revoke consent for external connections (SpikeAPI)",
                    ),
                  ],
                ),
              ],
            ),

            _buildSection(
              title: "5. Third-Party Subprocessors",
              children: [
                _buildParagraph(
                  "We use third-party subprocessors to provide our services. We conduct due diligence to assess their privacy and security practices before engaging them.",
                ),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[700]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      // headingRowColor: MaterialStateProperty.all(Colors.grey[900]),
                      // dataRowColor: MaterialStateProperty.all(Colors.transparent),
                      columns: const [
                        DataColumn(label: _TableHeaderText("Entity")),
                        DataColumn(label: _TableHeaderText("Purpose")),
                        DataColumn(label: _TableHeaderText("Country")),
                      ],
                      rows: const [
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                "Amazon Web Services (AWS)",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            DataCell(
                              Text(
                                "Hosting and infrastructure services",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            DataCell(
                              Text(
                                "United States",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                "Google LLC",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            DataCell(
                              Text(
                                "Analytics and usage measurement services",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            DataCell(
                              Text(
                                "United States",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                "SpikeAPI",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            DataCell(
                              Text(
                                "Integration and temporary processing of physiological metrics",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            DataCell(
                              Text(
                                "United States",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            _buildSection(
              title: "6. Intellectual Property",
              children: [
                _buildParagraph(
                  "All rights, title, and interest in the Platform, including the algorithm, software, text, graphics, and logos, are the exclusive property of Genius Fit Watch LLC. You are not granted any right to use our trademark or intellectual property without our prior written consent.",
                ),
              ],
            ),

            _buildSection(
              title: "7. Changes to the Terms and Privacy Policy",
              children: [
                _buildParagraph(
                  "We may update these terms occasionally. We will notify you of any changes by posting the new policy on this page. If the changes are significant, we will provide you with a more prominent notice, such as an email.",
                ),
              ],
            ),

            _buildSection(
              title: "8. Contact",
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    children: [
                      const TextSpan(
                        text:
                            "If you have any questions or concerns about these terms or our privacy policy, please contact us at: ",
                      ),
                      WidgetSpan(
                        child: InkWell(
                          // onTap: _sendEmail,
                          child: Text(
                            "privacidad@geniusfitwatch.com",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            _buildAcceptButton(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptButton(BuildContext context, ThemeData theme) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context, true);
      },
      child: Text('Aceptar Términos y Condiciones'),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSubsection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildParagraph(String text, {bool isImportant = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: isImportant ? const Color(0xFFef4444) : Colors.grey,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeaderText extends StatelessWidget {
  final String text;

  const _TableHeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    );
  }
}

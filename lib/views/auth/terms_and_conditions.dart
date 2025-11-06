import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Términos y Condiciones'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. ACEPTACIÓN DE LOS TÉRMINOS', theme),
            _buildSectionContent(
              'Al registrarte y utilizar nuestra aplicación, aceptas cumplir y estar sujeto a los siguientes términos y condiciones de uso. Si no estás de acuerdo con estos términos, por favor no utilices nuestra aplicación.'
            ),
            
            SizedBox(height: 25),
            _buildSectionTitle('2. USO DE LA APLICACIÓN', theme),
            _buildSectionContent(
              'La aplicación está destinada para uso personal y no comercial. No puedes utilizar nuestra aplicación para cualquier propósito ilegal o no autorizado. Eres responsable de todo el contenido que publiques y de las actividades que realices a través de tu cuenta.'
            ),
            
            SizedBox(height: 25),
            _buildSectionTitle('3. REGISTRO DE USUARIO', theme),
            _buildSectionContent(
              'Para utilizar ciertas funciones de la aplicación, debes registrarte proporcionando información precisa y completa. Eres responsable de mantener la confidencialidad de tu cuenta y contraseña. Aceptas notificarnos inmediatamente sobre cualquier uso no autorizado de tu cuenta.'
            ),
            
            SizedBox(height: 25),
            _buildSectionTitle('4. PRIVACIDAD Y PROTECCIÓN DE DATOS', theme),
            _buildSectionContent(
              'Respetamos tu privacidad y nos comprometemos a proteger tus datos personales. Tu información será tratada de acuerdo con nuestra Política de Privacidad. Recopilamos y utilizamos información personal solo para los fines especificados en dicha política.'
            ),
            
            SizedBox(height: 25),
            _buildSectionTitle('5. PROPIEDAD INTELECTUAL', theme),
            _buildSectionContent(
              'Todo el contenido de la aplicación, incluyendo pero no limitado a texto, gráficos, logotipos, imágenes, y software, está protegido por derechos de autor, marcas registradas y otras leyes de propiedad intelectual. No puedes reproducir, distribuir o crear obras derivadas sin nuestro permiso explícito.'
            ),
            
            SizedBox(height: 25),
            _buildSectionTitle('6. CONTENIDO DEL USUARIO', theme),
            _buildSectionContent(
              'Al publicar contenido en nuestra aplicación, nos otorgas una licencia mundial, no exclusiva y libre de regalías para usar, modificar, mostrar y distribuir dicho contenido. Eres el único responsable del contenido que publiques y garantizas que tienes todos los derechos necesarios para hacerlo.'
            ),
            
            SizedBox(height: 25),
            _buildSectionTitle('7. LIMITACIÓN DE RESPONSABILIDAD', theme),
            _buildSectionContent(
              'En la medida máxima permitida por la ley, no seremos responsables por daños indirectos, incidentales, especiales o consecuentes que resulten del uso o la imposibilidad de uso de la aplicación, incluso si hemos sido advertidos de la posibilidad de tales daños.'
            ),
            
            SizedBox(height: 25),
            _buildSectionTitle('8. MODIFICACIONES DE LOS TÉRMINOS', theme),
            _buildSectionContent(
              'Nos reservamos el derecho de modificar estos términos en cualquier momento. Las modificaciones entrarán en vigor inmediatamente después de su publicación en la aplicación. Tu uso continuado de la aplicación después de dichas modificaciones constituye tu aceptación de los términos revisados.'
            ),
            
            SizedBox(height: 25),
            _buildSectionTitle('9. TERMINACIÓN', theme),
            _buildSectionContent(
              'Podemos suspender o terminar tu acceso a la aplicación en cualquier momento, sin previo aviso, por cualquier motivo, incluyendo el incumplimiento de estos términos. Tras la terminación, tus derechos para usar la aplicación cesarán inmediatamente.'
            ),
            
            SizedBox(height: 25),
            _buildSectionTitle('10. LEY APLICABLE', theme),
            _buildSectionContent(
              'Estos términos se regirán e interpretarán de acuerdo con las leyes del país donde nuestra empresa tiene su sede principal, sin tener en cuenta sus disposiciones sobre conflicto de leyes.'
            ),
            
            SizedBox(height: 30),
            _buildAcceptButton(context, theme),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: theme.primaryColor,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 16,
        height: 1.6,
        color: Colors.grey[300],
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildAcceptButton(BuildContext context, ThemeData theme) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            // Retornar resultado a la pantalla anterior
            Navigator.pop(context, true);
          },
          child: Text(
            'Aceptar Términos y Condiciones',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
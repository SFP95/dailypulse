import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
    _confirmPasswordFocusNode.addListener(_onFocusChange);
    _nameFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Actualizar el nombre del usuario
      await credential.user!.updateDisplayName(_nameController.text.trim());

      // Navegar a pantalla principal (AuthWrapper lo manejará)
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_getErrorMessage(e.code))),
      );
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use': return 'El correo ya está registrado';
      case 'invalid-email': return 'Correo electrónico inválido';
      case 'weak-password': return 'La contraseña es muy débil (mínimo 6 caracteres)';
      default: return 'Error al registrar: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: EdgeInsets.all(25),
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primarylila,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isKeyboardOpen) ...[
                            Text(
                              'Crear Cuenta',
                              style: AppTextStyles.headlineLarge.copyWith(
                                color: AppColors.primarypurple,
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                          TextFormField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: AppColors.primaryyellow,
                                ),
                              ),
                              labelText: 'Nombre completo',
                              labelStyle: TextStyle(color: AppColors.primarypurple,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 14),
                            ),
                            validator: (value) =>
                            value!.isEmpty ? 'Ingresa tu nombre' : null,
                            textCapitalization: TextCapitalization.words,
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: AppColors.primaryyellow,
                                ),
                              ),
                              labelText: 'Email',
                              labelStyle: TextStyle(color: AppColors.primarypurple,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 14),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) return 'Ingresa tu email';
                              if (!value.contains('@')) return 'Email inválido';
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: AppColors.primaryyellow,
                                ),
                              ),
                              labelText: 'Contraseña',
                              labelStyle: TextStyle(color: AppColors.primarypurple,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 14),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.primarypurple,
                                ),
                                onPressed: () => setState(() {
                                  _obscurePassword = !_obscurePassword;
                                }),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) return 'Ingresa tu contraseña';
                              if (value.length < 6) return 'Mínimo 6 caracteres';
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocusNode,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: AppColors.primaryyellow,
                                ),
                              ),
                              labelText: 'Confirmar contraseña',
                              labelStyle: TextStyle(color: AppColors.primarypurple,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 14),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.primarypurple,
                                ),
                                onPressed: () => setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                }),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          if (_isLoading)
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primarypurple),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  backgroundColor: AppColors.primaryyellow,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _register,
                                child: Text(
                                  'Registrarse',
                                  style: TextStyle(
                                    color: AppColors.primarypurple,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: 15),
                          TextButton(
                            style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Área de tope ajustada
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              '¿Ya tienes cuenta? Inicia sesión',
                              style: TextStyle(fontSize: 17,
                                color: AppColors.textPrimary
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'api_service.dart';
import 'data_provider.dart';
import 'dashboard_page.dart';
import 'i18n_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    I18nService.loadTranslations();
  }

  String _selectedLang = 'en';
  int _buildCounter = 0;

  Widget _langDropdown() {
    final langs = [
      {'code': 'en', 'name': 'English'},
      {'code': 'ar', 'name': 'العربية'},
      {'code': 'ur', 'name': 'اردو'},
      {'code': 'eu', 'name': 'Euskara'},
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFFf4f4ef), borderRadius: BorderRadius.circular(8)),
      child: DropdownButton<String>(
        value: _selectedLang,
        underline: const SizedBox(),
        isDense: true,
        icon: const Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF06402B)),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF002819)),
        items: langs.map((l) => DropdownMenuItem(
            value: l['code'] as String, 
            child: Text(l['name'] as String))).toList(),
        onChanged: (val) { 
          if (val != null) {
            I18nService.setLocale(val);
            setState(() {
              _selectedLang = val;
              _buildCounter++;
            });
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final welcomeBack = I18nService.tr('auth.welcomeBack');
    final loginBtn = I18nService.tr('auth.login');
    final emailTxt = I18nService.tr('auth.email');
    final passwordTxt = I18nService.tr('auth.password');

    return Scaffold(
        backgroundColor: const Color(0xFF002819),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight - MediaQuery.of(context).padding.vertical - 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(alignment: Alignment.topRight, child: _langDropdown()),
                  Column(
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFe3e3de),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFfbbf24).withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.agriculture,
                        color: Color(0xFF4f6357),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'The Oasis',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFfbbf24),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'LIVESTOCK TRACKING',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFb8efd0),
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          welcomeBack,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002819),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign in to continue monitoring your livestock',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF404943),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          emailTxt,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF404943),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            filled: true,
                            fillColor: const Color(0xFFf4f4ef),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF717973),
                            ),
                            suffixIcon: _emailController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Color(0xFF717973),
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      _emailController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Email is required';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          passwordTxt,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF404943),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _login(auth),
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            filled: true,
                            fillColor: const Color(0xFFf4f4ef),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF717973),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Color(0xFF717973),
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Password is required';
                            if (v.length < 4)
                              return 'Password must be at least 4 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (v) => setState(
                                      () => _rememberMe = v ?? false,
                                    ),
                                    activeColor: const Color(0xFF06402B),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF404943),
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => _showForgotPassword(context),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF06402B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (auth.error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFffdad6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Color(0xFFba1a1a),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    auth.error!,
                                    style: const TextStyle(
                                      color: Color(0xFFba1a1a),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: auth.isLoading
                                ? null
                                : () => _login(auth),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF002819),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: auth.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    loginBtn,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: Color(0xFFb8efd0),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showSignup(context, I18nService.tr),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color(0xFFfbbf24),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        auth.setDemoMode();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => DashboardPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(
                              0xFFfbbf24,
                            ).withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Continue in Demo Mode',
                          style: TextStyle(
                            color: Color(0xFFfbbf24),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login(AuthProvider auth) async {
    if (_formKey.currentState!.validate()) {
      final success = await auth.login(
        _emailController.text,
        _passwordController.text,
      );
      if (success && mounted) {
        await auth.fetchCurrentUser();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardPage()),
        );
      }
    }
  }

  void _showForgotPassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002819),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your email to receive a password reset link',
                style: TextStyle(color: Color(0xFF404943)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  filled: true,
                  fillColor: const Color(0xFFf4f4ef),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset link sent!'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002819),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Send Reset Link'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignup(BuildContext context, String Function(String) tr) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002819),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: const Color(0xFFf4f4ef),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: tr('auth.email'),
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: const Color(0xFFf4f4ef),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) {
                          if (v?.isEmpty ?? true) return 'Email is required';
                          if (!v!.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: tr('auth.password'),
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: const Color(0xFFf4f4ef),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) {
                          if (v?.isEmpty ?? true) return 'Password is required';
                          if (v!.length < 8)
                            return 'Password must be at least 8 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: const Color(0xFFf4f4ef),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) {
                          if (v != passwordController.text)
                            return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              try {
                                await ApiService.register({
                                  'name': nameController.text,
                                  'email': emailController.text,
                                  'password': passwordController.text,
                                  'password_confirmation':
                                      confirmPasswordController.text,
                                });
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Account created successfully! Please login.',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002819),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

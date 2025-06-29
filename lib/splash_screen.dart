import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const route = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pathController;
  late AnimationController _shrinkController;
  late AnimationController _formController;

  late Animation<double> _pathAnimation;
  late Animation<double> _shrinkAnimation;
  late Animation<double> _formOpacityAnimation;
  late Animation<double> _formSlideAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  static const double _targetSize = 200.0; // Approximate 50% of screen width
  static const double _finalCenterRatio = 0.7;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _pathController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _shrinkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _formController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pathAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _pathController,
      curve: Curves.easeOut,
    ));

    _shrinkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shrinkController,
      curve: Curves.easeOutQuad,
    ));

    _formOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOut,
    ));

    _formSlideAnimation = Tween<double>(
      begin: 24.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimationSequence() {
    _pathController.forward();

    Future.delayed(const Duration(seconds: 4), () {
      _shrinkController.forward().then((_) {
        // Start form animation after shrink completes, with 100ms delay
        Future.delayed(const Duration(milliseconds: 50), () {
          _formController.forward();
        });
      });
    });
  }

  Future<void> _handleAuth() async {
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      AuthResponse response;

      if (_isLogin) {
        response = await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        response = await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (response.user != null) {
        if (!_isLogin) {
          await supabase.from('profiles').upsert({
            'id': response.user!.id,
          });
        }
        
        if (mounted) {
          final profile = await Supabase.instance.client
        .from('user_profiles')
        .select('role')
        .eq('id', response.user!.id)
        .maybeSingle();

        if (profile != null && profile['role'] != null) {
          final role = profile['role'] as String;
          final route = role == 'provider' ? JobFeedPage.route : PostJobPage.route;
          Navigator.pushReplacementNamed(context, route);
        } else {
          Navigator.pushReplacementNamed(context, RoleSelectPage.route);
        }

    }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
          ),
          
          AnimatedBuilder(
            animation: _shrinkAnimation,
            builder: (context, child) {
              final progress = _shrinkAnimation.value;
              
              final containerWidth = _lerpDouble(screenSize.width, _targetSize, progress);
              final containerHeight = _lerpDouble(screenSize.height, _targetSize, progress);
              final borderRadius = _lerpDouble(0.0, _targetSize / 2, progress);
              
              final translateY = _lerpDouble(
                0.0, 
                screenSize.height * _finalCenterRatio - screenSize.height / 2, 
                progress
              );
              final translateX = _lerpDouble(
                0.0, 
                (screenSize.width - _targetSize) / 2, 
                progress
              );

              return Positioned(
                top: translateY,
                left: translateX,
                child: Container(
                  width: containerWidth,
                  height: containerHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF8B5CF6), // Purple
                        Color(0xFF3B82F6), // Blue
                      ],
                    ),
                  ),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pathAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(_targetSize * 0.8, _targetSize * 0.8),
                          painter: CursiveOPainter(_pathAnimation.value),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Form
          AnimatedBuilder(
            animation: Listenable.merge([_formOpacityAnimation, _formSlideAnimation]),
            builder: (context, child) {
              return Positioned(
                bottom: 56,
                left: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(0, _formSlideAnimation.value),
                  child: Opacity(
                    opacity: _formOpacityAnimation.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              obscureText: true,
                            ),
                            const SizedBox(height: 28),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF8B5CF6), // Purple
                                    Color(0xFF3B82F6), // Blue
                                  ],
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleAuth,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: _isLoading 
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _isLogin ? 'Sign In' : 'Create Account',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: _isLogin 
                                        ? "Don't have an account? " 
                                        : "Already have an account? ",
                                    ),
                                    TextSpan(
                                      text: _isLogin ? 'Sign up' : 'Log in',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF64748B).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
            ),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: TextStyle(
                color: const Color(0xFF64748B).withOpacity(0.7),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @override
  void dispose() {
    _pathController.dispose();
    _shrinkController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class CursiveOPainter extends CustomPainter {
  final double progress;
  
  CursiveOPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;
    
    path.moveTo(center.dx - radius, center.dy);
    path.quadraticBezierTo(
      center.dx - radius, center.dy - radius * 1.2,
      center.dx, center.dy - radius * 1.2,
    );
    path.quadraticBezierTo(
      center.dx + radius, center.dy - radius * 1.2,
      center.dx + radius, center.dy,
    );
    path.quadraticBezierTo(
      center.dx + radius, center.dy + radius * 1.2,
      center.dx, center.dy + radius * 1.2,
    );
    path.quadraticBezierTo(
      center.dx - radius, center.dy + radius * 1.2,
      center.dx - radius, center.dy,
    );

    final pathMetric = path.computeMetrics().first;
    final animatedPath = pathMetric.extractPath(
      0.0,
      pathMetric.length * (1.0 - progress),
    );

    canvas.drawPath(animatedPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}


import 'package:agriculture/Auth/SetupAccount.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Removed unused shared_preferences import from AuthWrapper logic
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agriculture/Home/home.dart'; // Make sure this import is correct
import 'package:google_sign_in/google_sign_in.dart'; // Import google_sign_in
import 'package:flutter_svg/flutter_svg.dart';
// Import flutter_svg if using SVG logo

// --- AuthWrapper using Firebase Auth State Stream ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Use StreamBuilder to listen to Firebase Auth state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Connection state: checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While checking, show a simple splash screen or loading indicator
          // You can replace this with your actual splash screen UI
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        // Error state
        if (snapshot.hasError) {
          // Handle errors during auth state checking, maybe show an error screen
          return Scaffold(
            body: Center(
              child: Text('An error occurred: ${snapshot.error}'),
            ),
          );
        }
        // Data state: auth state is ready
        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in
          // Remove the SharedPreferences check here, Firebase handles it
          return const HomePage(); // Navigate to Home
        } else {
          // User is not signed in
          // Remove the SharedPreferences check here, Firebase handles it
          return const LoginPage(); // Navigate to Login
        }
      },
    );
  }
}

// --- Reusable Google Sign-In Button ---
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87, // Text color
        backgroundColor: Colors.white, // Background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        side: BorderSide(color: Colors.grey[300]!, width: 1.0), // Border color
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      ),
      onPressed: isLoading ? null : onPressed, // Disable button when loading
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min, // Use minimum space
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Use flutter_svg for the official Google logo
                // Ensure you have 'assets/google_logo.svg' and configured pubspec.yaml
                SvgPicture.asset(
                  'assets/google_logo.svg', // Make sure you have the SVG in your assets
                  height: 20.0,
                ),
                const SizedBox(width: 12.0),
                const Text(
                  'Sign in with Google',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
    );
  }
}

// --- Modernized LoginPage ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Add form key for validation
  bool _isPasswordVisible = false;
  bool _isLoading = false; // State to manage loading

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(), // Trim whitespace
          password: _passwordController.text.trim(),
        );
        // Authentication successful. The AuthWrapper will automatically
        // detect the state change and navigate. No need for manual navigation here
        // and no need to manually set isLoggedIn in SharedPreferences for routing.
        if (userCredential.user != null) {
          // Optional: You might still want to save user data *other* than auth status
          // final prefs = await SharedPreferences.getInstance();
          // await prefs.setString('email', userCredential.user!.email!); // Example

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Successful!')),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );

          // Navigation is handled by AuthWrapper's StreamBuilder
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An unknown error occurred.';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Invalid email format.';
        } else if (e.code == 'user-disabled') {
          errorMessage = 'This user account has been disabled.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        print('Firebase Auth Error: ${e.code}'); // Log for debugging
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
        print('General Error: $e'); // Log for debugging
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Sign out from Google first to ensure account selection dialog appears if needed
      // Note: This is a good practice but might annoy users if they expect
      // to be signed in automatically if they have a Google account logged in on the device.
      // Consider removing this line if you want seamless sign-in.
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In cancelled.')),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Authentication successful. The AuthWrapper will automatically
      // detect the state change and navigate. No need for manual navigation here.
      // and no need to manually set isLoggedIn in SharedPreferences for routing.
      try {
        if (userCredential.user != null) {
          // Optional: Save user details from Google profile
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', googleUser.displayName ?? 'User');
          await prefs.setString('email', googleUser.email);
          // await prefs.setBool('isLoggedIn', true); // No longer needed for AuthWrapper routing

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google Sign-In Successful!')),
          );
          // Navigation is handled by AuthWrapper's StreamBuilder
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Failed to sign in with Google.';
        if (e.code == 'account-exists-with-different-credential') {
          errorMessage =
              'An account already exists with the same email address but different sign-in credentials.';
        } else if (e.code == 'invalid-credential') {
          errorMessage = 'The credential is not valid or malformed.';
        } else {
          errorMessage =
              'Google Sign-In failed: ${e.message}'; // Use Firebase message
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        print(
            'Firebase Auth Error (Google Sign-In): ${e.code}'); // Log for debugging
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In failed: ${e.toString()}')),
        );
        print('General Error (Google Sign-In): $e'); // Log for debugging
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Back'),
        centerTitle: true,
        elevation: 0, // Remove shadow for a flatter look
      ),
      body: Center(
        // Center the content vertically and horizontally
        child: SingleChildScrollView(
          // Allow scrolling if content overflows
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Stretch elements horizontally
              children: <Widget>[
                // Title/Logo (Optional: Add your app logo or a more engaging title)
                Text(
                  'Login to your Account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true, // Add a subtle fill color
                    fillColor: Colors.grey[200],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // Basic email format validation
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Please enter a valid email format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  obscureText: !_isPasswordVisible, // Toggle visibility
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    // Add password length validation if needed
                    // if (value.length < 6) {
                    //   return 'Password must be at least 6 characters';
                    // }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Forgot Password (Optional)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement Forgot Password functionality
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 20),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login, // Disable when loading
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5, // Add some shadow
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
                const SizedBox(height: 30),

                // OR Separator
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),

                // Google Sign-In Button
                GoogleSignInButton(
                  onPressed: _signInWithGoogle,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 30),

                // Link to Signup Page
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          // Disable when loading
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          );
                        },
                  child: RichText(
                    // Use RichText for different styles
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                          text: "Don't have an account? ",
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 15),
                        ),
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
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
    );
  }
}

// --- Modernized SignupPage ---
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false; // State to manage loading

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Optional: Update user profile with username

        // Authentication successful. The AuthWrapper will automatically
        // detect the state change and navigate. No need for manual navigation here
        // and no need to manually set isLoggedIn in SharedPreferences for routing.
        if (userCredential.user != null) {
          // Optional: Save user details using shared preferences (excluding sensitive info)
          // await prefs.setBool('isLoggedIn', true); // No longer needed for AuthWrapper routing

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup Successful!')),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => CreateProfilePage()),
          );
          // Navigation is handled by AuthWrapper's StreamBuilder
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An unknown error occurred.';
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Invalid email format.';
        } else {
          errorMessage = 'Signup failed: ${e.message}'; // Use Firebase message
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        print('Firebase Auth Error: ${e.code}'); // Log for debugging
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: ${e.toString()}')),
        );
        print('General Error: $e'); // Log for debugging
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Sign out from Google first to ensure account selection dialog appears if needed
      // Note: Same consideration as in LoginPage - you might remove this for seamless sign-in.
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In cancelled.')),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential (this will create the user if they don't exist)
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Authentication successful. The AuthWrapper will automatically
      // detect the state change and navigate. No need for manual navigation here.
      if (userCredential.user != null) {
        // Optional: Save user details from Google profile
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', googleUser.displayName ?? 'User');
        await prefs.setString('email', googleUser.email);
        // await prefs.setBool('isLoggedIn', true); // No longer needed for AuthWrapper routing

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-Up Successful!')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );

        // Navigation is handled by AuthWrapper's StreamBuilder
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to sign up with Google.';
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage =
            'An account already exists with the same email address but different sign-in credentials.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'The credential is not valid or malformed.';
      } else {
        errorMessage =
            'Google Sign-Up failed: ${e.message}'; // Use Firebase message
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      print(
          'Firebase Auth Error (Google Sign-In): ${e.code}'); // Log for debugging
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-Up failed: ${e.toString()}')),
      );
      print('General Error (Google Sign-In): $e'); // Log for debugging
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        // Center the content
        child: SingleChildScrollView(
          // Allow scrolling
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Title
                Text(
                  'Sign up to get Started',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const SizedBox(height: 40),

                // Username Field
                const SizedBox(height: 20),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Please enter a valid email format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      // Add password length validation
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Signup Button
                ElevatedButton(
                  onPressed:
                      _isLoading ? null : _signup, // Disable when loading
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18),
                        ),
                ),

                const SizedBox(height: 30),

                // OR Separator
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),

                // Google Sign-Up Button
                GoogleSignInButton(
                  onPressed:
                      _signInWithGoogle, // Google Sign-Up is essentially just Sign-In via credential
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 30),

                // Link to Login Page
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          // Disable when loading
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                          // Go back to Login Page
                        },
                  child: RichText(
                    // Use RichText for different styles
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                          text: "Already have an account? ",
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 15),
                        ),
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
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
    );
  }
}

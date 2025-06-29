import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'splash_screen.dart'; // your animated splash implementation


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://pkjnudgaohbgwptsbhne.supabase.co', // Replace with your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBram51ZGdhb2hiZ3dwdHNiaG5lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1MzU2MzgsImV4cCI6MjA2NjExMTYzOH0.UwO6DnRGnmPmuIK-ZR400YRo2fm6OE5j0vqS5M6NMiU', // Replace with your Supabase anon key
  );
  
  runApp(const OpraApp());
}

class OpraApp extends StatelessWidget {
  const OpraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Opra',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6F7CFF)),
        useMaterial3: true,
        fontFamily: 'SF Pro',
      ),
      initialRoute: SplashScreen.route,
      routes: {
        SplashScreen.route: (_) => const SplashScreen(),
        RoleSelectPage.route: (_) => const RoleSelectPage(),
        PersonalInfoPage.route: (_) => const PersonalInfoPage(),
        AddressPage.route: (_) => const AddressPage(),
        HomePage.route: (_) => const HomePage(),
        JobFeedPage.route: (_) => const JobFeedPage(),
        PostJobPage.route: (_) => const PostJobPage(),
      },
    );
  }
}


class OnboardingData {
  String? role;         
  String? firstName;
  String? lastName;
  String? phone;
  String? street;
  String? city;
  String? state;
  String? zip;

  Map<String, dynamic> toJson(String uid, String email) => {
        'id': uid,
        'email': email,
        'role': role,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'street': street,
        'city': city,
        'state': state,
        'zip': zip,
      };
}

//////////////////////////////////////////////////////////////
//  Page 1 – choose role                                   //
//////////////////////////////////////////////////////////////
class RoleSelectPage extends StatelessWidget {
  const RoleSelectPage({super.key});
  static const route = '/role';

  @override
  Widget build(BuildContext context) {
    final data = OnboardingData();

    Widget card(String title, String subtitle, IconData icon, String value) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: value == 'provider'
                ? const Color(0xFF9C68FD)
                : const Color(0xFF4F7CFF),
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          onTap: () {
            data.role = value;
            Navigator.pushNamed(context, PersonalInfoPage.route,
                arguments: data);
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const SizedBox(height: 32),
          const Icon(Icons.apartment, size: 72, color: Color(0xFF6F7CFF)),
          const SizedBox(height: 16),
          const Text('Welcome to Opra',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Text(
              'Professional services marketplace connecting skilled workers with discerning clients',
              textAlign: TextAlign.center,
            ),
          ),
          card('Service Provider', 'Offer professional services to clients',
              Icons.work, 'provider'),
          card('Client', 'Find and hire professional services', Icons.person,
              'client'),
        ],
      ),
    );
  }
}

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});
  static const route = '/personal';

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as OnboardingData;

    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => Navigator.pop(context))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('Personal Information',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _first,
                decoration: const InputDecoration(labelText: 'First Name *'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _last,
                decoration: const InputDecoration(labelText: 'Last Name *'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone Number *'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const Spacer(),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    data.firstName = _first.text.trim();
                    data.lastName = _last.text.trim();
                    data.phone = _phone.text.trim();
                    Navigator.pushNamed(context, AddressPage.route,
                        arguments: data);
                  }
                },
                child: const Text('Continue  →'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class AddressPage extends StatefulWidget {
  const AddressPage({super.key});
  static const route = '/address';

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _zip = TextEditingController();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as OnboardingData;
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => Navigator.pop(context))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('Service Location',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _street,
                decoration: const InputDecoration(labelText: 'Street Address *'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _city,
                decoration: const InputDecoration(labelText: 'City *'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _state,
                decoration: const InputDecoration(labelText: 'State *'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _zip,
                decoration: const InputDecoration(labelText: 'ZIP Code *'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const Spacer(),
              FilledButton(
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                onPressed: _loading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _loading = true);

                        final client = Supabase.instance.client;
                        final user = client.auth.currentUser;
                        if (user == null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Not logged in')));
                          }
                          return;
                        }
                        data
                          ..street = _street.text.trim()
                          ..city = _city.text.trim()
                          ..state = _state.text.trim()
                          ..zip = _zip.text.trim();

                        final res = await client
                            .from('user_profiles')
                            .upsert(data.toJson(user.id, user.email!));

                        if (res.error != null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(res.error!.message)));
                          }
                        } else {
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                                context, HomePage.route, (_) => false);
                          }
                        }
                        if (mounted) setState(() => _loading = false);
                      },
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Finish  →'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JobFeedPage extends StatelessWidget {
  const JobFeedPage({super.key});
  static const route = '/jobs';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Feed')),
      body: const Center(child: Text('Jobs available for service providers')),
    );
  }
}

class PostJobPage extends StatelessWidget {
  const PostJobPage({super.key});
  static const route = '/post';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Job')),
      body: const Center(child: Text('Post a job for service providers to view')),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const route = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Opra')),
      body: const Center(child: Text('Welcome to Opra 🎉')),
    );
  }
}


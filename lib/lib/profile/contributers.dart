import 'package:flutter/material.dart';

class ContributorsPage extends StatefulWidget {
  const ContributorsPage({Key? key}) : super(key: key);

  @override
  _ContributorsPageState createState() => _ContributorsPageState();
}

class _ContributorsPageState extends State<ContributorsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Contributor> contributors = [
    Contributor(
      name: "Samay Patel",
      role: "ROLE",
      description: "Passionate about creating intuitive and visually appealing designs. Samay has 5 years of experience in mobile app development and specializes in user-centric design approaches.",
      image: "assets/images/samay.jpg",
      github: "github.com/samaypatel",
      linkedin: "linkedin.com/in/samaypatel",
    ),
    Contributor(
      name: "Umang Mishra",
      role: "ROLEr",
      description: "Experienced in building robust backend services. Umang has contributed to several open-source projects and loves solving complex architectural challenges.",
      image: "assets/images/umang.jpg",
      github: "github.com/umangmishra",
      linkedin: "linkedin.com/in/umangmishra",
    ),
    Contributor(
      name: "Monisha",
      role: "ROLE",
      description: "Expert in creating responsive and interactive user interfaces. Monisha has a strong background in web technologies and is passionate about accessibility in design.",
      image: "assets/images/monisha.jpg",
      github: "github.com/monisha",
      linkedin: "linkedin.com/in/monisha",
    ),
    Contributor(
      name: "Jayanth",
      role: "ROLE",
      description: "Skilled in coordinating team efforts and ensuring project success. Jayanth has managed multiple software development projects and excels in agile methodologies.",
      image: "assets/images/jayanth.jpg",
      github: "github.com/jayanth",
      linkedin: "linkedin.com/in/jayanth",
    ),
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onContributorTap(int index) {
    setState(() {
      _currentIndex = index;
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the primary and accent colors from the theme
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contributors'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Contributors list horizontally scrollable
          Container(
            height: 150,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: contributors.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onContributorTap(index),
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _currentIndex == index
                                  ? colorScheme.secondary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(contributors[index].image),
                            backgroundColor: colorScheme.surface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          contributors[index].name.split(' ')[0],
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontWeight: _currentIndex == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Contributor details
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _controller,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeOut,
                    )),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile image
                      Hero(
                        tag: contributors[_currentIndex].name,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                            image: DecorationImage(
                              image: AssetImage(contributors[_currentIndex].image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Name and role
                      Text(
                        contributors[_currentIndex].name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          contributors[_currentIndex].role,
                          style: TextStyle(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bio
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          contributors[_currentIndex].description,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Social links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialButton(
                            icon: Icons.link,
                            label: 'GitHub',
                            url: contributors[_currentIndex].github,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 16),
                          _SocialButton(
                            icon: Icons.person,
                            label: 'LinkedIn',
                            url: contributors[_currentIndex].linkedin,
                            color: colorScheme.secondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final Color color;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.url,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: () {
        // Add URL launching logic here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $url')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 3,
      ),
    );
  }
}

class Contributor {
  final String name;
  final String role;
  final String description;
  final String image;
  final String github;
  final String linkedin;

  Contributor({
    required this.name,
    required this.role,
    required this.description,
    required this.image,
    required this.github,
    required this.linkedin,
  });
}
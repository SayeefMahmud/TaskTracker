import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../theme/doto_theme.dart';
import '../widgets/category_chip.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0; // 0 = Pending, 1 = Done
  bool _isFabPressed = false;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<DotoColors>() ?? DotoColors.light;
    final provider = Provider.of<TaskProvider>(context);

    final pendingTasks = provider.pendingTasks;
    final completedTasks = provider.completedTasks;
    final currentList = _selectedTab == 0 ? pendingTasks : completedTasks;

    final todayFormatted = DateFormat('d MMMM').format(DateTime.now()).toUpperCase();
    final streak = provider.currentStreak > 0 ? provider.currentStreak : 12; // default mock if fresh

    final categories = [
      ('All', c.fg, 'all'),
      ('Work', DotoSemantic.categoryWork, 'work'),
      ('Personal', DotoSemantic.categoryPersonal, 'personal'),
      ('Health', DotoSemantic.categoryHealth, 'health'),
      ('Home', DotoSemantic.categoryHome, 'home'),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Header Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: DotoSpace.screenH,
                      right: DotoSpace.screenH,
                      top: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Eyebrow + Streak Pill
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              todayFormatted,
                              style: DotoText.eyebrow.copyWith(
                                color: c.muted,
                              ),
                            ),
                            // Streak pill
                            GlassSurface(
                              radius: DotoRadius.pill,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              shadow: DotoShadow.tabPill,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.eco_rounded,
                                    size: 14,
                                    color: DotoSemantic.success,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '$streak',
                                    style: DotoText.counter.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: c.fg,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'DAY',
                                    style: DotoText.eyebrow.copyWith(
                                      fontSize: 10,
                                      color: c.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Main Screen Title
                        Text(
                          'Your day,\nin layers',
                          style: DotoText.screenTitle.copyWith(
                            color: c.fg,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Horizontal Category Filter Carousel
                        SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: categories.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final (label, dotColor, id) = categories[index];
                              final isSelected = provider.selectedCategory == id;
                              return CategoryChip(
                                label: label,
                                dotColor: dotColor,
                                isSelected: isSelected,
                                onTap: () {
                                  provider.setSelectedCategory(id);
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Tab Switcher Pill (Pending · X / Done · Y)
                        GlassSurface(
                          radius: DotoRadius.pill,
                          padding: const EdgeInsets.all(5),
                          shadow: DotoShadow.tabPill,
                          child: Row(
                            children: [
                              // Pending tab
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _selectedTab = 0);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: AnimatedContainer(
                                    duration: DotoMotion.control,
                                    curve: DotoMotion.curve,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _selectedTab == 0 ? c.pill : Colors.transparent,
                                      borderRadius: BorderRadius.circular(DotoRadius.pill),
                                      boxShadow: _selectedTab == 0 ? DotoShadow.tabPill : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Pending · ${provider.pendingCount}',
                                        style: DotoText.tabLabel.copyWith(
                                          color: _selectedTab == 0 ? c.onPill : c.muted,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Done tab
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _selectedTab = 1);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: AnimatedContainer(
                                    duration: DotoMotion.control,
                                    curve: DotoMotion.curve,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _selectedTab == 1 ? c.pill : Colors.transparent,
                                      borderRadius: BorderRadius.circular(DotoRadius.pill),
                                      boxShadow: _selectedTab == 1 ? DotoShadow.tabPill : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Done · ${provider.completedCount}',
                                        style: DotoText.tabLabel.copyWith(
                                          color: _selectedTab == 1 ? c.onPill : c.muted,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),

                // Task List or Empty State
                if (currentList.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: DotoSpace.screenH,
                        right: DotoSpace.screenH,
                        bottom: DotoSpace.scrollBottomHome,
                      ),
                      child: EmptyStateView(
                        isCompletedTab: _selectedTab == 1,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      left: DotoSpace.screenH,
                      right: DotoSpace.screenH,
                      bottom: DotoSpace.scrollBottomHome,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final task = currentList[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: DotoSpace.cardGap),
                            child: TaskCard(
                              key: ValueKey(task.id),
                              task: task,
                            ),
                          );
                        },
                        childCount: currentList.length,
                      ),
                    ),
                  ),
              ],
            ),

            // Floating Action Button (FAB)
            Positioned(
              right: DotoSpace.fabRight,
              bottom: DotoSpace.fabBottom,
              child: GestureDetector(
                onTapDown: (_) => setState(() => _isFabPressed = true),
                onTapUp: (_) => setState(() => _isFabPressed = false),
                onTapCancel: () => setState(() => _isFabPressed = false),
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTaskScreen(),
                    ),
                  );
                  if (mounted) {
                    setState(() => _selectedTab = 0);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedScale(
                  scale: _isFabPressed ? 1.03 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: DotoMotion.curve,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: DotoMotion.curve,
                    transform: Matrix4.translationValues(0, _isFabPressed ? -3 : 0, 0),
                    width: DotoSpace.fabSize,
                    height: DotoSpace.fabSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.accent,
                      border: Border.all(color: c.edge, width: 1),
                      boxShadow: DotoShadow.fab,
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 26,
                      color: c.onAccent,
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
}

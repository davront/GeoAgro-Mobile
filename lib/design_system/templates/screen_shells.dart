import 'package:flutter/material.dart';
import 'package:agro_employee_public/design_system/tokens/adaptive_colors.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/radius.dart';
import '../theme/typography.dart';
import '../components/empty_state.dart';
import '../components/skeletons.dart';
import '../components/banners.dart';
import '../components/buttons.dart';

/// Design System Screen Templates
/// 
/// Reusable screen shells with consistent layouts:
/// - ListScreenShell - List view with search/filters
/// - DetailScreenShell - Detail view with sections
/// - FormScreenShell - Form view with validation

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LIST SCREEN SHELL
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ListScreenShell extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? searchField;
  final Widget? filterSection;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool isEmpty;
  final Widget? emptyState;
  final Widget? listContent;
  final Widget? floatingActionButton;
  final bool useSliverAppBar;

  const ListScreenShell({
    super.key,
    required this.title,
    this.actions,
    this.searchField,
    this.filterSection,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.onRetry,
    this.isEmpty = false,
    this.emptyState,
    this.listContent,
    this.floatingActionButton,
    this.useSliverAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    if (useSliverAppBar) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(title),
              floating: true,
              pinned: false,
              actions: actions,
              bottom: searchField != null || filterSection != null
                  ? PreferredSize(
                      preferredSize: Size.fromHeight(
                        (searchField != null ? 60.0 : 0) +
                            (filterSection != null ? 60.0 : 0),
                      ),
                      child: Column(
                        children: [
                          if (searchField != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              child: searchField!,
                            ),
                          if (filterSection != null) filterSection!,
                        ],
                      ),
                    )
                  : null,
            ),
            if (hasError)
              SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: AppErrorBanner(
                    message: errorMessage ?? "Xatolik yuz berdi",
                    onRetry: onRetry,
                  ),
                ),
              )
            else if (isLoading)
              const SliverFillRemaining(
                child: AppSkeletonList(itemCount: 8),
              )
            else if (isEmpty)
              SliverFillRemaining(
                child: emptyState ?? const AppEmptyListState(),
              )
            else if (listContent != null)
              SliverToBoxAdapter(child: listContent!),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    }

    // Standard AppBar layout
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: Column(
        children: [
          if (searchField != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: searchField!,
            ),
          if (filterSection != null) filterSection!,
          Expanded(
            child: hasError
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: AppErrorBanner(
                      message: errorMessage ?? "Xatolik yuz berdi",
                      onRetry: onRetry,
                    ),
                  )
                : isLoading
                    ? const AppSkeletonList(itemCount: 8)
                    : isEmpty
                        ? emptyState ?? const AppEmptyListState()
                        : listContent ?? const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DETAIL SCREEN SHELL
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class DetailScreenShell extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? summaryCard;
  final List<DetailSection>? sections;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget? floatingActionButton;

  const DetailScreenShell({
    super.key,
    required this.title,
    this.actions,
    this.summaryCard,
    this.sections,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.onRetry,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: hasError
          ? Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppErrorBanner(
                message: errorMessage ?? "Xatolik yuz berdi",
                onRetry: onRetry,
              ),
            )
          : isLoading
              ? const SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      AppSkeletonCard(),
                      SizedBox(height: AppSpacing.lg),
                      AppSkeletonCard(),
                      SizedBox(height: AppSpacing.lg),
                      AppSkeletonCard(),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (summaryCard != null) ...[
                        summaryCard!,
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (sections != null && sections!.isNotEmpty)
                        ...sections!.map((section) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.lg,
                              ),
                              child: _DetailSectionWidget(section: section),
                            )),
                    ],
                  ),
                ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class DetailSection {
  final String title;
  final IconData? icon;
  final Widget content;

  DetailSection({
    required this.title,
    this.icon,
    required this.content,
  });
}

class _DetailSectionWidget extends StatelessWidget {
  final DetailSection section;

  const _DetailSectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (section.icon != null) ...[
              Icon(
                section.icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              section.title,
              style: AppTypography.headlineMedium(context),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        section.content,
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FORM SCREEN SHELL
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class FormScreenShell extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final List<FormSection>? sections;
  final String submitLabel;
  final VoidCallback? onSubmit;
  final bool isSubmitting;
  final bool isValid;
  final String? errorMessage;

  const FormScreenShell({
    super.key,
    required this.title,
    this.actions,
    this.sections,
    this.submitLabel = "Saqlash",
    this.onSubmit,
    this.isSubmitting = false,
    this.isValid = true,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: Column(
        children: [
          if (errorMessage != null)
            AppErrorBanner(
              message: errorMessage!,
              margin: const EdgeInsets.all(AppSpacing.md),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sections != null && sections!.isNotEmpty)
                    ...sections!.map((section) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.lg,
                          ),
                          child: _FormSectionWidget(section: section),
                        )),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppButton(
                text: submitLabel,
                onPressed: isValid && !isSubmitting ? onSubmit : null,
                isLoading: isSubmitting,
                isFullWidth: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FormSection {
  final String? title;
  final IconData? icon;
  final List<Widget> fields;

  FormSection({
    this.title,
    this.icon,
    required this.fields,
  });
}

class _FormSectionWidget extends StatelessWidget {
  final FormSection section;

  const _FormSectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.title != null) ...[
            Row(
              children: [
                if (section.icon != null) ...[
                  Icon(
                    section.icon,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  section.title!,
                  style: AppTypography.headlineSmall(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          ...section.fields.map((field) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: field,
              )),
        ],
      ),
    );
  }
}


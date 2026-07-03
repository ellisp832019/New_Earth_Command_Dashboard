# Add to Dashboard

## Suggested path
`modules/24_NEW_EARTH_EDUCATION_AND_LEARNING_HUB/`

## Registry entry
Add the module to your dashboard module registry with:
- id: `24_NEW_EARTH_EDUCATION_AND_LEARNING_HUB`
- title: Education & Learning Hub
- icon: `school_outlined`
- route: `/modules/education-learning-hub`
- status: active
- category: Knowledge & Research

## Navigation entry
Add a quick-open tile in the More screen for:
- Education & Learning Hub

## Route hook
The dashboard route should open the module screen directly from:
- `lib/core/routing/app_router.dart`
- `lib/features/more/presentation/more_screen.dart`

## First build target
Show the Education Dashboard with mock data and tab navigation to the pathway, lesson, project, progress, tutor, mentor, assessment, reflection, certificate, and settings views.

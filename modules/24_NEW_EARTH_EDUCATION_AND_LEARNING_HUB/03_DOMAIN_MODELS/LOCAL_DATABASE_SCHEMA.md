# Local Database Schema

Recommended tables:

- learners
- pathways
- units
- lessons
- projects
- skills
- badges
- reflections
- assessments
- quiz_attempts
- project_evidence
- mentor_notes
- content_packs
- settings

## Storage approach
For content-heavy lessons, keep Markdown files in `/content`. Store progress and metadata in the local database.

## Sync approach
Core v1 should not require cloud sync. Export/import content packs as zip files or JSON bundles.

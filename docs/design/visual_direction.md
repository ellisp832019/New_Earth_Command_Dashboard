# Visual Direction

The PNG assets already define a strong New Earth visual language. This page turns those assets into practical guidance for app screens, documentation, and future design work.

## Core Mood

New Earth Command Dashboard should feel calm, focused, private, and purposeful.

The app is not a busy productivity cockpit. It is a daily command centre that helps the user answer:

> What should I focus on today to move New Earth forward?

## Asset-Led Direction

Use these assets as visual references:

- `assets/branding/40_brand_style_guide.png` is the main brand reference.
- `assets/branding/new_earth_command_dashboard_12_colour_palette.png` is the quick palette strip.
- `assets/screenshots/27_mobile_app_screens_overview.png` shows the broader mobile product direction.
- `assets/screenshots/new_earth_command_dashboard_02_dashboard_mockup.png` through `06_more_mockup.png` show the lighter in-app MVP direction.
- `assets/repo/41_github_docs_folder_map.png` gives a strong model for documentation structure.

## Colour Guidance

The assets use two related palettes:

### Documentation and Marketing Palette

This is the dark, high-contrast style used in repo banners, diagrams, app store visuals, and the brand guide.

- Deep near-black navy backgrounds.
- Lime green as the primary signal colour.
- Electric blue for information and secondary emphasis.
- White text for contrast.
- Occasional purple, orange, red, and cyan semantic accents.

Use this palette for:

- README hero visuals.
- GitHub documentation images.
- Architecture diagrams.
- User-guide screenshots and covers.
- App store or promotional material.

### In-App MVP Palette

The current Flutter theme uses a calmer app palette:

- Warm off-white background.
- Soft surface cards.
- Sage green primary actions.
- Warm brown secondary colour.
- Charcoal text.
- Muted grey-green secondary text.
- Light outline borders.

Use this palette for the actual V0.1 app UI unless the current task explicitly changes the theme.

The split matters: documentation can be dramatic and branded, while the working app should stay clear, soft, and low-overwhelm.

## Current Flutter Theme Alignment

Current theme colours in `lib/core/theme/app_colours.dart`:

- `seed`: `#5E7D5A`
- `background`: `#F8F5EE`
- `surface`: `#FFFCF7`
- `primary`: `#426B4B`
- `secondary`: `#8A6F4D`
- `charcoal`: `#202722`
- `mutedText`: `#687168`
- `outline`: `#E2DDD3`

These fit the lighter MVP mockups and should remain the default for app-shell work.

## Layout Guidance

Use simple, focused layouts:

- Dashboard first.
- One clear main focus area.
- Top 3 tasks visible without clutter.
- Cards for grouped information, not decoration.
- Bottom navigation limited to Dashboard, Projects, Tasks, Planner, and More.
- More screen holds supporting modules so the primary navigation stays calm.

Avoid:

- Overloading the dashboard with every future feature.
- Heavy visual effects inside the app UI.
- Too many competing accent colours on one screen.
- Marketing-style hero layouts inside the working app.

## Documentation Layout Guidance

Documentation can use the darker asset style more confidently:

- Start pages with a visual where it genuinely helps orientation.
- Use repo assets to explain structure, roadmap, and architecture.
- Keep Markdown pages short enough to scan.
- Link back to the FSD and current task when explaining implementation.

## Voice and Tone

Use calm, practical New Earth wording:

- "Carry Forward" instead of "failed".
- "Parked" instead of "abandoned".
- "Today" and "next useful action" over abstract productivity language.
- "Local-first" and "private by design" where privacy is relevant.

## Asset Usage Rules

- Keep `assets/branding` for brand identity.
- Keep `assets/screenshots` for app screen references and mockups.
- Keep `assets/diagrams` for architecture, flows, database, and process visuals.
- Keep `assets/repo` for README and GitHub-facing documentation.
- Keep `assets/user_guide` for help pages and user documentation.
- Use existing assets before generating new ones.
- If an image is needed inside the Flutter app later, add it deliberately to `pubspec.yaml`; the current asset library is primarily documentation/reference material.

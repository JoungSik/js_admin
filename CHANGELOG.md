# Changelog

## Unreleased

- Add index search across string and text columns, configurable with `fields search:`.
- Add index filters for `belongs_to`, enum, and boolean columns, kept across pagination and deletes.

- Add `fields` configuration to choose visible columns for the index, detail, and form screens, and to hide columns by model.
- Hide columns matching the host application's `filter_parameters` by default, with `hide_filtered_columns` to disable it.

- Show an alert instead of a success notice when a record deletion is blocked by dependent records or foreign key constraints.
- Render polymorphic `belongs_to` columns as plain inputs instead of failing to load the form.

## 0.2.0 - 2026-10-18

- Add host application authentication and authorization callbacks as an alternative to Basic Auth.
- Reject conflicting or incomplete authentication configuration with localized errors.
- Add English and Korean I18n translations for the JSAdmin interface.
- Add `select_options` configuration to render a column as a select with static or callable choices.

## 0.1.0 - 2026-07-18

- Change the default mount path to `/admin`.
- Add optional HTTP Basic Auth configuration.
- Generate a commented `config/initializers/js_admin.rb` during installation.
- Pin JSAdmin JavaScript through `importmap-rails` during installation.
- Add sidebar model navigation with namespace grouping.
- Use Turbo Frames, Turbo Streams, and Stimulus controllers for the admin shell.
- Add fixed header/sidebar layout, dark mode support, and improved Tailwind UI spacing.
- Add compact pagination controls and set the default page size to 10 records.
- Add `View`, `Edit`, and `Delete` actions to resource tables.
- Render form validation errors inline without Rails `field_with_errors` layout wrappers.
- Add sandbox setup for browser testing with richer demo models and seed data.
- Add AGENTS/CLAUDE project guidance files for LLM-assisted development.

## 0.0.1 - 2026-07-12

- Initial release for RubyGems publishing test.

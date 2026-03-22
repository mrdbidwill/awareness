# Test Coverage Plan

## Current Status
- **Tests**: 717 passing
- **Coverage**: 7.59% (Target: 80%)
- **Test Files**: 82

## Missing Tests

### Controllers (32 missing)
- [ ] admin/application_controller
- [ ] admin/articles_controller
- [ ] admin/dashboard_controller
- [ ] admin/dna_sequences_controller
- [ ] admin/fungus_types_controller
- [ ] admin/lenses_controller
- [ ] admin/lookup_items_controller
- [ ] admin/mb_lists_controller
- [ ] admin/mr_characters_controller
- [ ] admin/mr_characters_sources_controller
- [ ] admin/permissions_controller
- [ ] admin/roles_controller
- [ ] admin/source_data_types_controller
- [ ] admin/states_controller
- [ ] admin/storage_locations_controller
- [ ] admin/utility_controller
- [ ] application_controller
- [ ] articles_controller
- [ ] books_controller
- [ ] contacts_controller
- [ ] genus_mushrooms_controller
- [ ] home_controller
- [ ] image_mushrooms_controller
- [ ] mr_character_mushrooms_controller
- [ ] mushroom_projects_controller
- [ ] mushroom_search_controller
- [ ] mushroom_species_controller
- [ ] pages_controller
- [ ] projects_controller
- [ ] states_controller
- [ ] users/registrations_controller
- [ ] users/sessions_controller
- [ ] users/two_factor_authentication_controller
- [ ] users/two_factor_settings_controller
- [ ] users_controller

### Policies (35 missing tests)
- [ ] admin_policy
- [ ] all_group_mushroom_policy
- [ ] all_group_policy
- [ ] application_policy
- [ ] article_policy
- [ ] cluster_mushroom_policy
- [ ] cluster_policy
- [ ] color_policy
- [ ] country_policy
- [ ] database_export_policy
- [ ] display_option_policy
- [ ] dna_sequence_policy
- [ ] fungus_type_policy
- [ ] genus_mushroom_policy
- [ ] genus_policy
- [ ] image_mushroom_policy
- [ ] lens_policy
- [ ] lookup_item_policy
- [ ] mr_character_policy
- [ ] mushroom_plant_policy
- [ ] mushroom_project_policy
- [ ] mushroom_species_policy
- [ ] mushroom_tree_policy
- [ ] observation_method_policy
- [ ] part_policy
- [ ] permission_policy
- [ ] plant_policy
- [ ] project_policy
- [ ] role_policy
- [ ] source_data_policy
- [ ] source_data_type_policy
- [ ] species_policy
- [ ] state_policy
- [ ] storage_location_policy
- [ ] tree_policy

### Mailers (2 missing)
- [ ] contact_mailer_test
- [ ] devise_mailer_test

### Jobs (0 missing - CompareMushroomsJob already tested)
✓ All jobs tested

### Integration Tests (needed)
- [ ] Authentication flow (login, logout, 2FA)
- [ ] Mushroom CRUD workflow
- [ ] Image upload and association
- [ ] Search functionality
- [ ] Admin workflows
- [ ] Authorization flows

### System Tests (expand existing 4)
- [ ] Mushroom creation with images
- [ ] Search and filter
- [ ] Mobile navigation
- [ ] Admin dashboard
- [ ] User registration and 2FA setup

### Request/API Tests
- [ ] JSON API endpoints
- [ ] Autocomplete endpoints
- [ ] Data export endpoints

### Performance Tests
- [ ] N+1 query detection
- [ ] Database query optimization
- [ ] Large dataset handling

## Implementation Order
1. ✅ Setup (SimpleCov, FactoryBot, parallel tests, support files)
2. Mailer tests (quick wins)
3. Policy tests (security critical)
4. Controller tests (bulk of work)
5. Integration tests (user flows)
6. System tests (UI/UX)
7. Request tests (API)
8. Performance tests
9. Mutation testing setup
10. CI/CD integration

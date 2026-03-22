-- keep parts out of lookup_items
INSERT INTO `parts` (`id`, `name`, `description`, `comments`, `created_at`, `updated_at`) VALUES
(1, 'Admin', '',  '' , now(), now()),
(2, 'Basic', '', '' , now(), now()),
(3, 'Cap', '', '' , now(), now()),
(4, 'Gills', '','' , now(), now()),
(5, 'Stem', '','' , now(), now()),
(6, 'Veil', '','' , now(), now()),
(7, 'Mycelium', '','' , now(), now()),
(8, 'Spores', 'micro for spores is here - not in micro','' , now(), now()),
(9, 'Micro', '','' , now(), now()),
(10, 'DNA', '', '' , now(), now()),
(11, 'Habitat', 'Habitat, Plant Assoc ','' , now(), now()),
(12, 'Rhizomorph', '', '' , now(), now()),
(13, 'Chemical Reaction', '', '' , now(), now()),
(14, 'Color', 'this will allow color selection for ALL color characters to be in one place', '' , now(), now()),
(15, 'Location', 'lat lon city county state country','' , now(), now()),
(16, 'Identification', 'species genus inaturalist etc','' , now(), now()),
(17, 'Storage', '','' , now(), now());

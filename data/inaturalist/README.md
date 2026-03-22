# iNaturalist Observation Fields Dataset

## Overview

This dataset contains a complete list of all observation fields available on [iNaturalist](https://www.inaturalist.org), particularly useful for mushroom and fungi identification projects.

**Total Fields:** 19,522
**Last Updated:** February 13, 2026
**Source:** [iNaturalist API](https://www.inaturalist.org/pages/api+reference#get-observation_fields)

## Why This Dataset?

Observation fields on iNaturalist are user-created metadata fields that can be attached to observations. While extremely useful, there are issues with:
- **Duplication** - Multiple fields serving the same purpose
- **Inconsistency** - Varying naming conventions and data types
- **Discoverability** - Difficult to find existing fields before creating new ones

This dataset helps researchers and observers find existing observation fields to use rather than creating duplicates, improving data quality and consistency across the platform.

## Files

### `observation_fields.csv`
Standard CSV format, compatible with Excel, Google Sheets, LibreOffice, and data analysis tools.

**Columns:**
- `id` - Unique identifier
- `name` - Display name of the field
- `datatype` - Type of data (text, numeric, date, taxon, etc.)
- `user_id` - Creator's user ID
- `description` - Detailed description of the field's purpose
- `created_at` - When the field was created
- `updated_at` - Last modification date
- `allowed_values` - Predefined options (for dropdown fields)
- `values_count` - Number of times this field has been used
- `users_count` - Number of unique users who have used this field
- `uuid` - Universal unique identifier

### `observation_fields.json`
JSON format for programmatic access and web applications. Contains the same data as the CSV file.

## Usage Examples

### Finding Mushroom-Related Fields

**Excel/Sheets:**
Filter the `name` or `description` columns for keywords like "mushroom", "fungi", "spore", "cap", "gill", etc.

**Command Line:**
```bash
grep -i "mushroom\|fungi\|spore" observation_fields.csv
```

**Python:**
```python
import pandas as pd
df = pd.read_csv('observation_fields.csv')
mushroom_fields = df[df['name'].str.contains('mushroom|fungi|spore', case=False, na=False)]
```

### Finding Most Used Fields
Sort by `values_count` or `users_count` to find the most popular fields in your area of interest.

### Avoiding Duplicates
Before creating a new observation field, search this dataset to see if a similar field already exists.

## Data Collection Method

Data was collected via the [iNaturalist Observation Fields API](https://www.inaturalist.org/observation_fields.json) using a systematic pagination approach with rate limiting to be respectful to the API.

See the Rails script in `lib/tasks/inaturalist_observation_fields.rake` for implementation details.

## Updates

This dataset is a snapshot from February 13, 2026. As new observation fields are created on iNaturalist daily, this data will become outdated over time.

To refresh the data, run:
```bash
rails inaturalist:observation_fields
rails inaturalist:csv_to_json
```

## Related Links

- [iNaturalist Observation Fields](https://www.inaturalist.org/observation_fields)
- [iNaturalist API Documentation](https://www.inaturalist.org/pages/api+reference)
- [Forum Discussion](https://forum.inaturalist.org/t/how-can-i-download-the-complete-list-of-observation-fields/33345)

## License

This data is derived from iNaturalist's public API. Please respect [iNaturalist's Terms of Service](https://www.inaturalist.org/pages/terms) when using this data.

## Contributing

Found an issue or have suggestions? Please open an issue on the [GitHub repository](https://github.com/mrdbidwill/mrdbid).

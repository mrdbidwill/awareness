# iNaturalist Forum Post - Complete Observation Fields Dataset

## Post Title
Complete iNaturalist Observation Fields Dataset (19,522 fields) - February 2026

## Post Content

Hi everyone,

Following up on the discussion about downloading observation fields, I've created a complete, up-to-date dataset of all **19,522 observation fields** currently on iNaturalist (as of February 13, 2026).

### Why This Matters

Many of us work with observation fields for mushrooms, fungi, and other taxa. However, there's often confusion and duplication because it's hard to know what fields already exist. This dataset helps by:

- Making all fields searchable before creating new ones
- Identifying duplicates and similar fields
- Finding the most-used fields in your area of interest
- Improving data consistency across observations

### Download Options

**Option 1: Direct Downloads**
- [CSV Format](https://github.com/mrdbidwill/mrdbid/raw/main/data/inaturalist/observation_fields.csv) (4.6 MB) - Works with Excel, Google Sheets, LibreOffice
- [JSON Format](https://github.com/mrdbidwill/mrdbid/raw/main/data/inaturalist/observation_fields.json) (8.8 MB) - For developers

**Option 2: Interactive Web View**
- [Browse and search online](https://mrdbid.com/inaturalist/observation_fields) - View first 100 fields with search functionality

**Option 3: GitHub Repository**
- [Full repository with documentation](https://github.com/mrdbidwill/mrdbid/tree/main/data/inaturalist)

### What's Included

Each observation field includes:
- ID and name
- Data type (text, numeric, date, taxon, etc.)
- Description
- Allowed values (for dropdown fields)
- Usage statistics (how many times used, by how many users)
- Creation and update timestamps
- UUID

### Example Uses

**For Mushroom/Fungi Observers:**
Search for keywords like "mushroom", "fungi", "spore", "cap", "gill", "mycelium" to find relevant fields before creating new ones.

**Finding Popular Fields:**
Sort by `values_count` or `users_count` to see which fields are most commonly used.

### Technical Details

The dataset was collected using a Rails script that queries the [iNaturalist API](https://www.inaturalist.org/pages/api+reference#get-observation_fields) with proper rate limiting (1-second delays between requests) to be respectful to the platform.

**For developers:** The Ruby/Rails scripts are available in the repository at:
- `lib/tasks/inaturalist_observation_fields.rake` - Fetches data from API
- `lib/tasks/convert_csv_to_json.rake` - Converts CSV to JSON

### Updates

This is a snapshot from February 2026. Since new observation fields are created daily, the data will become outdated over time. I plan to update this quarterly, but you can also run the scripts yourself to get fresh data.

### License & Credit

This data comes from iNaturalist's public API. Please respect [iNaturalist's Terms of Service](https://www.inaturalist.org/pages/terms) when using this data.

Special thanks to jwidness Forum Moderator in the original thread July 2022 for the Python script that inspired this work!

---

**Questions? Issues?**
Please report any problems or suggestions on the [GitHub repository](https://github.com/mrdbidwill/mrdbid/issues).

Hope this helps the community! 🍄


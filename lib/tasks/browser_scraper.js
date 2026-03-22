// Mushroom Observer Glossary Scraper
// Run this in browser console on https://mushroomobserver.org/glossary_terms
// This will collect all terms from all 55 pages

(async function() {
  const terms = [];
  const totalPages = 55;

  console.log('Starting glossary scraper...');

  for (let page = 1; page <= totalPages; page++) {
    console.log(`Processing page ${page} of ${totalPages}...`);

    // Navigate to page if not on page 1
    if (page > 1) {
      const url = `https://mushroomobserver.org/glossary_terms?page=${page}`;
      window.location.href = url;

      // Wait for page to load
      await new Promise(resolve => setTimeout(resolve, 2000));
    }

    // Extract terms from current page
    // You'll need to inspect the page and update these selectors
    const termElements = document.querySelectorAll('.glossary-entry'); // UPDATE THIS SELECTOR

    termElements.forEach(el => {
      const term = el.querySelector('.term-name')?.innerText?.trim(); // UPDATE THIS SELECTOR
      const definition = el.querySelector('.definition')?.innerText?.trim(); // UPDATE THIS SELECTOR

      if (term && definition) {
        terms.push({ term, definition });
      }
    });

    console.log(`Found ${termElements.length} terms on page ${page}`);
  }

  console.log(`\nTotal terms collected: ${terms.length}`);
  console.log('\nCopy the output below and save to tmp/glossary_terms.json:\n');
  console.log(JSON.stringify(terms, null, 2));

  // Also download as file
  const blob = new Blob([JSON.stringify(terms, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'glossary_terms.json';
  a.click();

  console.log('\nFile downloaded as glossary_terms.json');
})();

// INSTRUCTIONS:
// 1. Visit https://mushroomobserver.org/glossary_terms
// 2. Open DevTools (F12) and go to Console tab
// 3. First, inspect the page to find the correct CSS selectors:
//    - Right-click on a glossary term and "Inspect"
//    - Find the container class for each term
//    - Find the class for term name
//    - Find the class for definition
// 4. Update the selectors in this script (lines marked with "UPDATE THIS SELECTOR")
// 5. Paste this entire script and press Enter
// 6. Wait for it to complete (may take 2-3 minutes for 55 pages)
// 7. The file will auto-download, or copy from console output
// 8. Save to tmp/glossary_terms.json in your Rails app
// 9. Run: rails glossary:import

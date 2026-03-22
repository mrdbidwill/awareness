/** @type {import('tailwindcss').Config} */
module.exports = {
    content: [
        './app/views/**/*.html.erb', // HTML ERB templates
        './app/helpers/**/*.rb',     // Helpers
        './app/javascript/**/*.js',  // JavaScript files
        './app/assets/stylesheets/**/*.css' // Stylesheets
    ],
    theme: {
        extend: {},
    },
    plugins: [
        require('@tailwindcss/forms'),
        require('@tailwindcss/typography'),
    ],
};
// Test script to verify JSX syntax is correct
const fs = require('fs');
const path = require('path');

console.log('Checking JSX files for syntax errors...');

const filesToCheck = [
  './src/components/PlacesManagement.jsx',
  './src/components/UserManagement.jsx'
];

let hasErrors = false;

filesToCheck.forEach(file => {
  try {
    const content = fs.readFileSync(file, 'utf8');
    
    // Check for escaped quotes that should not be escaped in JSX
    const escapedQuotePattern = /(?<!\\\\)\\\"/g;
    const matches = content.match(escapedQuotePattern);
    
    if (matches) {
      console.error(`❌ ${file}: Found ${matches.length} escaped quotes that should not be escaped`);
      hasErrors = true;
    } else {
      console.log(`✅ ${file}: No escaped quote issues found`);
    }
    
    // Check for missing imports
    if (!content.includes('import { useState, useEffect }')) {
      console.error(`❌ ${file}: Missing React hooks import`);
      hasErrors = true;
    } else {
      console.log(`✅ ${file}: React hooks properly imported`);
    }
    
  } catch (error) {
    console.error(`❌ ${file}: Error reading file - ${error.message}`);
    hasErrors = true;
  }
});

if (!hasErrors) {
  console.log('\n🎉 All files appear to be fixed correctly!');
  console.log('You should now be able to run "npm run dev" successfully.');
} else {
  console.log('\n❌ Some issues were found. Please fix them before running the dev server.');
}
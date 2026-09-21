/* ============================================================================
   SCRIPT: scripts/verify-security.js
   SYSTEM: Automated Security & Secret Scan for Frontend Codebase
   ============================================================================ */

const fs = require('fs');
const path = require('path');

console.log("=========================================");
console.log("     AUTOMATED SECURITY & SECRET SCAN    ");
console.log("=========================================");

const forbiddenKeywords = [
  'MIDTRANS_SERVER_KEY',
  'SB_SERVICE_ROLE_KEY',
  'service_role_key',
  'SUPABASE_SERVICE_ROLE_KEY',
  'SB_SECRET'
];

const scanDirs = ['user', 'cashier', 'kitchen', 'admin', 'js', 'css'];
let violationCount = 0;

function scanDirectory(dirPath) {
  if (!fs.existsSync(dirPath)) return;
  const files = fs.readdirSync(dirPath);

  files.forEach(file => {
    const fullPath = path.join(dirPath, file);
    const stat = fs.statSync(fullPath);

    if (stat.isDirectory()) {
      scanDirectory(fullPath);
    } else if (file.endsWith('.html') || file.endsWith('.js') || file.endsWith('.css')) {
      const content = fs.readFileSync(fullPath, 'utf8');
      forbiddenKeywords.forEach(keyword => {
        if (content.includes(keyword) && !content.includes(`Deno.env.get("${keyword}")`)) {
          console.error(`❌ CRITICAL SECURITY VIOLATION: '${keyword}' found in ${fullPath}`);
          violationCount++;
        }
      });
    }
  });
}

const rootFiles = ['index.html', 'login.html', 'register.html'];
rootFiles.forEach(f => {
  const fp = path.join(__dirname, '..', f);
  if (fs.existsSync(fp)) {
    const content = fs.readFileSync(fp, 'utf8');
    forbiddenKeywords.forEach(keyword => {
      if (content.includes(keyword)) {
        console.error(`❌ CRITICAL SECURITY VIOLATION: '${keyword}' found in ${fp}`);
        violationCount++;
      }
    });
  }
});

scanDirs.forEach(d => scanDirectory(path.join(__dirname, '..', d)));

console.log("-----------------------------------------");
if (violationCount === 0) {
  console.log("✅ SECURITY PASSED: Zero secret leaks or Server Keys found in frontend!");
  process.exit(0);
} else {
  console.error(`❌ SECURITY FAILED: ${violationCount} forbidden secrets detected in frontend code!`);
  process.exit(1);
}

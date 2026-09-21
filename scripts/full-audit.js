/* ============================================================================
   SCRIPT: scripts/full-audit.js
   SYSTEM: Comprehensive master audit script for all system components
   ============================================================================ */

const { execSync } = require('child_process');
const path = require('path');

console.log("=================================================");
console.log("     STARTING COMPREHENSIVE FULL AUDIT RUN      ");
console.log("=================================================");

function runStep(scriptName, description) {
  console.log(`\n▶ [STEP] Running ${description}...`);
  try {
    const scriptPath = path.join(__dirname, scriptName);
    const output = execSync(`node "${scriptPath}"`, { encoding: 'utf8' });
    console.log(output);
    return true;
  } catch (err) {
    console.error(`❌ FAILED at ${scriptName}:`, err.stdout || err.message);
    return false;
  }
}

const s1 = runStep('verify-assets.js', '1. Product Asset Verification');
const s2 = runStep('verify-schema.js', '2. PostgreSQL Database Schema & RLS Audit');
const s3 = runStep('verify-security.js', '3. Secret Leak & Frontend Security Scan');

console.log("\n=================================================");
if (s1 && s2 && s3) {
  console.log("🎉 FULL AUDIT PASSED: ALL SYSTEM CHECKS PASSED WITH ZERO ERRORS!");
  process.exit(0);
} else {
  console.error("❌ FULL AUDIT FAILED: ONE OR MORE AUDIT CHECKS FAILED!");
  process.exit(1);
}

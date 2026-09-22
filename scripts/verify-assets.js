/* ============================================================================
   SCRIPT: scripts/verify-assets.js
   SYSTEM: Automated asset verification check for product image files
   ============================================================================ */

const fs = require('fs');
const path = require('path');

const requiredAssets = [
  'airmineral.webp',
  'esgobaksodor.webp',
  'hero-banner.png',
  'Hero.png',
  'lemontea.webp',
  'lumpiaudang.webp',
  'mie gacoan.webp',
  'miehompimpa.webp',
  'miesuit.webp',
  'orange.webp',
  'pangsitgoreng.webp',
  'siomay.webp',
  'Tea.webp',
  'thaigreentea.webp',
  'thaitea.webp',
  'udahngrambutan.webp',
  'udangkeju.webp'
];

console.log("=========================================");
console.log("   AUTOMATED ASSET VERIFICATION AUDIT   ");
console.log("=========================================");

const assetDir = path.join(__dirname, '..', 'asset');
let missingCount = 0;

if (!fs.existsSync(assetDir)) {
  console.error(`[FAIL] CRITICAL: Asset directory not found at ${assetDir}`);
  process.exit(1);
}

requiredAssets.forEach(asset => {
  const filePath = path.join(assetDir, asset);
  if (fs.existsSync(filePath)) {
    const stats = fs.statSync(filePath);
    console.log(`  [OK] ${asset.padEnd(22)} - ${(stats.size / 1024).toFixed(1)} KB`);
  } else {
    console.error(`  [MISSING] [FAIL] ${asset}`);
    missingCount++;
  }
});

console.log("-----------------------------------------");
if (missingCount === 0) {
  console.log("[PASS] SUCCESS: All 17 product assets are present and valid!");
  process.exit(0);
} else {
  console.error(`[FAIL] FAILED: ${missingCount} required assets are missing!`);
  process.exit(1);
}

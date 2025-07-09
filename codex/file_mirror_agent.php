<?php
// 📄 File: E:\LocalClone\Vera\vera-truth-system\codex\file_mirror_agent.php
// 🧭 Purpose: Automatically replicate key high-traffic files to mirror destinations (E: only)
// 🛠️ Created: 2025-07-07
// 🔁 Updated with each clean/log phase run

$map = [
  'E:\LocalClone\Vera\logs\mission_history.json' => 'E:\LocalClone\Vera\switchboard\mirrors\mission_history.json',
  'E:\LocalClone\Vera\logs\service_index.json' => 'E:\LocalClone\Vera\codex\cache\service_index.json',
  'E:\LocalClone\Vera\vera-dashboard\logs\house_cleaning_execution.json' => 'E:\LocalClone\Vera\build\logs\house_cleaning_execution.json'
];

foreach ($map as $source => $target) {
  if (!file_exists($source)) {
    echo "❌ Missing: $source\n";
    continue;
  }
  
  $targetDir = dirname($target);
  if (!is_dir($targetDir)) mkdir($targetDir, 0777, true);

  copy($source, $target);
  echo "✅ Mirrored: $source → $target\n";
}

exit("\nMirror sync complete. All active logs now aligned across E:.\n");

<?php
// 📄 File: E:\LocalClone\Vera\vera-truth-system\codex\regen_truth_logs.php
// 🧠 Purpose: Regenerates required logs and seeds them to their correct E:\ locations
// 🛠️ Created: 2025-07-07

$files = [
  // Official targets
  'E:\LocalClone\Vera\logs\mission_history.json' => [
    ["timestamp" => date('c'), "updates" => ["Initialized mission history"]]
  ],
  'E:\LocalClone\Vera\logs\service_index.json' => [
    "Services" => [], "Scripts" => [], "UI" => [], "Truth" => [],
    "generated_at" => date('c')
  ],
  'E:\LocalClone\Vera\vera-dashboard\logs\house_cleaning_execution.json' => [
    "phases" => [], "status" => "pending", "updated_at" => date('c')
  ]
];

foreach ($files as $path => $data) {
  $dir = dirname($path);
  if (!is_dir($dir)) mkdir($dir, 0777, true);
  file_put_contents($path, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
  echo "✅ Created: $path\n";
}

echo "\nTruth log regeneration complete. All primary logs are now correctly placed in E:\.\n";

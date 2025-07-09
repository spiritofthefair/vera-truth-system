// Switchboard Dashboard App (Live Log Sync)
import React, { useEffect, useState } from 'react';
import { Card, CardContent } from '@/components/ui/card';
import { Progress } from '@/components/ui/progress';

export default function SwitchboardDashboard() {
  const [phases, setPhases] = useState([]);

  useEffect(() => {
    fetch('/logs/house_cleaning_execution.json')
      .then(res => res.json())
      .then(data => setPhases(data.phases || []))
      .catch(err => console.error('Failed to load mission log:', err));
  }, []);

  return (
    <div className="grid grid-cols-1 gap-4 p-6">
      <h1 className="text-2xl font-bold">System Master Workflow</h1>
      {phases.length === 0 && (
        <div className="text-gray-500 text-center">No mission data available.</div>
      )}
      {phases.map(phase => (
        <Card key={phase.id} className="rounded-2xl shadow-md">
          <CardContent className="p-4">
            <div className="flex justify-between items-center">
              <span className="font-semibold text-lg">{phase.label}</span>
              <span className={`text-sm capitalize ${phase.status === 'in progress' ? 'text-yellow-600' : phase.status === 'complete' ? 'text-green-600' : 'text-gray-500'}`}>
                {phase.status}
              </span>
            </div>
            <Progress value={phase.status === 'complete' ? 100 : phase.status === 'in progress' ? 50 : 0} />
          </CardContent>
        </Card>
      ))}
    </div>
  );
}

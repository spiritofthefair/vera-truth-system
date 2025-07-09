import React, { useEffect, useState } from 'react';
import './App.css';

function App() {
  const [phases, setPhases] = useState([]);

  useEffect(() => {
    fetch('/logs/house_cleaning_execution.json')
      .then(res => res.json())
      .then(data => setPhases(data.phases || []))
      .catch(err => console.error('Failed to load mission log:', err));
  }, []);

  return (
    <div className="App">
      <h1>System Master Workflow</h1>
      <ul>
        {phases.map(phase => (
          <li key={phase.id}>
            {phase.label} — <strong>{phase.status}</strong>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
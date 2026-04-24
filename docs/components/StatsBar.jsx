const StatsBar = () => (
  <section className="stats-bar">
    <div className="container stats-grid">
      <div className="stat"><div className="stat-num">36</div><div className="stat-label">Modules</div></div>
      <div className="stat"><div className="stat-num">5</div><div className="stat-label">Phases</div></div>
      <div className="stat"><div className="stat-num">7.4<span className="u">GB</span></div><div className="stat-label">RAM ceiling</div></div>
      <div className="stat"><div className="stat-num">0</div><div className="stat-label">Cloud deps</div></div>
      <div className="stat"><div className="stat-num">∞</div><div className="stat-label">Yours forever</div></div>
    </div>
  </section>
);
window.StatsBar = StatsBar;

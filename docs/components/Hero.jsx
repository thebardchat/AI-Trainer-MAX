const Hero = () => (
  <section className="hero">
    <div className="container">
      <span className="t-tagline">Angel Cloud AI Training Tools · ACATT</span>
      <h1 className="h-display chrome">Local AI literacy,<br/>for every person.</h1>
      <p className="lead hero-lead">
        A CLI-based training system that takes Windows users from <em>installing their first model</em> to <em>passing down a personal AI brain</em> their family can still run after they're gone.
      </p>
      <div className="hero-ctas">
        <a className="btn btn-primary" href="https://github.com/thebardchat/AI-Trainer-MAX" target="_blank" rel="noopener">Get on GitHub →</a>
        <a className="btn btn-secondary" href="#phases">View Curriculum</a>
      </div>
      <div className="hero-banner">
        <video src="assets/spinning-brain.mp4" autoPlay muted loop playsInline preload="auto" aria-label="AI-Trainer-MAX hero banner" />
      </div>
      <div className="hero-meta">
        <span>36 modules · 5 phases · $0 · runs local</span>
        <span>Built in Alabama · built for everyone</span>
      </div>
    </div>
  </section>
);
window.Hero = Hero;

const Footer = () => (
  <footer className="footer">
    <div className="container footer-grid">
      <div>
        <div className="footer-logo"><span className="tri">▲</span> AI-Trainer-MAX</div>
        <p className="footer-blurb">We believe AI literacy is a right, not a subscription. Built in Alabama. Built for everyone.</p>
      </div>
      <div className="footer-cols">
        <div>
          <div className="footer-h">Curriculum</div>
          <a>Phase 1 · Builders</a>
          <a>Phase 2 · Operators</a>
          <a>Phase 3 · Everyday</a>
          <a>Phase 4 · Legacy</a>
          <a>Phase 5 · Multipliers</a>
        </div>
        <div>
          <div className="footer-h">Ecosystem</div>
          <a>ShaneBrain</a>
          <a>Angel Cloud</a>
          <a>Pulsar AI</a>
          <a>OBLIVION</a>
        </div>
        <div>
          <div className="footer-h">Resources</div>
          <a>GitHub ↗</a>
          <a>Constitution</a>
          <a>Hardware guide</a>
          <a>Changelog</a>
        </div>
      </div>
    </div>
    <div className="footer-rule"/>
    <div className="container footer-base">
      <span>MIT · © 2025 thebardchat</span>
      <span>Your legacy runs local. ⋆ Built with Ollama · Weaviate · Claude</span>
    </div>
  </footer>
);
window.Footer = Footer;

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
          <a href="#phases">Phase 1 · Builders</a>
          <a href="#phases">Phase 2 · Operators</a>
          <a href="#phases">Phase 3 · Everyday</a>
          <a href="#phases">Phase 4 · Legacy</a>
          <a href="#phases">Phase 5 · Multipliers</a>
        </div>
        <div>
          <div className="footer-h">Ecosystem</div>
          <a href="https://angel-cloud-hub.pages.dev" target="_blank" rel="noopener">Angel Cloud</a>
          <a href="https://halofinance.pages.dev" target="_blank" rel="noopener">HaloFinance</a>
          <a href="https://ai-trainer-oblivion.pages.dev" target="_blank" rel="noopener">OBLIVION</a>
          <a href="https://github.com/thebardchat" target="_blank" rel="noopener">thebardchat ↗</a>
        </div>
        <div>
          <div className="footer-h">Follow</div>
          <a href="https://www.youtube.com/channel/UCFrv2F3Kird13yfBVIflTVA" target="_blank" rel="noopener">YouTube ↗</a>
          <a href="https://github.com/thebardchat/AI-Trainer-MAX" target="_blank" rel="noopener">GitHub ↗</a>
          <a href="https://www.buymeacoffee.com/thebardchat" target="_blank" rel="noopener">Buy Me a Coffee ↗</a>
          <a href="https://github.com/thebardchat/AI-Trainer-MAX/commits/main" target="_blank" rel="noopener">Changelog ↗</a>
        </div>
      </div>
    </div>
    <div className="footer-rule"/>
    <div className="container footer-base">
      <span>MIT · © 2026 thebardchat</span>
      <span>Your legacy runs local. ⋆ Built with Ollama · Weaviate · Claude</span>
    </div>
  </footer>
);
window.Footer = Footer;

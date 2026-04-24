const NODES = [
  { nm:"ShaneBrain",      r:"Local · Private",    active:false, href:"https://github.com/thebardchat/shanebrain-core" },
  { nm:"AI-Trainer-MAX",  r:"Training layer",     active:true,  href:"https://github.com/thebardchat/AI-Trainer-MAX" },
  { nm:"Angel Cloud",     r:"Public · Families",  active:false, href:"https://angel-cloud-hub.pages.dev" },
  { nm:"Pulsar AI",       r:"Enterprise",         active:false, href:"https://github.com/thebardchat" },
  { nm:"TheirNameBrain",  r:"Legacy · Coming",    active:false, href:null },
];

const EcosystemChain = () => (
  <section className="section">
    <div className="container">
      <div className="section-head">
        <span className="section-marker">The Ecosystem</span>
        <h2>MAX is one link in the chain.</h2>
        <p className="lead">The training layer. Graduate out of MAX into the surface that fits your life — a private family brain, a business AI, or an enterprise deployment. All built on the same foundation.</p>
      </div>
      <div className="chain">
        {NODES.map(n => {
          const inner = (
            <>
              <div className="chain-name">{n.nm}</div>
              <div className="chain-role">{n.r}</div>
            </>
          );
          return n.href
            ? <a key={n.nm} href={n.href} target="_blank" rel="noopener" className={`chain-node ${n.active ? "active" : ""}`}>{inner}</a>
            : <div key={n.nm} className={`chain-node ${n.active ? "active" : ""}`}>{inner}</div>;
        })}
      </div>
    </div>
  </section>
);
window.EcosystemChain = EcosystemChain;

const NODES = [
  { nm:"ShaneBrain",      r:"Local · Private",    active:false },
  { nm:"AI-Trainer-MAX",  r:"Training layer",     active:true  },
  { nm:"Angel Cloud",     r:"Public · Families",  active:false },
  { nm:"Pulsar AI",       r:"Enterprise",         active:false },
  { nm:"TheirNameBrain",  r:"Legacy",             active:false },
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
        {NODES.map(n => (
          <div key={n.nm} className={`chain-node ${n.active ? "active" : ""}`}>
            <div className="chain-name">{n.nm}</div>
            <div className="chain-role">{n.r}</div>
          </div>
        ))}
      </div>
    </div>
  </section>
);
window.EcosystemChain = EcosystemChain;

const PHASES = [
  { n:"01", mods:5,  name:"Builders",    img:"assets/phase1-builders.png",    cls:"p1",
    aud:"Developers · self-learners",
    blurb:"Install Ollama. Wire up Weaviate. Build your first RAG app on your laptop. No cloud. No API keys.",
    proves:["Local model running","RAG pipeline","Basic MCP server"] },
  { n:"02", mods:7,  name:"Operators",   img:"assets/phase2-operators.png",   cls:"p2",
    aud:"Business owners · dispatchers",
    blurb:"Turn your company's knowledge — SOPs, playbooks, tribal knowledge — into a private AI your team actually trusts.",
    proves:["Branded AI","Workflow automation","Team-wide deployment"] },
  { n:"03", mods:7,  name:"Everyday",    img:"assets/phase3-everyday.png",    cls:"p3",
    aud:"Non-technical Windows users",
    blurb:"Your private vault. Morning briefing. Email drafts. A research assistant that never sends your data anywhere.",
    proves:["Personal vault","Daily briefing","Private research"] },
  { n:"04", mods:7,  name:"Legacy",      img:"assets/phase4-legacy.png",      cls:"p4",
    aud:"Families · next generation",
    blurb:"A personal AI trained on your stories, values, and voice — still runnable by your grandchildren, long after you're gone.",
    proves:["Family-runnable AI","Values + voice capture","Inheritance protocol"] },
  { n:"05", mods:10, name:"Multipliers", img:"assets/phase5-multipliers.png", cls:"p5",
    aud:"Phase 1-4 graduates",
    blurb:"Teach. Mentor. Ship. Build businesses that run on the foundation you just poured. You become the community's hammer.",
    proves:["Teaching protocol","Business playbook","Graduate credential"] },
];

const PhaseCards = () => (
  <section id="phases" className="section">
    <div className="container">
      <div className="section-head">
        <span className="section-marker">The Curriculum</span>
        <h2>Five phases. Zero to AI sovereignty.</h2>
        <p className="lead">Each phase is a self-contained ladder. Start wherever you fit — builders go first, everyday users can skip to Phase 3. Every module ends with a verified build you can show someone.</p>
      </div>
      <div className="phase-grid">
        {PHASES.map(p => (
          <article key={p.n} className={`phase-card ${p.cls}`}>
            <div className="phase-img" style={{backgroundImage:`url(${p.img})`}} />
            <div className="phase-body">
              <div className="phase-num">Phase {p.n} · {p.mods} modules</div>
              <h3>{p.name}</h3>
              <div className="phase-aud">{p.aud}</div>
              <p>{p.blurb}</p>
              <ul className="phase-proves">
                {p.proves.map(x => <li key={x}>{x}</li>)}
              </ul>
            </div>
          </article>
        ))}
      </div>
    </div>
  </section>
);
window.PhaseCards = PhaseCards;

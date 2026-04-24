const TIERS = [
  { tag:"Minimum",  cls:"p3", ram:"8GB RAM", cpu:"Any 64-bit CPU",       gpu:"None required",
    note:"Phase 1-3 run comfortably. Models cap at ~3B params.",
    models:["llama3.2:1b","gemma2:2b","qwen2.5:3b"] },
  { tag:"Recommended", cls:"p1", ram:"16GB RAM", cpu:"i5 / Ryzen 5 or newer", gpu:"Integrated OK",
    note:"Full curriculum at comfortable speed. 7B models run.",
    models:["llama3.1:8b","mistral:7b","phi3:mini"] },
  { tag:"Power", cls:"p5", ram:"32GB+ RAM", cpu:"i7 / Ryzen 7",            gpu:"8GB+ VRAM (RTX 3060+)",
    note:"Ceiling for MAX. Required entry for OBLIVION.",
    models:["llama3.1:70b","mixtral:8x7b","deepseek-r1:32b"] },
];

const HardwareTiers = () => (
  <section className="section section-alt">
    <div className="container">
      <div className="section-head">
        <span className="section-marker">Hardware</span>
        <h2>Runs on what you already own.</h2>
        <p className="lead">If it boots Windows 10/11, you can start. Laptop from 2019? Fine. Beige desktop your dad left you? Fine. No new machine required.</p>
      </div>
      <div className="hw-grid">
        {TIERS.map(t => (
          <article key={t.tag} className={`hw-card ${t.cls}`}>
            <div className="hw-tag">{t.tag}</div>
            <dl className="hw-specs">
              <div><dt>RAM</dt><dd>{t.ram}</dd></div>
              <div><dt>CPU</dt><dd>{t.cpu}</dd></div>
              <div><dt>GPU</dt><dd>{t.gpu}</dd></div>
            </dl>
            <p className="hw-note">{t.note}</p>
            <ul className="hw-models">
              {t.models.map(m => <li key={m}><code>{m}</code></li>)}
            </ul>
          </article>
        ))}
      </div>
    </div>
  </section>
);
window.HardwareTiers = HardwareTiers;

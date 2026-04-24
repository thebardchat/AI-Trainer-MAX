const Terminal = () => (
  <section id="how" className="section section-alt">
    <div className="container two-col">
      <div>
        <span className="section-marker">How it works</span>
        <h2>One launcher. Everything else is modules.</h2>
        <p className="lead">Boring tools. On purpose. The whole training system is Windows <code>.bat</code> scripts, markdown lessons, and pass/fail checks. No Electron, no web app, no subscription. Double-click <code>launch-training.bat</code> and you're in.</p>
        <ul className="bullets">
          <li>Every lesson opens with <strong>What You'll Build</strong>.</li>
          <li>Every exercise closes with <strong>What You Proved</strong>.</li>
          <li>Three escalating levels of hints before the solution.</li>
          <li>Runs offline after initial model pull.</li>
        </ul>
      </div>
      <div className="terminal">
        <div className="terminal-bar">
          <span className="tl-dot r"/><span className="tl-dot y"/><span className="tl-dot g"/>
          <span className="terminal-path">C:\AI-Trainer-MAX&gt; launch-training.bat</span>
        </div>
        <pre className="terminal-body">
{`╭────────────────────────────────────────╮
│   AI-Trainer-MAX  ·  Phase 1 · M 1.1   │
╰────────────────────────────────────────╯

[92m✓[0m Ollama detected    localhost:11434
[92m✓[0m Weaviate ready     localhost:8080
[92m✓[0m Model: llama3.2:1b  1.3GB

[93mWHAT YOU'LL BUILD[0m
  A local chat that stays on your machine.

[93m> press ENTER to begin[0m
`}
        </pre>
      </div>
    </div>
  </section>
);
window.Terminal = Terminal;

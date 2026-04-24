const STACK = [
  { lbl:"LLM Runtime",  val:"Ollama",     det:"localhost:11434" },
  { lbl:"Vector DB",    val:"Weaviate",   det:"localhost:8080"  },
  { lbl:"MCP Server",   val:"ShaneBrain", det:"29 tools · :8100" },
  { lbl:"Scripting",    val:"Windows .bat", det:"CMD compatible" },
  { lbl:"Reasoning",    val:"Claude",     det:"Anthropic"  },
  { lbl:"Edge device",  val:"Raspberry Pi", det:"Optional · home server" },
  { lbl:"Docs format",  val:"Markdown",   det:"Readable in any editor" },
  { lbl:"License",      val:"MIT",        det:"Fork, remix, ship" },
];

const StackGrid = () => (
  <section id="stack" className="section">
    <div className="container">
      <div className="section-head">
        <span className="section-marker">The Stack</span>
        <h2>Credit-covenant partners.</h2>
        <p className="lead">Every tool that makes this possible, named. Every time.</p>
      </div>
      <div className="stack-grid">
        {STACK.map(s => (
          <div key={s.lbl} className="stack-cell">
            <div className="stack-lbl">{s.lbl}</div>
            <div className="stack-val">{s.val}</div>
            <div className="stack-det">{s.det}</div>
          </div>
        ))}
      </div>
    </div>
  </section>
);
window.StackGrid = StackGrid;

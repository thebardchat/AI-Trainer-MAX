const FeedPanel = ({ feed }) => (
  <div className={`feed-panel ${feed.cls}${feed.featured ? ' feed-featured-panel' : ''}`}>
    <div className="feed-header">
      <span className="feed-badge">{`FEED ${feed.num}`}</span>
      <span className="feed-sep">·</span>
      <span className="feed-title-label">{feed.title}</span>
      <span className="feed-dot" aria-hidden="true"></span>
      {feed.featured && <span className="feed-live">LIVE</span>}
    </div>
    <div className="feed-embed">
      <iframe
        src={`https://www.youtube-nocookie.com/embed/${feed.yt}?modestbranding=1&rel=0&color=white`}
        title={feed.title}
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowFullScreen
      />
      <div className="feed-scanlines" aria-hidden="true"></div>
      <div className="feed-corner feed-corner-tl" aria-hidden="true"></div>
      <div className="feed-corner feed-corner-tr" aria-hidden="true"></div>
      <div className="feed-corner feed-corner-bl" aria-hidden="true"></div>
      <div className="feed-corner feed-corner-br" aria-hidden="true"></div>
    </div>
  </div>
);

const VideoReel = () => {
  const featured = {
    id: 'feat',
    yt: 'xViPj6KZ2p4',
    num: '01',
    title: 'AI-TRAINER-MAX · HOLOGRAM',
    cls: 'feed-p1',
    featured: true,
  };

  const secondary = [
    {
      id: 'sec1',
      yt: 'zeZsFHQ_P4Q',
      num: '02',
      title: 'RASPBERRY PI 5 · MACRO',
      cls: 'feed-p2',
    },
    {
      id: 'sec3',
      yt: 'Cyjyj2DmE_M',
      num: '03',
      title: 'GOLDEN HOUR · THE LAB',
      cls: 'feed-p5',
    },
  ];

  return (
    <section className="video-reel section-alt">
      <div className="container">
        <div className="section-head">
          <span className="section-marker vr-marker">Signal Feed</span>
          <h2>From The Machine</h2>
          <p className="section-lead">
            Shot live on a Raspberry Pi 5 in Alabama. No renders, no actors.
            Just steel, light, and local AI doing its thing.
          </p>
        </div>
        <div className="vr-main">
          <FeedPanel feed={featured} />
        </div>
        <div className="vr-secondary">
          {secondary.map(f => <FeedPanel key={f.id} feed={f} />)}
        </div>
      </div>
    </section>
  );
};
window.VideoReel = VideoReel;

// ~/.finicky.js

module.exports = {
  defaultBrowser: 'Firefox',
  handlers: [
    {
      match: finicky.matchHostnames(['music.apple.com', 'geo.music.apple.com']),
      browser: 'Music',
      url: ({ url }) => ({...url, protocol: 'itmss'}),
    },
    {
      // Open apple.com urls in Safari
      match: finicky.matchHostnames(['apple.com', 'www.apple.com', 'icloud.com', 'www.icloud.com']),
      browser: 'Safari',
    },
    {
      match: finicky.matchHostnames('meet.google.com'),
      browser: 'Google Chrome',
    },
    {
      match: finicky.matchHostnames('teams.microsoft.com'),
      browser: '/Applications/Microsoft Teams.app',
      url: ({url}) => ({...url, protocol: 'msteams'})
    },
    {
      match: finicky.matchHostnames('*.slack.com'),
      browser: '/Applications/Slack.app'
    },
    {
      match: ['*.zoom.us/j/*'],
      browser: '/Applications/zoom.us.app',
    },
    {
      match: finicky.matchHostnames('open.spotify.com'),
      browser: 'Spotify',
    },
  ],
};

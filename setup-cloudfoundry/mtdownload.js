var options = {
  count: 64,
  method: 'GET',
  port: 80,
  range: '0-100',
  onStart: function (meta) {
    headers: {
        cookie: 'aa=bb'
    };
    console.log('Download Started', meta);
  },
  onEnd: function (err, result) {
    if (err) console.error(err);
    console.log('Download Complete');
  }
};

var mtd = require('mt-downloader');

var url = process.argv.slice(2)[0];
var file = process.argv.slice(2)[1];

var downloader = new mtd(file, url, options);

downloader.start();

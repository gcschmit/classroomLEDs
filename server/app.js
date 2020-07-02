const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');
const app = express();
const port = 3000;

var color = '#FF0000';

app.use(bodyParser.json());


app.use('/', require(path.join(__dirname, 'routes')));

app.use((req, res, next) => {
  const err = new Error(`${req.method} ${req.url} Not Found`);
  err.status = 404;
  next(err);
});

app.use((err, req, res, next) => {
  console.error(err);
  res.status(err.status || 500);
  res.json({
    error: {
      message: err.message,
    },
  });
});

console.log(JSON.stringify({'now': new Date()}))


//app.get('/', (req, res) => res.send('Hello World!'))

//app.get('/leds', (req, res) => res.json({color: color}))
//app.get('/leds/:ledID', (req, res) => res.json({color: color}))
//app.put('/leds', (req, res) => res.send('color: ' + color))

app.listen(port, () => console.log(`Example app listening at http://localhost:${port}`))
